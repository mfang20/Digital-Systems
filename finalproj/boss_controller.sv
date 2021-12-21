module boss_controller(	input Reset, frame_clk, start_Boss,
								input [2:0] difficulty,
								input beat_Boss, hit_bottom, hit_top,
								output logic boss_flydown, boss_rise, boss_hold, boss_back_and_forth, boss_shoot1, boss_shoot2, boss_shoot3, boss_shoot4,
								output logic Boss_exists
								);
								
	logic [7:0]  spawn_wait_timer, flydown_wait_timer;
	logic [10:0] flydown_timer;
	logic [4:0] shoot_timer;
	
	
	
	enum logic [2:0] {	Reset_state,
								hide,
								spawn_hold, 
								back_and_forth,
								wait_to_drop,
								flydown_state,
								rise_state}	State, Next_State;
	
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
			Reset_state:	Next_State = hide;
			hide:
				if(beat_Boss == 1'b1)
					Next_State = hide;
				else if(start_Boss) 
					Next_State = spawn_hold;
			spawn_hold:
				if(spawn_wait_timer == 8'b0)
					Next_State = back_and_forth;
			back_and_forth:
				if(flydown_timer == 11'b0)
					Next_State = wait_to_drop;
				else if(beat_Boss == 1'b1)
					Next_State = hide;
			wait_to_drop:
				if(flydown_wait_timer == 8'b0)
					Next_State = flydown_state;
				else if(beat_Boss == 1'b1)
					Next_State = hide;
			flydown_state:
				if(hit_bottom== 1'b1)
					Next_State = rise_state;
				else if(beat_Boss == 1'b1)
					Next_State = hide;
			rise_state:
				if(hit_top== 1'b1)
					Next_State = spawn_hold;
				else if(beat_Boss == 1'b1)
					Next_State = hide;
			
		endcase
	end
	
	always_ff @ (posedge frame_clk)
	begin
		unique case (State)
		Reset_state:
			begin
				spawn_wait_timer <= 8'b11111111;
				flydown_wait_timer <= 8'b11111111;
				flydown_timer <= 11'b11111111111;
				boss_flydown <= 0;
				boss_rise <= 0;
				boss_hold <=1;
				boss_back_and_forth <= 0;
				Boss_exists<=0;
			end
		hide:	
			begin
				spawn_wait_timer <= 8'b11111111;
				flydown_wait_timer <= 8'b11111111;
				flydown_timer <= 11'b11111111111;
				boss_flydown <= 0;
				boss_rise <= 0;
				boss_hold <= 1;
				boss_back_and_forth <= 0;
				Boss_exists <=0;
			end
		spawn_hold: 
			begin
				spawn_wait_timer <= spawn_wait_timer-1;
				flydown_wait_timer <= 8'b11111111;
				flydown_timer <= 11'b11111111111;
				boss_flydown <= 0;
				boss_rise <= 0;
				boss_hold <= 1;
				boss_back_and_forth <= 0;
				Boss_exists <=1;
			end
		back_and_forth: 
			begin
				spawn_wait_timer <= 8'b11111111;
				flydown_wait_timer <= 8'b11111111;
				flydown_timer <= flydown_timer - 1;
				boss_flydown <= 0;
				boss_rise <= 0;
				boss_hold <= 0;
				boss_back_and_forth <= 1;
				Boss_exists <=1;
			end
		wait_to_drop: 
			begin
				spawn_wait_timer <= 8'b11111111;
				flydown_wait_timer <= flydown_wait_timer - 1;
				flydown_timer <= 11'b11111111111;
				boss_flydown <= 0;
				boss_rise <= 0;
				boss_hold <= 1;
				boss_back_and_forth <= 0;
				Boss_exists <=1;
			end
		flydown_state:
			begin
				spawn_wait_timer <= 8'b11111111;
				flydown_wait_timer <= 8'b11111111;
				flydown_timer <= 11'b11111111111;
				boss_flydown <= 1;
				boss_rise <= 0;
				boss_hold <= 0;
				boss_back_and_forth <= 0;
				Boss_exists <=1;
			end
		rise_state:
			begin
				spawn_wait_timer <= 8'b11111111;
				flydown_wait_timer <= 8'b11111111;
				flydown_timer <= 11'b11111111111;
				boss_flydown <= 0;
				boss_rise <= 1;
				boss_hold <= 0;
				boss_back_and_forth <= 0;
				Boss_exists <=1;
			end
		
		endcase
	end
	
	//doesn't depend on state, shoot timer always ticking
	always_ff @ (posedge frame_clk)
	begin
		if(shoot_timer != 0)
		begin
			shoot_timer <= shoot_timer -1;
			boss_shoot1 <= 0;
			boss_shoot2 <= 0;
			boss_shoot3 <= 0;
			boss_shoot4 <= 0;
		end
		else
		begin
			shoot_timer <= 5'b11111;
			boss_shoot1 <= 1;
			boss_shoot2 <= 1;
			boss_shoot3 <= 1;
			boss_shoot4 <= 1;
		end
	end
	
	
endmodule

