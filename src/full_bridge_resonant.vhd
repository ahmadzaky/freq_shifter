library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--library machXO3;
--use machXO3.all;


entity full_bridge_resonant is
	port
	(
		clk_i     	: in  std_logic;
		input_freq	: in  std_logic;
		button_up  	: in  std_logic;
		button_dw  	: in  std_logic;
		button_sel  : in  std_logic;
		clock_o   	: out std_logic;
		sig_a_0   	: out std_logic;
		sig_a_1   	: out std_logic;
		sig_b_0   	: out std_logic;
		sig_b_1   	: out std_logic
	);
end entity full_bridge_resonant;


architecture rtl of full_bridge_resonant is

--   COMPONENT OSCH
--   GENERIC (NOM_FREQ: string := "88.67");
--   PORT ( STDBY:IN std_logic;
--         OSC:OUT std_logic;
--          SEDSTDBY:OUT std_logic);
--  END COMPONENT;
-- 
--   attribute NOM_FREQ : string;
--   attribute NOM_FREQ of OSCinst0 : label is "88.67";
  
 component pll IS
	PORT
	(
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
END component;

component frequency_shifter is
	port
	(
		rst_n		: in  std_logic;
		clk     	: in  std_logic;
	    data    	: in  std_logic_vector (11 downto 0);-- := "000000110000";
		sig_i   	: in  std_logic;
		sig_a   	: out std_logic;
		sig_o   	: out std_logic
	);
end component;


component signal_switch is
	port
	(
		rst_n		: in  std_logic;
		clk   	    : in  std_logic;
		sig_i   	: in  std_logic;
		sig0_o   	: out std_logic;
		sig1_o   	: out std_logic
	);
end component;

component clock_delay is
	port
	(
		rst_n		: in  std_logic;
		clk		    : in  std_logic;
		data		: in  std_logic_vector (11 downto 0);
		clk_i   	: in  std_logic;
		clk_o   	: out std_logic
	);
end component;

	signal phase_selector : std_logic_vector (4 downto 0) := "00000";
	signal const_data	: std_logic_vector (11 downto 0) := "000011000100";
	signal const_delay	: std_logic_vector (11 downto 0) := "000000011110";
    signal stdby_sed    : std_logic;
    signal clk          : std_logic;
    signal out_ch_1     : std_logic;
    signal up_s         : std_logic;
    signal dw_s         : std_logic;
    signal up_ss        : std_logic;
    signal dw_ss        : std_logic;
    signal up_sss       : std_logic;
    signal dw_sss       : std_logic;
    signal rst_n		: std_logic;
    signal signal_i		: std_logic;
    signal signal_s		: std_logic;
    signal signal_ss	: std_logic;
    signal phase_11		: std_logic_vector (11 downto 0);
    signal phase_22		: std_logic_vector (11 downto 0);
    signal phase_67		: std_logic_vector (11 downto 0);
    signal phase_45		: std_logic_vector (11 downto 0);
    signal phase_90		: std_logic_vector (11 downto 0);
    signal phase_180    : std_logic_vector (11 downto 0);
	signal count	    : std_logic_vector (11 downto 0);
	signal freq_count	: std_logic_vector (11 downto 0);
	signal s_sig_a_0   	: std_logic;
	signal s_sig_b_0   	: std_logic;
    
begin

--OSCInst0: OSCH
-- GENERIC MAP( NOM_FREQ => "88.67" )
-- PORT MAP (STDBY=> '0',
--    OSC => clk,
--    SEDSTDBY => stdby_sed
-- );

 --clk <= clk_i;

 clock_o <= clk;

    CLK_pll : pll
  	port map
  	(
  		inclk0	=> clk_i,
  		c0		=> clk,
  		locked	=> rst_n
  	);

DUT_0 : frequency_shifter 
	port map
	(
		rst_n		=>  rst_n,
		clk   	    =>  clk,
	    data    	=>  const_delay,
		sig_i   	=>  input_freq,
		sig_a   	=>  sig_a_1,
		sig_o   	=>  s_sig_a_0
	);
    
    sig_a_0 <= s_sig_a_0;
    sig_b_0 <= s_sig_b_0;
    
 DUT_1 : frequency_shifter 
 	port map
 	(
 		rst_n		=>  rst_n,
 		clk   	    =>  clk,
 	    data    	=>  const_delay,
 		sig_i   	=>  out_ch_1,
 		sig_a   	=>  sig_b_1,
 		sig_o   	=>  s_sig_b_0
 	);
    
    CD : clock_delay
	port map
	(
		rst_n		=> rst_n,
		clk		    => clk,
		data		=> const_data,
		clk_i   	=> input_freq,
		clk_o   	=> out_ch_1
	);
    
    CD_A : clock_delay
	port map
	(
		rst_n		=> rst_n,
		clk		    => clk,
		data		=> phase_180,
		clk_i   	=> s_sig_a_0
	--	clk_o   	=> sig_a_1
	);
    
    CD_B : clock_delay
	port map
	(
		rst_n		=> rst_n,
		clk		    => clk,
		data		=> phase_180,
		clk_i   	=> s_sig_b_0
	--	clk_o   	=> sig_b_1
	);
    
   
  process(clk, rst_n)
    begin
    if(rst_n = '0') then                                 
        signal_i     <= '0';                             
        signal_s     <= '0';                             
        signal_ss    <= '0';                              
    elsif(clk'event and clk = '1') then                                  
        signal_i     <= input_freq;                               
        signal_s     <= signal_i;                              
        signal_ss    <= signal_s;      
    end if;
    end process; 
    
    
  process(clk, rst_n)
    begin
    if(rst_n = '0') then                                 
        count     <= (others => '0');                               
    elsif(clk'event and clk = '1') then  
        if  signal_s = '1' and  signal_ss = '0' then            
            count   <= (others => '0');    
        else
            count   <= count+1;
        end if;
    end if;
    end process; 
    
  process(clk, rst_n)
    begin
    if(rst_n = '0') then                                 
        freq_count     <= (others => '0');                               
    elsif(clk'event and clk = '1') then    
        if  signal_s = '0' and  signal_i = '1' then
            freq_count   <= count;
        end if;
    end if;
    end process; 
    
  process(clk, rst_n)
    begin
    if(rst_n = '0') then                                 
        phase_67 <= (others => '0');                               
    elsif(clk'event and clk = '1') then    
        phase_67 <= phase_45 + phase_22;
    end if;
    end process; 
    
    phase_180 <= '0' & freq_count(11 downto 1);
    phase_90  <= "00" & freq_count(11 downto 2);
    phase_45  <= "000" & freq_count(11 downto 3);
    phase_22  <= "0000" & freq_count(11 downto 4);
    phase_11  <= "00000" & freq_count(11 downto 5);
    
       process(clk, rst_n)
       variable v_const_data : std_logic_vector(11 downto 0) := "000000000001";
        begin
        if rst_n = '0' then
            v_const_data := phase_90;
            const_data   <= phase_90;
        elsif clk'event and clk = '0' then 
            case phase_selector is
                when "00000" =>
                    v_const_data := "000000000001";
                when "00001" =>
                    v_const_data := phase_11;
                when "00010" =>
                    v_const_data := phase_22;
                when "00011" =>
                    v_const_data := phase_22 + phase_11;
                when "00100" =>
                    v_const_data := phase_45;
                when "00101" =>
                    v_const_data := phase_45 + phase_11;
                when "00110" =>
                    v_const_data := phase_45 + phase_22;
                when "00111" =>
                    v_const_data := phase_45 + (phase_22 + phase_11);
                when "01000" =>
                    v_const_data := phase_90;
                when "01001" =>
                    v_const_data := phase_90 + phase_11;
                when "01010" =>
                    v_const_data := phase_90 + phase_22;
                when "01011" =>
                    v_const_data := phase_90 + (phase_22 + phase_11);
                when "01100" =>
                    v_const_data := phase_90 + phase_45;
                when "01101" =>
                    v_const_data := phase_90 + (phase_45 + phase_11);
                when "01110" =>
                    v_const_data := phase_90 + (phase_45 + phase_22);
                when "01111" =>
                    v_const_data := (phase_90 + phase_11) + phase_67;
                when "10000" =>
                    v_const_data := phase_180;
                when "10001" =>
                    v_const_data := phase_180 + phase_11;
                when "10010" =>              
                    v_const_data := phase_180 + phase_22;
                when "10011" =>              
                    v_const_data := phase_180 + (phase_22 + phase_11);
                when "10100" =>              
                    v_const_data := phase_180 + phase_45;
                when "10101" =>              
                    v_const_data := phase_180 + phase_45 + phase_11;
                when "10110" =>              
                    v_const_data := phase_180 + phase_67;
                when "10111" =>
                    v_const_data := phase_180 + phase_67 + phase_11;
                when "11000" =>
                    v_const_data := phase_180 + phase_90;
                when "11001" =>
                    v_const_data := phase_180 + (phase_90 + phase_11);
                when "11010" =>
                    v_const_data := phase_180 + (phase_90 + phase_22);
                when "11011" =>
                    v_const_data := (phase_180+ phase_11) + (phase_90 + phase_22);
                when "11100" =>
                    v_const_data := phase_180 + (phase_90 + phase_45);
                when "11101" =>
                    v_const_data := (phase_180+ phase_11) + (phase_90 + phase_45);
                when "11110" =>
                    v_const_data := phase_180 + (phase_90 + phase_67);
                when "11111" =>
                    v_const_data := (phase_180+ phase_11) + (phase_90 + phase_67);
                when others =>
                    v_const_data := phase_90;     
        end case;
            const_data <= v_const_data;
    end if;
end process; 
    
  process(clk, rst_n)
    begin
    if(rst_n = '0') then                                 
        up_s     <= '1';                               
        up_ss    <= '1';                               
        up_sss   <= '1';                             
    elsif(clk'event and clk = '1') then                                  
        up_s     <= button_up;                               
        up_ss    <= up_s;                               
        up_sss   <= up_ss;  
    end if;
    end process; 
    
  process(clk, rst_n)
    begin
    if(rst_n = '0') then                                 
        dw_s     <= '1';                               
        dw_ss    <= '1';                               
        dw_sss   <= '1';                             
    elsif(clk'event and clk = '1') then                                  
        dw_s     <= button_dw;                               
        dw_ss    <= dw_s;                               
        dw_sss   <= dw_ss;  
    end if;
    end process; 


  process(clk, rst_n)
    begin
    if(rst_n = '0') then                                 
        phase_selector	<= "01000";                         
    elsif(clk'event and clk = '1') then  
        if button_sel = '1' then
            if dw_sss = '1' and dw_ss = '0' then
                phase_selector <= phase_selector-1;
            elsif up_sss = '1' and up_ss = '0' then
                phase_selector <= phase_selector+1;
            end if;
        end if;
    end if;
    end process; 

  process(clk, rst_n)
    begin
    if(rst_n = '0') then                                 
        const_delay	<= "000000001110";                         
    elsif(clk'event and clk = '1') then  
        if button_sel = '0' then
            if dw_sss = '1' and dw_ss = '0' then
                const_delay <= const_delay-1;
            elsif up_sss = '1' and up_ss = '0' then
                const_delay <= const_delay+1;
            end if;
        end if;
    end if;
    end process; 

end rtl;