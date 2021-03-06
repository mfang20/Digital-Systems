module enemycontroller(	input Reset, frame_clk, start_game,
								input easy_selected, normal_selected, hard_selected,
								input e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12,
								input es1, es2, es3, es4,
								output logic start_Boss,
								output logic [2:0] difficulty,
								output logic flydown, enemy_shoot,
								output logic wave1_1sig, wave1_2sig, wave1_3sig, wave1_4sig,
								output logic wave2_1sig, wave2_2sig, wave2_3sig, wave2_4sig,
								output logic wave3_1sig, wave3_2sig, wave3_3sig, wave3_4sig,
								output logic wave4_1sig, wave4_2sig, wave4_3sig, wave4_4sig
								);
								
	logic [7:0]  wave1_timer, wave2_timer, wave3_timer, wave4_timer;
	logic [6:0] buffer_timer;
	logic [5:0] boss_timer;
	logic [10:0] flydown_timer;
	logic [4:0] shoot_timer;
	logic game_in_progress, difficulty_selected;
	logic wave1_1, wave1_2, wave1_3, wave1_4;
	logic wave2_1, wave2_2, wave2_3, wave2_4;
	logic wave3_1, wave3_2, wave3_3, wave3_4;
	logic wave4_1, wave4_2, wave4_3, wave4_4;
	assign difficulty_selected = easy_selected || normal_selected || hard_selected;
	
	
	enum logic [3:0] {	Reset_state,
								start,
								first_wave, 
								second_wave,
								third_wave,
								fourth_wave,
								buffer,	//for enemy ships to flydown and reset, slightly longer than a wave
								flydown_state,
								boss_stage}	State, Next_State;
	logic [2:0] wavetracker;
	
	always_ff @ (posedge frame_clk)
	begin
		if(Reset)
		begin
			State <= Reset_state;
		end
		else
			State <= Next_State;
	end
	
	always_comb
	begin
		//default contorl signals
		Next_State = State;
		unique case(State)
			Reset_state:	Next_State = start;
			start:
				if(difficulty_selected) 
					Next_State = first_wave;
					//Next_State = boss_stage;
			first_wave:
				if(wave1_timer == 8'b0)
					Next_State = flydown_state;
			second_wave:
				if(wave2_timer == 8'b0)
					Next_State = flydown_state;
			third_wave:
				if(wave3_timer == 8'b0)
					Next_State = flydown_state;
			fourth_wave:
				if(wave4_timer == 8'b0)
					Next_State = flydown_state;
			buffer:
				if(buffer_timer == 6'b0)
				begin
					case(wavetracker)
						3'b001:	Next_State = first_wave;
						3'b100:	Next_State = fourth_wave;
					endcase
				end
			flydown_state:	//could create two flydown states with different timers to make the game more interesting, FSM control will stay in only one though
				if(flydown_timer == 11'b00000000000)
				begin
					case(wavetracker)
						3'b001:	Next_State = buffer;
						3'b010:	Next_State = second_wave;
						3'b011:	Next_State = third_wave;
						3'b100:	Next_State = buffer;
						3'b101:  Next_State = boss_stage;
						3'b110:
							case(difficulty)
								3'b001 : Next_State = first_wave;
								3'b010 : Next_State = second_wave;
								3'b100 : Next_State = fourth_wave;
								default:;
							endcase
						default: ;
					endcase
				end
			boss_stage:
				if(boss_timer == 6'b0)
				begin
					case(difficulty)
						3'b001 : Next_State = first_wave;
						3'b010 :	Next_State = second_wave;
						3'b100 : Next_State = fourth_wave;
						default:;
					endcase
				end
		endcase
	end
		
	
	always_ff @ (posedge frame_clk)
	begin
		unique case (State)
		Reset_state:
			begin
				wave1_timer <= 8'b11111111;
				wave2_timer <= 8'b11111111;
				wave3_timer <= 8'b11111111;
				wave4_timer <= 8'b11111111;
				buffer_timer <= 7'b1111111;
				boss_timer <= 6'b111111;
				wave1_1 <= 0;
				wave1_2 <= 0;
				wave1_3 <= 0;
				wave1_4 <= 0;
				wave2_1 <= 0;
				wave2_2 <= 0;
				wave2_3 <= 0;
				wave2_4 <= 0;
				wave3_1 <= 0;
				wave3_2 <= 0;
				wave3_3 <= 0;
				wave3_4 <= 0;
				flydown <= 0;
				wavetracker <= 3'b001;
				difficulty <= 3'b000;
				start_Boss <= 1'b0;
				end
		start:	
			begin
				if(easy_selected)
					difficulty <= 3'b001;
				else if(normal_selected)
					difficulty <= 3'b010;
				else if(hard_selected)
					difficulty <= 3'b100;
			end
		first_wave: 
			begin
				//can't check if == 0 because the state will have changed already?
				//doesn't really make sense since the signals are synchornized with frame_clk but whatever
				//can create similar fire signals for ships that can fire
				if(wave1_timer == 8'b00000010)
					wave1_1 <= 1;
				if(wave1_timer == 8'b00100000)
					wave1_2 <= 1;
				if(wave1_timer == 8'b01000000)
					wave1_3 <= 1;
				if(wave1_timer == 8'b01100000)
					wave1_4 <= 1;
				else if(wave1_timer == 8'b00000001 || wave1_timer == 8'b00100001 || wave1_timer == 8'b01100001 || wave1_timer == 8'b01000001)
				begin
					wave1_1 <= 0;
					wave1_2 <= 0;
					wave1_3 <= 0;
					wave1_4 <= 0;
					flydown_timer <= 11'b01111111111;
					if(wavetracker != 3'b110)
						wavetracker <= 3'b010;
				end
				wave1_timer <= wave1_timer - 1;
			end
		second_wave: 
			begin
				if(wave2_timer == 8'b00000010)
					wave2_1 <= 1;
				if(wave2_timer == 8'b00100000)
					wave2_2 <= 1;
				if(wave2_timer == 8'b01000000)
					wave2_3 <= 1;
				if(wave2_timer == 8'b01100000)
					wave2_4 <= 1;
				else if(wave2_timer == 8'b00000001 || wave2_timer == 8'b00100001 || wave2_timer == 8'b01100001 || wave2_timer == 8'b01000001)
				begin
					wave2_1 <= 0;
					wave2_2 <= 0;
					wave2_3 <= 0;
					wave2_4 <= 0;
					flydown_timer <= 11'b01111111111;
					if(wavetracker != 3'b110)
						wavetracker <= 3'b011;
				end
				wave2_timer <= wave2_timer - 1;
			end
		third_wave: 
			begin
				if(wave3_timer == 8'b00000010)
					wave3_1 <= 1;
				if(wave3_timer == 8'b00100000)
					wave3_2 <= 1;
				if(wave3_timer == 8'b01000000)
					wave3_3 <= 1;
				if(wave3_timer == 8'b01100000)
					wave3_4 <= 1;
				else if(wave3_timer == 8'b00000001 || wave3_timer == 8'b00100001 || wave3_timer == 8'b01100001 || wave3_timer == 8'b01000001)
				begin
					wave3_1 <= 0;
					wave3_2 <= 0;
					wave3_3 <= 0;
					wave3_4 <= 0;
					flydown_timer <= 11'b01111111111;
					wavetracker <= 3'b100; //looping back to wave1, inf loop at the moment
				end
				wave3_timer <= wave3_timer - 1;
			end
		fourth_wave:
			begin
				if(wave4_timer == 8'b00000010)
					wave4_1 <= 1;
				if(wave4_timer == 8'b00100000)
					wave4_2 <= 1;
				if(wave4_timer == 8'b01000000)
					wave4_3 <= 1;
				if(wave4_timer == 8'b01100000)
					wave4_4 <= 1;
				else if(wave4_timer == 8'b00000001 || wave4_timer == 8'b00100001 || wave4_timer == 8'b01100001 || wave4_timer == 8'b01000001)
				begin
					wave4_1 <= 0;
					wave4_2 <= 0;
					wave4_3 <= 0;
					wave4_4 <= 0;
					flydown_timer <= 11'b01111111111;
					if(wavetracker != 3'b110)
						wavetracker <= 3'b101; 
				end
				wave4_timer <= wave4_timer - 1;
			end
		buffer:
			begin
				buffer_timer <= buffer_timer - 1;
			end
		flydown_state:	
			begin
				if(flydown_timer == 11'b00000000010)
				begin
					flydown <= 1;
				end
				else if(flydown_timer == 11'b00000000001)
				begin
					flydown <= 0;
				end
				flydown_timer <= flydown_timer - 1;
				//wave optimization, all enemies were already destoryed
				if(flydown_timer > 11'b00000011111 && !(e1 || e2 || e3 || e4 || e5 || e6 || e7 || e8 || e9 || e10 || e11 || e12 ||
					es1 || es2 || es3 || es4))
					flydown_timer <= 11'b00000011111;
				//can check for lose here 
			end
		boss_stage:
			begin
				start_Boss <= 1'b1;
				boss_timer <= boss_timer - 1;
				wavetracker <= 3'b110;
			end
		endcase
	end
	
	//doesn't depend on state, shoot timer always ticking
	always_ff @ (posedge frame_clk)
	begin
		if(shoot_timer != 0)
		begin
			shoot_timer <= shoot_timer -1;
			enemy_shoot <= 0;
		end
		else
		begin
			shoot_timer <= 5'b11111;
			enemy_shoot <= 1;
		end
	end
	
	always_comb
	begin	
		wave1_1sig = wave1_1;
		wave1_2sig = wave1_2;
		wave1_3sig = wave1_3;
		wave1_4sig = wave1_4;
		wave2_1sig = wave2_1;
		wave2_2sig = wave2_2;
		wave2_3sig = wave2_3;
		wave2_4sig = wave2_4;
		wave3_1sig = wave3_1;
		wave3_2sig = wave3_2;
		wave3_3sig = wave3_3;
		wave3_4sig = wave3_4;
		wave4_1sig = wave4_1;
		wave4_2sig = wave4_2; 
		wave4_3sig = wave4_3;
		wave4_4sig = wave4_4;
	end
endmodule

