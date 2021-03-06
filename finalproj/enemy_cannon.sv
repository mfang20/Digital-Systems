module enemy_cannon(	input Reset, frame_clk,
					input [5:0] LFSR,
					input [9:0] PSX, PSY,
					input [9:0] EX, EY,
					input prev_laser_exists,
					input [9:0] laser_width, laser_height,
					input enemy_alive,
					output [9:0] laserX, laserY,
					output logic laserexists,
					output logic Phit
					);

	logic [9:0] laser_X_pos, laser_Y_pos, laser_size, ES;
	logic LFSR_shoot;
	
	parameter [9:0] laser_Y_max = 479;
	parameter [9:0] playership_width = 30;
	parameter [9:0] playership_height = 30;
	
	assign laser_size = 2;
	assign ES = 4;
		
	logic [2:0] test;
	always_ff @ (posedge Reset or posedge frame_clk)
	begin
		if(Reset)
		begin	//remove laser from screen
			laserexists <= 0;
			laser_X_pos <= 10'b0;
			laser_Y_pos <= 10'b0;	
		end
		
		else
		begin
			if(LFSR_shoot && !laserexists && prev_laser_exists && enemy_alive) //create a laser
			begin	
				laserexists <= 1;
				laser_Y_pos <= EY + 16;
				laser_X_pos <= EX + ES[9:1]; 
			end	

			else if ( (laser_Y_pos + laser_size) >= laser_Y_max - 7)
			begin	//remove laser from screen
				laserexists <= 0;
				laser_X_pos <= 10'b0;
				laser_Y_pos <= 10'b0;
			end
				
			else if(laserexists == 1'b1)
			begin	
				//laser moves downwards
				laser_X_pos <= laser_X_pos;	
				laser_Y_pos <= (laser_Y_pos + 6);
				//collision with player logic		
				if( ((PSX <= laser_X_pos && (PSX + playership_width) >= laser_X_pos)	||
					(PSX <= (laser_X_pos + laser_width) && (PSX + playership_width) >= (laser_X_pos + laser_width)) ) &&
					((PSY <= laser_Y_pos && (PSY + playership_height) >= laser_Y_pos) ||
					(PSY <= (laser_Y_pos + laser_height) && (PSY + playership_height) >= (laser_Y_pos + laser_height)))
					)
				begin	
					Phit <= 1;
					laserexists <= 0;
				end
				else
					Phit <= 0;		
			end
			
			else
			begin
			Phit <=0;
			end
		
			if(LFSR != 0)
				LFSR_shoot <= 0;
			else
				LFSR_shoot <= 1;
		end
	end
	
	assign laserX = laser_X_pos;
	assign laserY = laser_Y_pos;

endmodule
				