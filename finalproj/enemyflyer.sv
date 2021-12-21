module enemyflyer(input Reset, frame_clk, spawn, 
					input [2:0] difficulty,
					input [9:0] laser_width, laser_height,
					input [9:0] PX1, PX2, PX3, PX4, PY1, PY2, PY3, PY4,
					input PL1, PL2, PL3, PL4,
					input logic [9:0] PSX, PSY,
					input logic [1:0] flyer_num,
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
	logic erase, spaceship_exists;
	logic [9:0] Spaceship_X_motion, Spaceship_Y_motion, Spaceship_Y_pos, Spaceship_X_pos, X_dif, Y_dif;
	logic [9:0] Spaceship_Size = 30;
	logic [3:0] explosion_timer;
	
	logic [9:0] Spaceship_Y_start;
	logic [2:0] health, speed;
	logic follow;
					
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
				
				if(explosion)
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
				
				else
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
					
					if(follow == 0)//has not reached middle yet
					begin
						if(Spaceship_Y_pos > 160)
							follow <= 1;
					end
					else if (follow == 1)
					begin
						if( (Spaceship_X_pos < (PSX + 5)) && (Spaceship_X_pos > (PSX - 5)))//range so not as much stuttering
							Spaceship_X_motion <= 0;
						else if(Spaceship_X_pos > PSX)
							Spaceship_X_motion <= ~speed;
						else// if (Spaceship_X_pos < PSX)
							Spaceship_X_motion <= speed;
						
						if( (Spaceship_Y_pos < (PSY + 5)) && (Spaceship_Y_pos > (PSY - 5)))//range so not as much stuttering
							Spaceship_Y_motion <= 0;
						if(Spaceship_Y_pos > PSY)
							Spaceship_Y_motion <= ~speed;
						else// if(Spaceship_Y_pos < PSY)
							Spaceship_Y_motion <= speed;
					end
					
					Spaceship_X_pos <= Spaceship_X_pos + Spaceship_X_motion;
					Spaceship_Y_pos <= Spaceship_Y_pos + Spaceship_Y_motion;
				end
			end
			
			else if(spawn)	
			begin
				spaceship_exists <= 1;
				health <= 4;
				Spaceship_Y_motion <= 1;
				Spaceship_Y_pos = 2;
				Spaceship_X_motion <= 0;
				follow <= 0;
				explosion <= 0;
				erase <= 0;
				explosion_timer <= 4'b1111;
				case (flyer_num)
					2'b00	:	Spaceship_X_pos <= 148;
					2'b01	:	Spaceship_X_pos <= 315;
					2'b10	:	Spaceship_X_pos <= 481;
					default:;
				endcase
			end
			
			else if(erase) //reset hit signal
			begin
				hit1 <= 0;
				hit2 <= 0;
				hit3 <= 0;
				hit4 <= 0;
				hitship <= 0;
				erase <= 0;
				explosion <= 0;
				Spaceship_X_pos <= 639;
				Spaceship_Y_pos <= 0;
				Spaceship_X_motion <= 0;
				Spaceship_Y_motion <= 0;
			end
		end
   end  
	 
	always_comb
	begin
		//easy is slower than normal and hard
		if(difficulty == 3'b100)
			speed = 1;	//2 is way too hard all will just be 1
		else
			speed = 1;
			
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
