
module cpu (
	clk_clk,
	enable_export,
	in1_export,
	in2_export,
	in3_export,
	in4_export,
	outx_export,
	outy_export,
	ready_export,
	reset_reset_n);	

	input		clk_clk;
	input		enable_export;
	input	[31:0]	in1_export;
	input	[31:0]	in2_export;
	input	[31:0]	in3_export;
	input	[31:0]	in4_export;
	output	[2:0]	outx_export;
	output	[2:0]	outy_export;
	output		ready_export;
	input		reset_reset_n;
endmodule
