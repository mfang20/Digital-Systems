/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  explosion_drawRAM
(
		input [3:0] data_In,
		input [18:0] write_address, read_address,
		input we, Clk,

		output logic [3:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:899];

initial
begin
	 $readmemh("Explosion.txt",mem);
end


always_ff @ (posedge Clk) begin
	if (we)
		mem[write_address] <= data_In;
	data_Out<= mem[read_address];
end

endmodule
