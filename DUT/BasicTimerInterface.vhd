				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY BT_Interface IS
	generic (ResSize : positive := 32;
			address_size_orig :positive:=12
			); 
	PORT(  clock,reset_timer       	     : IN 	 STD_LOGIC;
		   memRead,	memWrite 			 : IN 	 STD_LOGIC;
		   Address_Bus       			 : IN 	 STD_LOGIC_VECTOR( address_size_orig-1 DOWNTO 0 );
		   Data_Bus         			 : INOUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		   OUT_signal       			 : OUT 	 STD_LOGIC;
		   set_TBIFG					 : OUT 	 STD_LOGIC
		   );
END 	BT_Interface;

ARCHITECTURE behavior OF BT_Interface IS
signal CS6,CS7,CS8,CS9 						   : STD_LOGIC;
-------------------------------------------------Basic timer-------------------------------------
signal 			BTCCR1,BTCCR0 			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
signal			BTCNT_In 				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
signal			BTCTL 					: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
signal			BTCNT_Out 				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
-----------------------------------------------------------------------------------
alias A11 is Address_Bus(11);
alias A5  is Address_Bus(5);
alias A4  is Address_Bus(4);
alias A3  is Address_Bus(3);
alias A2  is Address_Bus(2);
alias A1  is Address_Bus(1);
alias A0  is Address_Bus(0);
BEGIN
	CS6<='1' when (A11='1' and A5='0' and A4='1' and A3='1' and A2='1' and A1='0') else '0'; --BTCTL
	CS7<='1' when (A11='1' and A5='1' and A4='0' and A3='0' and A2='0' and A1='0') else '0'; --BTCNT
	CS8<='1' when (A11='1' and A5='1' and A4='0' and A3='0' and A2='1' and A1='0') else '0'; --BTCCR0
	CS9<='1' when (A11='1' and A5='1' and A4='0' and A3='1' and A2='0' and A1='0') else '0'; --BTCCR1
	
	-----------------------------------write to Data bus	
	Data_Bus <=X"000000"&BTCTL  when (CS6='1' and memRead='1') else (others=>'Z');
	Data_Bus <=BTCNT_Out 		when (CS7='1' and memRead='1') else (others=>'Z');
	Data_Bus <=BTCCR0			when (CS8='1' and memRead='1') else (others=>'Z');
	Data_Bus <=BTCCR1 			when (CS9='1' and memRead='1') else (others=>'Z');
	
	BasicTimer_portmap:BasicTimer PORT MAP (	
			BTCCR1					=> BTCCR1,
			BTCCR0					=> BTCCR0,
			BTCNT_In 			    => BTCNT_In,
			BTCTL 					=> BTCTL,
			clock 					=> clock,
			reset_timer             => reset_timer,
			CS7		 				=> CS7,
			OUT_signal 				=> OUT_signal,
			set_TBIFG 				=> set_TBIFG,
			BTCNT_Out 				=> BTCNT_Out
			);
			
---------------------------------write to timer---------------------------------------
timer_insert_proc:process(clock)
		BEGIN
			if (clock'EVENT  AND clock = '0')THEN
				IF(reset_timer = '1')THEN
					BTCTL <=(5=>'1',others=>'0');
					BTCNT_In<=(others=>'0');
					BTCCR0 <=(others=>'0');
					BTCCR1 <= (others=>'0');
				elsif(CS6='1' and memWrite='1') THEN
					BTCTL <= Data_Bus(7 DOWNTO 0);
				elsif(CS7='1' and memWrite='1')THEN
					BTCNT_In <= Data_Bus ;
				elsif(CS8='1' and memWrite='1')THEN
					BTCCR0	 <= Data_Bus;
				elsif(CS9='1' and memWrite='1')THEN
					BTCCR1	 <= Data_Bus; 
				else 
					null;
				END IF;
			END IF;
		END process;
	
	
END behavior;

