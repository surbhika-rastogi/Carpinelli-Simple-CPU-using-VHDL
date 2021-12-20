library ieee ; 
use ieee.std_logic_1164.all ;

entity tb_VSCPU is end entity ;

architecture stim of tb_VSCPU is 

  constant INSTR_add : std_logic_vector( 2 downto 0 ) := "000" ;
  constant INSTR_and : std_logic_vector( 2 downto 0 ) := "001" ;
  constant INSTR_jmp : std_logic_vector( 2 downto 0 ) := "010" ;
  constant INSTR_inc : std_logic_vector( 2 downto 0 ) := "011" ;
  constant INSTR_cmp : std_logic_vector( 2 downto 0 ) := "100" ; --compare operands stored in accumulator with those stored in specified memory location and sets/resets carry flag
  constant INSTR_sll : std_logic_vector( 2 downto 0 ) := "101" ; --logical left shift on contents stored in accumulator
  constant INSTR_ral : std_logic_vector( 2 downto 0 ) := "110" ; --rotate contents of accumulator to left and sets/resets carry flag high
  constant INSTR_jnc : std_logic_vector( 2 downto 0 ) := "111" ; --jump to a specified memory location if carry flag is reset


  constant A_WIDTH : integer := 8 ; 
  constant D_WIDTH : integer := 16 ;
  
  signal clk , reset , start , write_en : std_logic ;
  signal addr : std_logic_vector( A_WIDTH-1 downto 0 ) ; 
  signal data : std_logic_vector ( D_WIDTH-1 downto 0 ) ;
  signal status : std_logic;

  procedure do_synch_active_high_half_pulse ( 
      signal formal_p_clk : in std_logic ; 
      signal formal_p_sig : out std_logic 
    ) is
  begin
    wait until formal_p_clk='0' ;  formal_p_sig <= '1' ;
    wait until formal_p_clk='1' ;  formal_p_sig <= '0' ;
  end procedure ;

  procedure do_program ( 
      signal formal_p_clk : in std_logic ; 
      signal formal_p_write_en : out std_logic ; 
      signal formal_p_addr_out , formal_p_data_out : out std_logic_vector ;
      formal_p_ADDRESS_in , formal_p_DATA_in : in std_logic_vector     
    ) is
  begin
    wait until formal_p_clk='0' ;  formal_p_write_en <= '1' ;
    formal_p_addr_out <= formal_p_ADDRESS_in ; 
    formal_p_data_out <= formal_p_DATA_in ;
    wait until formal_p_clk='1' ;  formal_p_write_en <='0' ;
  end procedure ;

begin

--Simple VSCPU under test:
  dut_vscpu : entity work.vscpu( rch )
      port map ( clock => clk , reset => reset , start => start ,
             mem_write => write_en , addr => addr  , data => data , status =>status) ;
             
  process begin
    clk <= '0' ;
    for i in 0 to 99 loop 
      wait for 1 ns ; clk <= '1' ;  wait for 1 ns ; clk <= '0';
    end loop ;
    wait ;
  end process ;

  
  process begin
    reset <= '0' ;  start <= '0' ; write_en <= '0' ;
    addr <= "00000000" ;  data <= "0000000000000000" ;
    do_synch_active_high_half_pulse ( clk, reset ) ; -- acc=0
	 
	 -- signal formal_p_clk , formal_p_write_en , formal_p_addr_out , formal_p_data_out ,formal_p_ADDRESS_in , formal_p_DATA_in
    do_program ( clk, write_en, addr, data, "00000001" , INSTR_add & "000000000" & "1001"  ) ; 
    -- LABEL1 acc += mem [ 9 ]
    do_program ( clk, write_en, addr, data, "00000010" , INSTR_and & "000000000" & "1010"  ) ; 
    -- acc &= mem [ 10 ]
    do_program ( clk, write_en, addr, data, "00000011" , INSTR_inc & "000000000" & "0000"  ) ; 
    -- acc += 1
	 do_program ( clk, write_en, addr, data, "00000100" , INSTR_cmp & "000000000" & "1011"  ) ; 
    -- cmp(acc, mem[11])
	 do_program ( clk, write_en, addr, data, "00000101" , INSTR_jnc & "000000000" & "0001"  ) ; 
    -- conditional jmp to LABEL1 if cy = 0
	 do_program ( clk, write_en, addr, data, "00000110" , INSTR_sll & "000000000" & "0000"  ) ; 
    -- shift logical left on accumulator (highest bit discarded, lowest bit gets a zero)
	 do_program ( clk, write_en, addr, data, "00000111" , INSTR_ral & "000000000" & "0000"  ) ; 
    -- rotate contents of acc to left with carry
	 do_program ( clk, write_en, addr, data, "00001000" , INSTR_jmp & "000000000" & "0001"  ) ; 
    -- jmp to LABEL1
	 
    do_program ( clk, write_en, addr, data, "00001001" , X"0027"  ) ; -- mem[ 9  ]
    do_program ( clk, write_en, addr, data, "00001010" , X"0039"  ) ; -- mem[ 10 ]
	 do_program ( clk, write_en, addr, data, "00001011" , X"0022"  ) ; -- mem[ 11 ]
                                                                      
    do_synch_active_high_half_pulse ( clk, start ) ; 
    wait ;
  end process ;
end architecture ;


