	component cpu is
		port (
			clk_clk       : in  std_logic                     := 'X';             -- clk
			enable_export : in  std_logic                     := 'X';             -- export
			in1_export    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- export
			in2_export    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- export
			in3_export    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- export
			in4_export    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- export
			outx_export   : out std_logic_vector(2 downto 0);                     -- export
			outy_export   : out std_logic_vector(2 downto 0);                     -- export
			ready_export  : out std_logic;                                        -- export
			reset_reset_n : in  std_logic                     := 'X'              -- reset_n
		);
	end component cpu;

	u0 : component cpu
		port map (
			clk_clk       => CONNECTED_TO_clk_clk,       --    clk.clk
			enable_export => CONNECTED_TO_enable_export, -- enable.export
			in1_export    => CONNECTED_TO_in1_export,    --    in1.export
			in2_export    => CONNECTED_TO_in2_export,    --    in2.export
			in3_export    => CONNECTED_TO_in3_export,    --    in3.export
			in4_export    => CONNECTED_TO_in4_export,    --    in4.export
			outx_export   => CONNECTED_TO_outx_export,   --   outx.export
			outy_export   => CONNECTED_TO_outy_export,   --   outy.export
			ready_export  => CONNECTED_TO_ready_export,  --  ready.export
			reset_reset_n => CONNECTED_TO_reset_reset_n  --  reset.reset_n
		);

