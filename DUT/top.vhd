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
		   Key1,Key2,Key3			     : IN 	STD_LOGIC; 
		   Leds							 : OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0 );
		   Hex0,Hex1,Hex2,Hex3,Hex4,Hex5 : OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0 );
		   OUT_signal                  	 : OUT 	STD_LOGIC
		   );
END 	top;

ARCHITECTURE structure OF top IS
signal memRead,	memWrite,reset_local : STD_LOGIC;
signal Address_Bus       			 : STD_LOGIC_VECTOR( address_size_orig-1 DOWNTO 0 );
signal Data_Bus          			 : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
signal set_TBIFG,GIE,INTA,INTR 		 : STD_LOGIC;	
signal clr_req						 : STD_LOGIC_VECTOR( 4 DOWNTO 0 );
BEGIN

	Mips_portmap:MIPS GENERIC MAP(isModelSim,adress_size) 
	PORT MAP (	
				ena          => ena,
				clock        => clock,	
				INTR         => INTR,
				Memwrite_out => memWrite,
				MemRead_out  => memRead,
				Address_Bus  => Address_Bus,
				INTA         => INTA,
				GIE          => GIE,
				Data_Bus     => Data_Bus,
				clr_req      => clr_req,
				reset_local  => reset_local
				);
	
	GPIO_portmap: GPIO
	PORT MAP (	clock        => clock,	 
				reset        => reset_local,
				memRead		 =>memRead,
				memWrite	 =>memWrite,			
				Address_Bus  =>Address_Bus,       			 
				SW			 =>SW,   			 			 
				Data_Bus	 =>Data_Bus,        			 
				Leds		 =>Leds,							
				Hex0		 =>Hex0,
				Hex1		 =>Hex1,
				Hex2		 =>Hex2,
				Hex3		 =>Hex3,
				Hex4		 =>Hex4,
				Hex5		 =>Hex5
				);
				
	BT_Interface_portmap: BT_Interface
	PORT MAP (	clock 		=> clock,
				reset 		=> reset_local, 
				memRead 	=> memRead,
				memWrite 	=> memWrite, 		
				Address_Bus => Address_Bus, 
				Data_Bus	=>Data_Bus, 				
				OUT_signal  => OUT_signal,      			 
				set_TBIFG 	=> set_TBIFG					 
				);
				
	
	IV_portmap: IV
	PORT MAP (	clock 		=> clock,
				reset 		=> reset,
				Address_Bus => Address_Bus,      	
				memRead     => memRead,
				memWrite    => memWrite,
				clr_req     => clr_req,
				reqSrcKey1  => Key1,
				reqSrcKey2  => Key2,			
				reqSrcKey3  => Key3,
				reqSrcBT    => set_TBIFG, 			
				INTA	    => INTA,
				GIE 	    => GIE, 
				INTR	    => INTR,
				Data_Bus    => Data_Bus					 
				);
				
	
	

				
	
END structure;

