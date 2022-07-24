module writeToMem(

	input clk,
	input enable,    //if this is on, generate output
	input [5:0]SW, 	//SW[2:0] controls the x-grid, SW[5:3] controls the y-grid
 
	
	
	output [2:0] writeToMemData,
	output [14:0] writeToMemAddress,
	output [7:0] writeToVGAX,
	output [6:0] writeToVGAY,
	output currentPieceColour
);


	//changes the piece's color on each write cycle
	reg pieceColor; //0: black; 1: white
	reg lastEnable;
	
	always @(posedge clk)
		if (enable == 1)
			
			//switch color
			if (lastEnable == 0)
				begin
					lastEnable = 1;
					pieceColor = !pieceColor;
				end
			else
				pieceColor = pieceColor;
		else
			begin
				pieceColor = pieceColor;
				lastEnable = 0;
			end

			
	reg [7:0] address;	
	wire [2:0] blackData, whiteData;

	black blackRAM(
			.address(address),
			.clock(clk),
			.wren(1'b0),
			.q(blackData)
	);
	
	white whiteRAM(
			.address(address),
			.clock(clk),
			.wren(1'b0),
			.q(whiteData)
	);
	
	
	reg [3:0] deltaX, deltaY;
	
	
	always @(posedge clk)
		begin
			//outputs the address to retrive data
			
			if (enable == 1)
				begin
					//generates the address for reading from memory buffers containing the pieces
					
					if (deltaX < 4'd11)
							deltaX <= deltaX + 1'b1;
					else if (deltaY < 4'd11)
						begin
							deltaX <= 0;
							deltaY <= deltaY + 1'b1;
						end
					else	
						begin
							deltaX <= 0;
							deltaY <= 0;
						end
					

					address = deltaX + (deltaY * 4'd12) + 2'd2;
					if (address >= 144)
						address = address - 8'd144;
				end
			
			else 
				begin
					deltaX <= 0;
					deltaY <= 0;
					address = 0;
				end
		end
		
	//generate address according to switch position
	wire [7:0] x = 3'd2 + 8'd13 * SW[2:0];
	wire [6:0] y = 2'd3 + 7'd13 * SW[5:3];
	assign writeToVGAX = x + deltaX;
	assign writeToVGAY = y + deltaY;
	assign writeToMemAddress = x + deltaX + ((y+deltaY)*14'd160) - 2;
	assign writeToMemData = pieceColor ? whiteData : blackData;
	assign currentPieceColour = pieceColor;
	
endmodule