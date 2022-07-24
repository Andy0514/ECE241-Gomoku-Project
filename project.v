module project (

	input 			CLOCK_50,
	input 			[3:0] KEY,
	
	inout 			PS2_CLK,
	inout 			PS2_DAT,
	
	output			VGA_CLK,  				//	VGA Clock
	output			VGA_HS,					//	VGA H_SYNC
	output			VGA_VS,					//	VGA V_SYNC
	output			VGA_BLANK_N,			//	VGA BLANK
	output			VGA_SYNC_N,				//	VGA SYNC
	output	[7:0]	VGA_R,   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G,	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B,	   				//	VGA Blue[7:0]
	output 	[1:0] LEDR
);


wire mouseClicked, VGAEn;
wire [2:0] pvpColour, aiColour, winnerClr;
reg [2:0] colour;
wire [7:0] pvp_X, pvp_Y, ai_X, ai_Y, winnerX, winnerY, correctionX, correctionY;
reg [7:0] VGA_X, VGA_Y;
wire [7:0] Mx, My;
wire correction;

assign LEDR[0] = winner[0];
assign LEDR[1] = winner[1];

vga_adapter VGA(
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(colour),
			.x(VGA_X),
			.y(VGA_Y),
			.plot(VGAEn),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA.BACKGROUND_IMAGE = "board.mif";
			
	ps2 mouse(
			  .iSTART(KEY[3]),   //press the button for transmitting instrucions to device;
			  .iRST_n(KEY[0]),   //FSM reset signal;
			  .iCLK_50(CLOCK_50),  //clock source;
			  .PS2_CLK(PS2_CLK),  //ps2_clock signal inout;
			  .PS2_DAT(PS2_DAT),  //ps2_data  signal inout;
			  .oLEFBUT(mouseClicked),  //left button press display;
			  .outx(Mx),
			  .outy(My)
	);


	wire pvpMode, aiMode, drawMouse, waitState, drawWinner; //outputs of FSM
	wire switchToPVP, switchToAI;
	wire [1:0] AIWinner, pvpWinner;
	reg [1:0] winner;
	
	always @(posedge CLOCK_50)
		begin
			if (aiMode == 1)
				//winner[1:0] = {AIWinner[0], AIWinner[1]};
				winner[1:0] = AIWinner[1:0];
			else
				winner[1:0] = pvpWinner[1:0];
		end
	pvp PVP(
		.clk(CLOCK_50),
		.KEY(KEY),
		.Mx(Mx),
		.My(My),
		.enable(pvpMode),
		.mouseClicked(mouseClicked),
		
		.switchMode(switchToAI),
		.outputColour(pvpColour),
		.outputX(pvp_X), 
		.outputY(pvp_Y),
		.winner(pvpWinner)
	);

	ai AI(
		.clk(CLOCK_50),
		.KEY(KEY),
		.Mx(Mx),
		.My(My),
		.enable(aiMode),
		.mouseClicked(mouseClicked),
		
		.switchMode(switchToPVP),
		.outputColour(aiColour),
		.outputX(ai_X), 
		.outputY(ai_Y),
		.winner(AIWinner)
	);
	
	drawWinnerAnimation drawWinnerAnim(
		.clk(CLOCK_50),
		.winner(winner),
		
		.vga_X(winnerX),
		.vga_Y(winnerY),
		.colour(winnerClr)
	);
		
	correction correct(
		.clk(CLOCK_50),
		.enable(correction),
		.x(correctionX),
		.y(correctionY)
	);
	
	//switch VGA input source
	always @(posedge CLOCK_50)
		
		if (drawMouse == 1)
			begin
				VGA_X = Mx;
				VGA_Y = My;
				colour = 3'b011;
			end
		else if (drawWinner == 1)
			begin
				VGA_X = winnerX;
				VGA_Y = winnerY;
				colour = winnerClr;
			end
		else if (correction == 1)
			begin
				VGA_X = correctionX;
				VGA_Y = correctionY;
				colour = 3'b100;
			end
		else if (pvpMode == 1)
			begin
				VGA_X = pvp_X;
				VGA_Y = pvp_Y;
				colour = pvpColour;
			end
		else if (aiMode == 1)
			begin
				VGA_X = ai_X;
				VGA_Y = ai_Y;
				colour = aiColour;
			end

			

	overallFSM mainFSM(
		.clk(CLOCK_50),
		.switchToAI(switchToAI),
		.switchToPVP(switchToPVP),
		.winner(winner),
		
		.pvpEnable(pvpMode),
		.aiEnable(aiMode),
		.drawMouse(drawMouse),
		.vgaEn(VGAEn),
		.drawWinner(drawWinner),
		.correction(correction)
	);
		
endmodule


module overallFSM(input clk, switchToAI, switchToPVP, input [1:0] winner, output pvpEnable, aiEnable, drawMouse, vgaEn, drawWinner, correction);
	parameter pvp = 0, ai = 1, pvpDrawMouse = 2, aiDrawMouse = 3, pvpWait = 4, aiWait = 5, switchToPVPWait = 6, switchToAIWait = 7, pvpDrawWinner = 8, AIDrawWinner = 9;
	reg [3:0] currentState, nextState;
	
	
	reg startCount;
	integer count;
	always @(posedge clk)
		begin
			if (startCount == 1'b1)
				count <= count + 1;
			else
				count <= 1;
		end
		
		
	always @(*)
		case (currentState)
			pvp:
				if (count < 19200)
					begin
						nextState = pvp;
						startCount = 1;
					end
				else
					begin
						if (switchToAI == 1)
							nextState = switchToAIWait;
						else
							nextState = pvpDrawMouse;
							
						startCount = 0;
					end
					
			pvpDrawMouse:
				if (count < 20)
					begin
						nextState = pvpDrawMouse;
						startCount = 1;
					end
				else
					begin
						if (switchToAI == 1)
							nextState = switchToAIWait;
						else
							if (winner == 1 || winner == 2)
								nextState = pvpDrawWinner;
							else
								nextState = pvpWait;
							
						startCount = 0;
					end
					
			pvpWait: 
				if (count < 500000)
					begin
						nextState = pvpWait;
						startCount = 1;
					end
				else
					begin
						if (switchToAI == 1)
							nextState = switchToAIWait;
						else
							nextState = pvp;
							
						startCount = 0;
					end
				
			ai:
				if (count < 19200)
					begin
						nextState = ai;
						startCount = 1;
					end
				else
					begin
						if (switchToPVP == 1)
							nextState = switchToPVPWait;
						else
							nextState = aiDrawMouse;
							
						startCount = 0;
					end
					
			aiDrawMouse:
				if (count < 20)
					begin
						nextState = aiDrawMouse;
						startCount = 1;
					end
				else
					begin
						if (winner == 1 || winner == 2)
							nextState = AIDrawWinner;
						else
							nextState = aiWait;
							
							
						startCount = 0;
					end
					
			aiWait:
				if (count < 500000)
						begin
							nextState = aiWait;
							startCount = 1;
						end
					else
						begin
							if (switchToPVP == 1)
								nextState = switchToPVPWait;
							else
								nextState = ai;
								
							startCount = 0;
						end
						
			switchToPVPWait:
				if (switchToPVP == 1)
					nextState = switchToPVPWait;
				else
					nextState = pvp;
				
			switchToAIWait:
				if (switchToAI == 1)
					nextState = switchToAIWait;
				else
					nextState = ai;
					
					
			AIDrawWinner:
				if (count < 150)
					begin
						nextState = AIDrawWinner;
						startCount = 1;
					end
				else
					begin
						nextState = aiWait;
						startCount = 0;
					end
			pvpDrawWinner:		
				if (count < 150)
					begin
						nextState = pvpDrawWinner;
						startCount = 1;
					end
				else
					begin
						nextState = pvpWait;		
						startCount = 0;
					end
							
				
				
			default:
				nextState = pvpWait;
		endcase
		
		
	always @ (posedge clk)
		currentState = nextState;
		
		
	assign pvpEnable = (currentState == pvp || currentState == pvpWait || currentState == pvpDrawMouse || currentState == pvpDrawWinner || currentState == pvpWait);
	assign aiEnable = (currentState == ai || currentState == aiWait || currentState == aiDrawMouse || currentState == AIDrawWinner);
	assign drawMouse = (currentState == pvpDrawMouse || currentState == aiDrawMouse);
	assign vgaEn = 1;
	assign drawWinner = ( currentState == AIDrawWinner || currentState == pvpDrawWinner);
	assign correction = (currentState == pvpWait || currentState == aiWait);

endmodule