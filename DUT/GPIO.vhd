				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY GPIO IS
	generic (ResSize : positive := 32;
			address_size_orig :positive:=12
			); 
	PORT(  clock,reset       			 : IN 	 STD_LOGIC;
		   memRead,	memWrite 			 : IN 	 STD_LOGIC;
		   Address_Bus       			 : IN 	 STD_LOGIC_VECTOR( address_size_orig-1 DOWNTO 0 );
		   SW   			 			 : IN 	 STD_LOGIC_VECTOR(7 DOWNTO 0);
		   Data_Bus         			 : INOUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		   Leds							 : OUT 	 STD_LOGIC_VECTOR(7 DOWNTO 0 );
		   Hex0,Hex1,Hex2,Hex3,Hex4,Hex5 : OUT 	 STD_LOGIC_VECTOR(6 DOWNTO 0 );
		   OUT_signal       			 : OUT 	 STD_LOGIC;
		   set_TBIFG					 : OUT 	 STD_LOGIC
		   );
END 	GPIO;

ARCHITECTURE behavior OF GPIO IS
signal CS1,CS2,CS3,CS4,CS5,CS6,CS7,CS8,CS9 						   : STD_LOGIC;
signal Leds_interface,Hex0_interface,Hex1_interface				   :STD_LOGIC_VECTOR(7 DOWNTO 0);
signal Hex2_interface,Hex3_interface,Hex4_interface,Hex5_interface :STD_LOGIC_VECTOR(7 DOWNTO 0);
-------------------------------------------------Basic timer-------------------------------------
signal 			BTCCR1,BTCCR0 			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
signal			BTCNT_In 				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
signal			BTCTL 					: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
signal			BTCNT_Out 				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
signal			BTCTL_latch 					: STD_LOGIC_VECTOR( 7 DOWNTO 0 );

-----------------------------------------------------------------------------------
alias A11 is Address_Bus(11);
alias A5  is Address_Bus(5);
alias A4  is Address_Bus(4);
alias A3  is Address_Bus(3);
alias A2  is Address_Bus(2);
--alias A1  is Address_Bus(1);
alias A0  is Address_Bus(0);

BEGIN
	CS1<='1' when (A11='1' and A5='0' and A4='0' and A3='0' and A2='0' and A0='0') else '0'; --Leds
	CS2<='1' when (A11='1' and A5='0' and A2='1' and A3='0' and A4='0') else '0'; --HEX0 HEX1
	CS3<='1' when (A11='1' and A5='0' and A3='1' and A2='0' and A4='0') else '0'; --HEX2 HEX3
	CS4<='1' when (A11='1' and A5='0' and A4='0' and A3='1' and A2='1') else '0'; --HEX4 HEX5
	CS5<='1' when (A11='1' and A5='0' and A4='1' and A2='0' and A3='0') else '0'; --SW
	----------------------------------with interrupts-------------------------------------------------------
	CS6<='1' when (A11='1' and A5='0' and A4='1' and A3='1' and A2='1') else '0'; --BTCTL
	CS7<='1' when (A11='1' and A5='1' and A4='0' and A3='0' and A2='0') else '0'; --BTCNT
	CS8<='1' when (A11='1' and A5='1' and A4='0' and A3='0' and A2='1') else '0'; --BTCCR0
	CS9<='1' when (A11='1' and A5='1' and A4='0' and A3='1' and A2='0') else '0'; --BTCCR1
	

	
	-----------------------------------Leds -------------------------------------------------------------------
	Leds_interface<=Data_Bus(7 DOWNTO 0 ) when (CS1='1' and memWrite='1') else unaffected;  
	Leds<=Leds_interface;
	Data_Bus <=X"000000"&Leds_interface when (CS1='1' and memRead='1') else (others=>'Z');
	---- check if okay later
	-----------------------------------Hex0 -------------------------------------------------------------------
	Hex0_interface<=Data_Bus(7 DOWNTO 0 ) when (CS2='1' and memWrite='1' and A0='0' ) else unaffected;  
	Hex0_portmap:IO_ASSIGN PORT MAP (	
				Hex_value_byte => Hex0_interface,     
				Hex		       => Hex0				
				);
	Data_Bus <=X"000000"&Hex0_interface when (CS2='1' and memRead='1' and A0='0') else (others=>'Z');
	---- check if okay later
	-----------------------------------Hex1 -------------------------------------------------------------------
	Hex1_interface<=Data_Bus(7 DOWNTO 0 ) when (CS2='1' and memWrite='1' and A0='1' ) else unaffected;  
	Hex1_portmap:IO_ASSIGN PORT MAP (	
				Hex_value_byte => Hex1_interface,     
				Hex		       => Hex1				
				);
	Data_Bus<=X"000000"&Hex1_interface when (CS2='1' and memRead='1' and A0='1') else (others=>'Z');
	---- check if okay later
	
	-----------------------------------Hex2 -------------------------------------------------------------------
	Hex2_interface<=Data_Bus(7 DOWNTO 0 ) when (CS3='1' and memWrite='1' and A0='0' ) else unaffected;  
	Hex2_portmap:IO_ASSIGN PORT MAP (	
				Hex_value_byte => Hex2_interface,     
				Hex		       => Hex2				
				);
	Data_Bus <=X"000000"&Hex2_interface when (CS3='1' and memRead='1' and A0='0') else (others=>'Z');
	---- check if okay later
	-----------------------------------Hex3-------------------------------------------------------------------
	Hex3_interface<=Data_Bus(7 DOWNTO 0 ) when (CS3='1' and memWrite='1' and A0='1' ) else unaffected;  
	Hex3_portmap:IO_ASSIGN PORT MAP (	
				Hex_value_byte => Hex3_interface,     
				Hex		       => Hex3				
				);
	Data_Bus <=X"000000"&Hex3_interface when (CS3='1' and memRead='1' and A0='1') else (others=>'Z');
	---- check if okay later
	-----------------------------------Hex4-------------------------------------------------------------------
	Hex4_interface<=Data_Bus(7 DOWNTO 0 ) when (CS4='1' and memWrite='1' and A0='0' ) else unaffected;  
	Hex4_portmap: IO_ASSIGN PORT MAP (	
				Hex_value_byte => Hex4_interface,     
				Hex		       => Hex4				
				);
	Data_Bus <=X"000000"&Hex4_interface when (CS4='1' and memRead='1' and A0='0') else (others=>'Z');
	---- check if okay later
	-----------------------------------Hex5-------------------------------------------------------------------
	Hex5_interface<=Data_Bus(7 DOWNTO 0 ) when (CS4='1' and memWrite='1' and A0='1' ) else unaffected;  
	Hex5_portmap: IO_ASSIGN PORT MAP (	
				Hex_value_byte => Hex5_interface,     
				Hex		       => Hex5				
				);
	Data_Bus <=X"000000"&Hex5_interface when (CS4='1' and memRead='1' and A0='1') else (others=>'Z');
	---- check if okay later
	--------------------------------------SW -------------------------------------------------------------------
	Data_Bus <=X"000000"&SW when (CS5='1' and memRead='1') else (others=>'Z');
	
	-------------------------------------Basic Timer ---------------------------------------------------------------
		
	BTCNT_In <= Data_Bus when(CS7='1' and memWrite='1') else unaffected;
	
	BTCCR0	 <= Data_Bus when(CS8='1' and memWrite='1' and reset='0') else 
				unaffected when reset='0' else
				(others=>'0');
				
	BTCCR1	 <= Data_Bus when(CS9='1' and memWrite='1' and reset='0') else 
				unaffected when reset='0' else
				(others=>'0');
	
	
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
			reset                   => reset,
			en_BTCNT 				=> CS7,
			OUT_signal 				=> OUT_signal,
			set_TBIFG 				=> set_TBIFG,
			BTCNT_Out 				=> BTCNT_Out
			);
			

gpio_proc:process(clock)
		BEGIN
			IF (reset = '1')THEN
				BTCTL <=(5=>'1',others=>'0');
			elsif (clock'EVENT  AND clock = '1' and CS6='1' and memWrite='1')THEN
				BTCTL <= Data_Bus(7 DOWNTO 0);
			else 
				null;
			END IF;
		END process;
	
	
END behavior;

