module enemy_shooter_color_pallete (input [3:0] data_in,
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
	4'b0010:
	begin
		temp_red = 8'h44;
		temp_green = 8'h46;
		temp_blue = 8'h53;
	end
	4'b0011:   ////////////////edited to make new color(red)
	begin
		temp_red = 8'he9;
		temp_green = 8'h00;
		temp_blue = 8'h44;
	end
	4'b0100:
	begin
		temp_red = 8'h57;
		temp_green = 8'h52;
		temp_blue = 8'hc5e;
	end
	4'b0101:
	begin
		temp_red = 8'h91;
		temp_green = 8'h85;
		temp_blue = 8'h94;
	end
	4'b0110:
	begin
		temp_red = 8'h1e;
		temp_green = 8'h1f;
		temp_blue = 8'h27;
	end
	4'b0111:
	begin
		temp_red = 8'h37;
		temp_green = 8'h39;
		temp_blue = 8'h46;
	end
	4'b1000:
	begin
		temp_red = 8'h3b;
		temp_green = 8'h40;
		temp_blue = 8'h5d;
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
