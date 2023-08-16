						--  Idecode module (implements the register file for
LIBRARY IEEE; 			-- the MIPS computer)
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY Idecode IS
--									*********Constants Delclaration**********								
generic ( 	AluOpSize  : positive  := 9;
			ResSize    : positive  := 32;
			PC_size    : positive  := 10;
			change_size: positive  := 8;
			cmd_size   : positive  := 5;
			Imm_val_I  : positive  :=16;
			Imm_val_J  : positive  :=26;
			K0 		   : positive  :=26;
			K1		   : positive  :=27
			);
	  PORT(	
			Instruction 		: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			read_data 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );   
			ALU_result			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			RegWrite 			: IN 	STD_LOGIC;
			MemtoReg 			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			RegDst 				: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			PC_plus_4   		: IN    STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
			clock,reset_local	: IN 	STD_LOGIC;
			INTA  				: IN 	STD_LOGIC;
			clr_req				: IN   STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			Sign_extend 		: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			read_data_1			: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			read_data_2			: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			GIE  				: OUT 	STD_LOGIC
		 );
END Idecode;


ARCHITECTURE behavior OF Idecode IS
TYPE     register_file IS ARRAY ( 0 TO ResSize-1 ) OF STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
SIGNAL  register_array				: register_file;
SIGNAL  write_register_address 		: STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
SIGNAL  write_data					: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
SIGNAL  J				            : STD_LOGIC;
SIGNAL  reti               	        : STD_LOGIC;
alias   Opcode  IS Instruction( 31 DOWNTO 26 );
alias   func_op IS Instruction( 5 DOWNTO 0 );
alias   clrReset is clr_req(0);
alias   read_register_1_address  is Instruction( 25 DOWNTO 21 );
alias   read_register_2_address  is Instruction( 20 DOWNTO 16 );
alias   write_register_address_1 is Instruction( 15 DOWNTO 11 );
alias   write_register_address_0 is Instruction( 20 DOWNTO 16 );
alias   imm_value_I  is Instruction( Imm_val_I-1 DOWNTO 0 ); --decompositioning Immediate part of the intruction
alias	imm_value_J  is Instruction( Imm_val_J-1 DOWNTO 0 );	
BEGIN
	
	J <= '1' when (Opcode = "000010" or Opcode = "000011") ELSE --detecting wether J type is required
	'0'; --- jmp or jal
					-- Read Register 1 Operation
					
	reti <= '1' when (CONV_INTEGER(read_register_1_address) = K1 and Opcode=X"00"&B"00" and func_op = "001000") else '0';
	
	read_data_1 <= register_array( CONV_INTEGER( read_register_1_address ) );
					-- Read Register 2 Operation		 
	read_data_2 <= register_array( CONV_INTEGER( read_register_2_address ) );
					-- Mux for Register Write Address
	
	
   write_register_address <= write_register_address_1 WHEN RegDst = "01"    ELSE 
							write_register_address_0  WHEN RegDst = "00"    ELSE 
							CONV_STD_LOGIC_VECTOR( ResSize-1, cmd_size ) WHEN RegDst = "10"  ELSE 
							(others=>'0');
							
					-- Mux to bypass data memory for Rformat instructions
	write_data <= ALU_result( ResSize-1 DOWNTO 0 ) WHEN  MemtoReg = "00"    ELSE 
				  read_data  WHEN ( MemtoReg = "01" ) ELSE  
				  X"00000"&B"00"&PC_plus_4 WHEN MemtoReg = "10"  ELSE   
				  (others=>'0');
					-- Sign Extend 16-bits to 32-bits
		--- sign extention
    	Sign_extend <= X"0000" & imm_value_I WHEN ((imm_value_I(Imm_val_I-1) = '0' and J = '0') or Opcode="001101") ELSE
		X"FFFF" & imm_value_I when (imm_value_I(Imm_val_I-1) = '1' and J = '0') ELSE
		B"000000" & imm_value_J WHEN (imm_value_J(Imm_val_J-1) = '0' and J = '1') ELSE
		B"111111" & imm_value_J when (imm_value_J(Imm_val_J-1) = '1' and J = '1');
			
PROCESS
	variable PC_register : STD_LOGIC;
	variable PC_local : STD_LOGIC_VECTOR(PC_size-1 DOWNTO 0);
	BEGIN
		WAIT UNTIL clock'EVENT AND clock = '1';
		IF reset_local = '1' THEN
					-- Initial register values on reset are register = reg#
					-- use loop to automatically generate reset logic 
					-- for all registers
			PC_register :='0';
			FOR i IN 0 TO ResSize-1 LOOP
					register_array(i) <= CONV_STD_LOGIC_VECTOR( i, ResSize );
 			END LOOP;	
		ELSIF(INTA = '0') then
			register_array(K0)(0) <= '0';	
			if(PC_register='0') THEN
				PC_local( PC_size-1 DOWNTO 2 )  := PC_plus_4( PC_size-1 DOWNTO 2 ) - 1;
				PC_local( 1 DOWNTO 0 )  :="00";
				register_array(K1) <= X"00000"&B"00"&PC_local;
				PC_register:='1';
			END if;
		ELSIF(reti='1') THEN	
			PC_register:='0';
			register_array(K0)(0) <= '1';
  		ELSIF RegWrite = '1' AND write_register_address /= 0 THEN -- Write back to register - don't write to register 0
		      register_array(CONV_INTEGER(write_register_address)) <= write_data;
		END IF;
END PROCESS;
	GIE <= register_array(K0)(0);
END behavior;


