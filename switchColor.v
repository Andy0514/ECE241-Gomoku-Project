module switchColor(
	input clk,
	input enable,
	output reg pieceColor
	);
	
	reg lastEnable;
	
	always @(posedge clk)
		begin
//			pieceColor = 1;
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
		end
			
endmodule