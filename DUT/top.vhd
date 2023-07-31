				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY top IS
	generic (ResSize : positive := 32;
			address_size_orig :positive:=12;
			isModelSim  : boolean :=TRUE;
			adress_size  : positive :=8
			); 
	PORT(  reset,ena, clock				 : IN 	STD_LOGIC; 
		   SW   						 : IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		   Leds							 : OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0 );
		   Hex0,Hex1,Hex2,Hex3,Hex4,Hex5 : OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0 );
		   OUT_signal                  	 : OUT 	STD_LOGIC
		   );
END 	top;

ARCHITECTURE structure OF top IS
signal memRead,	memWrite : STD_LOGIC;
signal Address_Bus       : STD_LOGIC_VECTOR( address_size_orig-1 DOWNTO 0 );
signal Data_Bus          : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
signal set_TBIFG 		 : STD_LOGIC;	
signal CS1,CS2,CS3,CS4,CS5,CS6,CS7,CS8,CS9 	: STD_LOGIC;
alias A11 is Address_Bus(11);
alias A5  is Address_Bus(5);
alias A4  is Address_Bus(4);
alias A3  is Address_Bus(3);
alias A2  is Address_Bus(2);
alias A1  is Address_Bus(1);
alias A0  is Address_Bus(0);
	
BEGIN
	CS1<='1' when (A11='1' and A5='0' and A4='0' and A3='0' and A2='0' and A0='0' and A1='0') else '0'; --Leds
	CS2<='1' when (A11='1' and A5='0' and A2='1' and A3='0' and A4='0' and A1='0') else '0'; --HEX0 HEX1
	CS3<='1' when (A11='1' and A5='0' and A3='1' and A2='0' and A4='0' and A1='0') else '0'; --HEX2 HEX3
	CS4<='1' when (A11='1' and A5='0' and A4='0' and A3='1' and A2='1' and A1='0') else '0'; --HEX4 HEX5
	CS5<='1' when (A11='1' and A5='0' and A4='1' and A2='0' and A3='0' and A1='0') else '0'; --SW
	----------------------------------with interrupts-------------------------------------------------------
	CS6<='1' when (A11='1' and A5='0' and A4='1' and A3='1' and A2='1' and A1='0') else '0'; --BTCTL
	CS7<='1' when (A11='1' and A5='1' and A4='0' and A3='0' and A2='0' and A1='0') else '0'; --BTCNT
	CS8<='1' when (A11='1' and A5='1' and A4='0' and A3='0' and A2='1' and A1='0') else '0'; --BTCCR0
	CS9<='1' when (A11='1' and A5='1' and A4='0' and A3='1' and A2='0' and A1='0') else '0'; --BTCCR1
	
	
	Mips_portmap:MIPS GENERIC MAP(isModelSim,adress_size) 
	PORT MAP (	reset        => reset,
				ena          => ena,
				clock        => clock,	 
				Memwrite_out => memWrite,
				MemRead_out  => memRead,
				Address_Bus  => Address_Bus,
				Data_Bus     => Data_Bus
				);
	
	GPIO_portmap: GPIO
	PORT MAP (	clock        => clock,	 
				reset        => reset,
				memRead=>memRead,
				memWrite=>memWrite,			
				Address_Bus=>Address_Bus,       			 
				SW=>SW,   			 			 
				Data_Bus=>Data_Bus,        			 
				Leds=>Leds,							
				Hex0=>Hex0,
				Hex1=>Hex1,
				Hex2=>Hex2,
				Hex3=>Hex3,
				Hex4=>Hex4,
				Hex5=>Hex5,
				OUT_signal=>OUT_signal,
				set_TBIFG =>set_TBIFG,
				CS1=>CS1,
				CS2=>CS2,
				CS3=>CS3,
				CS4=>CS4,
				CS5=>CS5,
				CS6=>CS6,
				CS7=>CS7,
				CS8=>CS8,
				CS9=>CS9
				);
END structure;

