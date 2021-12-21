/////////////////module to interface with VRAM
module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address	
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	input logic lose_life, pass_up1, pass_up2, pass_up3,
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs,		// VGA HS/VS
	output logic [10:0] DrawX, DrawY
);


//put other local variables here
//logic [9:0] DrawX, DrawY;
logic blank, pixel_clk, write;
logic [31:0] read_data, write_data, control_reg;
logic [31:0] palette[8];
logic [31:0] xtend_lose_life;

always_comb
begin
	if (lose_life==1'b0)
	begin
		xtend_lose_life = 32'b0;
	end
	else
	begin
	xtend_lose_life = 32'b00000000000000000000000000000001;

	end
end

//logic [10:0] shape_x;
//logic [10:0] shape_y;
//logic [10:0] shape_size_x = 8;
//logic [10:0] shape_size_y = 16;


//Declare submodules..e.g. VGA controller, ROMS, etc
final_font_rom final_font_rom0(.addr(char_row), .data(char_data));


assign write =  AVL_WRITE & ~AVL_ADDR[11];
vga_controller vga_controller0( .Clk(CLK), 
										  .Reset(RESET), 
										  .hs(hs),
										  .vs(vs),
										  .pixel_clk(pixel_clk),
										  .blank(blank),
										  .sync(),
										  .DrawX(DrawX),
										  .DrawY(DrawY)
										  );
										  

//instantiate ram
ram ram0( .clock(CLK),
			 .byteena_a(AVL_BYTE_EN),
			 .data(AVL_WRITEDATA),
			 .rdaddress(VRAM_Address), 
			 .wraddress(AVL_ADDR[10:0]),
			 .wren(write),
			 .q(read_data)
			);
			
			
 
// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff
always_ff @ (posedge CLK)
begin //write into palette registers and lose_life
	if(AVL_CS && AVL_WRITE && AVL_ADDR[11] && AVL_ADDR < 2056)
	begin
		palette[AVL_ADDR-2048] <= AVL_WRITEDATA;
	end
	else if(AVL_CS && AVL_READ && AVL_ADDR[11] && AVL_ADDR < 2056)
	begin
		AVL_READDATA <= palette[AVL_ADDR-2048];
	end
end


//handle drawing (may either be combinational or sequential - or both).
logic [6:0] col;
logic [7:0] row;
logic [11:0] addr;
logic [11:0] VRAM_Address;
//logic [31:0] word;
logic [15:0] char, char_data;
logic char_chooser;
logic [10:0] char_row; 
//logic [3:0] fgd_red, fgd_blue, fgd_green, bgd_red, bgd_blue, bgd_green;
logic char_val, char_final;
//////////////////////////////////////////////////////////////
always_comb
begin //find correct character and font rom
	col = DrawX[9:3];
	row = DrawY[9:4];

	addr = col + (row * 80);
	VRAM_Address = addr[11:1];//divide addr by 2

	char_chooser = addr[0];
	char = read_data[16*char_chooser +: 16];//can left shift by 3
	char_row = (16*char[14:8]+DrawY[3:0]);//can left shift by 4
	char_val = char_data[~(DrawX[2:0])];
end

always_comb
begin //invert
	if (char[15])
		char_final = ~char_val;
	else
		char_final = char_val;
end


logic [3:0] fgdidx, bgdidx;
logic [3:0] fgd_red, fgd_green, fgd_blue, bgd_red, bgd_green, bgd_blue;

//divide idx by two to get which pallete
always_comb 
begin //fgd, bgd from pallete initialization
	fgdidx = char[7:4];//char[7:4] get fgdidx and char[3:0] gets bgdidx (one number out of 16)
	bgdidx = char[3:0];
	if(fgdidx[0]) //if one it means it was odd and we need [24:21][20:17][16:13]
	begin
		fgd_red = palette[fgdidx[3:1]][24:21];	
		fgd_green = palette[fgdidx[3:1]][20:17];
		fgd_blue = palette[fgdidx[3:1]][16:13];
	end
	else
	begin
		fgd_red = palette[fgdidx[3:1]][12:9];
		fgd_green = palette[fgdidx[3:1]][8:5];
		fgd_blue = palette[fgdidx[3:1]][4:1];
	end
	
	if(bgdidx[0]) //if one it means it was odd and we need [24:21][20:17][16:13]
	begin
		bgd_red = palette[bgdidx[3:1]][24:21];	
		bgd_green = palette[bgdidx[3:1]][20:17];
		bgd_blue = palette[bgdidx[3:1]][16:13];
	end
	else
	begin
		bgd_red = palette[bgdidx[3:1]][12:9];
		bgd_green = palette[bgdidx[3:1]][8:5];
		bgd_blue = palette[bgdidx[3:1]][4:1];
	end
end

always_ff @(posedge pixel_clk)
begin //assign rgb
	if(~blank)
	begin
		red <= 4'h0;
		blue <= 4'h0;
		green <= 4'h0;
	end	
	
	
	else if(char_final)
	begin
		red <= fgd_red;
		blue <= fgd_blue;
		green <= fgd_green;
	end

	else
	begin
		red <= bgd_red;
		blue <= bgd_blue;
		green <= bgd_green;
	end
end


endmodule