LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
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
signal Key1,Key2,Key3,OUT_signal	 :  	STD_LOGIC; 
		   
   -- Component Declarations
    
Component top IS
	generic (ResSize : positive := 32;
			address_size_orig :positive:=12
			); 
	PORT(  reset,ena, clock				 : IN 	STD_LOGIC; 
		   SW   						 : IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		   Key1,Key2,Key3			     : IN 	STD_LOGIC; 
		   Leds							 : OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0 );
		   Hex0,Hex1,Hex2,Hex3,Hex4,Hex5 : OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0 );
		   OUT_signal                  	 : OUT 	STD_LOGIC
		   );
END 	Component; 
   



BEGIN

   -- Instance port mappings.
   U_0 : top
      PORT MAP (
		   reset	  =>	reset,
		   ena		  =>	ena,
		   clock	  =>	clock,
		   SW 		  =>	SW, 						 
		   Leds		  =>	Leds,					
		   Hex0		  =>	Hex0,
		   Hex1		  =>	Hex1,
		   Hex2		  =>	Hex2,
		   Hex3		  =>	Hex3,
		   Hex4		  =>	Hex4,
		   Hex5		  =>	Hex5,
		   Key1		  =>    Key1,
		   Key2 	  =>    Key2,
		   Key3		  =>    Key3, 
		   OUT_signal =>    OUT_signal
      );
	  
   rst: PROCESS
   BEGIN
		reset<='0';
        WAIT FOR 25 ns;
		reset<='1';
		 WAIT;-- FOR 1000 ns;
   END PROCESS rst;
   

   clk: PROCESS
   BEGIN
		clock<='0';
        WAIT FOR 50 ns;
		clock<='1';
		WAIT FOR 50 ns;
     END PROCESS clk;
	
   switches : process
        begin
		  SW <= (others => '0');
		  for i in 0 to 10 loop
			wait for 500 ns;
			SW <= (others => '0');
				--SW <= SW+1;
		  end loop;
		  wait;
        end process;
END struct;
