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
	PORT(  memRead,	memWrite 			 : IN 	 STD_LOGIC;
		   Address_Bus       			 : IN 	 STD_LOGIC_VECTOR( address_size_orig-1 DOWNTO 0 );
		   SW   			 			 : IN 	 STD_LOGIC_VECTOR(7 DOWNTO 0);
		   Data_Bus         			 : INOUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		   Leds							 : OUT 	 STD_LOGIC_VECTOR(7 DOWNTO 0 );
		   Hex0,Hex1,Hex2,Hex3,Hex4,Hex5 : OUT 	 STD_LOGIC_VECTOR(6 DOWNTO 0 )
		   );
END 	GPIO;

ARCHITECTURE behavior OF GPIO IS
signal CS1,CS2,CS3,CS4,CS5,CS6,CS7 								   : STD_LOGIC;
--signal Hex0_val,Hex1_val,Hex2_val,Hex3_val,Hex4_val,Hex5_val : STD_LOGIC_VECTOR(7 DOWNTO 0 ); -- the numeric value we want to show\
signal Leds_interface,Hex0_interface,Hex1_interface				   :STD_LOGIC_VECTOR(7 DOWNTO 0);
signal Hex2_interface,Hex3_interface,Hex4_interface,Hex5_interface :STD_LOGIC_VECTOR(7 DOWNTO 0);
alias A11 is Address_Bus(11);
alias A4  is Address_Bus(4);
alias A3  is Address_Bus(3);
alias A2  is Address_Bus(2);
alias A0  is Address_Bus(0);

BEGIN
	CS1<='1' when (A11='1' and A4='0' and A3='0' and A2='0' and A0='0') else '0'; --Leds
	CS2<='1' when (A11='1' and A2='1' and A3='0' and A4='0') else '0'; --HEX0 HEX1
	CS3<='1' when (A11='1' and A3='1' and A2='0' and A4='0') else '0'; --HEX2 HEX3
	CS4<='1' when (A11='1' and A4='0' and A3='1' and A2='1') else '0'; --HEX4 HEX5
	CS5<='1' when (A11='1' and A4='1' and A2='0' and A3='0') else '0'; --SW
	--CS6<='1' when (A11='1' and A4='1') else '0';
	--CS7<='1' when (A11='1' and A4='1') else '0';
	
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
	
	
	
	
	
END behavior;

