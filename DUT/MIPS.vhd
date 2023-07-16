				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY MIPS IS
	generic ( AluOpSize : positive := 9;
			  ResSize : positive := 32;
			  shamt_size: positive := 5;
			  PC_size : positive := 10;
			  change_size: positive := 8;
			  Imm_size: positive := 26;
			  clkcnt_size: positive := 16;
			  address_size_orig :positive:=12;
			  isModelSim  : boolean :=TRUE;
			  adress_size  : positive :=8
			); 
	PORT( reset,ena, clock		: IN 	STD_LOGIC; 
		Memwrite_out,MemRead_out: OUT 	STD_LOGIC ;
		Address_Bus   			: OUT 	STD_LOGIC_VECTOR( address_size_orig-1 DOWNTO 0 );
		Data_Bus   			    : INOUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 ));
END 	MIPS;

ARCHITECTURE structure OF MIPS IS
				-- declare signals used to connect VHDL components
	SIGNAL PC_plus_4 		: STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
	SIGNAL read_data_1 		: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL read_data_2 		: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL Sign_Extend 		: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL Add_result 		: STD_LOGIC_VECTOR( change_size-1 DOWNTO 0 );
	SIGNAL ALU_result 		: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL read_data 		: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL ALUSrc 			: STD_LOGIC;
	SIGNAL Branch 			: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL Jump       		: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL RegDst 			: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL Regwrite 		: STD_LOGIC;
	SIGNAL Zero 			: STD_LOGIC;
	SIGNAL MemWrite 		: STD_LOGIC;
	SIGNAL MemtoReg 		: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL MemRead 			: STD_LOGIC;
	SIGNAL ALUop 			: STD_LOGIC_VECTOR(  AluOpSize-1 DOWNTO 0 );
	SIGNAL Instruction		: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL JumpAdress		: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	
	alias address is ALU_Result(address_size_orig-1 DOWNTO 0);
	alias isGPIO  is address(address_size_orig-1);
BEGIN
				
   MemRead_out		<= MemRead;	
   MemWrite_out 	<= MemWrite;	
   Address_Bus      <= address;
   Data_Bus			<= read_data_2 when (MemWrite='1' and isGPIO='1') else (others=>'Z'); -- if we're in GPIO and want to write data - insert data' else - high z
   
--------------------------- connect the 5 MIPS components----------------------------------------------------------   
  IFE :Ifetch GENERIC MAP(isModelSim,adress_size) PORT MAP (	
				Instruction 	=> Instruction,
    	    	PC_plus_4_out 	=> PC_plus_4,
				Add_result 		=> Add_result,
				Branch 			=> Branch,
				Zero 			=> Zero,
				--PC_out 			=> PC,        		
				clock 			=> clock,  
				reset 			=> reset,
				data_reg 	    => read_data_1,
				Jump            => Jump,
				JumpAdress		=> JumpAdress);


   ID : Idecode
	PORT MAP (	read_data_1 	=> read_data_1,
        		read_data_2 	=> read_data_2,
        		Instruction 	=> Instruction,
        		read_data 		=> read_data,
				ALU_result 		=> ALU_result,
				RegWrite 		=> RegWrite,
				MemtoReg 		=> MemtoReg,
				RegDst 			=> RegDst,
				Sign_extend 	=> Sign_extend,
				PC_plus_4       => PC_plus_4,
        		clock 			=> clock,  
				reset 			=> reset );


   CTL:   control
	PORT MAP ( 	Opcode 			=> Instruction( 31 DOWNTO 26 ),
				func_op     	=> Instruction( 5 DOWNTO 0 ),
				RegDst 			=> RegDst,
				ALUSrc 			=> ALUSrc,
				MemtoReg 		=> MemtoReg,
				RegWrite 		=> RegWrite,
				MemRead 		=> MemRead,
				MemWrite 		=> MemWrite,
				Branch 			=> Branch,
				Jump            => Jump,
				ALUop 			=> ALUop,
                clock 			=> clock,
				reset 			=> reset );

   EXE:  Execute
   	PORT MAP (	Read_data_1 	=> read_data_1,
             	Read_data_2 	=> read_data_2,
				Sign_extend 	=> Sign_extend,
				shamt 			=> Instruction( 10 DOWNTO 6 ),
                Function_opcode	=> Instruction( 5 DOWNTO 0 ),
				ALUOp 			=> ALUop,
				ALUSrc 			=> ALUSrc,
				Zero 			=> Zero,
                ALU_Result		=> ALU_Result,
				Add_Result 		=> Add_Result,
				PC_plus_4		=> PC_plus_4,
                Clock			=> clock,
				Reset			=> reset );

   MEM: dmemory generic MAP(isModelSim,adress_size) PORT MAP (	
				read_data 		=> read_data,
				address 		=> address,--- address to write/read
				write_data 		=> read_data_2, -- data to write
				MemRead 		=> MemRead, 
				Memwrite 		=> MemWrite, 
                clock 			=> clock,  
				reset 			=> reset );
				
	Jmp :  jmp_unit 
	PORT MAP (
			instruction 	=> Instruction( 25 DOWNTO 0 ),
			PC_plus_4_out   => PC_plus_4(3 DOWNTO 0 ),
			JumpAdress		=>JumpAdress
			);


END structure;

