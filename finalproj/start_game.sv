module start_game( input frame_clk, Reset,
						 input easy_selected, normal_selected, hard_selected, powerup_exists,
						 input [8:0] LFSR_powerup_startpos, LFSR_powerup_drop_timer,
						 output logic [9:0] powerup_startpos, 
						 output logic generate_powerup, start_game
						 );

//powerup fsm
logic [9:0] powerup_drop_timer;					 
						 
always_ff @(posedge frame_clk or posedge Reset)
begin
	if (Reset)
		begin
		start_game <= 1'b0;
		generate_powerup <=1'b0;
		powerup_startpos <=10'b0;
		powerup_drop_timer <=10'b0;
		end
		
	else if (start_game ==1'b1)
		begin
		if (powerup_drop_timer == 10'b0)
			begin
			
			if (powerup_exists == 1'b0)
			begin
			generate_powerup <= 1'b1;
			end
			
			powerup_drop_timer <= LFSR_powerup_drop_timer;
			powerup_startpos <= LFSR_powerup_startpos + 84;
			end
		else
			begin
			generate_powerup <= 1'b0;
			powerup_drop_timer <= powerup_drop_timer - 1;
			end		
		end	
		
	else if (easy_selected || normal_selected || hard_selected)
		begin
		start_game <=1'b1;
		powerup_drop_timer <= 10'b0111111111;
		end
	
end		

endmodule
