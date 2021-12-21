//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input        [9:0] SpaceshipX, SpaceshipY, DrawX, DrawY, Spaceship_size,
							  input        [9:0] Laser1X, Laser2X, Laser3X, Laser4X, laser_width, laser_height,
							  input        [9:0] Laser1Y, Laser2Y, Laser3Y, Laser4Y,
							  input 			le1, le2, le3, le4,
							  input 			lose_game,
							  input 			[9:0] e1X, e2X, e3X, e4X, e5X, e6X, e7X, e8X, e9X, e10X, e11X, e12X,
                       input 			[9:0] e1Y, e2Y, e3Y, e4Y, e5Y, e6Y, e7Y, e8Y, e9Y, e10Y, e11Y, e12Y,
                       input        e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12,
							  input			[9:0] LivesX, LivesY,
							  input			[3:0] vram_r, vram_g, vram_b,
							  input			[1:0] num_lives,
							  input			[9:0] score_x, score_y, score_val,
							  input			[9:0] PowerupX, PowerupY,Powerupwidth, Powerupheight,
							  input			draw_powerup,
							  input			[3:0] powerup_red, powerup_green, powerup_blue,
							  input			win_game,
							  input			[7:0] ship_ram_red, ship_ram_green, ship_ram_blue,
							  input 			[7:0] enemy_ram_red, enemy_ram_green, enemy_ram_blue,
							  input 			[7:0] enemy_flyer_ram_red, enemy_flyer_ram_green, enemy_flyer_ram_blue,
							  input 			[7:0] enemy_shooter_ram_red, enemy_shooter_ram_green, enemy_shooter_ram_blue,
							  input			[7:0] boss_ram_red, boss_ram_green, boss_ram_blue,
							  input			[7:0] explosion_ram_red, explosion_ram_green, explosion_ram_blue,
							  input			explosion1, explosion2, explosion3, explosion4, explosion5, explosion6, explosion7, explosion8, explosion9, explosion10, explosion11, explosion12,
							  input			explosions1, explosions2, explosions3, explosions4,
							  input 			explosionf1, explosionf2, explosionf3,
							  //enemy shooter
								input [9:0] es1X, es2X, es3X, es4X,
								input [9:0] es1Y, es2Y, es3Y, es4Y,
								input es1, es2, es3, es4,
								//enemy lasers
								input [9:0] EL1X, EL2X, EL3X, EL4X,
								input [9:0] EL1Y, EL2Y, EL3Y, EL4Y,
								input EL1, EL2, EL3, EL4,
								//difficulty blocks
								input [9:0] E_blockX, N_blockX, H_blockX,
								input [9:0] E_blockY, N_blockY, H_blockY,
								input [9:0] block_width, block_height,
								input difficulty_selected,
								input [9:0] BossX, BossY, Boss_width, Boss_height,
								input Boss_exists,
								input beat_Boss,
								//enemy flyers
                        input [9:0] ef1X, ef2X, ef3X,
                        input [9:0] ef1Y, ef2Y, ef3Y,
                        input ef1, ef2, ef3,
								//beam
                        input [9:0] beamX, beamY,
                        input [4:0] beam_size,
                        input beam_exists,
								input	[7:0] spaceship_red, spaceship_blue, spaceship_green,
								output logic [3:0]  Red, Green, Blue );
    
    logic Spaceship_on, Lives_on, Powerup_on, Boss_on;
	 logic Laser_on, enemy_on, Score_on, enemy_shooter_on, enemy_laser_on, enemy_flyer_on, beam_on;
	 logic E_block_on, N_block_on, H_block_on;
	 logic [9:0] lives_width, lives_height, score_width, score_height;
	 logic [3:0] lives_bkd_r, lives_bkd_g, lives_bkd_b, lives_fgd_r, lives_fgd_g, lives_fgd_b, Lives_R, Lives_G, Lives_B;
	 logic [9:0] font_addr;
	 logic [7:0] font_data;
	 logic lives_char;
	 
	 logic [3:0] ship_r, ship_b, ship_g;
	 logic [3:0] body_red, body_blue, body_green;
	 logic [3:0] outer_red, outer_blue, outer_green;
	 logic [3:0] tail_red, tail_blue, tail_green;
	 logic [5:0] ship_font_addr;
	 logic [3:0] ship_col;
	 logic [15:0] ship_font_data;
	 logic ship_bit;
	 
	 
	 logic enemy1_on, enemy2_on, enemy3_on, enemy4_on, enemy5_on, enemy6_on, enemy7_on, enemy8_on, enemy9_on, enemy10_on, enemy11_on, enemy12_on;
	 logic enemys1_on, enemys2_on, enemys3_on, enemys4_on;
	 logic enemyf1_on, enemyf2_on, enemyf3_on;
	 logic draw_explosion;
	 
	 
	 parameter [9:0] Ship_Width=16;  // Center position on the X axis
	 parameter [9:0] Ship_Height=32;
	 
	 
	 final_font_rom ffr( .addr(font_addr), .data(font_data));
	 parameter [9:0] spaceship_width = 30;
	 parameter [9:0] spaceship_height = 30;
	 
	 
	 //ship_rom ship_rom( .addr(ship_font_addr), .data(ship_font_data));
	 
	 ///////// = ignore
	
			
   
	//////Dist, size for player ship
	int DistX, DistY, Size;
	 assign DistX = DrawX - SpaceshipX;
    assign DistY = DrawY - SpaceshipY;
    assign Size = Spaceship_size;
	 
	 
	 //////////draw hearts for lives
	 assign lives_width = num_lives * 8;
	 always_comb
	 begin 
		if (num_lives==0)
		 lives_height = 0;
		else
		 lives_height = 16;
	 end
	 
	  always_comb
     begin:Lives_on_proc
        if ( DrawX >=LivesX && DrawX <= (LivesX + lives_width) && DrawY>= LivesY &&
				DrawY <= LivesY + lives_height) 
            Lives_on = 1'b1;
        else 
            Lives_on = 1'b0;
     end 
	  
	   always_comb
	 begin
	 lives_bkd_r = 4'h0;
	 lives_bkd_g = 4'h0;
	 lives_bkd_b = 4'h0;
	 
	 lives_fgd_r = 4'hf;
	 lives_fgd_g = 4'h0;
	 lives_fgd_b = 4'h0;
	 end
	 
	 always_comb//////////////////get char data from font_rom
	 begin
	 if (Lives_on)
	 begin
		font_addr = 48 + (DrawY-LivesY);
		lives_char = font_data[DrawX[2:0]];
	 end
	 else
	 begin
		font_addr = 0;
		lives_char = 0;
	 end
	 end
	 
	 always_comb
	 begin
		if (lives_char)
		begin
			Lives_R = lives_fgd_r;
			Lives_G = lives_fgd_g;
			Lives_B = lives_fgd_b;
		end
		else
		begin
			Lives_R = lives_bkd_r;
			Lives_G = lives_bkd_g;
			Lives_B = lives_bkd_b;
		end
	end
	
	

	
	
	//enemy flyer
	always_comb
	begin
			if (ef1 && (DrawX >= ef1X) && (DrawX < ef1X + spaceship_width) &&
            (DrawY >= ef1Y) && (DrawY < ef1Y + spaceship_height)    )
			begin
				enemyf1_on = 1'b1;
				enemyf2_on = 1'b0;
				enemyf3_on = 1'b0;
			end
				
         else if  (ef2 && (DrawX >= ef2X) && (DrawX < ef2X + spaceship_width) &&
            (DrawY >= ef2Y) && (DrawY < ef2Y + spaceship_height)    ) 
			begin
				enemyf1_on = 1'b0;
				enemyf2_on = 1'b1;
				enemyf3_on = 1'b0;
			end
				
          else if  (ef3 && (DrawX >= ef3X) && (DrawX < ef3X + spaceship_width) &&
            (DrawY >= ef3Y) && (DrawY < ef3Y + spaceship_height)  )
			 begin
				enemyf1_on = 1'b0;
				enemyf2_on = 1'b0;
				enemyf3_on = 1'b1;
			 end
            
         else
			begin
				enemyf1_on = 1'b0;
				enemyf2_on = 1'b0;
				enemyf3_on = 1'b0;
			end
	end
	  
assign enemy_flyer_on = enemyf1_on | enemyf2_on | enemyf3_on;	  
	 /* //////////draw bar for score
	 assign score_height = score_val * 16;
	 always_comb
	 begin 
		if (score_val==0)
		 score_width = 0;
		else
		 score_width = 8;
	 end
	 
	  always_comb
     begin:Score_on_proc
        if ( DrawX >=score_x && DrawX <= (score_x + score_width) && DrawY>= score_y &&
				DrawY <= score_y + score_height) 
            Score_on = 1'b1;
        else 
            Score_on = 1'b0;
     end */
	  
	  assign Score_on = 1'b0;
	 
    //////////draw ship
	 always_comb
    begin:Spaceship_on_proc
        if ( ( DistX >=0 && DistY>=0 && DistX <=Size && DistY <= Size))
            Spaceship_on = 1'b1;
        else 
            Spaceship_on = 1'b0;
     end  
	 /////////check for laser in current spot
	  always_comb
	  begin
	if(  (le1 && (	(DrawX >= Laser1X) && (DrawX < Laser1X + laser_width) &&
				 (DrawY >= Laser1Y) && (DrawY < Laser1Y + laser_height)	)	)	||
				 
				 (le2 && (	(DrawX >= Laser2X) && (DrawX < Laser2X + laser_width) &&
				 (DrawY >= Laser2Y) && (DrawY < Laser2Y + laser_height)	) 	)	||
				 
				 (le3 && (	(DrawX >= Laser3X) && (DrawX < Laser3X + laser_width) &&
				 (DrawY >= Laser3Y) && (DrawY < Laser3Y + laser_height)	) 	)	||
				 
				 (le4 && (	(DrawX >= Laser4X) && (DrawX < Laser4X + laser_width) &&
				 (DrawY >= Laser4Y) && (DrawY < Laser4Y + laser_height)	)	)
				 )
				Laser_on = 1'b1;
			else
				Laser_on = 1'b0;
				 
     end 
	  
	  
	//////////////////////////////check for enemy in current spot  
	 logic [9:0] ewidth, elength;
	 int eDistX, eDistY, eSize;
	 //assign eDistX = DrawX - enemy_x;
    //assign eDistY = DrawY - enemy_y;
    assign ewidth = 4;
	 assign elength = 4;
	 
	  
	  
	 always_comb
    begin:enemy_on_proc
		if (e1 &&	(DrawX >= e1X) && (DrawX < e1X + 30) &&
			(DrawY >= e1Y) && (DrawY < e1Y + 30)	)
		begin
				enemy1_on  = 1'b1;
				enemy2_on = 1'b0;
				enemy3_on = 1'b0;
				enemy4_on = 1'b0;
				enemy5_on = 1'b0;
				enemy6_on = 1'b0;
				enemy7_on = 1'b0;
				enemy8_on = 1'b0;
				enemy9_on = 1'b0;
				enemy10_on = 1'b0;
				enemy11_on = 1'b0;
				enemy12_on = 1'b0;
		end
		
				
				
			
		else if (e2 && 	(DrawX >= e2X) && (DrawX < e2X + 30) &&
					(DrawY >= e2Y) && (DrawY < e2Y + 30)	)	
		begin
				enemy1_on  = 1'b0;
				enemy2_on = 1'b1;
				enemy3_on = 1'b0;
				enemy4_on = 1'b0;
				enemy5_on = 1'b0;
				enemy6_on = 1'b0;
				enemy7_on = 1'b0;
				enemy8_on = 1'b0;
				enemy9_on = 1'b0;
				enemy10_on = 1'b0;
				enemy11_on = 1'b0;
				enemy12_on = 1'b0;
		end
			
		else if	(e3 && 	(DrawX >= e3X) && (DrawX < e3X + 30) &&
				(DrawY >= e3Y) && (DrawY < e3Y + 30)	)		
		begin
				enemy1_on  = 1'b0;
				enemy2_on = 1'b0;
				enemy3_on = 1'b1;
				enemy4_on = 1'b0;
				enemy5_on = 1'b0;
				enemy6_on = 1'b0;
				enemy7_on = 1'b0;
				enemy8_on = 1'b0;
				enemy9_on = 1'b0;
				enemy10_on = 1'b0;
				enemy11_on = 1'b0;
				enemy12_on = 1'b0;
		end
			
		else if (e4 && 	(DrawX >= e4X) && (DrawX < e4X + 30) &&
				(DrawY >= e4Y) && (DrawY < e4Y + 30)	)
		begin
				enemy1_on  = 1'b0;
				enemy2_on = 1'b0;
				enemy3_on = 1'b0;
				enemy4_on = 1'b1;
				enemy5_on = 1'b0;
				enemy6_on = 1'b0;
				enemy7_on = 1'b0;
				enemy8_on = 1'b0;
				enemy9_on = 1'b0;
				enemy10_on = 1'b0;
				enemy11_on = 1'b0;
				enemy12_on = 1'b0;
		end
			
		else if	(e5 && 	(DrawX >= e5X) && (DrawX < e5X + 30) &&
			(DrawY >= e5Y) && (DrawY < e5Y + 30)	)
		begin
				enemy1_on  = 1'b0;
				enemy2_on = 1'b0;
				enemy3_on = 1'b0;
				enemy4_on = 1'b0;
				enemy5_on = 1'b1;
				enemy6_on = 1'b0;
				enemy7_on = 1'b0;
				enemy8_on = 1'b0;
				enemy9_on = 1'b0;
				enemy10_on = 1'b0;
				enemy11_on = 1'b0;
				enemy12_on = 1'b0;
		end
			
		else if	(e6 && 	(DrawX >= e6X) && (DrawX < e6X + 30) &&
			(DrawY >= e6Y) && (DrawY < e6Y + 30)	)
		begin
				enemy1_on  = 1'b0;
				enemy2_on = 1'b0;
				enemy3_on = 1'b0;
				enemy4_on = 1'b0;
				enemy5_on = 1'b0;
				enemy6_on = 1'b1;
				enemy7_on = 1'b0;
				enemy8_on = 1'b0;
				enemy9_on = 1'b0;
				enemy10_on = 1'b0;
				enemy11_on = 1'b0;
				enemy12_on = 1'b0;
		end
			
		else if	(e7 && 	(DrawX >= e7X) && (DrawX < e7X + 30) &&
			(DrawY >= e7Y) && (DrawY < e7Y + 30)	)
		begin
				enemy1_on  = 1'b0;
				enemy2_on = 1'b0;
				enemy3_on = 1'b0;
				enemy4_on = 1'b0;
				enemy5_on = 1'b0;
				enemy6_on = 1'b0;
				enemy7_on = 1'b1;
				enemy8_on = 1'b0;
				enemy9_on = 1'b0;
				enemy10_on = 1'b0;
				enemy11_on = 1'b0;
				enemy12_on = 1'b0;
		end
			
		else if	(e8 && 	(DrawX >= e8X) && (DrawX < e8X + 30) &&
			(DrawY >= e8Y) && (DrawY < e8Y + 30)	)
		begin
				enemy1_on  = 1'b0;
				enemy2_on = 1'b0;
				enemy3_on = 1'b0;
				enemy4_on = 1'b0;
				enemy5_on = 1'b0;
				enemy6_on = 1'b0;
				enemy7_on = 1'b0;
				enemy8_on = 1'b1;
				enemy9_on = 1'b0;
				enemy10_on = 1'b0;
				enemy11_on = 1'b0;
				enemy12_on = 1'b0;
		end
			
		else if	(e9 && 	(DrawX >= e9X) && (DrawX < e9X + 30) &&
			(DrawY >= e9Y) && (DrawY < e9Y + 30)	)
		begin
				enemy1_on  = 1'b0;
				enemy2_on = 1'b0;
				enemy3_on = 1'b0;
				enemy4_on = 1'b0;
				enemy5_on = 1'b0;
				enemy6_on = 1'b0;
				enemy7_on = 1'b0;
				enemy8_on = 1'b0;
				enemy9_on = 1'b1;
				enemy10_on = 1'b0;
				enemy11_on = 1'b0;
				enemy12_on = 1'b0;
		end
			
		else if	(e10 && 	(DrawX >= e10X) && (DrawX < e10X + 30) &&
			(DrawY >= e10Y) && (DrawY < e10Y + 30)	)
		begin
				enemy1_on  = 1'b0;
				enemy2_on = 1'b0;
				enemy3_on = 1'b0;
				enemy4_on = 1'b0;
				enemy5_on = 1'b0;
				enemy6_on = 1'b0;
				enemy7_on = 1'b0;
				enemy8_on = 1'b0;
				enemy9_on = 1'b0;
				enemy10_on = 1'b1;
				enemy11_on = 1'b0;
				enemy12_on = 1'b0;
		end
			
		else if	(e11 && 	(DrawX >= e11X) && (DrawX < e11X + 30) &&
			(DrawY >= e11Y) && (DrawY < e11Y + 30)	)
		begin
				enemy1_on  = 1'b0;
				enemy2_on = 1'b0;
				enemy3_on = 1'b0;
				enemy4_on = 1'b0;
				enemy5_on = 1'b0;
				enemy6_on = 1'b0;
				enemy7_on = 1'b0;
				enemy8_on = 1'b0;
				enemy9_on = 1'b0;
				enemy10_on = 1'b0;
				enemy11_on = 1'b1;
				enemy12_on = 1'b0;
		end
			
		else if	(e12 && 	(DrawX >= e12X) && (DrawX < e12X + 30) &&
			(DrawY >= e12Y) && (DrawY < e12Y + 30)	)
		begin
				enemy1_on  = 1'b0;
				enemy2_on = 1'b0;
				enemy3_on = 1'b0;
				enemy4_on = 1'b0;
				enemy5_on = 1'b0;
				enemy6_on = 1'b0;
				enemy7_on = 1'b0;
				enemy8_on = 1'b0;
				enemy9_on = 1'b0;
				enemy10_on = 1'b0;
				enemy11_on = 1'b0;
				enemy12_on = 1'b1;
		end
		else 
		begin
				enemy1_on  = 1'b0;
				enemy2_on = 1'b0;
				enemy3_on = 1'b0;
				enemy4_on = 1'b0;
				enemy5_on = 1'b0;
				enemy6_on = 1'b0;
				enemy7_on = 1'b0;
				enemy8_on = 1'b0;
				enemy9_on = 1'b0;
				enemy10_on = 1'b0;
				enemy11_on = 1'b0;
				enemy12_on = 1'b0;
		end
   end 
assign enemy_on = enemy1_on | enemy2_on | enemy3_on | enemy4_on | enemy5_on | enemy6_on | enemy7_on | enemy8_on | enemy9_on | enemy10_on | enemy11_on | enemy12_on;
	
always_comb
		begin
			if(
            (beam_exists && (DrawX <= (beamX + beam_size) && DrawX >= (beamX - beam_size)) &&
            (DrawY >= beamY) && DrawY < 500)
            )
            beam_on = 1'b1;
        else
            beam_on = 1'b0;
	  end
	  
////boss
 always_comb
    begin:boss_on_proc
		if (Boss_exists && (DrawX >= BossX) && (DrawX < BossX + Boss_width) &&
			(DrawY >= BossY) && (DrawY < BossY + Boss_height))
			Boss_on = 1'b1;
		else
			Boss_on = 1'b0;
end
	  
	  

//enemy shooter

	always_comb
	begin
		if	(es1 &&	(DrawX >= es1X) && (DrawX < es1X + spaceship_width) &&
			(DrawY >= es1Y) && (DrawY < es1Y + spaceship_height)	)
		begin
			enemys1_on = 1'b1;
			enemys2_on = 1'b0;
			enemys3_on = 1'b0;
			enemys4_on = 1'b0;
		end
			
		else if	(es2 &&	(DrawX >= es2X) && (DrawX < es2X + spaceship_width) &&
			(DrawY >= es2Y) && (DrawY < es2Y + spaceship_height)	)
		begin
			enemys1_on = 1'b0;
			enemys2_on = 1'b1;
			enemys3_on = 1'b0;
			enemys4_on = 1'b0;
		end
		
		else if	(es3 &&	(DrawX >= es3X) && (DrawX < es3X + spaceship_width) &&
			(DrawY >= es3Y) && (DrawY < es3Y + spaceship_height)	) 
		begin
			enemys1_on = 1'b0;
			enemys2_on = 1'b0;
			enemys3_on = 1'b1;
			enemys4_on = 1'b0;
		end
		
		else if (es4 &&	(DrawX >= es4X) && (DrawX < es4X + spaceship_width) &&
			(DrawY >= es4Y) && (DrawY < es4Y + spaceship_height)	)
		begin
			enemys1_on = 1'b0;
			enemys2_on = 1'b0;
			enemys3_on = 1'b0;
			enemys4_on = 1'b1;
		end
		else
		begin
			enemys1_on = 1'b0;
			enemys2_on = 1'b0;
			enemys3_on = 1'b0;
			enemys4_on = 1'b0;
		end

		//enemy laser
		if	(  (EL1 && (	(DrawX >= EL1X) && (DrawX < EL1X + laser_width) &&
				(DrawY >= EL1Y) && (DrawY < EL1Y + laser_height)	)	)	||
				(EL3 && (	(DrawX >= EL3X) && (DrawX < EL3X + laser_width) &&
				(DrawY >= EL3Y) && (DrawY < EL3Y + laser_height)	)	) 	||
				(EL2 && (	(DrawX >= EL2X) && (DrawX < EL2X + laser_width) &&
				(DrawY >= EL2Y) && (DrawY < EL2Y + laser_height)	)	)	||
				(EL4 && (	(DrawX >= EL4X) && (DrawX < EL4X + laser_width) &&
				(DrawY >= EL4Y) && (DrawY < EL4Y + laser_height)	)	)
			)
			enemy_laser_on = 1'b1;
		else	
			enemy_laser_on = 1'b0;

//difficulty block
		if	(!difficulty_selected && ( 
			(DrawX >= E_blockX) && (DrawX < E_blockX + block_width) &&
			(DrawY >= E_blockY) && (DrawY < E_blockY + block_height)	) )
			E_block_on = 1'b1;
		else
			E_block_on = 1'b0;
			
		if	(!difficulty_selected && ( 
			(DrawX >= N_blockX) && (DrawX < N_blockX + block_width) &&
			(DrawY >= N_blockY) && (DrawY < N_blockY + block_height)	) )
			N_block_on = 1'b1;
		else
			N_block_on = 1'b0;
			
		if	(!difficulty_selected && ( 
			(DrawX >= H_blockX) && (DrawX < H_blockX + block_width) &&
			(DrawY >= H_blockY) && (DrawY < H_blockY + block_height)	) )
			H_block_on = 1'b1;
		else
			H_block_on = 1'b0;
	end
		
assign enemy_shooter_on = enemys1_on | enemys2_on | enemys3_on | enemys4_on;
assign draw_explosion = (enemy1_on & explosion1) | (enemy2_on & explosion2) | (enemy3_on & explosion3) | (enemy4_on & explosion4) | (enemy5_on & explosion5) | (enemy6_on & explosion6) | (enemy7_on & explosion7) | (enemy8_on & explosion8) | (enemy9_on & explosion9) | (enemy10_on & explosion10) | (enemy11_on & explosion11) | (enemy12_on & explosion12) |
								(enemys1_on & explosions1) | (enemys2_on & explosions2) | (enemys3_on & explosions3) | (enemys4_on & explosions4) |
								(enemyf1_on & explosionf1) | (enemyf2_on & explosionf2) | (enemyf3_on & explosionf3);
	  
///////////draw power up ////////////////// PowerupX, PowerupY specify top left corner
always_comb  ///////////////////
begin:Powerup_on_proc  /////////////////////
	if ((DrawX >= PowerupX) && (DrawX <= (Powerupwidth + PowerupX))
	     && (DrawY >= PowerupY) && (DrawY <= (PowerupY + Powerupheight)))
		  Powerup_on = 1'b1;
	else
		  Powerup_on = 1'b0;
	 
end  
	  
	  
	  
	  
 ///////////////output RGB values      
    always_comb
    begin:RGB_Display
		if(lose_game || beat_Boss) //display lose_game/win_game screen
		begin
			Red = vram_r; 
         Green = vram_g;
         Blue = vram_b;
		end
			
		else
	   begin	
			if(E_block_on == 1'b1)
         begin
            Red = 4'h0;
            Green = 4'hf;
            Blue = 4'h0;
         end

         else if(N_block_on == 1'b1)
         begin
            Red = 4'h0;
            Green = 4'h0;
            Blue = 4'hf;
         end

         else if(H_block_on == 1'b1)
         begin
            Red = 4'hf;
            Green = 4'h0;
            Blue = 4'h0;
         end
			else if (Boss_on == 1'b1)
			begin
				if (boss_ram_red == 8'hff && boss_ram_green == 8'hc0 && boss_ram_blue == 8'hcb)
				begin
					Red = vram_r; 
					Green = vram_g;
					Blue = vram_b;
				end
				else
				begin
					Red = boss_ram_red[7:4];
					Green = boss_ram_green[7:4];
					Blue = boss_ram_blue[7:4];
				end
			end
			else if (beam_on == 1'b1 && beam_size < 3)
         begin
                Red = 8'hff;
                Green = 8'hff;
                Blue = 8'hff;
            end
         else if (beam_on == 1'b1)
         begin
                Red = 8'hff;
                Green = 8'h00;
                Blue = 8'h00;
         end
			else if(Powerup_on == 1'b1)
			begin
				Red = powerup_red;
				Green = powerup_green;
				Blue = powerup_blue;
			end
			else if ((Spaceship_on == 1'b1)) //spaceship takes precedence
			begin 
				if (ship_ram_red == 8'hff && ship_ram_green == 8'hc0 && ship_ram_blue == 8'hcb)
				begin
					Red = vram_r; 
					Green = vram_g;
					Blue = vram_b;
				end
				else
				begin
					Red = ship_ram_red[7:4];
					Green = ship_ram_green[7:4];
					Blue = ship_ram_blue[7:4];
				end
			end 
			else if(Laser_on == 1'b1)
			begin
				Red = spaceship_red;
				Green = spaceship_green;
				Blue = spaceship_blue;
				/*
				Red = 4'hf;
				Green = 4'h0;
				Blue = 4'h0;*/
			end
			else if(enemy_on == 1'b1)
			begin
				if(draw_explosion)
				begin
					if (explosion_ram_red == 8'hff && explosion_ram_green == 8'hc0 && explosion_ram_blue == 8'hcb)
					begin
						Red = vram_r; 
						Green = vram_g;
						Blue = vram_b;
					end
					else
					begin
						Red = explosion_ram_red[7:4];
						Green = explosion_ram_green[7:4];
						Blue = explosion_ram_blue[7:4];
					end
				end
				
				else
				begin
					if (enemy_ram_red == 8'hff && enemy_ram_green == 8'hc0 && enemy_ram_blue == 8'hcb)
					begin
						Red = vram_r; 
						Green = vram_g;
						Blue = vram_b;
					end
					else
					begin
						Red = enemy_ram_red[7:4];
						Green = enemy_ram_green[7:4];
						Blue = enemy_ram_blue[7:4];
					end
				end
			end
			else if(Lives_on == 1'b1)
			begin
				Red = Lives_R;
				Green = Lives_G; 
				Blue = Lives_B;
			end
			else if(Score_on == 1'b1)
			begin
				Red = 4'hf;
				Green = 4'hf; 
				Blue = 4'hf;
			end
			else if (enemy_laser_on == 1'b1)
         begin
            Red = 4'h0;
            Green = 4'hf;
            Blue = 4'h0;
            end
			else if(enemy_shooter_on == 1'b1)
         begin
				if(draw_explosion)
				begin
					if (explosion_ram_red == 8'hff && explosion_ram_green == 8'hc0 && explosion_ram_blue == 8'hcb)
					begin
						Red = vram_r; 
						Green = vram_g;
						Blue = vram_b;
					end
					else
					begin
						Red = explosion_ram_red[7:4];
						Green = explosion_ram_green[7:4];
						Blue = explosion_ram_blue[7:4];
					end
				end
				
				else
				begin
					if (enemy_shooter_ram_red == 8'hff && enemy_shooter_ram_green == 8'hc0 && enemy_shooter_ram_blue == 8'hcb)
					begin
					Red = vram_r; 
					Green = vram_g;
					Blue = vram_b;
					end
					else
					begin
						Red = enemy_shooter_ram_red[7:4];
						Green = enemy_shooter_ram_green[7:4];
						Blue = enemy_shooter_ram_blue[7:4];
					end
				end
			end
			else if(enemy_flyer_on == 1'b1)
         begin 
				if(draw_explosion)
				begin
					if (explosion_ram_red == 8'hff && explosion_ram_green == 8'hc0 && explosion_ram_blue == 8'hcb)
					begin
						Red = vram_r; 
						Green = vram_g;
						Blue = vram_b;
					end
					else
					begin
						Red = explosion_ram_red[7:4];
						Green = explosion_ram_green[7:4];
						Blue = explosion_ram_blue[7:4];
					end
				end
				else
				begin
					if (enemy_flyer_ram_red == 8'hff && enemy_flyer_ram_green == 8'hc0 && enemy_flyer_ram_blue == 8'hcb)
					begin
						Red = vram_r; 
						Green = vram_g;
						Blue = vram_b;
					end
					else
					begin
						Red = enemy_flyer_ram_red[7:4];
						Green = enemy_flyer_ram_green[7:4];
						Blue = enemy_flyer_ram_blue[7:4];
					end
				end
			end
			else 
			begin 
            Red = vram_r; 
            Green = vram_g;
            Blue = vram_b;
			end 
		end
	end 	  
	  
   
endmodule
