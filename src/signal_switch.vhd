library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



entity signal_switch is
	port
	(
		rst_n		: in  std_logic;
		clk   	    : in  std_logic;
		sig_i   	: in  std_logic;
		sig0_o   	: out std_logic;
		sig1_o   	: out std_logic
	);
end entity signal_switch;


architecture rtl of signal_switch is

  
	
	signal en_0         : std_logic;
	signal en_1         : std_logic;
	signal clk_prv_s    : std_logic;
	signal clk_prv      : std_logic;
	signal clk_inv      : std_logic;
    signal stdby_sed    : std_logic;
      
    
begin



 en_1 <= not en_0;
 
 

  process(clk, rst_n)
    begin
    if(rst_n = '0') then                                 
        clk_prv   <= '0';                               
        clk_prv_s   <= '0';                               
    elsif(clk'event and clk = '1') then                                 
        clk_prv_s   <= sig_i;                        
        clk_prv     <= clk_prv_s;     
    end if;
    end process; 
    
  process(clk, rst_n)
    begin
    if(rst_n = '0') then                                 
        clk_inv   <= '1';                               
    elsif(clk'event and clk = '1') then                                 
        clk_inv   <= not clk_prv;     
    end if;
    end process; 

    
  process(clk, rst_n)
    begin
    if(rst_n = '0') then                                 
        en_0   <= '0';                               
    elsif(clk'event and clk = '1') then    
        if clk_prv_s = '1' and clk_prv = '0' then 
            en_0   <= not en_0;     
        end if;
    end if;
    end process; 


  process(clk, rst_n)
    begin
    if(rst_n = '0') then                                 
        sig0_o   <= '0';                                   
    elsif(clk'event and clk = '1') then
        if en_0 = '1' then
            sig0_o   <= clk_prv;            
        else                         
            sig0_o   <= '0';    
        end if;
    end if;
    end process; 

  process(clk, rst_n)
    begin
    if(rst_n = '0') then                                 
        sig1_o   <= '0';                                   
    elsif(clk'event and clk = '1') then
        if en_1 = '1' then
            sig1_o   <= clk_prv;            
        else                         
            sig1_o   <= '0';    
        end if;
    end if;
    end process; 




	

	
end architecture;