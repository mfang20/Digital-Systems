
module labfinal_soc (
	clk_clk,
	hex_digits_export,
	key_external_connection_export,
	keycode_export,
	keycode2_export,
	keycode3_export,
	leds_export,
	lose_game_export,
	rand_side_export,
	reset_reset_n,
	score_val_export,
	sdram_clk_clk,
	sdram_wire_addr,
	sdram_wire_ba,
	sdram_wire_cas_n,
	sdram_wire_cke,
	sdram_wire_cs_n,
	sdram_wire_dq,
	sdram_wire_dqm,
	sdram_wire_ras_n,
	sdram_wire_we_n,
	spi0_MISO,
	spi0_MOSI,
	spi0_SCLK,
	spi0_SS_n,
	usb_gpx_export,
	usb_irq_export,
	usb_rst_export,
	vga_port_drawx,
	vga_port_drawy,
	vga_port_blue,
	vga_port_green,
	vga_port_hs,
	vga_port_lose_life,
	vga_port_pass_up1,
	vga_port_pass_up2,
	vga_port_pass_up3,
	vga_port_red,
	vga_port_vs,
	win_game_export,
	reset_button_export,
	difficulty_export);	

	input		clk_clk;
	output	[15:0]	hex_digits_export;
	input	[1:0]	key_external_connection_export;
	output	[7:0]	keycode_export;
	output	[7:0]	keycode2_export;
	output	[7:0]	keycode3_export;
	output	[13:0]	leds_export;
	input		lose_game_export;
	output		rand_side_export;
	input		reset_reset_n;
	input	[9:0]	score_val_export;
	output		sdram_clk_clk;
	output	[12:0]	sdram_wire_addr;
	output	[1:0]	sdram_wire_ba;
	output		sdram_wire_cas_n;
	output		sdram_wire_cke;
	output		sdram_wire_cs_n;
	inout	[15:0]	sdram_wire_dq;
	output	[1:0]	sdram_wire_dqm;
	output		sdram_wire_ras_n;
	output		sdram_wire_we_n;
	input		spi0_MISO;
	output		spi0_MOSI;
	output		spi0_SCLK;
	output		spi0_SS_n;
	input		usb_gpx_export;
	input		usb_irq_export;
	output		usb_rst_export;
	output	[10:0]	vga_port_drawx;
	output	[10:0]	vga_port_drawy;
	output	[3:0]	vga_port_blue;
	output	[3:0]	vga_port_green;
	output		vga_port_hs;
	input		vga_port_lose_life;
	input		vga_port_pass_up1;
	input		vga_port_pass_up2;
	input		vga_port_pass_up3;
	output	[3:0]	vga_port_red;
	output		vga_port_vs;
	input		win_game_export;
	input		reset_button_export;
	input		difficulty_export;
endmodule
