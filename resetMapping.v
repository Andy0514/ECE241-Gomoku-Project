module resetMapping(
		input [7:0] inX, inY,
		input mouseClicked,
		output reg reset,
		output reg back
		);
		
	always@(*)
		begin
		
			if (inX >= 67 && inX <= 93 && inY >= 109 && inY <= 118 && mouseClicked == 1) //negative reset
				reset = 0;
			else
				reset = 1;
				
			if (inX >= 15 && inX <= 41 && inY >= 109 && inY <= 118 && mouseClicked == 1)
				back = 1;
			else
				back = 0;
		end
		
endmodule