module explosion(	input Reset, 
						input frame_clk,
						input [9:0] e1X, e2X, e3X, e4X, e5X, e6X, e7X, e8X, e9X, e10X, e11X, e12X,
                  input [9:0] e1Y, e2Y, e3Y, e4Y, e5Y, e6Y, e7Y, e8Y, e9Y, e10Y, e11Y, e12Y,
						input e1E, e2E, e3E, e4E, e5E, e6E, e7E, e8E, e9E, e10E, e11E, e12E,
						
						input [9:0] es1X, es2X, es3X, es4X,
						input [9:0] es1Y, es2Y, es3Y, es4Y,
						input es1E, es2E, es3E, es4E,
						
						input [9:0] ef1X, ef2X, ef3X,
                  input [9:0] ef1Y, ef2Y, ef3Y,
						input ef1E, ef2E, ef3E
						
						output logic exp1, exp2, exp3, exp4, exp5, exp6, exp7, exp8, exp9, exp10, exp11, exp12,
						output logic exps1, exps2, exps3, exps4,
						output logic expf1, expf2, expf3
						);					
						
	always_ff @ (posedge Reset or posedge frame_clk )
	begin: Move_block
		if (Reset)  // Asynchronous Reset
		begin 
			exp1 <= 0;
			exp2 <= 0;
			exp3 <= 0;
			exp4 <= 0;
			exp5 <= 0;
			exp6 <= 0;
			exp7 <= 0;
			exp8 <= 0;
			exp9 <= 0;
			exp10 <= 0;
			exp11 <= 0;
			exp12 <= 0;
			exps1 <= 0;
			exps2 <= 0;
			exps3 <= 0;
			exps4 <= 0;
			expf1 <= 0;
			expf2 <= 0;
			expf3 <= 0;
		end
		
		else
		begin
			
		end

