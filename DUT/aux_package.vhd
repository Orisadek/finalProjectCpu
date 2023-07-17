LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

package aux_package is

COMPONENT MIPS IS
	generic (  isModelSim  : boolean := TRUE;
			  adress_size  : positive :=8;
				AluOpSize : positive := 9;
			  ResSize : positive := 32;
			  shamt_size: positive := 5;
			  PC_size : positive := 10;
			  change_size: positive := 8;
			  Imm_size: positive := 26;
			  clkcnt_size: positive := 16;
			  address_size_orig :positive:=12
			); 
	PORT( reset,ena, clock		: IN 	STD_LOGIC; 
		Memwrite_out,MemRead_out: OUT 	STD_LOGIC ;
		Address_Bus   			: OUT 	STD_LOGIC_VECTOR( address_size_orig-1 DOWNTO 0 );
		Data_Bus   			    : INOUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 )
		);
END 	COMPONENT;



COMPONENT Ifetch
	generic ( 
		isModelSim  : boolean;
		address_size  : positive;
		ResSize : positive := 32;
		PC_size : positive := 10;
		change_size: positive := 8
		); 
   	     PORT(	Instruction			: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        		PC_plus_4_out 		: OUT  	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
        		Add_result 			: IN 	STD_LOGIC_VECTOR( change_size-1 DOWNTO 0 );
        		Branch 				: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
        		Zero 				: IN 	STD_LOGIC;
        		--PC_out 				: OUT 	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
        		clock,reset 		: IN 	STD_LOGIC;
				data_reg 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
				Jump       		    : IN   STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				JumpAdress		    : IN   STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 )
				);
END COMPONENT; 

COMPONENT Idecode
	generic ( AluOpSize : positive := 9;
		ResSize : positive := 32;
		PC_size : positive := 10;
		change_size: positive := 8;
		cmd_size: positive := 5;
		Imm_val_I: positive  :=16;
		Imm_val_J: positive  :=26
			);
 	     PORT(	read_data_1 		: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        		read_data_2 		: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        		Instruction 		: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        		read_data 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        		ALU_result 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        		RegWrite			: IN 	STD_LOGIC;
				MemtoReg 			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
        		RegDst 				: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
        		Sign_extend 		: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
				PC_plus_4   		: IN    STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); --- change if needed
        		clock, reset		: IN 	STD_LOGIC );
END COMPONENT;

COMPONENT control
generic ( AluOpSize : positive := 9 ;
		  cmd_size    : positive := 6 ); 
	     PORT( 	Opcode 				: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
				func_op     	    : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
             	RegDst 				: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
             	ALUSrc 				: OUT 	STD_LOGIC;
             	MemtoReg 			: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
             	RegWrite 			: OUT 	STD_LOGIC;
             	MemRead 			: OUT 	STD_LOGIC;
             	MemWrite 			: OUT 	STD_LOGIC;
             	Branch 				: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				Jump       			: OUT   STD_LOGIC_VECTOR( 1 DOWNTO 0 );
             	ALUop 				: OUT 	STD_LOGIC_VECTOR( AluOpSize-1 DOWNTO 0 );
             	clock, reset		: IN 	STD_LOGIC );
END COMPONENT;

COMPONENT  Execute
	generic ( AluOpSize : positive := 9;
		add_res_size : positive := 8;
		shamt_size: positive := 5;
		func_op_size: positive := 6;
		ResSize : positive := 32;
		PC_size : positive := 10;
		change_size: positive := 8;
		mult_size: positive := 64	); 
   	     PORT(	Read_data_1 		: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
                Read_data_2 		: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
               	Sign_Extend 		: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
				shamt 			    : IN 	STD_LOGIC_VECTOR( shamt_size-1 DOWNTO 0 );
               	Function_opcode		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
               	ALUOp 				: IN 	STD_LOGIC_VECTOR( AluOpSize-1 DOWNTO 0 );
               	ALUSrc 				: IN 	STD_LOGIC;
				PC_plus_4 			: IN 	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
               	clock, reset		: IN 	STD_LOGIC;
               	Zero 				: OUT	STD_LOGIC;
               	ALU_Result 			: OUT	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
               	Add_Result 			: OUT	STD_LOGIC_VECTOR( change_size-1 DOWNTO 0 )
				);
END COMPONENT;

COMPONENT dmemory
	generic (isModelSim  : boolean;
			 address_size  : positive;
			 AluOpSize : positive := 9;
			 ResSize       : positive := 32;
			 address_size_orig :positive:=12
		); 
	     PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        		address 			: IN 	STD_LOGIC_VECTOR( address_size_orig -1 DOWNTO 0 );
        		write_data 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        		MemRead, Memwrite 	: IN 	STD_LOGIC;
        		Clock,reset			: IN 	STD_LOGIC );
	END COMPONENT;


COMPONENT jmp_unit IS
	generic ( ResSize : positive := 32;
			Imm_size: positive := 26);  
	PORT(	 instruction 	: IN	STD_LOGIC_VECTOR( 25 DOWNTO 0 );
			 PC_plus_4_out 	: IN	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
			 JumpAdress		: OUT   STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 )
			 );

END COMPONENT;


COMPONENT top IS
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
END 	COMPONENT;

COMPONENT GPIO IS
generic (ResSize : positive := 32;
			address_size_orig :positive:=12
			); 
PORT(  memRead,	memWrite 				 : IN 	 STD_LOGIC;
		   Address_Bus       			 : IN 	 STD_LOGIC_VECTOR( address_size_orig-1 DOWNTO 0 );
		   SW   			 			 : IN 	 STD_LOGIC_VECTOR(7 DOWNTO 0);
		   Data_Bus         			 : INOUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		   Leds							 : OUT 	 STD_LOGIC_VECTOR(7 DOWNTO 0 );
		   Hex0,Hex1,Hex2,Hex3,Hex4,Hex5 : OUT 	 STD_LOGIC_VECTOR(6 DOWNTO 0 )
		   );
END 	COMPONENT;

COMPONENT IO_ASSIGN IS
	PORT(  
		   Hex_value_byte      			 : IN 	 STD_LOGIC_VECTOR(7 DOWNTO 0 );
		   Hex							 : OUT 	 STD_LOGIC_VECTOR(6 DOWNTO 0 )
		   );
END COMPONENT;

end aux_package;