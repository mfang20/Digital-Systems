module  draw_lives ( input Reset, frame_clk, lose_life, extralife, powerup,
							output logic [9:0]  LivesX, LivesY,
							output logic [1:0] lives_counter,
							output logic lose_game
							);
							
	 parameter [9:0] Lives_X_UL=608;  // Center position on the X axis
    parameter [9:0] Lives_Y_UL=17;
	 assign LivesX = Lives_X_UL;
	 assign LivesY = Lives_Y_UL;

always_ff @ (posedge Reset or posedge frame_clk )
begin
	if (Reset)
	begin
	lives_counter <= 2'b11;
	lose_game <=1'b0;
	end
	
	else if (lose_life && lives_counter != 0 )
	begin
	lives_counter <= lives_counter - 1;
	end

	else if (extralife && powerup && lives_counter != 3 )
	begin
	lives_counter <= lives_counter + 1;
	end
	
	else if (lives_counter == 0)
	begin
	lose_game <=1'b1;
	end

end

	


endmodule
	