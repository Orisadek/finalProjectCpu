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
	PORT(  );
END 	GPIO;

ARCHITECTURE behavior OF GPIO IS

BEGIN

	
	
	
END behavior;

