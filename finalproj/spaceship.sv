module  spaceship ( input Reset, frame_clk, hit, speedup, powerup, invincible, doublescore,
					input [7:0] keycode, keycode2, keycode3,
               output logic [9:0]  SpaceshipX, SpaceshipY, SpaceshipS,
					output logic shoot, lose_life,
					output logic [7:0] spaceship_red, spaceship_green, spaceship_blue
					);
    
    logic [9:0] Spaceship_X_Pos, Spaceship_X_Motion, Spaceship_Y_Pos, Spaceship_Y_Motion, Spaceship_Size;
	 logic [27:0] timer;
	 logic [3:0] shoot_timer;
	 logic [7:0] hit_timer;
	 logic [3:0] hit_hold;
	 logic [8:0] speed_timer, invincible_timer, doublescore_timer;
	 logic [9:0] speed;
	 logic immune;
	 //assign cm_check_lose_life = lose_life;
	 
    parameter [9:0] Spaceship_X_Center=305;  // Center position on the X axis
    parameter [9:0] Spaceship_Y_Center=320;  // Center position on the Y axis
    parameter [9:0] Spaceship_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Spaceship_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Spaceship_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Spaceship_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Slow_step = 1;
	 parameter [9:0] Step=3;      // Step size
	 parameter [9:0] Fast_step=6;
    assign Spaceship_Size = 30;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
    
	//set speed to vary based on powerup
	always_ff @ (posedge Reset or posedge frame_clk )
	begin
		if (Reset)
		begin
			speed_timer <= 0;
			invincible_timer <= 0;
			doublescore_timer <= 0;
			spaceship_red <= 8'hff;
			spaceship_green <= 8'h00;
			spaceship_blue <= 8'h00;
			immune <= 0;
		end
		else if (powerup && speedup)
		begin
			speed_timer <= 9'b111111111;
			invincible_timer <= 0;
			doublescore_timer <= 0;
			speed <= Fast_step;
			spaceship_red <= 8'h00;
			spaceship_green <= 8'h00;
			spaceship_blue <= 8'hff;
		end
		else if (powerup && invincible)
		begin
			speed_timer <= 0;
			invincible_timer <= 9'b111111111;
			doublescore_timer <= 0;
			speed <= Slow_step;
			spaceship_red <= 8'h00;
			spaceship_green <= 8'hff;
			spaceship_blue <= 8'h00;
			immune <= 1;
		end
		else if (powerup && doublescore)
		begin
			speed_timer <= 0;
			invincible_timer <= 0;
			doublescore_timer <= 9'b111111111;
			spaceship_red <= 8'hff;
			spaceship_green <= 8'hff;
			spaceship_blue <= 8'h00;
		end
		else if (speed_timer !=0) 
		begin
			speed <= Fast_step;
			speed_timer <= speed_timer -1;
			spaceship_red <= 8'h00;
			spaceship_green <= 8'h00;
			spaceship_blue <= 8'hff;
		end
		else if (invincible_timer !=0) 
		begin
			speed <= Slow_step;
			invincible_timer <= invincible_timer -1;
			spaceship_red <= 8'h00;
			spaceship_green <= 8'hff;
			spaceship_blue <= 8'h00;
			immune <= 1;
		end
		else if(doublescore_timer != 0)
		begin
			doublescore_timer <= doublescore_timer - 1;
			speed <= Step;
			spaceship_red <= 8'hff;
			spaceship_green <= 8'hff;
			spaceship_blue <= 8'h00;	
		end
		else
		begin
			speed <= Step;
			spaceship_red <= 8'hff;
			spaceship_green <= 8'h00;
			spaceship_blue <= 8'h00;
			immune <= 0;
		end
	end
	
	
	always_ff @ (posedge Reset or posedge frame_clk )
	begin: Move_Spaceship
		if (Reset)  // Asynchronous Reset
		begin 
			Spaceship_Y_Motion <= 10'd0; //Ball_Y_Step;
			Spaceship_X_Motion <= 10'd0; //Ball_X_Step;
			Spaceship_Y_Pos <= Spaceship_Y_Center;
			Spaceship_X_Pos <= Spaceship_X_Center;
			hit_timer <= 8'b0;
		end
        
		else
		begin
			//case (keycode)
			if(keycode == 8'h04 ||keycode == 8'h07 || keycode2 == 8'h04 ||keycode2 == 8'h07 || keycode3 == 8'h04 ||keycode3 == 8'h07)
			begin
				if(keycode == 8'h04 || keycode2 == 8'h04 || keycode3 == 8'h04) //a
				begin
					if( (Spaceship_X_Pos - Spaceship_Size) <= Spaceship_X_Min + 12) //edge case 
					begin
						Spaceship_X_Motion <= 0;
					end
					else
					begin
						Spaceship_X_Motion <= -(speed);
					end
				end
				else if (keycode == 8'h07 || keycode2 == 8'h07 || keycode3 == 8'h07) //d
				begin
					if( (Spaceship_X_Pos + Spaceship_Size) >= Spaceship_X_Max - 12)	//edge case
					begin
						Spaceship_X_Motion <= 0;
					end
					else
					begin
						Spaceship_X_Motion <= speed;
					end
				end
			end
			else	//no x motion if a or d not pressed
			begin
				Spaceship_X_Motion <= 0;
			end
			
			if(keycode == 8'h16 ||keycode == 8'h1A || keycode2 == 8'h16 ||keycode2 == 8'h1A || keycode3 == 8'h16 ||keycode3 == 8'h1A)	//this should allow for non exclusive x y motion
			begin
				if(keycode == 8'h16 || keycode2 == 8'h16 || keycode3 == 8'h16) //s
				begin
					if ( (Spaceship_Y_Pos + Spaceship_Size) >= Spaceship_Y_Max - 12 )	//edge case
					begin
						Spaceship_Y_Motion <= 0;
					end
					else 
					begin
						Spaceship_Y_Motion <= speed;
					end
				end
				else if(keycode == 8'h1A || keycode2 == 8'h1A || keycode3 == 8'h1A) //w
				begin
					if ( (Spaceship_Y_Pos - Spaceship_Size) <= Spaceship_Y_Min + 12)	//edge case
					begin
						Spaceship_Y_Motion <= 0;
					end
					else
					begin
						Spaceship_Y_Motion <= -(speed);
					end
				end
			end
			else	//no y motion if s or w not pressed
			begin
				Spaceship_Y_Motion <= 0;
			end
						
			if((keycode == 8'h2C || keycode2 == 8'h2C || keycode3 == 8'h2C) && shoot_timer==0)
			begin
				shoot <= 1'b1;
				shoot_timer <= 4'b1111;
			end
			else if (shoot_timer !=0)
			begin
				shoot <= 1'b0;
				shoot_timer <= shoot_timer-1;
			end
			
			
			
			if((hit && hit_timer == 0 && immune == 1'b0))	//creates a pseduo invincibility state
			begin
				lose_life <= 1;
				hit_timer <= 8'b00111111;
			end
			else if(hit_timer != 0 || immune == 1'b1)
			begin
				lose_life <= 0;
				hit_timer <= hit_timer - 1;
			end
		
			
			Spaceship_Y_Pos <= (Spaceship_Y_Pos + Spaceship_Y_Motion);  // Update ship position could be pot problem
			Spaceship_X_Pos <= (Spaceship_X_Pos + Spaceship_X_Motion);
			
		end
	end
       
		 
	assign SpaceshipX = Spaceship_X_Pos;
   assign SpaceshipY = Spaceship_Y_Pos;
   assign SpaceshipS = Spaceship_Size;
    

endmodule
