module boss(	input Reset, frame_clk, spawn, flydown, rise, hold, back_and_forth,/////frh are controller signals
					input [2:0] difficulty,
					input [9:0] laser_width, laser_height,
					input [2:0] row,
					input [9:0] PX1, PX2, PX3, PX4, PY1, PY2, PY3, PY4,
					input PL1, PL2, PL3, PL4,
					input Boss_exists, 
					input logic [9:0] PSX, PSY,
               output logic [9:0]  BossX, BossY, Bosswidth, Bossheight,
					output logic h1, h2, h3, h4, hs, beat_Boss,
					output logic hit_top, hit_bottom
					);
					
	parameter [9:0] Boss_width = 250; //can be changed
	parameter [9:0] Boss_height = 111;
	parameter [9:0] playership_width = 30;
	parameter [9:0] playership_height = 30;
	
	parameter [9:0] screen_x_min = 0;
	parameter [9:0] screen_x_max = 639;
	parameter [9:0] screen_y_min = 0;
	parameter [9:0] screen_y_max = 479;
	
	logic hit1, hit2, hit3, hit4, hitship;
		//internal logic
	logic [9:0] Boss_X_motion, Boss_Y_motion, Boss_Y_pos, Boss_X_pos;
	logic [9:0] Spaceship_Size = 4;
	
	logic [9:0] Boss_Y_start, Boss_X_start;
	logic [9:0] health;
					
	always_ff @ (posedge Reset or posedge frame_clk )
	begin: Move_Boss
		if (Reset)  // Asynchronous Reset
		begin 
			Boss_X_pos <= 639;
			Boss_Y_pos <= 0;
			Boss_X_motion <= 0;
			Boss_Y_motion <= 0;
			hit1 <= 0;
			hit2 <= 0;
			hit3 <= 0;
			hit4 <= 0;
			hitship <= 0;
			beat_Boss <= 0;
			hit_bottom <= 0;
			hit_top <= 0;
		end
		
		else
		begin
			//the order and embedded if order matters so that I'm, not assigning two things with <= in the same clk cycle
			if(Boss_exists)  //collision detection
			begin
				if( ((BossX <= PSX && (BossX + Boss_width) >= PSX)	||
					(BossX <= (PSX + playership_width) && (BossX + Boss_width) >= (PSX + playership_width)) ) &&
					((BossY <= PSY && (BossY + Boss_height) >= PSY) ||
					(BossY <= (PSY + playership_height) && (BossY + Boss_height) >= (PSY + playership_height)))
					)
				begin	
					hitship <= 1;
				end
				else
				begin
					hitship <= 0;
				end
				
				//collision with lasers
				if(PL1)
				begin	//player laser 1 exists
					if( ((BossX <= PX1 && (BossX + Boss_width) >= PX1)	||
						(BossX <= (PX1 + laser_width) && (BossX + Boss_width) >= (PX1 + laser_width)) ) &&
						((BossY <= PY1 && (BossY + Boss_height) >= PY1) ||
						(BossY <= (PY1 + laser_height) && (BossY + Boss_height) >= (PY1 + laser_height)))
						)
					begin	//collision with laser 1 occured
						hit1 <= 1;
					end
				end
				if(PL2)
				begin	//player laser 2 exists
					if( ((BossX <= PX2 && (BossX + Boss_width) >= PX2)	||
						(BossX <= (PX2 + laser_width) && (BossX + Boss_width) >= (PX2 + laser_width)) ) &&
						((BossY <= PY2 && (BossY + Boss_height) >= PY2) ||
						(BossY <= (PY2 + laser_height) && (BossY + Boss_height) >= (PY2 + laser_height)))
						)
					begin	//collision with laser 2 occured
						hit2 <= 1;
					end
				end
				if(PL3)
				begin	//player laser 3 exists
					if( ((BossX <= PX3 && (BossX + Boss_width) >= PX3)	||
						(BossX <= (PX3 + laser_width) && (BossX + Boss_width) >= (PX3 + laser_width)) ) &&
						((BossY <= PY3 && (BossY + Boss_height) >= PY3) ||
						(BossY <= (PY3 + laser_height) && (BossY + Boss_height) >= (PY3 + laser_height)))
						)
					begin	//collision with laser 3 occured
						hit3 <= 1;
					end
				end
				if(PL4)
				begin	//player laser 4 exists
					if( ((BossX <= PX4 && (BossX + Boss_width) >= PX4)	||
						(BossX <= (PX4 + laser_width) && (BossX + Boss_width) >= (PX4 + laser_width)) ) &&
						((BossY <= PY4 && (BossY + Boss_height) >= PY4) ||
						(BossY <= (PY4 + laser_height) && (BossY + Boss_height) >= (PY4 + laser_height)))
						)
					begin	//collision with laser 4 occured
						hit4 <= 1;
					end
				end
		
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
					else if(health > 4)
					begin
						health <= health - 4;
					end
					
					else
						beat_Boss <=1;
				end
				
				
				//check all the states
				if(flydown)	
				begin
					Boss_X_motion <= 0;
					Boss_Y_motion <= 10;
					hit_top <=0;
			
					if(BossY >= screen_y_max - 100)	//bounce back up from flydown
					begin
						hit_bottom <= 1;
					end
				end
				
				else if (rise)
				begin
					Boss_X_motion <= 0;
					Boss_Y_motion <= -2;
					hit_bottom <=0;
			
					if(BossY <= screen_y_min + 12)	//stick at the top from rise
					begin
						hit_top <= 1;
					end
				end
				
				//default bouncing
				else if (hold)
				begin
					Boss_X_motion <=0;
					Boss_Y_motion <=0;
				end
				
				else if (back_and_forth)
				begin
				
					if(BossX <= screen_x_min + 5)	// left bounce
					begin 
						Boss_X_motion <= 2;
					end
					else if(	(BossX + Boss_width) >= screen_x_max) // right bounce
					begin
						Boss_X_motion <= -2;
					end
					else
					begin
						if (Boss_X_motion == 0)
							Boss_X_motion <= 2;
					end
				end
				
				
				
				Boss_X_pos <= Boss_X_pos + Boss_X_motion;
				Boss_Y_pos <= Boss_Y_pos + Boss_Y_motion;
			end
			
			else if(spawn)	
			begin
				Boss_Y_start <= 10;	
				Boss_Y_pos <= Boss_Y_start;
				Boss_X_start <= 270;
				Boss_X_pos <= Boss_X_start;
				health <= 200;
			end
		end
   end  
	 
	always_comb
	begin
		BossX = Boss_X_pos;
		BossY = Boss_Y_pos;
		Bosswidth = Boss_width;
		Bossheight = Boss_height;
		h1 = hit1;
		h2 = hit2;
		h3 = hit3;
		h4 = hit4;
		hs = hitship;
	end

endmodule
