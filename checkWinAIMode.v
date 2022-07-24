module checkWinAIMode(
	input clk,
	input updateStatus,
	input checkWinning,
	input resetBoard,
	input selector,
	input [3:0] xPosition,
	input [3:0] yPosition,
	
	output reg resultObtained,
	output reg validInput,
	output [1:0] outputResult
);
	reg tie = 1'b1;
	reg [1:0] result;
	assign outputResult = result;
	reg [5:0] address;
	reg [1:0] boardState [63:0];
	reg [2:0] x, y;
	reg [5:0] i;

	
	
	always @(posedge clk)
	
			if (resetBoard == 1) 
				begin
					//reset the board to represent an empty board
					if (i < 63)
						i <= i + 1;
					else
						i <= 0;
					boardState[i] = 2'b00;

				end
						
					
			else if (updateStatus == 1)
				begin
					address = yPosition[2:0]*8 + xPosition[2:0];
					if (selector == 0)
						boardState[address] = 2'd1;  //represents black
					else
						boardState[address] = 2'd2;  //represents white
					
				end
			else
				i <= 0;
				
				
	reg [5:0] validAddress;
	reg [5:0] currentAddress;
	reg [1:0] currentColour;
	always @(posedge clk)
	
		begin
			//this segments checks if an input is valid, ie is written on a fresh block
			
			if (resetBoard == 1)
				result = 0;
				
			validAddress = yPosition[2:0]*8 + xPosition[2:0];
			if(boardState[validAddress] == 2'd1 || boardState[validAddress] == 2'd2 || xPosition > 7 || yPosition > 7 || result != 0)	
				validInput = 0;
			else
				validInput = 1;
				
				
			
			if (checkWinning == 1)
				begin
					
					if (x < 7)
						x <= x + 1;
					else if (y < 7)
						begin
							y <= y + 1;
							x <= 0;
						end
					else
						begin
							x <= 0;
							y <= 0;
						end
						
					currentAddress = y*8 + x;
					currentColour = boardState[currentAddress]; //1: black; 2: white;
					
					if (currentColour != 2'b00)
						begin

							if (x <= 3 && y <= 3) 
								begin
									//check diagonally across, from top left to bottom right
									if (boardState[currentAddress + 6'd9] == currentColour &&
										boardState[currentAddress + 6'd18] == currentColour &&
										boardState[currentAddress + 6'd27] == currentColour &&
										boardState[currentAddress + 6'd36] == currentColour)
											begin
												resultObtained = 1;
												result = currentColour;
											end
								end
											
							if (x >= 4 && y <= 3) 
								begin
									//check diagonally across, from top right to bottom left
									if (boardState[currentAddress + 6'd7] == currentColour &&
										boardState[currentAddress + 6'd14] == currentColour &&
										boardState[currentAddress + 6'd21] == currentColour &&
										boardState[currentAddress + 6'd28] == currentColour)
											begin
												resultObtained = 1;
												result = currentColour;
											end
								end
							
							if (x <= 3) 
							
								begin
									//check horizontally across
									if (boardState[currentAddress + 6'd1] == currentColour &&
										boardState[currentAddress + 6'd2] == currentColour &&
										boardState[currentAddress + 6'd3] == currentColour &&
										boardState[currentAddress + 6'd4] == currentColour) 
											//win
											begin
												resultObtained = 1;
												result = currentColour;
											end
								end
							
							if (y <= 3) 
							
								begin
									//check vertically
									if (boardState[currentAddress + 6'd8] == currentColour &&
										boardState[currentAddress + 6'd16] == currentColour &&
										boardState[currentAddress + 6'd24] == currentColour &&
										boardState[currentAddress + 6'd32] == currentColour)
											//win
											begin
												resultObtained = 1;
												result = currentColour;
											end
								end
							if (y == 7 && x == 7)
								begin
									resultObtained = 1;
									if(tie == 1)
										result = 3;
									else 
										result = 0;
								end

						end
						
					else if (y == 7 && x == 7)
						begin
							resultObtained = 1;
							if (currentColour != 0 && tie == 1)
								result = 3;
							else
								result = 0;
						end
						
					else
						begin
							resultObtained = 0;
							tie = 0;
						end
				end
				
			else
				begin
					resultObtained = 0;
					tie = 1;
					x <= 0;
					y <= 0;
				end
			
		end
	
endmodule