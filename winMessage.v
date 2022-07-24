module winMessage (
	input clk,
	input whiteWin,
	input blackWin,
	input tie,

	output reg [7:0] dataX,
	output reg [6:0] dataY,
	output reg [14:0] writeToMemAddress,
	output reg [2:0] colour );

	reg [7:0] x;
	reg [6:0] y;
	reg [11:0] address;
	wire [2:0] dataBlackWin, dataWhiteWin, dataTie;
	
	blackWin blackWinImage(
		.clock(clk),
		.wren(1'b0),
		.address(address),
		
		.q(dataBlackWin) );
		
		
	whiteWin whiteWinImage(
		.clock(clk),
		.wren(1'b0),
		.address(address),
		
		.q(dataWhiteWin)  );

	
	tie tieImage(
		.clock(clk),
		.wren(1'b0),
		.address(address),
		
		.q(dataTie)  );
	
	always @(posedge clk)
		if (whiteWin == 1 || blackWin == 1 || tie == 1)
			//display things related to white or black piece winning
			begin
				
				if (x < 8'd154)
						x <= x + 1;
				else if (y < 7'd109)
					begin
						x <= 105;
						y <= y + 1;
					end
				else	
					begin
						x <= 105;
						y <= 70;
					end
					
				address = (x-8'd105) + (y-8'd70)*8'd50;
				if (blackWin == 1)
					colour = dataBlackWin;
				else if (whiteWin == 1)
					colour = dataWhiteWin;
				else
					colour = dataTie;
				
				
				dataX = x;
				dataY = y;
				writeToMemAddress = x + y*14'd160;
			end
			
		else
			begin
				x <= 105;
				y <= 70;
			end

endmodule
	