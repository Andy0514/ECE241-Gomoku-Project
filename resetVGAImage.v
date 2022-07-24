module resetVGAImage(
	input clk,
	input resetSignal,
	
	output [2:0] colour,
	output [7:0] resetX,
	output [6:0] resetY,
	output [14:0] outputAddress
);
	//this module resets the board to initial state - it contains the memory that stores the untouched board
	
	reg [7:0] x;
	reg [6:0] y;
	wire [14:0] address;
	
	assign address = x + (y*160) + 2;
	
	assign outputAddress = address;
	ramBackground background(.clock(clk), .address(address), .wren(1'b0), .q(colour));
	
	always @(posedge clk)
	
			if (resetSignal == 1)
			
				if (x < 159)
						x <= x + 1;
				else if (y < 119)
					begin
						x <= 0;
						y <= y + 1;
					end
				else
					begin
						x <= 0;
						y <= 0;
					end
			else
				begin
					x <= 0;
					y <= 0;
				end
			
	assign resetX = x;
	assign resetY = y;
endmodule
