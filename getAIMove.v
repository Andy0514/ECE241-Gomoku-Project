module getAIMove(
		input clk,
		input initializeAI, 
		input updateStatus,
		input resetBoard,
		input [3:0]xPosition,
		input [3:0]yPosition,
		input selector,
		
		output  aiDone,
		output  [3:0]playX,
		output  [3:0]playY
		);
		reg [5:0] i;
		reg [5:0] address;
		reg [1:0] boardState [63:0];
		reg [2:0] x, y;
		reg [5:0] currentAddress;
		
		always @(posedge clk)
			begin
	
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
			end		

wire [8:0] outReg;

wire [32:0] in1 = {boardState[15], boardState[14], boardState[13], boardState[12], boardState[11], boardState[10], boardState[9], boardState[8], boardState[7], boardState[6], boardState[5], boardState[4], boardState[3], boardState[2], boardState[1], boardState[0]};
wire [32:0] in2 = {boardState[31], boardState[30], boardState[29], boardState[28], boardState[27], boardState[26], boardState[25], boardState[24], boardState[23], boardState[22], boardState[21], boardState[20], boardState[19], boardState[18], boardState[17], boardState[16]};
wire [32:0] in3 = {boardState[47], boardState[46], boardState[45], boardState[44], boardState[43], boardState[42], boardState[41], boardState[40], boardState[39], boardState[38], boardState[37], boardState[36], boardState[35], boardState[34], boardState[33], boardState[32]};
wire [32:0] in4 = {boardState[63], boardState[62], boardState[61], boardState[60], boardState[59], boardState[58], boardState[57], boardState[56], boardState[55], boardState[54], boardState[53], boardState[52], boardState[51], boardState[50], boardState[49], boardState[48]};



myTest cpu1(
		.clk_clk(clk),
		.enable_export(initializeAI),
		.in1_export(in1),
		.in2_export(in2),
		.in3_export(in3),
		.in4_export(in4),
		.reset_reset_n(1),
		
		.outx_export(playX),
		.outy_export(playY),
		.ready_export(aiDone)
		

	);
	

endmodule
				
				
