module difficulty_blocks(	input Reset, frame_clk, 
									input [9:0] PX1, PX2, PX3, PX4, PY1, PY2, PY3, PY4,
									input PL1, PL2, PL3, PL4,
									input [9:0] laser_width, laser_height,
									input other_selected,
									input [1:0] difficulty,
									input [9:0] block_height, block_width,
									output logic [9:0] blockX, blockY,
									output logic selected,
									output h1, h2, h3, h4
									);
									
	logic block_exists, hit1, hit2, hit3, hit4;
									
	always_ff @ (posedge Reset or posedge frame_clk )
	begin: Move_block
		if (Reset)  // Asynchronous Reset
		begin 
			block_exists <= 1;
			hit1 <= 0;
			hit2 <= 0;
			hit3 <= 0;
			hit4 <= 0;
			blockY <= 240;
			selected <= 0;
			if(difficulty == 2'b00)
				blockX <= 160;//96; in case multi was reimplemented
			else if(difficulty == 2'b01)
				blockX <= 288;//224;
			else if(difficulty == 2'b10)
				blockX <= 416;//352;
		end
		
		else if(other_selected)
			block_exists <= 0;
		
		else if(block_exists)
		begin
			if(PL1)
			begin	//player laser 1 exists
				if( ((blockX <= PX1 && (blockX + block_width) >= PX1)	||
					(blockX <= (PX1 + laser_width) && (blockX + block_width) >= (PX1 + laser_width)) ) &&
					((blockY <= PY1 && (blockY + block_height) >= PY1) ||
					(blockY <= (PY1 + laser_height) && (blockY + block_height) >= (PY1 + laser_height)))
					)
				begin	//collision with laser 1 occured
					hit1 <= 1;
					block_exists <= 0;
					selected <= 1;
				end
			end
			if(PL2)
			begin	//player laser 2 exists
				if( ((blockX <= PX2 && (blockX + block_width) >= PX2)	||
					(blockX <= (PX2 + laser_width) && (blockX + block_width) >= (PX2 + laser_width)) ) &&
					((blockY <= PY2 && (blockY + block_height) >= PY2) ||
					(blockY <= (PY2 + laser_height) && (blockY + block_height) >= (PY2 + laser_height)))
					)
				begin	//collision with laser 2 occured
					hit2 <= 1;
					block_exists <= 0;
					selected <= 1;
				end
			end
			if(PL3)
			begin	//player laser 3 exists
				if( ((blockX <= PX3 && (blockX + block_width) >= PX3)	||
					(blockX <= (PX3 + laser_width) && (blockX + block_width) >= (PX3 + laser_width)) ) &&
					((blockY <= PY3 && (blockY + block_height) >= PY3) ||
					(blockY <= (PY3 + laser_height) && (blockY + block_height) >= (PY3 + laser_height)))
					)
				begin	//collision with laser 3 occured
					hit3 <= 1;
					block_exists <= 0;
					selected <= 1;
				end
			end
			if(PL4)
			begin	//player laser 4 exists
				if( ((blockX <= PX4 && (blockX + block_width) >= PX4)	||
					(blockX <= (PX4 + laser_width) && (blockX + block_width) >= (PX4 + laser_width)) ) &&
					((blockY <= PY4 && (blockY + block_height) >= PY4) ||
					(blockY <= (PY4 + laser_height) && (blockY + block_height) >= (PY4 + laser_height)))
					)
				begin	//collision with laser 4 occured
					hit4 <= 1;
					block_exists <= 0;
					selected <= 1;
				end
			end
		end
		
		else
		begin
			hit1 <= 0;
			hit2 <= 0;
			hit3 <= 0;
			hit4 <= 0;
		end
	end
	
	assign h1 = hit1;
	assign h2 = hit2;
	assign h3 = hit3;
	assign h4 = hit4;
	
endmodule
