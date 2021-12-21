module LFSR(	input Reset, frame_clk,
					output logic [5:0] enemy_shoot1, enemy_shoot2, enemy_shoot3, enemy_shoot4,
					output logic [8:0] LFSR_powerup_pos, LFSR_powerup_timer,
					output logic [1:0] LFSR_powerup_type
					);
	//this module is purely used as a random number generator
	
	logic [7:0] LFSR1, LFSR2, LFSR3, LFSR4, LFSR_Powerup_type;
	
		
	
	///block to randomize enemy shoot times
	always_ff @ (posedge Reset or posedge frame_clk)
	begin
		if(Reset)
		begin	
			//can probably pass up a random 8 bit string based from NIOS II later
			//or can keep using these random numbers, doesn't have to be totally randomized
			LFSR1 <= 8'b10101011; 
			LFSR2 <= 8'b01000110;
			LFSR3 <= 8'b11001001;
			LFSR4 <= 8'b01010101;
			
		end	
		else
		begin	
			//shifting
			LFSR1[6:0] <= LFSR1[7:1];
			LFSR2[6:0] <= LFSR2[7:1];
			LFSR3[6:0] <= LFSR3[7:1];
			LFSR4[6:0] <= LFSR4[7:1];
			//new bit is idx 0, 1, 2, 3 xord together
			LFSR1[7] <= LFSR1[0] ^ LFSR1[1] ^ LFSR1[2] ^ LFSR1[3];
			LFSR2[7] <= LFSR2[0] ^ LFSR2[1] ^ LFSR2[2] ^ LFSR2[3];
			LFSR3[7] <= LFSR3[0] ^ LFSR3[1] ^ LFSR3[2] ^ LFSR3[3];
			LFSR4[7] <= LFSR4[0] ^ LFSR4[1] ^ LFSR4[2] ^ LFSR4[3];
			
			//probability calculating can be done in enemy modules
			enemy_shoot1 <= LFSR1[5:0];
			enemy_shoot2 <= LFSR2[5:0];
			enemy_shoot3 <= LFSR3[5:0];
			enemy_shoot4 <= LFSR4[5:0];
		end
	end
	
	///block to randomize powerup_pos and timer
	always_ff @ (posedge Reset or posedge frame_clk)
	begin
		if(Reset)
		begin	
			//can probably pass up a random 8 bit string based from NIOS II later
			//or can keep using these random numbers, doesn't have to be totally randomized
			LFSR_powerup_pos <= 9'b100100110;
			LFSR_powerup_timer <= 9'b100100110;
			
		end	
		else
		begin	
			//shifting
			LFSR_powerup_pos[7:0] <= LFSR_powerup_pos[8:1];
			LFSR_powerup_timer[7:0] <= LFSR_powerup_timer[8:1];
			//new bit is idx 0, 1, 2, 3 xord together
			LFSR_powerup_pos[8] <= LFSR_powerup_pos[0] ^ LFSR_powerup_pos[1] ^ LFSR_powerup_pos[2] ^ LFSR_powerup_pos[3];
			LFSR_powerup_timer[8] <= LFSR_powerup_timer[0] ^ LFSR_powerup_timer[1] ^ LFSR_powerup_timer[2] ^ LFSR_powerup_timer[3];
			
			
		end
	end
	
	///block to randomize powerup type
	always_ff @ (posedge Reset or posedge frame_clk)
	begin
		if(Reset)
		begin	
			//can probably pass up a random 8 bit string based from NIOS II later
			//or can keep using these random numbers, doesn't have to be totally randomized
			LFSR_Powerup_type <= 8'b10010011;
			
		end	
		else
		begin	
			//shifting
			LFSR_Powerup_type[6:0] <= LFSR_Powerup_type[7:1];
			//new bit is idx 0, 1, 2, 3 xord together
			LFSR_Powerup_type[7] <= LFSR_Powerup_type[0] ^ LFSR_Powerup_type[1] ^ LFSR_Powerup_type[2] ^ LFSR_Powerup_type[3];
			LFSR_powerup_type <= LFSR_Powerup_type[1:0];
		end
	end
endmodule
