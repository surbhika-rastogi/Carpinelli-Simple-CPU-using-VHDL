--Enhanced VSCPU
--Changes:
--1) Changed data lines from 8-bits to 16-bits. Databus, accumulator and data register are also 16 bits longer therefore.
--2) Changed address lines from 6 bits to 8 bits. So it can address 2^8 = 256 memory locations with 16-bits each (means 512Bytes).
--	  Also PC, AR is 8 bits.
--3) 4 more instructions added: CMP, SLL, RAL, JNC. So instruction register is now 3-bits long to hold 8 instructions.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--interfacing ports of the VSCPU
--8-bit address and 16-bit data 
entity vscpu is
generic (	VSCPU_D_WIDTH : integer := 16;
			VSCPU_A_WIDTH : integer := 8;
			PC_STARTS_AT : std_logic_vector( 7 downto 0) := "00000001" ) ; 
port (clock, reset, start, mem_write: in std_logic;
		addr	: in std_logic_vector(VSCPU_A_WIDTH-1 downto 0);
		data	: in std_logic_vector(VSCPU_D_WIDTH-1 downto 0);
		status : out std_logic);
end entity;

--behavioral functionality of the Carpinelli simple CPU
architecture rch of vscpu is

--VSCPU has eight instructions. They are assigned 3-bit notation here
constant INSTR_add: std_logic_vector(2 downto 0):= "000"; --addition of operand stored in accumulator with those specified in specified memory location
constant INSTR_and: std_logic_vector(2 downto 0):= "001"; --and operation
constant INSTR_jmp: std_logic_vector(2 downto 0):= "010"; --jump to specified memory location
constant INSTR_inc: std_logic_vector(2 downto 0):= "011"; --increment contents of accumulator
constant INSTR_cmp: std_logic_vector(2 downto 0):= "100"; --compare operands stored in accumulator with those stored in specified memory location and sets/resets carry flag
constant INSTR_sll: std_logic_vector(2 downto 0):= "101"; --shift logical left on contents stored in accumulator
constant INSTR_ral: std_logic_vector(2 downto 0):= "110"; --rotate contents of accumulator to left and sets/resets carry flag with highest bit of acc
constant INSTR_jnc: std_logic_vector(2 downto 0):= "111"; --jump to a specified memory location if carry flag is reset

--64 bytes of memory
TYPE ram IS ARRAY((2**VSCPU_A_WIDTH) - 1 downto 0) of std_logic_vector(VSCPU_D_WIDTH-1 downto 0);
signal mem: ram;

--memory address lines and read signal
signal mem_address : std_logic_vector(VSCPU_A_WIDTH-1 downto 0);
signal mem_read : std_logic := '0';

--VSCPU is able to perform all its operations by transitioning through following 10 states.
--State type and signal declaration
type t_state is (sthalt, stfetch1, stfetch2, stfetch3, stadd1, stadd2, stand1, stand2, stinc1, stjmp1, stcmp1, stcmp2, stsll, stral, stjnc);
signal stvar_ff, stvar_ns: t_state := sthalt;

--|VSCPU 4 registers:
--|6-bit address register (AR)
--|6-bit program counter (PC)
--|8-bit data register (DR)
--|2-bit instruction register (IR)
signal AC_ff, AC_ns: std_logic_vector(VSCPU_D_WIDTH -1 downto 0) := (others => '0');
signal PC_ff : std_logic_vector(VSCPU_A_WIDTH -1 downto 0) := PC_STARTS_AT;
signal PC_ns : std_logic_vector(VSCPU_A_WIDTH -1 downto 0) := (others => '0');
signal AR_ff, AR_ns: std_logic_vector(VSCPU_A_WIDTH -1 downto 0) := (others => '0');
signal IR_ff, IR_ns: std_logic_vector(2 downto 0) := (others => '0');
signal DR_ff, DR_ns: std_logic_vector(VSCPU_D_WIDTH -1 downto 0) := (others => '0');

--carry flag
signal cy_flag, cy_ns  : std_logic := '0';

--data bus of 8-bit
signal dbus : std_logic_vector(VSCPU_D_WIDTH-1 downto 0);

begin

--update of state storage registers
process begin 
	wait until clock='1';
	if reset = '1' then
		PC_ff <= PC_STARTS_AT;
		AC_ff <= (others => '0');
		AR_ff <= (others => '0');
		IR_ff <= (others => '0');
		DR_ff <= (others => '0');
		cy_flag <= '0';
	else
		stvar_ff <= stvar_ns;
		PC_ff <= PC_ns;
		AC_ff <= AC_ns;
		AR_ff <= AR_ns;
		IR_ff <= IR_ns;
		DR_ff <= DR_ns;
		cy_flag <= cy_ns;
	end if;
end process;


--combinational process for computing next values of datapath registers
process (stvar_ff, PC_ff, AC_ff, DR_ff, AR_ff, IR_ff, dbus, cy_flag)
begin
--first defaults
PC_ns <= PC_ff;
AC_ns <= AC_ff;
AR_ns <= AR_ff;
IR_ns <= IR_ff;
DR_ns <= DR_ff;
cy_ns <= cy_flag;
case(stvar_ff) is
	when sthalt => null;
	when stfetch1 => AR_ns <= PC_ff; 
	when stfetch2 => 
		PC_ns <= std_logic_vector(unsigned(PC_ff) +1);
		DR_ns <= dbus;
		IR_ns <= dbus(VSCPU_D_WIDTH-1 downto VSCPU_D_WIDTH-3); 
		AR_ns <= dbus(VSCPU_A_WIDTH-1 downto 0) ; 
	when stfetch3 => null;
	when stadd1 => DR_ns <= dbus;
	when stadd2 => AC_ns <= std_logic_vector(unsigned(AC_ff) + unsigned(DR_ff));
	when stand1 => DR_ns <= dbus;
	when stand2 => AC_ns <= AC_ff and DR_ff;
	when stinc1 => AC_ns <= std_logic_vector(unsigned(AC_ff) + 1);
	when stjmp1 => PC_ns <= DR_ff(VSCPU_A_WIDTH-1 downto 0);
	when stcmp1 => DR_ns <= dbus;
	when stcmp2 => if (AC_ff = DR_ff) then cy_ns <= '1'; else cy_ns <= '0'; end if;
	when stsll => AC_ns <= std_logic_vector(shift_left(unsigned(AC_ff), 1));
	when stral => cy_ns <= AC_ff(VSCPU_D_WIDTH-1);  AC_ns <= std_logic_vector(rotate_left(unsigned(AC_ff), 1));
	when stjnc => if cy_flag = '0' then PC_ns <= DR_ff(VSCPU_A_WIDTH-1 downto 0); end if;
end case;
end process;

--combinational process for computing next values of controller state
process (stvar_ff, PC_ff, AC_ff, DR_ff, AR_ff, IR_ff, dbus, start)
begin
--wait until clock = '1';
--first defaults
stvar_ns <= stvar_ff;
case(stvar_ff) is
	when sthalt => if(start ='1') then stvar_ns <= stfetch1; end if;
--	when sthalt =>   stvar_ns <= sthalt;
	when stfetch1 => stvar_ns <= stfetch2;
	when stfetch2 => stvar_ns <= stfetch3;
	when stfetch3 =>
		case(IR_ff) is
			when INSTR_add => stvar_ns <= stadd1;
			when INSTR_and => stvar_ns <= stand1;
			when INSTR_inc => stvar_ns <= stinc1;
			when INSTR_jmp => stvar_ns <= stjmp1;
			when INSTR_cmp => stvar_ns <= stcmp1;
			when INSTR_sll => stvar_ns <= stsll;
			when INSTR_ral => stvar_ns <= stral;
			when INSTR_jnc => stvar_ns <= stjnc;
			when others => null;
		end case;
	when stadd1 => stvar_ns <= stadd2;
	when stadd2 => stvar_ns <= stfetch1;
	when stand1 => stvar_ns <= stand2;
	when stand2 => stvar_ns <= stfetch1;
	when stinc1 => stvar_ns <= stfetch1;
	when stjmp1 => stvar_ns <= stfetch1;
	when stcmp1 => stvar_ns <= stcmp2;
	when stcmp2 => stvar_ns <= stfetch1;
	when stsll => stvar_ns <= stfetch1;
	when stral => stvar_ns <= stfetch1;
	when stjnc => stvar_ns <= stfetch1;
end case;
end process;

-- ram mem (with synchronous write and asynchronous reads)
process begin
	wait until clock = '1';
	if reset = '1' then
		for i in 0 to 63 loop
			mem(i) <= (others => '0');
		end loop;
	elsif (mem_write = '1') then 
		mem(to_integer(unsigned(mem_address))) <= data; 
	end if;
end process;

dbus <= mem(to_integer(unsigned(mem_address))) when mem_read = '1' else (others => '0');

mem_read <= '1' when stvar_ff=stfetch2 or stvar_ff=stadd1 or stvar_ff=stand1 or stvar_ff=stcmp1 else '0';

mem_address <= addr when sthalt = stvar_ff else AR_ff;


process
begin
wait until clock = '1';

if start = '1' then 
		report "==================>>> VSCPU start signal received!<<<=================";
		status <= '1';
end if;

if (stvar_ff = stfetch1) then
		report "--------------------> AC = " &integer'image(to_integer(unsigned(AC_ff)));
end if;
end process;

--update status of registers and signals on console
process (clock)
begin
report  "   clock = " &std_logic'image(clock)  
		 &"   reset = " &std_logic'image(reset)
		 &"   start = " &std_logic'image(start)
		 &"   write = " &std_logic'image(mem_write)
		 &"   PC = " &integer'image(to_integer(unsigned(PC_ff)))
		 &"   state = " &t_state'image(stvar_ff)
		 &"   AC = " &integer'image(to_integer(unsigned(AC_ff)))
		 &"   AR = " &integer'image(to_integer(unsigned(AR_ff)))
		 &"   IR = " &integer'image(to_integer(unsigned(IR_ff)))
		 &"   DR = " &integer'image(to_integer(unsigned(DR_ff)))
		 &"   carry flag = " &std_logic'image(cy_flag)
		 &"   data_bus = " &integer'image(to_integer(unsigned(dbus)))
		 &"   read = " &std_logic'image(mem_read)
		 &"   address = " &integer'image(to_integer(unsigned(mem_address)));
end process;


end architecture;

