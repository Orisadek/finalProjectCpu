				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY IO_ASSIGN IS
	PORT(  
		   Hex_value_byte      			 : IN 	 STD_LOGIC_VECTOR(7 DOWNTO 0 );
		   Hex							 : OUT 	 STD_LOGIC_VECTOR(6 DOWNTO 0 )
		   );
END 	IO_ASSIGN;

ARCHITECTURE behavior OF IO_ASSIGN IS
signal hex_decode_negative :std_logic_vector(6 downto 0);
alias hex_val is Hex_value_byte(3 DOWNTO 0 );
BEGIN
hex_decode_negative <=(6=>'0',others=>'1') 		  		 		when hex_val = "0000" else -- 0
					  (1=>'1',2=>'1',others=>'0') 		 		when hex_val = "0001" else --1
					  (2=>'0',5=>'0',others=>'1') 		 		when hex_val = "0010" else --2
					  (4=>'0',5=>'0',others=>'1') 		 		when hex_val = "0011" else --3
					  (0=>'0',3=>'0',4=>'0',others=>'1') 		when hex_val = "0100" else --4
					  (1=>'0',4=>'0',others=>'1') 		 		when hex_val = "0101" else --5
					  (1=>'0',others=>'1') 				 	    when hex_val = "0110" else --6
					  (3=>'0',4=>'0',5=>'0',6=>'0',others=>'1') when hex_val = "0111" else --7
					  (others=>'1') 							when hex_val = "1000" else --8
					  (3=>'0',4=>'0',others=>'1') 				when hex_val = "1001" else --9
					  (3=>'0',others=>'1') 						when hex_val = "1010" else --A
					  (0=>'0',1=>'0',others=>'1') 				when hex_val = "1011" else --B
					  (0=>'0',1=>'0',2=>'0',5=>'0',others=>'1') when hex_val = "1100" else --C
					  (0=>'0',5=>'0',others=>'1') 				when hex_val = "1101" else --D
					  (1=>'0',2=>'0',others=>'1')				when hex_val = "1110" else --E
					  (1=>'0',2=>'0',3=>'0',others=>'1'); --F

Hex<=not hex_decode_negative;
END behavior;

