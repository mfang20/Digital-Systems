module power_up(	input Reset, frame_clk, generate_powerup,
					input [9:0] ShipX, ShipY, ShipS, powerup_startpos,
					output logic got_powerup, powerup_exists,
					output logic [9:0] PowerupX, PowerupY, Powerupwidth, Powerupheight
					);

assign Powerupwidth = 7;
assign Powerupheight = 7;


logic [9:0] Powerup_Y_motion, Powerup_X_motion;
	parameter Powerup_X_Offscreen = 679;
	parameter Powerup_Y_Offscreen = 0;
	parameter playership_width = 30;
	parameter playership_height = 30;


always_ff @ (posedge Reset or posedge frame_clk )
begin: Move_Powerup
		if (Reset)  // if reset, don't want it on screen
		begin 
			Powerup_Y_motion <= 10'd0; //Ball_Y_Step;
			Powerup_X_motion <= 10'd0; //Ball_X_Step;
			PowerupY <= Powerup_Y_Offscreen;
			PowerupX <= Powerup_X_Offscreen;
			powerup_exists<=0;
		end
		
		else
		begin
			if(powerup_exists)
			begin
				//////collides with ship
				if( (PowerupX >= ShipX) && (PowerupX + Powerupwidth <= ShipX + playership_width) && 
						(PowerupY >= ShipY) && (PowerupY + Powerupheight <= ShipY + playership_height)
					)
				begin	
					got_powerup <= 1;
					powerup_exists <= 0;
					PowerupY <= Powerup_Y_Offscreen;
					PowerupX <= Powerup_X_Offscreen;
				end    
				//////below bottom of screen
			   else if (PowerupY >= 476)  ////////orig. else if
				begin
					powerup_exists <=0;
					got_powerup <=0;
					PowerupY <= Powerup_Y_Offscreen;
					PowerupX <= Powerup_X_Offscreen;

				end
				/////else move down
				else
				begin
					Powerup_Y_motion <= 2;
					PowerupY <= (PowerupY + Powerup_Y_motion);
					got_powerup <=0;
				end
			end
			////else set position to spawn
			else if (generate_powerup)
			begin
				PowerupX <= powerup_startpos;
				PowerupY <= 5;
				powerup_exists <= 1;
				got_powerup <=0;
			end
			////else make sure power_up is offscreen
			else
			begin
				PowerupX <= Powerup_X_Offscreen;
				PowerupY <= Powerup_Y_Offscreen;
				got_powerup <=0;
				
			end
		end
end 

endmodule			
					
					
