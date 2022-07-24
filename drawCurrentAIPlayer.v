module drawCurrentAIPlayer(
	input currentPlayer,
	input enableDraw,
	input clk,
	
	output reg[2:0] writeToMemData,
	output reg [14:0] writeToMemAddress
);
	//this module must write both to VGA and to the memory module that replicates the VGA's video memory
	
	wire [2:0] blackTurnData, whiteTurnData;
	reg [12:0] readAddress;
	
	blackTurnAI blackturnAI(
		.clock(clk),
		.address(readAddress),
		
		.q(blackTurnData)
	);
	
	whiteTurnAI whiteturnAI(
		.clock(clk),
		.address(readAddress),
		
		.q(whiteTurnData)
	);
	
	
	
	reg [7:0] x;
	reg [6:0] y;
	
	always @(posedge clk)
		begin
			//this module controls the drawing of the current player (black or white) at the top right corner
			
			if (enableDraw == 1)
				begin
					if (x < 159)
						x <= x + 1'd1;
					else if (y < 49)
						begin
							x <= 110;
							y <= y + 7'd1;
						end
					else
						begin
							x <= 110;
							y <= 10;
						end
						
					readAddress = (x - 13'd110) + (y - 13'd10) * 13'd50;
					
					if (currentPlayer == 0) //black player 
						writeToMemData = blackTurnData;
					else if (currentPlayer == 1)
						writeToMemData = whiteTurnData;
						
					writeToMemAddress = x + y*14'd160;
				end
			else
				begin
					x <= 110;
					y <= 10;
				end
	
		end
endmodule