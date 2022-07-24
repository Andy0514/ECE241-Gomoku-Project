module deleteMouse(
	input clk,
	input deleteSignal,
	
	output [7:0] deleteX,
	output [6:0] deleteY,
	output [14:0] address
);
	//this module resets the board to initial state - it contains the memory that stores the untouched board
	
	reg [7:0] x;
	reg [6:0] y;
//	wire [14:0] address;
//	
	assign address = x + (y*160);
//	
//	
//	ramBackground background(.clock(clk), .address(address), .wren(0), .q(colour));
//	
	always @(posedge clk)
	
		if (deleteSignal == 1)
		
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

			
	assign deleteX = x;
	assign deleteY = y;


endmodule
