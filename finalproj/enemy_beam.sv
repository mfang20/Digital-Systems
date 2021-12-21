module enemy_beam(input Reset, frame_clk,
						input [1:0] LFSR_position,
						input [2:0] difficulty,
						input [9:0] PSX, PSY,
						input [9:0] bsX, bsY,
						input boss_exists,
						output [9:0] beamX, beamY,
						output [4:0] beam_size,
						output logic beam_exists,
						output Phit
						);

	logic [9:0] beam_X_pos, beam_Y_pos, Xoffset;
	logic [9:0] beam_cooldown;
	logic [6:0] beam_timer;
	logic shoot;
	
	parameter [9:0] playership_width = 30;
	parameter [9:0] playership_height = 30;
		
	always_ff @ (posedge Reset or posedge frame_clk)
	begin
		if(Reset)
		begin	//remove laser from screen
			beam_exists <= 0;
			beam_X_pos <= 10'b0;
			beam_Y_pos <= 10'b0;	
			beam_cooldown <= 10'b0000111111;
		end
		
		else
		begin	
			beam_Y_pos <= bsY + 100;
			
			if(boss_exists && beam_cooldown == 0 && !beam_exists)
			begin
				shoot <= 1;
				case(difficulty)
					3'b001	:	beam_cooldown <= 10'b0111111111;
					3'b010	:	beam_cooldown <= 10'b0011111111;
					3'b100	:	beam_cooldown <= 10'b0000111111;
				endcase
			end
			else
				shoot <= 0;
				
			if(beam_cooldown != 0)
				beam_cooldown <= beam_cooldown - 1;
				
			if(shoot) //create a beam
			begin	
				beam_exists <= 1;
				beam_timer <= 6'b111111;
				beam_size <= 1;
				case(LFSR_position)
				2'b00	:	
					begin
						Xoffset <=  40; 	//change these values to match later
						beam_X_pos <= bsX + 40;
					end
				2'b01 :	
					begin
						Xoffset <= 90;
						beam_X_pos <= bsX + 90;
					end
				2'b10 :
					begin
						Xoffset <= 140;
						beam_X_pos <= bsX + 140;
					end
				2'b11 :
					begin
						Xoffset <=	190;
						beam_X_pos <= bsX + 190;
					end
				endcase
			end	
				
			else if(beam_exists == 1'b1)
			begin	
				beam_X_pos <= bsX + Xoffset;
				//collision with player logic	
				if( beam_size > 3 && 
					 ((PSX <= (beam_X_pos + beam_size) && PSX >= (beam_X_pos - beam_size)) ||
					 ((PSX + playership_width) <= (beam_X_pos + beam_size) && (PSX + playership_width) >= (beam_X_pos - beam_size)) &&
					 (PSY >= beam_Y_pos))
					 )
				begin	
					Phit <= 1;
				end
				else
					Phit <= 0;
				
				//beam increases in size
				if(beam_size <= 10 && beam_timer == 0)
				begin
					beam_size <= beam_size + 1;
					if(beam_size == 10)
						beam_timer <= 6'b111111;
					else
						beam_timer <= 6'b000011;
				end
				else if(beam_size >= 10 && beam_timer == 0)
				begin
					beam_exists <= 0;
					beam_size <= 0;
				end
				else if(beam_timer > 0)
					beam_timer <= beam_timer - 1;
			end
			else
			begin
				Phit <= 0;
			end
		end
	end
	
	assign beamX = beam_X_pos;
	assign beamY = beam_Y_pos;

endmodule
					