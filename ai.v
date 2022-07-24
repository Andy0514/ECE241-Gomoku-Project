module ai
	(
		input clk,						//	On Board 50 MHz
		// Your inputs and outputs here
		input [3:0] KEY,
		input [7:0] Mx, My,
		input enable,
		input mouseClicked,
		
		
		output switchMode,
		output reg [2:0] outputColour,
		output reg [7:0] outputX, outputY,
		output reg [1:0] winner
	);

	
	// Create the colour, x, y and writeEn wires that are inputs to the controller
	wire boardWriteEn;
	wire [7:0] mouseX;
	wire [7:0] mouseY;
	wire DrawCursor;
	wire resetBoard;
	wire switch;
	wire aiGetMove;
		
	
	//wires that are input sources for game board memory module
	wire [14:0] pieceBoardAddress, currentTurnBoardAddress, winAddress;
	reg [14:0] boardAddress;
	wire [2:0] pieceData, currentTurnData;
	reg [2:0] boardDataIn;
	wire [2:0] boardDataOut;
	reg [3:0] drawBoard;
	wire currentPlayer;
	wire aiDone;
	
	//wires that are input sources for VGA module
	wire [2:0] resetColour, winColour;
	
	reg [3:0] xMem, yMem;
	wire [3:0] xPosition, yPosition, AIMoveX, AIMoveY;
	
	mapping mapX(.in(mouseX), .result(xPosition));
	mapping mapY(.in(mouseY), .result(yPosition));
	
	
	wire clearBoard, drawTurn;
	
	gameStateImage boardAI(
			.address(boardAddress),
			.clock(clk),
			.wren(boardWriteEn),
			.data(boardDataIn),
			
			.q(boardDataOut)
	);
	
	
	switchColor(
			.clk(clk),
			.enable(switch),
			.pieceColor(currentPlayer)
	);
	
	writeToMemAI writeToBoardAI( //writing to board and VGA have similar processes
			.clk(clk),
			.enable(updatePiece),
			.SW({yMem[2:0], xMem[2:0]}),
			.pieceColor(currentPlayer),
			
			.writeToMemData(pieceData),
			.writeToMemAddress(pieceBoardAddress)
	);
	
	//switches between piece position sources (AI vs human)
	always @(posedge clk)
		if (AITurn == 0)
			//player's move
			begin
				xMem = xPosition;
				yMem = yPosition;
			end
		else
			begin
				xMem = AIMoveX;
				yMem = AIMoveY;
			end

	//module that displays whose turn it is
	drawCurrentAIPlayer drawPlayerToBoardAI(
			.clk(clk),
			.currentPlayer(currentPlayer),
			.enableDraw(drawTurn),
			
			.writeToMemData(currentTurnData),
			.writeToMemAddress(currentTurnBoardAddress)
	);
	
	//module that checks BOTH if an input is valid and if a side has won
	wire resultObtained, validInput;
	wire [1:0] winResult;
	wire checkWinning, blackWin, whiteWin, tie, deleteLastMouse, updatePiece, AITurn;

	getAIMove getaimove(
				.clk(clk),
				.updateStatus(updatePiece),
				.initializeAI(aiGetMove),
				.resetBoard(clearBoard),
				.xPosition(xMem),
				.yPosition(yMem),
				.selector(currentPlayer),
				
				.playX(AIMoveX),
				.playY(AIMoveY),
				.aiDone(aiDone));
	
	
	checkWinAIMode checkForWin(
				.clk(clk), 
				.updateStatus(updatePiece), 
				.checkWinning(checkWinning), 
				.resetBoard(clearBoard), 
				.selector(currentPlayer), 
				.xPosition(xMem),
				.yPosition(yMem),
				
				.resultObtained(resultObtained),
				.validInput(validInput),
				.outputResult(winResult));
							
	//module that prints the win message, which differs based on white or black piece wins
	winMessage printWins( 
				.clk(clk), 
				.whiteWin(whiteWin),
				.blackWin(blackWin),
				.tie(tie),
				.writeToMemAddress(winAddress),
				
				.colour(winColour));
							
	always @(posedge clk)
		begin
			if (winResult == 0 ||winResult == 3)
				winner = 0;
			else 
				winner = winResult; //here, winner can only be 1 or 2
		end						

				
	//module that controls the resetting of display (ie after a game has been won)
	resetVGAImage clear_boardAI(
			.clk(clk), 
			.resetSignal(clearBoard), 
			.colour(resetColour), 

			.outputAddress(clearBoardAddress));
	
	
	
	//finite state machine module		
	FSM_AI fsm1AI(
				.clk(clk), 
				.enable(enable),
				.resetSignal(resetBoard), 
				.resultObtained(resultObtained), 
				.winResult(winResult), 
				.inputIsValid(validInput),
				.mouseClicked(mouseClicked),
				.Mx(Mx),
				.My(My),
				.currentPlayer(currentPlayer),
				.aiDone(aiDone),
				
				.DrawCursor(DrawCursor),
				.boardEn(boardWriteEn), 
				.reset(clearBoard), 
				.checkWinning(checkWinning), 
				.blackWin(blackWin), 
				.whiteWin(whiteWin),
				.tie(tie),
				.drawTurn(drawTurn),
				.deleteLastMouse(deleteLastMouse),
				.mouseX(mouseX),
				.mouseY(mouseY),
				.updatePiece(updatePiece),
				.AITurn(AITurn),
				.switch(switch),
				.aiGetMove(aiGetMove)
	);
				

					
	wire [7:0] delX, delY;
	wire [14:0] delAddress, clearBoardAddress;
	deleteMouse delMAI(
		.clk(clk),
		.deleteSignal(deleteLastMouse),
		.deleteX(delX),
		.deleteY(delY),
		.address(delAddress) );
	//switch between board RAM sources and addresses, depending on the current mode
	always @(posedge clk)
		if (clearBoard == 1)
			begin
				boardAddress = clearBoardAddress;
				boardDataIn = resetColour;
			end
		else if (drawTurn == 1)
			begin
				boardAddress = currentTurnBoardAddress;
				boardDataIn = currentTurnData;
			end
		else if (deleteLastMouse == 1)
			begin
				boardAddress = delAddress +4;
				if (boardAddress >= 19200)
					boardAddress = boardAddress - 19200;
					
				outputX = delX;
				outputY = delY;
				outputColour = boardDataOut;
			end
		else if (blackWin == 1 || whiteWin == 1 || tie == 1)
			begin
				boardAddress = winAddress + 4;
				if (boardAddress >= 19200)
					boardAddress = boardAddress - 19200;
				boardDataIn = winColour;
			end
		else
			begin
				boardAddress = pieceBoardAddress + 4;
				if (boardAddress >= 19200)
					boardAddress = boardAddress - 19200;
				boardDataIn = pieceData;
			end
	
	resetMapping resetAndSwitchAI(
		.inX(Mx),
		.inY(My),
		.mouseClicked(mouseClicked),
		
		.reset(resetBoard),
		.back(switchMode)
	);

endmodule



module FSM_AI(input clk, enable, resetSignal, resultObtained, inputIsValid, mouseClicked, currentPlayer, aiDone, input [7:0] Mx, input [7:0] My, input [1:0] winResult, output boardEn, DrawCursor, reset, checkWinning, blackWin, whiteWin, tie, drawTurn, deleteLastMouse, updatePiece, AITurn, switch, aiGetMove, output reg [7:0] mouseX, output reg [7:0] mouseY);
	parameter waitForInput = 0, waitForRelease = 1, checkValid = 2, updateBoard = 3, updateStatus = 5, checkWin = 6, displayWinBlack = 7, displayWinWhite = 8, endGame = 9, clearWait = 10, clearBoard = 11, displayWinTie = 12, printTurn = 13, drawNewMouse = 14, deleteMouse = 15, AIMove = 16, AIUpdateBoard = 17, switchColor = 18;
	reg [4:0] nextState, currentState;
	
	reg [7:0] fixMx, fixMy;
	//counter, to be used in FSM states that have a finite number of cycles
	reg startCount;
	integer count;
	always @(posedge clk)
		begin
			if (startCount == 1'b1)
				count <= count + 1;
			else
				count <= 1;
		end
		
	
	//always block that generates the next state
	always @(*)
		begin
			
			case (currentState)
				printTurn:
						if (count < 2001)
							begin
								nextState = printTurn;
								startCount = 1;
							end
						else
							begin
								startCount = 0;
								if (currentPlayer == 0)
									nextState = waitForInput;
								else
									nextState = AIMove;
							end
				waitForInput:
				
						if (mouseClicked == 1) 
							begin
								nextState = waitForRelease;
								fixMx = Mx;
								fixMy = My;
							end
						else
							nextState = deleteMouse;

				
				waitForRelease:
					//this state is used for debouncing and to prevent repeated drawing of the same thing
						if (mouseClicked == 0)
							begin
								nextState = checkValid;
								mouseX = fixMx;
								mouseY = fixMy;
							end
						else
							nextState = waitForRelease;
							
				checkValid:
						if (inputIsValid == 1)
							//valid, go to update board
							nextState = updateBoard;
						else
							//not valid (ie on top of another), get another input
							nextState = waitForInput;
				
				updateBoard:
					//this state cycles 144 times, which allows the piece to be written to board image memory
						if (count < 144)
							begin
								nextState = updateBoard;
								startCount = 1;
							end
						else
							begin
								nextState = checkWin;
								startCount = 0;
							end

				checkWin:
					//this state checks if anybody has won. It continues to run until we get a result
						if (resultObtained == 1 && winResult == 1)
							nextState = displayWinBlack;
						else if (resultObtained == 1 && winResult == 2)
							nextState = displayWinWhite;
						else if (resultObtained == 1 && winResult == 0)
							nextState = switchColor;
						else if (resultObtained == 1 && winResult == 3)
							nextState = displayWinTie;
						else
							nextState = checkWin;
							
				switchColor:
						nextState = printTurn;
						
				//the states that display a winner:
				displayWinBlack:
						if (count < 2000)
							begin
								nextState = displayWinBlack;
								startCount = 1;
							end
						else
							begin
								nextState = endGame;
								startCount = 0;
							end
				displayWinWhite:
						if (count < 2000)
							begin
								nextState = displayWinWhite;
								startCount = 1;
							end
						else
							begin
								nextState = endGame;
								startCount = 0;
							end
				displayWinTie:
					if (count < 2000)
							begin
								nextState = displayWinTie;
								startCount = 1;
							end
						else
							begin
								nextState = endGame;
								startCount = 0;
							end
				endGame:
						nextState = waitForInput;
							
				clearWait:
						if (resetSignal == 0)
							nextState = clearWait;
						else
							nextState = clearBoard;
				clearBoard:
						if (count < 19200)
							begin
								nextState = clearBoard;
								startCount = 1;
							end
						else
							begin
								nextState = printTurn;
								startCount = 0;
							end
				deleteMouse:
						if (count < 19200)
							begin
								nextState = deleteMouse;
								startCount = 1;
							end
						else
							begin
								nextState = drawNewMouse;
								startCount = 0;
							end
						
				drawNewMouse:
						if (count < 19200)
							begin
								nextState = drawNewMouse;
								startCount = 1;
								mouseX = Mx;
								mouseY = My;
							end
						else
							begin
								nextState = waitForInput;
								startCount = 0;
							end
						
				AIMove:
				
						if (aiDone == 1)
							nextState = AIUpdateBoard;
						else
							nextState = AIMove;
					
				AIUpdateBoard:
						if (count < 144)
							begin
								nextState = AIUpdateBoard;
								startCount = 1;
							end
						else
							begin
								nextState = checkWin;
								startCount = 0;
							end
					
							
				default: nextState = clearBoard;
					
			endcase
		end
						
			
		//updates the state registers
		always @(posedge clk)
			if (enable == 0)
				currentState <= clearWait;
			else if (resetSignal == 0)
				currentState <= clearWait;
			else
				currentState <= nextState;
		
		
		//assigns output based on state
		
		assign boardEn = (currentState == updateBoard ||  currentState == clearWait || currentState == clearBoard || currentState == printTurn || currentState == displayWinBlack || currentState == displayWinWhite || currentState == displayWinTie || currentState == AIUpdateBoard);
		assign reset = (currentState == clearBoard || currentState == clearWait);
		assign checkWinning = (currentState == checkWin);
		assign blackWin = (currentState == displayWinBlack);
		assign whiteWin = (currentState == displayWinWhite);
		assign tie = (currentState == displayWinTie);
		assign drawTurn = (currentState == printTurn);
		assign DrawCursor = (currentState == drawNewMouse);
		assign deleteLastMouse = (currentState == deleteMouse);
		assign updatePiece = (currentState == updateBoard || currentState == AIUpdateBoard);
		assign aiGetMove = (currentState == AIMove);
		assign switch = currentState == switchColor;
		assign AITurn = (currentState == AIMove || currentState == AIUpdateBoard);
						
endmodule
