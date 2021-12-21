module explosion_color_pallete (input [3:0] data_in,
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
		temp_red = 8'hea;
		temp_green = 8'he5;
		temp_blue = 8'he4;
	end
	4'b0010:
	begin
		temp_red = 8'h87;
		temp_green = 8'h46;
		temp_blue = 8'h41;
	end
	4'b0011:
	begin
		temp_red = 8'h8a;
		temp_green = 8'h22;
		temp_blue = 8'h1b;
	end
	4'b0100:
	begin
		temp_red = 8'hcc;
		temp_green = 8'h90;
		temp_blue = 8'h8d;
	end
	4'b0101:
	begin
		temp_red = 8'hab;
		temp_green = 8'h1b;
		temp_blue = 8'h11;
	end
	4'b0110:
	begin
		temp_red = 8'hda;
		temp_green = 8'h49;
		temp_blue = 8'h13;
	end
	4'b0111:
	begin
		temp_red = 8'he7;
		temp_green = 8'h95;
		temp_blue = 8'h3a;
	end
	4'b1000:
	begin
		temp_red = 8'hf1;
		temp_green = 8'h7b;
		temp_blue = 8'h14;
	end
	4'b1001:
	begin
		temp_red = 8'hfa;
		temp_green = 8'hd2;
		temp_blue = 8'h38;
	end
	4'b1010:
	begin
		temp_red = 8'hfc;
		temp_green = 8'he5;
		temp_blue = 8'h90;
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
