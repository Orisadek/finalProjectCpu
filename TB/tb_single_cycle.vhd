LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
LIBRARY work;
USE work.aux_package.all;

ENTITY MIPS_tb IS
-- Declarations
END MIPS_tb ;



ARCHITECTURE struct OF MIPS_tb IS
signal reset,ena, clock				 : STD_LOGIC; 
signal SW   						 : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal Leds							 : STD_LOGIC_VECTOR(7 DOWNTO 0 );
signal Hex0,Hex1,Hex2,Hex3,Hex4,Hex5 : STD_LOGIC_VECTOR(6 DOWNTO 0 );

   -- Component Declarations
    
Component top IS
	generic (ResSize : positive := 32;
			address_size_orig :positive:=12
			); 
	PORT(  reset,ena, clock				 : IN 	STD_LOGIC; 
		   SW   						 : IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		   Leds							 : OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0 );
		   Hex0,Hex1,Hex2,Hex3,Hex4,Hex5 : OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0 ));
END 	Component; 
   



BEGIN

   -- Instance port mappings.
   U_0 : top
      PORT MAP (
		   reset	=>	reset,
		   ena		=>	ena,
		   clock	=>	clock,
		   SW 		=>	SW, 						 
		   Leds		=>	Leds,					
		   Hex0		=>	Hex0,
		   Hex1		=>	Hex1,
		   Hex2		=>	Hex2,
		   Hex3		=>	Hex3,
		   Hex4		=>	Hex4,
		   Hex5		=>	Hex5 
      );
	  
   rst: PROCESS
   BEGIN
		reset<='1';
        WAIT FOR 100 ns;
		reset<='0';
		wait;
  
   END PROCESS rst;
   
   clk: PROCESS
   BEGIN
		clock<='0';
        WAIT FOR 50 ns;
		clock<='1';
		WAIT FOR 50 ns;
     END PROCESS clk;
	
	switches: PROCESS
   BEGIN
		SW<=(others=>'0');
        WAIT FOR 50 ns;
		SW<=(others=>'1');
		WAIT FOR 50 ns;
    
   END PROCESS switches;
END struct;
