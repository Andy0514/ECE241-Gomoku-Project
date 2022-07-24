module correction(
	input clk,
	input enable,
	output reg [7:0]x,
	output reg [7:0]y
);


	reg [1:0] count;
	always @(posedge clk)
		begin
			if (count == 2'd0)
				begin
					x = 158;
					y = 119;
				end
				
			else if (count == 2'd1)
				begin
					x = 0;
					y = 0;
				end
			else if (count == 2'd2)
				begin
					x = 1;
					y = 0;
				end
			else
				begin
					x = 2;
					y = 0;
				end
			
			count = count + 1;
		end
				

endmodule