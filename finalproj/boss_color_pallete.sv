module boss_color_pallete (input [3:0] data_in,
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
		temp_red = 8'hff;
		temp_green = 8'hc0;
		temp_blue = 8'hcb;
	end
	4'b0010:
	begin
		temp_red = 8'hdc;
		temp_green = 8'he7;
		temp_blue = 8'hf1;
	end
	4'b0011:   ////////////////edited to make new color(red)
	begin
		temp_red = 8'h3c;
		temp_green = 8'h36;
		temp_blue = 8'h36;
	end
	4'b0100:
	begin
		temp_red = 8'h61;
		temp_green = 8'h63;
		temp_blue = 8'h58;
	end
	4'b0101:
	begin
		temp_red = 8'h45;
		temp_green = 8'h47;
		temp_blue = 8'h40;
	end
	4'b0110:
	begin
		temp_red = 8'hab;
		temp_green = 8'hb2;
		temp_blue = 8'ha5;
	end
	4'b0111:
	begin
		temp_red = 8'h20;
		temp_green = 8'h27;
		temp_blue = 8'h21;
	end
	4'b1000:
	begin
		temp_red = 8'h96;
		temp_green = 8'ha3;
		temp_blue = 8'ha4;
	end
	4'b1001:
	begin
		temp_red = 8'h6e;
		temp_green = 8'h75;
		temp_blue = 8'h7b;
	end
	4'b1010:
	begin
		temp_red = 8'ha5;
		temp_green = 8'h95;
		temp_blue = 8'h70;
	end
	4'b1011:
	begin
		temp_red = 8'h92;
		temp_green = 8'h83;
		temp_blue = 8'h32;
	end
	4'b1100:
	begin
		temp_red = 8'hc5;
		temp_green = 8'hc2;
		temp_blue = 8'h9e;
	end
	4'b1101:
	begin
		temp_red = 8'h66;
		temp_green = 8'h70;
		temp_blue = 8'h49;
	end
	4'b1110:
	begin
		temp_red = 8'h51;
		temp_green = 8'h66;
		temp_blue = 8'h59;
	end
	4'b1111:
	begin
		temp_red = 8'h22;
		temp_green = 8'h38;
		temp_blue = 8'h31;
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
