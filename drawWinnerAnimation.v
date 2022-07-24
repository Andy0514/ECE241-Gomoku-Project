module drawWinnerAnimation(

	input clk, 
	input [1:0] winner,
	
	output [7:0] vga_X, vga_Y,
	output reg [2:0] colour
);

	
	//all the frames stored in memory
	reg [7:0] address, x, y;
	wire [2:0] w1, w2, w3, w4, w5, b1, b2, b3, b4, b5;
	
	black1 B1(
		.clock(clk),
		.address(address),
		
		.q(b1)
	);

	black2 B2(
		.clock(clk),
		.address(address),
		
		.q(b2)
	);
	
	black3 B3(
		.clock(clk),
		.address(address),
		
		.q(b3)
	);
	
	black4 B4(
		.clock(clk),
		.address(address),
		
		.q(b4)
	);
	
	black5 B5(
		.clock(clk),
		.address(address),
		
		.q(b5)
	);
	
	white1 W1(
		.clock(clk),
		.address(address),
		
		.q(w1)
	);

	white2 W2(
		.clock(clk),
		.address(address),
		
		.q(w2)
	);
	
	white3 W3(
		.clock(clk),
		.address(address),
		
		.q(w3)
	);
	
	white4 W4(
		.clock(clk),
		.address(address),
		
		.q(w4)
	);
	
	white5 W5(
		.clock(clk),
		.address(address),
		
		.q(w5)
	);
	
	//x from 128 to 139, y from 107 to 118
	always @(posedge clk)
		begin //updates the x and y, as well as address
		
			if (x < 139)
				x <= x + 1;
			else if (y < 118)
				begin
					x <= 128;
					y <= y + 1;
				end
			else
				begin
					x <= 128;
					y <= 107;
				end
			address = (x-128) + (y-107) * 12;
		end
		
	assign vga_X = x;
	assign vga_Y = y;
	//down counter that controls what sequence to show
	//count for 2 seconds - cycle between animation in those 2 seconds
	reg [31:0] count;
	
	
	always @(posedge clk)
		begin
			count <= count + 1;

			if (count < 8000000)
				if (winner == 1)
					colour = b1;
				else
					colour = w1;
			else if (count < 14000000)
				if (winner == 1)
					colour = b2;
				else 
					colour = w2;
			else if (count < 22000000)
				if (winner == 1)
					colour = b3;
				else 
					colour = w3;
			else if (count < 32000000)
				if (winner == 1)
					colour = b4;
				else 
					colour = w4;
			else if (count < 40000000)
				if (winner == 1)
					colour = b5;
				else 
					colour = w5;
			else if (count < 48000000)
				if (winner == 1)
					colour = b4;
				else
					colour = w4;
			else if (count < 56000000)
				if (winner == 1)
					colour = b3;
				else 
					colour = w3;
			else if (count < 64000000)
				if (winner == 1)
					colour = b2;
				else
					colour = w2;
			else if (count < 72000000)
				if (winner == 1)
					colour = b1;
				else
					colour = w1;
			else if (count == 76000000)
				begin
					colour = 3'b100;
					count <= 0;
				end

		end
endmodule