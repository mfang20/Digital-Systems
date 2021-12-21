module enemy(	input Reset, frame_clk, spawn, flydown,
					input [2:0] difficulty,
					input [9:0] laser_width, laser_height,
					input [2:0] row,
					input [9:0] PX1, PX2, PX3, PX4, PY1, PY2, PY3, PY4,
					input PL1, PL2, PL3, PL4,
					input rand_side,
					input logic [9:0] PSX, PSY,
               output logic [9:0]  SpaceshipX, SpaceshipY, SpaceshipS,
					output logic SpaceshipE,
					output logic h1, h2, h3, h4, hs,
					output logic explosion
					);
					
	parameter [9:0] Spaceship_width = 30; //can be changed
	parameter [9:0] Spaceship_height = 30;
	parameter [9:0] playership_width = 30;
	parameter [9:0] playership_height = 30;
	
	parameter [9:0] screen_x_min = 0;
	parameter [9:0] screen_x_max = 639;
	parameter [9:0] screen_y_min = 0;
	parameter [9:0] screen_y_max = 479;
	
	logic hit1, hit2, hit3, hit4, hitship;	//internal logic
	logic erase, spaceship_exists, descent;
	logic [9:0] Spaceship_X_motion, Spaceship_Y_motion, Spaceship_Y_pos, Spaceship_X_pos;
	logic [9:0] Spaceship_Size = 30;
	logic [3:0] explosion_timer ;
	
	logic [9:0] Spaceship_Y_start;
	logic [2:0] health;
					
	always_ff @ (posedge Reset or posedge frame_clk )
	begin: Move_Spaceship
		if (Reset)  // Asynchronous Reset
		begin 
			spaceship_exists <= 0;	
			Spaceship_X_pos <= 639;
			Spaceship_Y_pos <= 0;
			Spaceship_X_motion <= 0;
			Spaceship_Y_motion <= 0;
			erase <= 0;
			hit1 <= 0;
			hit2 <= 0;
			hit3 <= 0;
			hit4 <= 0;
			hitship <= 0;
			descent <= 0;
			explosion <= 0;
			explosion_timer <= 4'b1111;
		end
		
		else
		begin
			//the order and embedded if order matters so that I'm, not assigning two things with <= in the same clk cycle
			if(spaceship_exists)  //collision detection
			begin
				if( ((SpaceshipX <= PSX && (SpaceshipX + Spaceship_width) >= PSX)	||
					(SpaceshipX <= (PSX + playership_width) && (SpaceshipX + Spaceship_width) >= (PSX + playership_width)) ) &&
					((SpaceshipY <= PSY && (SpaceshipY + Spaceship_height) >= PSY) ||
					(SpaceshipY <= (PSY + playership_height) && (SpaceshipY + Spaceship_height) >= (PSY + playership_height)))
					)
				begin	
					hitship <= 1;
					explosion <= 1;
				end
				
				//collision with lasers
				if(PL1)
				begin	//player laser 1 exists
					if( ((SpaceshipX <= PX1 && (SpaceshipX + Spaceship_width) >= PX1)	||
						(SpaceshipX <= (PX1 + laser_width) && (SpaceshipX + Spaceship_width) >= (PX1 + laser_width)) ) &&
						((SpaceshipY <= PY1 && (SpaceshipY + Spaceship_height) >= PY1) ||
						(SpaceshipY <= (PY1 + laser_height) && (SpaceshipY + Spaceship_height) >= (PY1 + laser_height)))
						)
					begin	//collision with laser 1 occured
						hit1 <= 1;
					end
				end
				if(PL2)
				begin	//player laser 2 exists
					if( ((SpaceshipX <= PX2 && (SpaceshipX + Spaceship_width) >= PX2)	||
						(SpaceshipX <= (PX2 + laser_width) && (SpaceshipX + Spaceship_width) >= (PX2 + laser_width)) ) &&
						((SpaceshipY <= PY2 && (SpaceshipY + Spaceship_height) >= PY2) ||
						(SpaceshipY <= (PY2 + laser_height) && (SpaceshipY + Spaceship_height) >= (PY2 + laser_height)))
						)
					begin	//collision with laser 2 occured
						hit2 <= 1;
					end
				end
				if(PL3)
				begin	//player laser 3 exists
					if( ((SpaceshipX <= PX3 && (SpaceshipX + Spaceship_width) >= PX3)	||
						(SpaceshipX <= (PX3 + laser_width) && (SpaceshipX + Spaceship_width) >= (PX3 + laser_width)) ) &&
						((SpaceshipY <= PY3 && (SpaceshipY + Spaceship_height) >= PY3) ||
						(SpaceshipY <= (PY3 + laser_height) && (SpaceshipY + Spaceship_height) >= (PY3 + laser_height)))
						)
					begin	//collision with laser 3 occured
						hit3 <= 1;
					end
				end
				if(PL4)
				begin	//player laser 4 exists
					if( ((SpaceshipX <= PX4 && (SpaceshipX + Spaceship_width) >= PX4)	||
						(SpaceshipX <= (PX4 + laser_width) && (SpaceshipX + Spaceship_width) >= (PX4 + laser_width)) ) &&
						((SpaceshipY <= PY4 && (SpaceshipY + Spaceship_height) >= PY4) ||
						(SpaceshipY <= (PY4 + laser_height) && (SpaceshipY + Spaceship_height) >= (PY4 + laser_height)))
						)
					begin	//collision with laser 4 occured
						hit4 <= 1;
					end
				end
				
				if(explosion == 1)
				begin
					//draw explosion
					hit1 <= 0;
					hit2 <= 0;
					hit3 <= 0;
					hit4 <= 0;
					Spaceship_X_motion <= 0;
					Spaceship_Y_motion <= 0;
					if(explosion_timer == 0)
					begin
						spaceship_exists <= 0;
						erase <= 1;
						explosion <= 0;
					end
					else
						explosion_timer <= explosion_timer - 1;	
				end
		
				else if(explosion == 0)
				begin		
					//decrease hp control
					if(hit1 || hit2 || hit3 || hit4)
					begin
						hit1 <= 0;
						hit2 <= 0;
						hit3 <= 0;
						hit4 <= 0;
						if(difficulty[1] && health > 2)
							health <= health - 2;
						else if (difficulty[2] && health > 1)
							health <= health - 1;
						else 
						begin
							explosion <= 1;
						end
					end
						
					//flydown
					if(flydown)	
					begin
						Spaceship_Y_motion <= 2;
						descent <= 1;
					end
					if(SpaceshipY >= screen_y_max - 2)
					begin
							erase <= 1;
							spaceship_exists <= 0;
					end
					
					//default bouncing
					if(SpaceshipX <= screen_x_min + 5)	// left bounce
					begin 
						Spaceship_X_motion <= 2;
					end
					else if(	(SpaceshipX + Spaceship_width) >= screen_x_max) // right bounce
					begin
						Spaceship_X_motion <= -2;
					end
					
					if(descent == 0)
					begin
						if((SpaceshipY <= screen_y_min + 5) || (SpaceshipY <= (Spaceship_Y_start - Spaceship_height * 2)))	//down bounce
							Spaceship_Y_motion <= 2;
						else if(SpaceshipY >= Spaceship_Y_start + Spaceship_height * 2 + 3)	//up bounce
							Spaceship_Y_motion <= -2;
					end
					
					Spaceship_X_pos <= Spaceship_X_pos + Spaceship_X_motion;
					Spaceship_Y_pos <= Spaceship_Y_pos + Spaceship_Y_motion;
				end
			end
			
			else if(spawn)	
			begin
				hit1 <= 0;
				hit2 <= 0;
				hit3 <= 0;
				hit4 <= 0;
				spaceship_exists <= 1;
				Spaceship_Y_start <= Spaceship_height * (row + 2);	
				Spaceship_Y_pos <= Spaceship_Y_start;
				Spaceship_Y_motion <= 2;
				erase <= 0;
				health <= 4;
				descent <= 0;
				explosion <= 0;
				explosion_timer <= 4'b1111;
				if(rand_side==0) //odd start left
				begin
					Spaceship_X_pos <= 2;
					Spaceship_X_motion <= 2;
				end
				else	//even start right
				begin
					Spaceship_X_pos <= 608; 
					Spaceship_X_motion <= -2;
				end
			end
			
			else if(erase) //reset hit signal
			begin
				hit1 <= 0;
				hit2 <= 0;
				hit3 <= 0;
				hit4 <= 0;
				spaceship_exists <= 0;
				hitship <= 0;
				explosion <= 0;
				explosion_timer <= 4'b1111;
				Spaceship_X_pos <= 639;
				Spaceship_Y_pos <= 0;
				Spaceship_X_motion <= 0;
				Spaceship_Y_motion <= 0;
			end
		end
   end  
	 
	always_comb
	begin
		SpaceshipX = Spaceship_X_pos;
		SpaceshipY = Spaceship_Y_pos;
		SpaceshipS = Spaceship_Size;
		SpaceshipE = spaceship_exists;
	
		h1 = hit1;
		h2 = hit2;
		h3 = hit3;
		h4 = hit4;
		hs = hitship;
	end

endmodule
