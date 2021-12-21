module cannon(	input Reset, frame_clk, laser, laser_hit,  prevlaser_exists, shootfaster, powerup,
					input [9:0] ShipX, ShipY, ShipS,
					output logic [9:0] laserX, laserY,
					output logic laser_exists
					);
					
	logic [9:0] laser_x_pos, laser_y_pos, laser_size;
	logic [9:0] shoot_fast_timer;
	logic [9:0] laserS;
	
	parameter [8:0] laser_y_min=0;
	
	assign laser_size = 2;
	assign laserX = laser_x_pos;
	assign laserY = laser_y_pos;
	assign laserS = laser_size;
					
	always_ff @ (posedge Reset or posedge frame_clk)
	begin
		if (Reset)
		begin	//remove laser from screen
		laser_exists <= 1'b0;
		laser_x_pos <= 10'b0;
		laser_y_pos <= 10'b0;
		shoot_fast_timer = 9'b0;
		end
		
		else if (powerup && shootfaster)
		begin
		shoot_fast_timer = 9'b111111111;
		end
		
		
		else if (laser_hit)
		begin	//remove laser from screen
		laser_exists <= 1'b0;
		laser_x_pos <= 10'b0;
		laser_y_pos <= 10'b0;
			if (shoot_fast_timer !=0)
			begin
			shoot_fast_timer = shoot_fast_timer  - 1;
			end
		end
		
		
		else if(laser & ~laser_exists & prevlaser_exists)
		begin	//creates a laser at x = (shipX + shipS/2) and y = shipy
		laser_exists <= 1'b1;
		laser_x_pos <= ShipX + ShipS[9:1];
		laser_y_pos <= ShipY;
			if (shoot_fast_timer !=0)
			begin
			shoot_fast_timer = shoot_fast_timer  - 1;
			end
		end
		
		else if ( (laser_y_pos - laser_size) <= laser_y_min + 11)
		begin	//remove laser from screen
		laser_exists <= 1'b0;
		laser_x_pos <= 10'b0;
		laser_y_pos <= 10'b0;
			if (shoot_fast_timer !=0)
			begin
			shoot_fast_timer = shoot_fast_timer  - 1;
			end
		end
		
		else if (laser_exists)
		begin	//laser moves upwards
			if (shoot_fast_timer != 0)
			begin
			laser_x_pos <= laser_x_pos;	
			laser_y_pos <= (laser_y_pos - 10);	
			shoot_fast_timer <= shoot_fast_timer -1;
			end
			
			else
			begin
			laser_x_pos <= laser_x_pos;	
			laser_y_pos <= (laser_y_pos - 5);	
			end
			
		end
	end
	
	
endmodule
					