module power_up_select(	input Reset, frame_clk, generate_powerup, 
								input [1:0]  LFSR_powerup_type,
								output logic speedup, extralife, shootfaster, doublescore, 
								output logic [3:0] powerup_red, powerup_green, powerup_blue
								);
logic [31:0] powerup_counter;
logic [2:0] powerup_type;


////color logic
logic [3:0] speed_red, speed_green, speed_blue;
logic [3:0] life_red, life_green, life_blue;
logic [3:0] shoot_red, shoot_green, shoot_blue;
logic [3:0] double_red, double_green, double_blue;

/////change powerup color for different powerups
//speed = blue for duration, life = white, shoot = green, doublescore = yellow
always_comb
begin
//speed
speed_red = 4'h0;
speed_green = 4'h0;
speed_blue = 4'hf;
//life
life_red = 4'hf;
life_green = 4'hf;
life_blue = 4'hf;
//invicible
shoot_red = 4'h0;
shoot_green = 4'hf;
shoot_blue = 4'h0;
//double
double_red = 4'hf;
double_green = 4'hf;
double_blue = 4'h0;
end

always_comb
begin
	if (powerup_type == 0)
	begin
		speedup = 1;
		extralife = 0;
		shootfaster = 0;
		doublescore = 0;
		powerup_red = speed_red;
		powerup_green = speed_green;
		powerup_blue = speed_blue;
	end
	else if (powerup_type == 1)
	begin
		speedup = 0;
		extralife = 1;
		shootfaster = 0;
		doublescore = 0;
		powerup_red = life_red;
		powerup_green = life_green;
		powerup_blue = life_blue;
	end
	else if (powerup_type == 2)
	begin
		speedup = 0;
		extralife = 0;
		shootfaster = 1;
		doublescore = 0;
		powerup_red = shoot_red;
		powerup_green = shoot_green;
		powerup_blue = shoot_blue;
	end
	else if (powerup_type == 3)
	begin
		speedup = 0;
		extralife = 0;
		shootfaster = 0;
		doublescore = 1;
		powerup_red = double_red;
		powerup_green = double_green;
		powerup_blue = double_blue;
	end
	else
	begin
		speedup = 0;
		extralife = 0;
		shootfaster = 0;
		doublescore = 0;
		powerup_red = 4'h0;
		powerup_green = 4'h0;
		powerup_blue = 4'h0;
		
	end
end

always_ff @ (posedge Reset or posedge frame_clk )
begin
	if(Reset)
	begin
		powerup_counter <= 32'h00000001;
		powerup_type <= 3'b111;
	end
	else if(generate_powerup)
	begin
		powerup_type[1:0] <= LFSR_powerup_type;
		powerup_type[2] <= 1'b0;
	end
	
end

endmodule
