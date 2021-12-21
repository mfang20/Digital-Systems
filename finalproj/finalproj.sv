//-------------------------------------------------------------------------
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab 62                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module finalproj (

      ///////// Clocks /////////
      input     MAX10_CLK1_50, 

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);




logic Reset_h, vssig, blank, sync, VGA_Clk;


//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [9:0] drawxsig, drawysig, shipxsig, shipysig, laserxsig, laser, shipsizesig;
	logic [3:0] Red, Blue, Green;
	logic [7:0] keycode, keycode2, keycode3;
	logic shootsig;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);

	//Our A/D converter is only 12 bit
	assign VGA_R = Red;
	assign VGA_B = Blue;
	assign VGA_G = Green;
	
	logic [3:0] VGA_R_int, VGA_G_int, VGA_B_int;
	
	labfinal_soc u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX and PIOS
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, LEDR}),
		.keycode_export(keycode),
		.keycode2_export(keycode2),
		.keycode3_export(keycode3),
		.score_val_export(score_val),
		.lose_game_export(lose_game),
		.win_game_export(beat_Boss),
		.difficulty_export(start_game),
		.reset_button_export(Reset_h),
		.rand_side_export(rand_side),
		
		//VGA signals
		.vga_port_red (VGA_R_int),
		.vga_port_green (VGA_G_int),
		.vga_port_blue (VGA_B_int),
		.vga_port_hs (VGA_HS),
		.vga_port_vs (VGA_VS),
		.vga_port_drawx (drawxsig),
		.vga_port_drawy (drawysig),
		.vga_port_lose_life (),
		.vga_port_pass_up1 (),
		.vga_port_pass_up2 (),
		.vga_port_pass_up3 ()
	 );


///////////////////////////////////////instantiate a vga_controller, ball, and color_mapper here with the ports.
//get logic wires
logic hs, h1, h2, h3, h4, lose_life, pl1, pl2, pl3, pl4;
logic ship1_hit;
logic [9:0] PX1, PX2, PX3, PX4;
logic [9:0] PY1, PY2, PY3, PY4;
logic [9:0] e1x, e1y;
logic lose_game, win_game;
logic [1:0] num_lives;
logic [9:0] lives_x, lives_y, score_x, score_y;
logic [9:0] score_val;


logic side1, side;
assign side1 = rand_side;
assign side2 = !rand_side;
	
	logic [7:0] spaceship_red, spaceship_green, spaceship_blue;
	spaceship  s0(	 .Reset(Reset_h),
					 .frame_clk(VGA_VS),
					 .keycode(keycode),
					 .keycode2(keycode2),
					 .keycode3(keycode3),
					 .SpaceshipX(shipxsig),
					 .hit(hs),
					 .SpaceshipY(shipysig),
					 .SpaceshipS(shipsizesig),
					 .shoot(shootsig),
					 .lose_life(lose_life),
					 .speedup(speedup),
					 .invincible(shootfaster),
					 .doublescore(doublescore),
					 .powerup(powerup),
					 .spaceship_red(spaceship_red), .spaceship_green(spaceship_green), .spaceship_blue(spaceship_blue)
					 );
					 
logic [9:0] powerupxsig, powerupysig, powerupwidthsig, powerupheightsig;
logic generate_powerup, powerup, draw_powerup;
logic speedup, extralife, shootfaster, doublescore;
logic [3:0] powerup_red, powerup_green, powerup_blue;
logic [8:0] shoot_fast_timer1, shoot_fast_timer2, shoot_fast_timer3, shoot_fast_timer4;
logic [8:0] shoot_fast_timer;



assign shoot_fast_timer = shoot_fast_timer1 & shoot_fast_timer2 & shoot_fast_timer3 & shoot_fast_timer4;
/////try to draw power ups
power_up  power_up(.Reset(Reset_h), .frame_clk(VGA_VS), .generate_powerup(generate_powerup),
					.ShipX(shipxsig), .ShipY(shipysig), .ShipS(shipsizesig),
					.got_powerup(powerup), .powerup_exists(draw_powerup), .powerup_startpos(powerup_startpos),
					.PowerupX(powerupxsig), .PowerupY(powerupysig), .Powerupwidth(powerupwidthsig), .Powerupheight(powerupheightsig)
					);
					
power_up_select ps(.Reset(Reset_h), .frame_clk(VGA_VS), .generate_powerup(generate_powerup),
						.speedup(speedup), .extralife(extralife), .shootfaster(shootfaster), .doublescore(doublescore),
						.powerup_red(powerup_red), .powerup_green(powerup_green), .powerup_blue(powerup_blue), .LFSR_powerup_type(LFSR_powerup_type)
						);
	
	color_mapper cm(.SpaceshipX(shipxsig), 
					 .SpaceshipY(shipysig), 
					 .Laser1X(PX1), .Laser2X(PX2), .Laser3X(PX3), .Laser4X(PX4),
					 .Laser1Y(PY1), .Laser2Y(PY2), .Laser3Y(PY3), .Laser4Y(PY4),
					 .laser_width(laser_width), .laser_height(laser_height),
					 .draw_powerup(draw_powerup), .PowerupX(powerupxsig), .PowerupY(powerupysig), 
					 .Powerupwidth(powerupwidthsig), .Powerupheight(powerupheightsig),
					 .powerup_red(powerup_red), .powerup_green(powerup_green), .powerup_blue(powerup_blue),
					 .DrawX(drawxsig), 
					 .DrawY(drawysig), 
					 .vram_r(VGA_R_int), .vram_g(VGA_G_int), .vram_b(VGA_B_int),
					 .Spaceship_size(shipsizesig),
					 .le1(pl1), .le2(pl2), .le3(pl3), .le4(pl4),
                .Red(Red), 
					 .Green(Green), 
					 .Blue(Blue),
					 .LivesX(lives_x),
					 .LivesY(lives_y),
					 .e1X(e1X), .e2X(e2X), .e3X(e3X), .e4X(e4X), .e5X(e5X), .e6X(e6X), .e7X(e7X), .e8X(e8X), .e9X(e9X), .e10X(e10X), .e11X(e11X), .e12X(e12X),
                .e1Y(e1Y), .e2Y(e2Y), .e3Y(e3Y), .e4Y(e4Y), .e5Y(e5Y), .e6Y(e6Y), .e7Y(e7Y), .e8Y(e8Y), .e9Y(e9Y), .e10Y(e10Y), .e11Y(e11Y), .e12Y(e12Y),
                .e1(e1E), .e2(e2E), .e3(e3E), .e4(e4E), .e5(e5E), .e6(e6E), .e7(e7E), .e8(e8E), .e9(e9E), .e10(e10E), .e11(e11E), .e12(e12E),
					 .num_lives(num_lives),
					 .lose_game(lose_game),
					 .score_x(score_x),
					 .score_y(score_y),
					 .score_val(score_val),
					 .win_game(win_game),
					 .es1X(es1X), .es2X(es2X), .es3X(es3X), .es4X(es4X),
					 .es1Y(es1Y), .es2Y(es2Y), .es3Y(es3Y), .es4Y(es4Y),
					 .es1(es1E), .es2(es2E), .es3(es3E), .es4(es4E),
					 //enemy laser
					 .EL1X(EL1X), .EL2X(EL2X), .EL3X(EL3X), .EL4X(EL4X),
					 .EL1Y(EL1Y), .EL2Y(EL2Y), .EL3Y(EL3Y), .EL4Y(EL4Y),
					 .EL1(EL1), .EL2(EL2), .EL3(EL3), .EL4(EL4),
					 //enemy flyers
					 /*.ef1X(ef1X), 
					 .ef1Y(ef1Y),
					 .ef1(ef1E),*/
					 //difficulty blocks
					 .E_blockX(E_blockX), .N_blockX(N_blockX), .H_blockX(H_blockX),
					 .E_blockY(E_blockY), .N_blockY(N_blockY), .H_blockY(H_blockY),
					 .block_width(block_width), .block_height(block_height),
					 .difficulty_selected(start_game),
					 ////boss stuff
					 .BossX(bossxsig), .BossY(bossysig), .Boss_width(bosswidthsig), .Boss_height(bossheightsig),
					 .Boss_exists(Boss_exists),
					 .beat_Boss(beat_Boss),
					 .beamX(beamX), .beamY(beamY),
                .beam_size(beam_size),
                .beam_exists(beam_exists),
						//enemy flyers
                .ef1X(ef1X), .ef2X(ef2X), .ef3X(ef3X),
                .ef1Y(ef1Y), .ef2Y(ef2Y), .ef3Y(ef3Y),
                .ef1(ef1E), .ef2(ef2E), .ef3(ef3E),
					 .ship_ram_red(shipredsig), .ship_ram_green(shipgreensig), .ship_ram_blue(shipbluesig),
					 .boss_ram_red(bossredsig), .boss_ram_green(bossgreensig), .boss_ram_blue(bossbluesig),
					 .enemy_ram_red(enemyredsig), .enemy_ram_green(enemygreensig), .enemy_ram_blue(enemybluesig),
					 .enemy_shooter_ram_red(enemyshooterredsig), .enemy_shooter_ram_green(enemyshootergreensig), .enemy_shooter_ram_blue(enemyshooterbluesig),
					 .enemy_flyer_ram_red(enemyflyerredsig), .enemy_flyer_ram_green(enemyflyergreensig), .enemy_flyer_ram_blue(enemyflyerbluesig),
					 .explosion_ram_red(explosionredsig), .explosion_ram_blue(explosionbluesig), .explosion_ram_green(explosiongreensig),
					 .*
					 );

///////////////sprite stuff
logic [18:0] write_address;
logic we;
logic [3:0] data_In, ship_ioout, enemy_ioout, enemy_ioouts, enemy_iooutf, enemy_iooute, boss_ioout;
logic [3:0] enemy_ioout1,enemy_ioout2,enemy_ioout3,enemy_ioout4,enemy_ioout5,enemy_ioout6,enemy_ioout7,enemy_ioout8,enemy_ioout9,enemy_ioout10,enemy_ioout11,enemy_ioout12;
logic [3:0] enemy_ioout1s, enemy_ioout2s, enemy_ioout3s, enemy_ioout4s;
logic [3:0] enemy_ioout1f, enemy_ioout2f, enemy_ioout3f;
logic [3:0] enemy_ioout1e,enemy_ioout2e,enemy_ioout3e,enemy_ioout4e,enemy_ioout5e,enemy_ioout6e,enemy_ioout7e,enemy_ioout8e,enemy_ioout9e,enemy_ioout10e,enemy_ioout11e,enemy_ioout12e;
logic [3:0] enemy_ioout1se, enemy_ioout2se, enemy_ioout3se, enemy_ioout4se;
logic [3:0] enemy_ioout1fe, enemy_ioout2fe, enemy_ioout3fe;
logic [7:0] shipredsig, shipgreensig, shipbluesig;
logic [7:0] bossredsig, bossgreensig, bossbluesig;
logic [7:0] enemyredsig, enemygreensig, enemybluesig;
logic [7:0] explosionredsig, explosiongreensig, explosionbluesig;
logic [7:0] enemyshooterredsig, enemyshootergreensig, enemyshooterbluesig;
logic [7:0] enemyflyerredsig, enemyflyergreensig, enemyflyerbluesig;
////////////////ship sprite	
color_pallete cp_ship(.data_in(ship_ioout), .spaceship_red(spaceship_red), .spaceship_blue(spaceship_blue), .spaceship_green(spaceship_green),
		.red(shipredsig), .green(shipgreensig), .blue(shipbluesig));

spaceship_drawRAM spRAM(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-shipysig)*30)+(drawxsig-shipxsig)), .data_Out(ship_ioout));


////boss sprite
boss_color_pallete bosscp(.data_in(boss_ioout), .red(bossredsig), .green(bossgreensig), .blue(bossbluesig));

boss_drawRAM bRAM(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-bossysig)*250)+(drawxsig-bossxsig)), .data_Out(boss_ioout));


///choose which enemy io_out to choose
always_comb
begin
if ((drawxsig >= e1X) && (drawxsig - e1X <= 30) && (drawysig >= e1Y) && (drawysig - e1Y <= 30))
	enemy_ioout = enemy_ioout1;
else if ((drawxsig >= e2X) && (drawxsig - e2X <= 30) && (drawysig >= e2Y) && (drawysig - e2Y <= 30))
	enemy_ioout = enemy_ioout2;
else if ((drawxsig >= e3X) && (drawxsig - e3X <= 30) && (drawysig >= e3Y) && (drawysig - e3Y <= 30))
	enemy_ioout = enemy_ioout3;
else if ((drawxsig >= e4X) && (drawxsig - e4X <= 30) && (drawysig >= e4Y) && (drawysig - e4Y <= 30))
	enemy_ioout = enemy_ioout4;
else if ((drawxsig >= e5X) && (drawxsig - e5X <= 30) && (drawysig >= e5Y) && (drawysig - e5Y <= 30))
	enemy_ioout = enemy_ioout5;
else if ((drawxsig >= e6X) && (drawxsig - e6X <= 30) && (drawysig >= e6Y) && (drawysig - e6Y <= 30))
	enemy_ioout = enemy_ioout6;
else if ((drawxsig >= e7X) && (drawxsig - e7X <= 30) && (drawysig >= e7Y) && (drawysig - e7Y <= 30))
	enemy_ioout = enemy_ioout7;
else if ((drawxsig >= e8X) && (drawxsig - e8X <= 30) && (drawysig >= e8Y) && (drawysig - e8Y <= 30))
	enemy_ioout = enemy_ioout8;
else if ((drawxsig >= e9X) && (drawxsig - e9X <= 30) && (drawysig >= e9Y) && (drawysig - e9Y <= 30))
	enemy_ioout = enemy_ioout9;
else if ((drawxsig >= e10X) && (drawxsig - e10X <= 30) && (drawysig >= e10Y) && (drawysig - e10Y <= 30))
	enemy_ioout = enemy_ioout10;
else if ((drawxsig >= e11X) && (drawxsig - e11X <= 30) && (drawysig >= e11Y) && (drawysig - e11Y <= 30))
	enemy_ioout = enemy_ioout11;
else if ((drawxsig >= e12X) && (drawxsig - e12X <= 30) && (drawysig >= e12Y) && (drawysig - e12Y <= 30))
	enemy_ioout = enemy_ioout12;
else
	enemy_ioout = 4'b0;

end

/// choose which enemy_shooter ioout
always_comb
begin
if ((drawxsig >= es1X) && (drawxsig - es1X <= 30) && (drawysig >= es1Y) && (drawysig - es1Y <= 30))
	enemy_ioouts = enemy_ioout1s;
else if ((drawxsig >= es2X) && (drawxsig - es2X <= 30) && (drawysig >= es2Y) && (drawysig - es2Y <= 30))
	enemy_ioouts = enemy_ioout2s;
else if ((drawxsig >= es3X) && (drawxsig - es3X <= 30) && (drawysig >= es3Y) && (drawysig - es3Y <= 30))
	enemy_ioouts = enemy_ioout3s;
else if ((drawxsig >= es4X) && (drawxsig - es4X <= 30) && (drawysig >= es4Y) && (drawysig - es4Y <= 30))
	enemy_ioouts = enemy_ioout4s;
else
	enemy_ioouts = 4'b0;

end


//choose which enemy_flyer ioout
always_comb
begin
if ((drawxsig >= ef1X) && (drawxsig - ef1X <= 30) && (drawysig >= ef1Y) && (drawysig - ef1Y <= 30))
	enemy_iooutf = enemy_ioout1f;
else if ((drawxsig >= ef2X) && (drawxsig - ef2X <= 30) && (drawysig >= ef2Y) && (drawysig - ef2Y <= 30))
	enemy_iooutf = enemy_ioout2f;
else if ((drawxsig >= ef3X) && (drawxsig - ef3X <= 30) && (drawysig >= ef3Y) && (drawysig - ef3Y <= 30))
	enemy_iooutf = enemy_ioout3f;
else
	enemy_iooutf = 4'b0;

end
/////enemy ship sprite

enemy_color_pallete cp_enemy(.data_in(enemy_ioout), .red(enemyredsig), .green(enemygreensig), .blue(enemybluesig));
enemy_shooter_color_pallete cp_enemy_shooter(.data_in(enemy_ioouts), .red(enemyshooterredsig), .green(enemyshootergreensig), .blue(enemyshooterbluesig));
enemy_flyer_color_pallete cp_enemy_flyer(.data_in(enemy_iooutf), .red(enemyflyerredsig), .green(enemyflyergreensig), .blue(enemyflyerbluesig));

//instantiate 12 eRAMs for normal enemies
enemyship_drawRAM eRAM1(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e1Y)*30)+(drawxsig-e1X)), .data_Out(enemy_ioout1));
enemyship_drawRAM eRAM2(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e2Y)*30)+(drawxsig-e2X)), .data_Out(enemy_ioout2));
enemyship_drawRAM eRAM3(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e3Y)*30)+(drawxsig-e3X)), .data_Out(enemy_ioout3));
enemyship_drawRAM eRAM4(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e4Y)*30)+(drawxsig-e4X)), .data_Out(enemy_ioout4));			
enemyship_drawRAM eRAM5(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e5Y)*30)+(drawxsig-e5X)), .data_Out(enemy_ioout5));	
enemyship_drawRAM eRAM6(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e6Y)*30)+(drawxsig-e6X)), .data_Out(enemy_ioout6));
enemyship_drawRAM eRAM7(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e7Y)*30)+(drawxsig-e7X)), .data_Out(enemy_ioout7));	
enemyship_drawRAM eRAM8(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e8Y)*30)+(drawxsig-e8X)), .data_Out(enemy_ioout8));
enemyship_drawRAM eRAM9(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e9Y)*30)+(drawxsig-e9X)), .data_Out(enemy_ioout9));
enemyship_drawRAM eRAM10(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e10Y)*30)+(drawxsig-e10X)), .data_Out(enemy_ioout10));
enemyship_drawRAM eRAM11(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e11Y)*30)+(drawxsig-e11X)), .data_Out(enemy_ioout11));	
enemyship_drawRAM eRAM12(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e12Y)*30)+(drawxsig-e12X)), .data_Out(enemy_ioout12));

//instantiate 4  eRAMS for 4 shooter enemies
enemyship_drawRAM eRAM1S(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-es1Y)*30)+(drawxsig-es1X)), .data_Out(enemy_ioout1s));
enemyship_drawRAM eRAM2S(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-es2Y)*30)+(drawxsig-es2X)), .data_Out(enemy_ioout2s));
enemyship_drawRAM eRAM3S(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-es3Y)*30)+(drawxsig-es3X)), .data_Out(enemy_ioout3s));
enemyship_drawRAM eRAM4S(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-es4Y)*30)+(drawxsig-es4X)), .data_Out(enemy_ioout4s));	

//instantiate 3  eRAMS for 3 flyer enemies
enemyship_drawRAM eRAM1F(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-ef1Y)*30)+(drawxsig-ef1X)), .data_Out(enemy_ioout1f));
enemyship_drawRAM eRAM2F(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-ef2Y)*30)+(drawxsig-ef2X)), .data_Out(enemy_ioout2f));
enemyship_drawRAM eRAM3F(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-ef3Y)*30)+(drawxsig-ef3X)), .data_Out(enemy_ioout3f));
//////////////////

/////explosion sprite
//////choose ioout for explosion
///choose which enemy io_out to choose


always_comb
begin
if ((drawxsig >= e1X) && (drawxsig - e1X <= 30) && (drawysig >= e1Y) && (drawysig - e1Y <= 30))
	enemy_iooute = enemy_ioout1e;
else if ((drawxsig >= e2X) && (drawxsig - e2X <= 30) && (drawysig >= e2Y) && (drawysig - e2Y <= 30))
	enemy_iooute = enemy_ioout2e;
else if ((drawxsig >= e3X) && (drawxsig - e3X <= 30) && (drawysig >= e3Y) && (drawysig - e3Y <= 30))
	enemy_iooute = enemy_ioout3e;
else if ((drawxsig >= e4X) && (drawxsig - e4X <= 30) && (drawysig >= e4Y) && (drawysig - e4Y <= 30))
	enemy_iooute = enemy_ioout4e;
else if ((drawxsig >= e5X) && (drawxsig - e5X <= 30) && (drawysig >= e5Y) && (drawysig - e5Y <= 30))
	enemy_iooute = enemy_ioout5e;
else if ((drawxsig >= e6X) && (drawxsig - e6X <= 30) && (drawysig >= e6Y) && (drawysig - e6Y <= 30))
	enemy_iooute = enemy_ioout6e;
else if ((drawxsig >= e7X) && (drawxsig - e7X <= 30) && (drawysig >= e7Y) && (drawysig - e7Y <= 30))
	enemy_iooute = enemy_ioout7e;
else if ((drawxsig >= e8X) && (drawxsig - e8X <= 30) && (drawysig >= e8Y) && (drawysig - e8Y <= 30))
	enemy_iooute = enemy_ioout8e;
else if ((drawxsig >= e9X) && (drawxsig - e9X <= 30) && (drawysig >= e9Y) && (drawysig - e9Y <= 30))
	enemy_iooute = enemy_ioout9e;
else if ((drawxsig >= e10X) && (drawxsig - e10X <= 30) && (drawysig >= e10Y) && (drawysig - e10Y <= 30))
	enemy_iooute = enemy_ioout10e;
else if ((drawxsig >= e11X) && (drawxsig - e11X <= 30) && (drawysig >= e11Y) && (drawysig - e11Y <= 30))
	enemy_iooute = enemy_ioout11e;
else if ((drawxsig >= e12X) && (drawxsig - e12X <= 30) && (drawysig >= e12Y) && (drawysig - e12Y <= 30))
	enemy_iooute = enemy_ioout12e;
else if ((drawxsig >= es1X) && (drawxsig - es1X <= 30) && (drawysig >= es1Y) && (drawysig - es1Y <= 30))
	enemy_iooute = enemy_ioout1se;
else if ((drawxsig >= es2X) && (drawxsig - es2X <= 30) && (drawysig >= es2Y) && (drawysig - es2Y <= 30))
	enemy_iooute = enemy_ioout2se;
else if ((drawxsig >= es3X) && (drawxsig - es3X <= 30) && (drawysig >= es3Y) && (drawysig - es3Y <= 30))
	enemy_iooute = enemy_ioout3se;
else if ((drawxsig >= es4X) && (drawxsig - es4X <= 30) && (drawysig >= es4Y) && (drawysig - es4Y <= 30))
	enemy_iooute = enemy_ioout4se;
else if ((drawxsig >= ef1X) && (drawxsig - ef1X <= 30) && (drawysig >= ef1Y) && (drawysig - ef1Y <= 30))
	enemy_iooute = enemy_ioout1fe;
else if ((drawxsig >= ef2X) && (drawxsig - ef2X <= 30) && (drawysig >= ef2Y) && (drawysig - ef2Y <= 30))
	enemy_iooute = enemy_ioout2fe;
else if ((drawxsig >= ef3X) && (drawxsig - ef3X <= 30) && (drawysig >= ef3Y) && (drawysig - ef3Y <= 30))
	enemy_iooute = enemy_ioout3fe;
else
	enemy_iooute = 4'b0;

end


////explosion_pallete
explosion_color_pallete exp_enemy(.data_in(enemy_iooute), .red(explosionredsig), .green(explosiongreensig), .blue(explosionbluesig));
/////////////explosion instantiations of explosion_ram
//instantiate 12 exRAMs for normal enemies
explosion_drawRAM exRAM1(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e1Y)*30)+(drawxsig-e1X)), .data_Out(enemy_ioout1e));
explosion_drawRAM exRAM2(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e2Y)*30)+(drawxsig-e2X)), .data_Out(enemy_ioout2e));
explosion_drawRAM exRAM3(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e3Y)*30)+(drawxsig-e3X)), .data_Out(enemy_ioout3e));
explosion_drawRAM exRAM4(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e4Y)*30)+(drawxsig-e4X)), .data_Out(enemy_ioout4e));			
explosion_drawRAM exRAM5(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e5Y)*30)+(drawxsig-e5X)), .data_Out(enemy_ioout5e));	
explosion_drawRAM exRAM6(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e6Y)*30)+(drawxsig-e6X)), .data_Out(enemy_ioout6e));
explosion_drawRAM exRAM7(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e7Y)*30)+(drawxsig-e7X)), .data_Out(enemy_ioout7e));	
explosion_drawRAM exRAM8(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e8Y)*30)+(drawxsig-e8X)), .data_Out(enemy_ioout8e));
explosion_drawRAM exRAM9(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e9Y)*30)+(drawxsig-e9X)), .data_Out(enemy_ioout9e));
explosion_drawRAM exRAM10(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e10Y)*30)+(drawxsig-e10X)), .data_Out(enemy_ioout10e));
explosion_drawRAM exRAM11(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e11Y)*30)+(drawxsig-e11X)), .data_Out(enemy_ioout11e));	
explosion_drawRAM exRAM12(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-e12Y)*30)+(drawxsig-e12X)), .data_Out(enemy_ioout12e));

//instantiate 4  exRAMS for 4 shooter enemies
explosion_drawRAM exRAM1S(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-es1Y)*30)+(drawxsig-es1X)), .data_Out(enemy_ioout1se));
explosion_drawRAM exRAM2S(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-es2Y)*30)+(drawxsig-es2X)), .data_Out(enemy_ioout2se));
explosion_drawRAM exRAM3S(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-es3Y)*30)+(drawxsig-es3X)), .data_Out(enemy_ioout3se));
explosion_drawRAM exRAM4S(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-es4Y)*30)+(drawxsig-es4X)), .data_Out(enemy_ioout4se));	

//instantiate 3  exRAMS for 3 flyer enemies
explosion_drawRAM exRAM1F(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-ef1Y)*30)+(drawxsig-ef1X)), .data_Out(enemy_ioout1fe));
explosion_drawRAM exRAM2F(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-ef2Y)*30)+(drawxsig-ef2X)), .data_Out(enemy_ioout2fe));
explosion_drawRAM exRAM3F(.data_In(data_In), .write_address(write_address), .we(we), .Clk(MAX10_CLK1_50), .read_address(((drawysig-ef3Y)*30)+(drawxsig-ef3X)), .data_Out(enemy_ioout3fe));

	
	
	
	///////four cannons, four lasers on screen at once				 
	cannon cannon1(.Reset(Reset_h),
						.frame_clk(VGA_VS),
						.laser(shootsig),
						.laser_hit(h1),
						.ShipX(shipxsig),
						.ShipY(shipysig),
						.ShipS(shipsizesig),
						.laserX(PX1),
						.laserY(PY1),
						.laser_exists(pl1),
						.prevlaser_exists(~(pl2|pl3)|pl4),
						.shootfaster(1'b0),
						.powerup(powerup)
						);
	cannon cannon2(.Reset(Reset_h),
						.frame_clk(VGA_VS),
						.laser(shootsig),
						.laser_hit(h2),
						.ShipX(shipxsig),
						.ShipY(shipysig),
						.ShipS(shipsizesig),
						.laserX(PX2),
						.laserY(PY2),
						.laser_exists(pl2),
						.prevlaser_exists(pl1),
						.shootfaster(1'b0),
						.powerup(powerup)
						);
	cannon cannon3(.Reset(Reset_h),
						.frame_clk(VGA_VS),
						.laser(shootsig),
						.laser_hit(h3),
						.ShipX(shipxsig),
						.ShipY(shipysig),
						.ShipS(shipsizesig),
						.laserX(PX3),
						.laserY(PY3),
						.laser_exists(pl3),
						.prevlaser_exists(pl2),
						.shootfaster(1'b0),
						.powerup(powerup)
						);
	cannon cannon4(.Reset(Reset_h),
						.frame_clk(VGA_VS),
						.laser(shootsig),
						.laser_hit(h4),
						.ShipX(shipxsig),
						.ShipY(shipysig),
						.ShipS(shipsizesig),
						.laserX(PX4),
						.laserY(PY4),
						.laser_exists(pl4),
						.prevlaser_exists(pl3),
						.shootfaster(1'b0),
						.powerup(powerup)
						);
						
/////////try to draw lives

	draw_lives	draw_lives(.Reset(Reset_h), .frame_clk(VGA_VS), .lose_life(lose_life),
						.LivesX(lives_x), .LivesY(lives_y), .powerup(powerup),
						.lives_counter(num_lives), .lose_game(lose_game), .extralife(extralife)
						);
						
///////start game

start_game startgame (.frame_clk(VGA_VS), .Reset(Reset_h),
							.easy_selected(easy_selected), .normal_selected(normal_selected), .hard_selected(hard_selected),
							.powerup_startpos(powerup_startpos), .generate_powerup(generate_powerup), .start_game(start_game),
							.LFSR_powerup_startpos(LFSR_powerup_pos), .LFSR_powerup_drop_timer(LFSR_powerup_timer),
							.powerup_exists(draw_powerup)
							);
						


///////logic to spawn enemies/powerups	
logic start_game;
logic [9:0] powerup_startpos;




parameter [9:0] laser_width = 2;
parameter [9:0] laser_height = 6;
//////////////////////////////////enemy stuff
	logic h1_1, h1_2, h1_3, h1_4, hs1;
	logic h2_1, h2_2, h2_3, h2_4, hs2;
	logic h3_1, h3_2, h3_3, h3_4, hs3;
	logic h4_1, h4_2, h4_3, h4_4, hs4;
	logic h5_1, h5_2, h5_3, h5_4, hs5;
	logic h6_1, h6_2, h6_3, h6_4, hs6;
	logic h7_1, h7_2, h7_3, h7_4, hs7;
	logic h8_1, h8_2, h8_3, h8_4, hs8;
	logic h9_1, h9_2, h9_3, h9_4, hs9;
	logic h10_1, h10_2, h10_3, h10_4, hs10;
	logic h11_1, h11_2, h11_3, h11_4, hs11;
	logic h12_1, h12_2, h12_3, h12_4, hs12;
	
	
	logic [9:0] e1X, e2X, e3X, e4X, e5X, e6X, e7X, e8X, e9X, e10X, e11X, e12X;
	logic [9:0] e1Y, e2Y, e3Y, e4Y, e5Y, e6Y, e7Y, e8Y, e9Y, e10Y, e11Y, e12Y;
	logic [9:0] e1S, e2S, e3S, e4S, e5S, e6S, e7S, e8S, e9S, e10S, e11S, e12S;
	logic e1E, e2E, e3E, e4E, e5E, e6E, e7E, e8E, e9E, e10E, e11E, e12E;

//////////////////////////////

							
	always_comb
	begin
		//ships can't be called the wave right after, need a one wave buffer to account for flydown time
		e1sig = wave1_1sig 					|| wave3_1sig 	|| wave4_1sig;
		e2sig = wave1_2sig 					|| wave3_2sig 	|| wave4_2sig;
		e3sig = wave1_3sig 					|| wave3_3sig 	|| wave4_3sig;
		e4sig = wave1_4sig 					|| wave3_4sig	|| wave4_4sig;
		e5sig = wave1_1sig					|| wave3_1sig;
		e6sig = wave1_2sig					|| wave3_2sig;
		e7sig = wave1_3sig					|| wave3_3sig;
		e8sig = wave1_4sig					|| wave3_4sig;
		e9sig = 										wave3_1sig 	|| wave4_1sig;
		e10sig =										wave3_2sig 	|| wave4_2sig;
		e11sig = 									wave3_3sig 	|| wave4_3sig;
		e12sig = 									wave3_4sig 	|| wave4_4sig;
		
		es1sig = 					wave2_1sig 				  	|| wave4_1sig;
		es2sig = 					wave2_2sig 				  	|| wave4_2sig;
		es3sig = 					wave2_3sig 				  	|| wave4_3sig;
		es4sig =					 	wave2_4sig 				  	|| wave4_4sig;
		ef1sig =						wave2_3sig || wave3_3sig || wave4_3sig;
		ef2sig =						wave2_4sig || wave3_4sig || wave4_4sig;
		ef3sig =						wave2_3sig || wave3_3sig || wave4_3sig;
	end	

logic [3:0] firstrow = 3'b000;
logic [3:0] secondrow = 3'b011;
logic [3:0] thirdrow = 3'b110;

///////////////
//player lasers					 
	
	//enemy lasers
	logic [9:0] EL1X, EL2X, EL3X, EL4X;
	logic [9:0] EL1Y, EL2Y, EL3Y, EL4Y;
	logic EL1, EL2, EL3, EL4;
	
	
	logic hs1_1, hs1_2, hs1_3, hs1_4, hss1;
	logic hs2_1, hs2_2, hs2_3, hs2_4, hss2;
	logic hs3_1, hs3_2, hs3_3, hs3_4, hss3;
	logic hs4_1, hs4_2, hs4_3, hs4_4, hss4;
	logic h1e, h2e, h3e, h4e;
	logic h1n, h2n, h3n, h4n;
	logic h1h, h2h, h3h, h4h;
	logic hf1_1, hf1_2, hf1_3, hf1_4, hsf1;
	logic hf2_1, hf2_2, hf2_3, hf2_4, hsf2;
	logic hf3_1, hf3_2, hf3_3, hf3_4, hsf3;
	logic Phit1, Phit2, Phit3, Phit4, PhitBeam;
	
	//enemy shooter
	logic [9:0] es1X, es2X, es3X, es4X;
	logic [9:0] es1Y, es2Y, es3Y, es4Y;
	logic [9:0] es1S, es2S, es3S, es4S;
	logic es1E, es2E, es3E, es4E;
	
	//difficulty blocks
	logic [9:0] E_blockX, E_blockY, N_blockX, N_blockY, H_blockX, H_blockY;
	logic easy_selected, normal_selected, hard_selected;
	parameter [9:0] block_height = 16;
	parameter [9:0] block_width = 64;

	logic [2:0] difficulty;
	logic [5:0] LFSR1, LFSR2, LFSR3, LFSR4;
	
	always_comb
	begin	
		//laser hits an enemy ship or difficulty block
		h1 = 	(h1_1 || h2_1 || h3_1 || h4_1 || h5_1 || h6_1 || h7_1 || h8_1 || h9_1 || h10_1 || h11_1 || h12_1	//normal enemy hit
				|| hs1_1 || hs2_1 || hs3_1 || hs4_1																						//enemy shooter hit
				|| hf1_1 || hf2_1 || hf3_1
				|| h1e || h1n || h1h || hb1);																										//difficulty block hit
				
		h2 = 	(h1_2 || h2_2 || h3_2 || h4_2 || h5_2 || h6_2 || h7_2 || h8_2 || h9_2 || h10_2 || h11_2 || h12_2
				|| hs1_2	|| hs2_2 || hs3_2 || hs4_2
				|| hf1_2 || hf2_2 || hf3_2
				|| h2e || h2n || h2h || hb2);
				
		h3 = 	(h1_3 || h2_3 || h3_3 || h4_3 || h5_3 || h6_3 || h7_3 || h8_3 || h9_3 || h10_3 || h11_3 || h12_3
				|| hs1_3 || hs2_3 || hs3_3 || hs4_3
				|| hf1_3 || hf2_3 || hf3_3
				|| h3e || h3n || h3h || hb3);
				
		h4 = 	(h1_4 || h2_4 || h3_4 || h4_4 || h5_4 || h6_4 || h7_4 || h8_4 || h9_4 || h10_4 || h11_4 || h12_4
				|| hs1_4 || hs2_4 || hs3_4 || hs4_4
				|| hf1_4 || hf2_4 || hf3_4
				|| h4e || h4n || h4h || hb4);
		//something hits player ship
		hs = hs1 || hs2 || hs3 || hs4 || hs5 || hs6 || hs7 || hs8 || hs9 || hs10 || hs11 || hs12	|| hss1 || hss2 || hss3 || hss4
				|| hsf1 || hsf2 || hsf3 || hbs
				|| Phit1 || Phit2 || Phit3 || Phit4 || PhitBeam;
		//you hit an enemey with a laser
		ship_hit = h1 || h2 || h3 || h4;
		end
	
///////////////////////////////////////////////
logic explosion1, explosion2, explosion3, explosion4, explosion5, explosion6, explosion7, explosion8, explosion9, explosion10, explosion11, explosion12;
logic explosions1, explosions2, explosions3, explosions4;
logic explosionf1, explosionf2, explosionf3, explosionf4;

	
	enemy e1(	.Reset(Reset_h),
					.frame_clk(VGA_VS),
					.spawn(e1sig),
					.row(firstrow),
					.flydown(flydown),
					.difficulty(difficulty),
					.rand_side(side1),
					.laser_width(laser_width), .laser_height(laser_height),
					.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
					.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
					.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
					.PSX(shipxsig), .PSY(shipysig),
					.SpaceshipX(e1X),
					.SpaceshipY(e1Y),
					.SpaceshipS(e1S),
					.SpaceshipE(e1E),
					.h1(h1_1), .h2(h1_2), .h3(h1_3), .h4(h1_4), .hs(hs1),
					.explosion(explosion1)
					);
	enemy e2(	.Reset(Reset_h),
					.frame_clk(VGA_VS),
					.spawn(e2sig),
					.row(firstrow),
					.flydown(flydown),
					.difficulty(difficulty),
					.rand_side(side1),
					.laser_width(laser_width), .laser_height(laser_height),
					.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
					.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
					.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
					.PSX(shipxsig), .PSY(shipysig),
					.SpaceshipX(e2X),
					.SpaceshipY(e2Y),
					.SpaceshipS(e2S),
					.SpaceshipE(e2E),
					.h1(h2_1), .h2(h2_2), .h3(h2_3), .h4(h2_4), .hs(hs2),
					.explosion(explosion2)
					);
	enemy e3(	.Reset(Reset_h),
					.frame_clk(VGA_VS),
					.spawn(e3sig),
					.row(firstrow),
					.flydown(flydown),
					.difficulty(difficulty),
					.rand_side(side1),
					.laser_width(laser_width), .laser_height(laser_height),
					.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
					.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
					.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
					.PSX(shipxsig), .PSY(shipysig),
					.SpaceshipX(e3X),
					.SpaceshipY(e3Y),
					.SpaceshipS(e3S),
					.SpaceshipE(e3E),
					.h1(h3_1), .h2(h3_2), .h3(h3_3), .h4(h3_4), .hs(hs3),
					.explosion(explosion3)
					);
	enemy e4(	.Reset(Reset_h),
					.frame_clk(VGA_VS),
					.spawn(e4sig),
					.row(firstrow),
					.flydown(flydown),
					.difficulty(difficulty),
					.rand_side(side1),
					.laser_width(laser_width), .laser_height(laser_height),
					.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
					.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
					.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
					.PSX(shipxsig), .PSY(shipysig),
					.SpaceshipX(e4X),
					.SpaceshipY(e4Y),
					.SpaceshipS(e4S),
					.SpaceshipE(e4E),
					.h1(h4_1), .h2(h4_2), .h3(h4_3), .h4(h4_4), .hs(hs4),
					.explosion(explosion4)
					);
	enemy e5(	.Reset(Reset_h),
					.frame_clk(VGA_VS),
					.spawn(e5sig),
					.row(secondrow),
					.flydown(flydown),
					.difficulty(difficulty),
					.rand_side(side2),
					.laser_width(laser_width), .laser_height(laser_height),
					.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
					.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
					.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
					.PSX(shipxsig), .PSY(shipysig),
					.SpaceshipX(e5X),
					.SpaceshipY(e5Y),
					.SpaceshipS(e5S),
					.SpaceshipE(e5E),
					.h1(h5_1), .h2(h5_2), .h3(h5_3), .h4(h5_4), .hs(hs5),
					.explosion(explosion5)
					);
	enemy e6(	.Reset(Reset_h),
					.frame_clk(VGA_VS),
					.spawn(e6sig),
					.row(secondrow),
					.flydown(flydown),
					.difficulty(difficulty),
					.rand_side(side2),
					.laser_width(laser_width), .laser_height(laser_height),
					.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
					.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
					.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
					.PSX(shipxsig), .PSY(shipysig),
					.SpaceshipX(e6X),
					.SpaceshipY(e6Y),
					.SpaceshipS(e6S),
					.SpaceshipE(e6E),
					.h1(h6_1), .h2(h6_2), .h3(h6_3), .h4(h6_4), .hs(hs6),
					.explosion(explosion6)
					);
	enemy e7(	.Reset(Reset_h),
					.frame_clk(VGA_VS),
					.spawn(e7sig),
					.row(secondrow),
					.flydown(flydown),
					.difficulty(difficulty),
					.rand_side(side2),
					.laser_width(laser_width), .laser_height(laser_height),
					.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
					.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
					.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
					.PSX(shipxsig), .PSY(shipysig),
					.SpaceshipX(e7X),
					.SpaceshipY(e7Y),
					.SpaceshipS(e7S),
					.SpaceshipE(e7E),
					.h1(h7_1), .h2(h7_2), .h3(h7_3), .h4(h7_4), .hs(hs7),
					.explosion(explosion7)
					);
	enemy e8(	.Reset(Reset_h),
					.frame_clk(VGA_VS),
					.spawn(e8sig),
					.row(secondrow),
					.flydown(flydown),
					.difficulty(difficulty),
					.rand_side(side2),
					.laser_width(laser_width), .laser_height(laser_height),
					.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
					.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
					.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
					.PSX(shipxsig), .PSY(shipysig),
					.SpaceshipX(e8X),
					.SpaceshipY(e8Y),
					.SpaceshipS(e8S),
					.SpaceshipE(e8E),
					.h1(h8_1), .h2(h8_2), .h3(h8_3), .h4(h8_4), .hs(hs8),
					.explosion(explosion8)
					);
	enemy e9(	.Reset(Reset_h),
					.frame_clk(VGA_VS),
					.spawn(e9sig),
					.row(thirdrow),
					.flydown(flydown),
					.difficulty(difficulty),
					.rand_side(side1),
					.laser_width(laser_width), .laser_height(laser_height),
					.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
					.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
					.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
					.PSX(shipxsig), .PSY(shipysig),
					.SpaceshipX(e9X),
					.SpaceshipY(e9Y),
					.SpaceshipS(e9S),
					.SpaceshipE(e9E),
					.h1(h9_1), .h2(h9_2), .h3(h9_3), .h4(h9_4), .hs(hs9),
					.explosion(explosion9)
					);
	enemy e10(	.Reset(Reset_h),
					.frame_clk(VGA_VS),
					.spawn(e10sig),
					.row(thirdrow),
					.flydown(flydown),
					.difficulty(difficulty),
					.rand_side(side1),
					.laser_width(laser_width), .laser_height(laser_height),
					.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
					.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
					.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
					.PSX(shipxsig), .PSY(shipysig),
					.SpaceshipX(e10X),
					.SpaceshipY(e10Y),
					.SpaceshipS(e610S),
					.SpaceshipE(e10E),
					.h1(h10_1), .h2(h10_2), .h3(h10_3), .h4(h10_4), .hs(hs10),
					.explosion(explosion10)
					);
	enemy e11(	.Reset(Reset_h),
					.frame_clk(VGA_VS),
					.spawn(e11sig),
					.row(thirdrow),
					.flydown(flydown),
					.difficulty(difficulty),
					.rand_side(side1),
					.laser_width(laser_width), .laser_height(laser_height),
					.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
					.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
					.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
					.PSX(shipxsig), .PSY(shipysig),
					.SpaceshipX(e11X),
					.SpaceshipY(e11Y),
					.SpaceshipS(e11S),
					.SpaceshipE(e11E),
					.h1(h11_1), .h2(h11_2), .h3(h11_3), .h4(h11_4), .hs(hs11),
					.explosion(explosion11)
					);		
	enemy e12(	.Reset(Reset_h),
					.frame_clk(VGA_VS),
					.spawn(e12sig),
					.row(thirdrow),
					.flydown(flydown),
					.difficulty(difficulty),
					.rand_side(side1),
					.laser_width(laser_width), .laser_height(laser_height),
					.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
					.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
					.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
					.PSX(shipxsig), .PSY(shipysig),
					.SpaceshipX(e12X),
					.SpaceshipY(e12Y),
					.SpaceshipS(e12S),
					.SpaceshipE(e12E),
					.h1(h12_1), .h2(h12_2), .h3(h12_3), .h4(h12_4), .hs(hs12),
					.explosion(explosion12)
					);	
	
	///////////////enemy controller
	enemycontroller waves(	.Reset(Reset_h),
									.frame_clk(VGA_VS),
									.easy_selected(easy_selected), .normal_selected(normal_selected), .hard_selected(hard_selected),
									.e1(e1E), .e2(e2E), .e3(e3E), .e4(e4E), .e5(e5E), .e6(e6E), .e7(e7E), .e8(e8E), .e9(e9E), .e10(e10E), .e11(e11E), .e12(e12E),
									.es1(es1E), .es2(es2E), .es3(es3E), .es4(es4E),
									.start_game(start_game),	//could also become initiate_waves and start_game could be something else
									.flydown(flydown),
									.start_Boss(spawn_boss),
									.difficulty(difficulty),
									.wave1_1sig(wave1_1sig), .wave1_2sig(wave1_2sig), .wave1_3sig(wave1_3sig), .wave1_4sig(wave1_4sig),
									.wave2_1sig(wave2_1sig), .wave2_2sig(wave2_2sig), .wave2_3sig(wave2_3sig), .wave2_4sig(wave2_4sig),
									.wave3_1sig(wave3_1sig), .wave3_2sig(wave3_2sig), .wave3_3sig(wave3_3sig), .wave3_4sig(wave3_4sig),
									.wave4_1sig(wave4_1sig), .wave4_2sig(wave4_2sig), .wave4_3sig(wave4_3sig), .wave4_4sig(wave4_4sig)
									);

	logic [8:0] LFSR_powerup_timer, LFSR_powerup_pos;
	logic [1:0] LFSR_powerup_type;
	
	////////////boss stuff
	logic spawn_boss, boss_flydown, boss_rise, boss_hold, back_and_forth, Boss_exists, beat_Boss;
	logic [9:0] bossxsig, bossysig, bosswidthsig, bossheightsig;
	logic hb1, hb2, hb3, hb4, hbs;
	logic hit_top, hit_bottom;
	
enemy_beam beam(    .Reset(Reset_h), .frame_clk(VGA_VS),
                            .LFSR_position(LFSR2[1:0]),
                            .difficulty(difficulty),
                            .PSX(shipxsig), .PSY(shipysig),
                            .bsX(bossxsig), .bsY(bossysig),
                            .boss_exists(Boss_exists),
                            .beamX(beamX), .beamY(beamY),
                            .beam_size(beam_size), .beam_exists(beam_exists),
                            .Phit(PhitBeam)
                    );	
	
	
boss boss(.Reset(Reset_h), .frame_clk(VGA_VS), .spawn(spawn_boss), .flydown(boss_flydown), .back_and_forth(back_and_forth),
				.rise(boss_rise), .hold(boss_hold), .difficulty(difficulty),
				.laser_width(laser_width), .laser_height(laser_height),
				.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
				.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
				.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
				.PSX(shipxsig), .PSY(shipysig),
				.Boss_exists(Boss_exists), 
            .BossX(bossxsig), .BossY(bossysig), .Bosswidth(bosswidthsig), .Bossheight(bossheightsig),
				.h1(hb1), .h2(hb2), .h3(hb3), .h4(hb4), .hs(hbs), .beat_Boss(beat_Boss),
				.hit_top(hit_top), .hit_bottom(hit_bottom)
				);
					
boss_controller boss_controller(.Reset(Reset_h), .frame_clk(VGA_VS), .start_Boss(spawn_boss),
											.difficulty(difficulty), .beat_Boss(beat_Boss), .hit_bottom(hit_bottom), .hit_top(hit_top),
											.boss_flydown(boss_flydown), .boss_rise(boss_rise), .boss_hold(boss_hold), .boss_shoot1(), .boss_shoot2(), .boss_shoot3(), .boss_shoot4(),
											.Boss_exists(Boss_exists), .boss_back_and_forth(back_and_forth)
											);
	
	/////randomizer
	LFSR RNG(	.Reset(Reset_h),
					.frame_clk(VGA_VS),
					.enemy_shoot1(LFSR1), .enemy_shoot2(LFSR2), .enemy_shoot3(LFSR3), .enemy_shoot4(LFSR4),
					.LFSR_powerup_type(LFSR_powerup_type), .LFSR_powerup_pos(LFSR_powerup_pos), .LFSR_powerup_timer(LFSR_powerup_timer)
					);

					
	enemy es1(	.Reset(Reset_h),
					.frame_clk(VGA_VS),
					.spawn(es1sig),														
					.row(secondrow),														
					.flydown(flydown),
					.difficulty(difficulty),
					.rand_side(side2),
					.laser_width(laser_width), .laser_height(laser_height),
					//lasers
					.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
					.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
					.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
					//player ship position
					.PSX(shipxsig), .PSY(shipysig),
					//enemy ship position
					.SpaceshipX(es1X),	.SpaceshipY(es1Y),	.SpaceshipS(es1S),	.SpaceshipE(es1E),										
					//collision signals
					.h1(hs1_1), .h2(hs1_2), .h3(hs1_3), .h4(hs1_4), .hs(hss1),
					.explosion(explosions1)
						);	

	enemy_cannon EL_1(.Reset(Reset_h),
							.frame_clk(VGA_VS),
							.LFSR(LFSR1),
							.PSX(shipxsig), .PSY(shipysig),
							.EX(es1X), .EY(es1Y),
							.enemy_alive(es1E),
							.prev_laser_exists(1),
							.laser_width(laser_width), .laser_height(laser_height),
							.laserX(EL1X), .laserY(EL1Y),
							.laserexists(EL1),
							.Phit(Phit1)
							);
				
	enemy es2(	.Reset(Reset_h),
					.frame_clk(VGA_VS),
					.spawn(es2sig),														
					.row(secondrow),														
					.flydown(flydown),
					.difficulty(difficulty),
					.rand_side(side2),
					.laser_width(laser_width), .laser_height(laser_height),
					//lasers
					.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
					.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
					.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
					//player ship position
					.PSX(shipxsig), .PSY(shipysig),
					//enemy ship position
					.SpaceshipX(es2X),	.SpaceshipY(es2Y),	.SpaceshipS(es2S),	.SpaceshipE(es2E),									
					//collision signals
					.h1(hs2_1), .h2(hs2_2), .h3(hs2_3), .h4(hs2_4), .hs(hss2),
					.explosion(explosions2)
						);	

	enemy_cannon EL_2(.Reset(Reset_h),
							.frame_clk(VGA_VS),
							.LFSR(LFSR2),
							.PSX(shipxsig), .PSY(shipysig),
							.EX(es2X), .EY(es2Y),
							.enemy_alive(es2E),
							.prev_laser_exists(1),
							.laser_width(laser_width), .laser_height(laser_height),
							.laserX(EL2X), .laserY(EL2Y),
							.laserexists(EL2),
							.Phit(Phit2)
							);
							
	enemy es3(	.Reset(Reset_h),
					.frame_clk(VGA_VS),
					.spawn(es3sig),														
					.row(secondrow),														
					.flydown(flydown),
					.difficulty(difficulty),
					.rand_side(side2),
					.laser_width(laser_width), .laser_height(laser_height),
					//lasers
					.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
					.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
					.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
					//player ship position
					.PSX(shipxsig), .PSY(shipysig),
					//enemy ship position
					.SpaceshipX(es3X),	.SpaceshipY(es3Y),	.SpaceshipS(es3S),	.SpaceshipE(es3E),										
					//collision signals
					.h1(hs3_1), .h2(hs3_2), .h3(hs3_3), .h4(hs3_4), .hs(hss3),
					.explosion(explosions3)
						);		
						
	enemy_cannon EL_3(.Reset(Reset_h),
							.frame_clk(VGA_VS),
							.LFSR(LFSR3),
							.PSX(shipxsig), .PSY(shipysig),
							.EX(es3X), .EY(es3Y),
							.enemy_alive(es3E),
							.prev_laser_exists(1),
							.laser_width(laser_width), .laser_height(laser_height),
							.laserX(EL3X), .laserY(EL3Y),
							.laserexists(EL3),
							.Phit(Phit3)
							);	
					
	enemy es4(	.Reset(Reset_h),
					.frame_clk(VGA_VS),
					.spawn(es4sig),														
					.row(secondrow),														
					.flydown(flydown),
					.difficulty(difficulty),
					.rand_side(side2),
					.laser_width(laser_width), .laser_height(laser_height),
					//lasers
					.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
					.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
					.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
					//player ship position
					.PSX(shipxsig), .PSY(shipysig),
					//enemy ship position
					.SpaceshipX(es4X),	.SpaceshipY(es4Y),	.SpaceshipS(es4S),	.SpaceshipE(es4E),										
					//collision signals
					.h1(hs4_1), .h2(hs4_2), .h3(hs4_3), .h4(hs4_4), .hs(hss4),
					.explosion(explosions4)
						);	
	enemy_cannon EL_4(.Reset(Reset_h),
                            .frame_clk(VGA_VS),
                            .LFSR(LFSR4),
                            .PSX(shipxsig), .PSY(shipysig),
                            .EX(es4X), .EY(es4Y),
                            .enemy_alive(es4E),
                            .prev_laser_exists(1),
                            .laser_width(laser_width), .laser_height(laser_height),
                            .laserX(EL4X), .laserY(EL4Y),
                            .laserexists(EL4),
                            .Phit(Phit4)
                            );	

							
		//enemy flyers
//enemy flyers
	logic [9:0] ef1X, ef2X, ef3X;
	logic [9:0] ef1Y, ef2Y, ef3Y;
	logic ef1E, ef2E, ef3E;

	logic [9:0] beamX, beamY;
	logic [4:0] beam_size;
	logic beam_exists;
	logic [7:0] beam_shoot;		
		
		
	enemyflyer ef1(.Reset(Reset_h),
						.frame_clk(VGA_VS),
						.spawn(ef1sig), //temp
						.flyer_num(0),
						.difficulty(difficulty),
						.laser_width(laser_width), .laser_height(laser_height),
						//lasers
						.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
						.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
						.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
						//player ship position
						.PSX(shipxsig), .PSY(shipysig),
						//enemy ship position
						.SpaceshipX(ef1X),	.SpaceshipY(ef1Y),	.SpaceshipS(ef1S),	.SpaceshipE(ef1E),										
						//collision signals
						.h1(hf1_1), .h2(hf1_2), .h3(hf1_3), .h4(hf1_4), .hs(hsf1),
						.explosion(explosionf1)
						);
						
	enemyflyer ef2(.Reset(Reset_h),	//middle
						.frame_clk(VGA_VS),
						.spawn(ef2sig), 
						.flyer_num(1),
						.difficulty(difficulty),
						.laser_width(laser_width), .laser_height(laser_height),
						//lasers
						.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
						.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
						.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
						//player ship position
						.PSX(shipxsig), .PSY(shipysig),
						//enemy ship position
						.SpaceshipX(ef2X),	.SpaceshipY(ef2Y),	.SpaceshipS(ef2S),	.SpaceshipE(ef2E),										
						//collision signals
						.h1(hf2_1), .h2(hf2_2), .h3(hf2_3), .h4(hf2_4), .hs(hsf2),
						.explosion(explosionf2)
						
						);
						
	enemyflyer ef3(.Reset(Reset_h),
						.frame_clk(VGA_VS),
						.spawn(ef3sig), 
						.flyer_num(2),
						.difficulty(difficulty),
						.laser_width(laser_width), .laser_height(laser_height),
						//lasers
						.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
						.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
						.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
						//player ship position
						.PSX(shipxsig), .PSY(shipysig),
						//enemy ship position
						.SpaceshipX(ef3X),	.SpaceshipY(ef3Y),	.SpaceshipS(ef3S),	.SpaceshipE(ef3E),										
						//collision signals
						.h1(hf3_1), .h2(hf3_2), .h3(hf3_3), .h4(hf3_4), .hs(hsf3),
						.explosion(explosionf3)
						);
						

	difficulty_blocks easy(	.Reset(Reset_h), .frame_clk(VGA_VS), 
									.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4),
									.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
									.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
									.laser_width(laser_width), .laser_height(laser_height),
									.other_selected(normal_selected || hard_selected),
									.difficulty(2'b00),
									.block_width(block_width), .block_height(block_height),
									.blockX(E_blockX), .blockY(E_blockY),
									.selected(easy_selected),
									.h1(h1e), .h2(h2e), .h3(h3e), .h4(h4e)
									);
						
	difficulty_blocks normal(.Reset(Reset_h), .frame_clk(VGA_VS), 
									.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4), 
									.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
									.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
									.laser_width(laser_width), .laser_height(laser_height),
									.other_selected(easy_selected || hard_selected),
									.difficulty(2'b01),
									.block_width(block_width), .block_height(block_height),
									.blockX(N_blockX), .blockY(N_blockY),
									.selected(normal_selected),
									.h1(h1n), .h2(h2n), .h3(h3n), .h4(h4n)
									);
				
	difficulty_blocks hard(	.Reset(Reset_h), .frame_clk(VGA_VS), 
									.PX1(PX1), .PX2(PX2), .PX3(PX3), .PX4(PX4), 
									.PY1(PY1), .PY2(PY2), .PY3(PY3), .PY4(PY4),
									.PL1(pl1), .PL2(pl2), .PL3(pl3), .PL4(pl4),
									.laser_width(laser_width), .laser_height(laser_height),
									.other_selected(normal_selected || easy_selected),
									.difficulty(2'b10),
									.block_width(block_width), .block_height(block_height),
									.blockX(H_blockX), .blockY(H_blockY),
									.selected(hard_selected),
									.h1(h1h), .h2(h2h), .h3(h3h), .h4(h4h)
									);

draw_score ds(.Reset(Reset_h), .frame_clk(VGA_VS), .ship_hit(ship_hit), .powerup(powerup),
						.ScoreX(score_x), .ScoreY(score_y),
						.score_counter(score_val), .doublescore(doublescore), .win_game(win_game),
						.start_game(start_game)
						);
						

endmodule
