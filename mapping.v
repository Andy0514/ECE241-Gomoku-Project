module mapping(

	input [7:0] in,
	output reg [3:0] result
);
	always @(*)
	
		if (in > 2 && in < 15)
			result = 0;
		else if (in > 15 && in < 28)
			result = 1;
		else if (in > 28 && in < 41)
			result = 2;
		else if (in > 41 && in < 54)
			result= 3;
		else if (in > 54 && in < 67)
			result = 4;
		else if (in > 67 && in < 80)	
			result = 5;
		else if (in > 80 && in < 93)
			result = 6;
		else if (in > 93 && in < 106)
			result = 7;
		else
			result = 8;

endmodule