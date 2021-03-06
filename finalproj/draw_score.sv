module  draw_score ( input Reset, frame_clk, ship_hit, doublescore, powerup, start_game,
							output logic [9:0] ScoreX, ScoreY,
							output logic [9:0]  score_counter,
							output logic win_game
							);
	
logic [8:0] dbl_score_timer;
	
	 parameter [9:0] Score_X_UL=32;  // Center position on the X axis
    parameter [9:0] Score_Y_UL=64;
	 assign ScoreX = Score_X_UL;
	 assign ScoreY = Score_Y_UL;

always_ff @ (posedge Reset or posedge frame_clk )
begin
	if (Reset)
	begin
	score_counter <= 10'b0;
	dbl_score_timer <= 9'b0;
	win_game <=1'b0;
	end
	
	else if(start_game)
	begin
		if (powerup && doublescore)
		begin
			dbl_score_timer <= 9'b111111111;
		end
	
		else if (ship_hit)
		begin
			if (dbl_score_timer !=0)
			begin
				score_counter <= score_counter + 2;
				dbl_score_timer <= dbl_score_timer - 1;
			end
			
			else
			begin
				score_counter <= score_counter + 1;
				dbl_score_timer <= 0;
			end
		end	
	end
	
	else
	begin
		if (dbl_score_timer !=0)
		begin
		dbl_score_timer <= dbl_score_timer - 1;
		end
		
		else
		begin
		dbl_score_timer <= 0;
		end	
	end
end
	


endmodule
	