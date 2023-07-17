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
		   Hex0,Hex1,Hex2,Hex3,Hex4,Hex5 : OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0 )
		   );
END 	top;

ARCHITECTURE structure OF top IS
signal memRead,	memWrite : STD_LOGIC;
signal Address_Bus       : STD_LOGIC_VECTOR( address_size_orig-1 DOWNTO 0 );
signal Data_Bus          : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
BEGIN

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
	PORT MAP (	memRead=>memRead,
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
				Hex5=>Hex5
				);
END structure;

