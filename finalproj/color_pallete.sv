module color_pallete (	input [3:0] data_in,
								input [7:0] spaceship_red, spaceship_blue, spaceship_green,
								output logic [7:0] red, green, blue
							 );
	

logic [7:0] temp_red, temp_green, temp_blue;
	
always_comb
begin
	case(data_in)
	4'b0000:
	begin
		temp_red = 8'hff;
		temp_green = 8'hc0;
		temp_blue = 8'hcb;
	end
	4'b0001:
	begin
		temp_red = 8'h00;
		temp_green = 8'h00;
		temp_blue = 8'h00;
	end
	4'b0010://white
	begin
		temp_red = 8'hff;
		temp_green = 8'hff;
		temp_blue = 8'hff;
	end
	4'b0011:
	begin
		temp_red = 8'h89;
		temp_green = 8'h89;
		temp_blue = 8'h89;
	end
	4'b0100:
	begin
		temp_red = 8'hcf;
		temp_green = 8'hcf;
		temp_blue = 8'hcd;
	end
	4'b0101://red
	begin
		temp_red = spaceship_red;
		temp_blue = spaceship_blue;
		temp_green = spaceship_green;
	end
	4'b0110:
	begin
		temp_red = 8'hd0;
		temp_green = 8'hd2;
		temp_blue = 8'h0e;
	end
	4'b0111:
	begin
		temp_red = 8'hc7;
		temp_green = 8'hf8;
		temp_blue = 8'hf8;
	end
	4'b1000:
	begin
		temp_red = 8'h03;
		temp_green = 8'h13;
		temp_blue = 8'hff;
	end
	default:
	begin
		temp_red = 8'h00;
		temp_green = 8'h00;
		temp_blue = 8'h00;
	end
	endcase
end
assign red  = temp_red;
assign green = temp_green;
assign blue = temp_blue;


endmodule

