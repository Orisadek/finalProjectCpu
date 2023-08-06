				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY MIPS IS
	generic (  isModelSim  : boolean;
			  adress_size  : positive;
				AluOpSize : positive := 9;
			  ResSize : positive := 32;
			  shamt_size: positive := 5;
			  PC_size : positive := 10;
			  change_size: positive := 8;
			  Imm_size: positive := 26;
			  clkcnt_size: positive := 16;
			  address_size_orig :positive:=12
			); 
	PORT( ena, clock    		: IN 	STD_LOGIC; 
		INTR			 	 	: IN	STD_LOGIC;
		Memwrite_out,MemRead_out: OUT 	STD_LOGIC ;
		clr_req                 : OUT 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
		Address_Bus   			: OUT 	STD_LOGIC_VECTOR( address_size_orig-1 DOWNTO 0 );
		GIE 				    : OUT	 STD_LOGIC;
		reset_local 			: OUT	 STD_LOGIC;
		INTA					: OUT	 STD_LOGIC;
		Data_Bus   			    : INOUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 )
		);
END 	MIPS;

ARCHITECTURE structure OF MIPS IS
				-- declare signals used to connect VHDL components
	SIGNAL PC_plus_4 			: STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
	SIGNAL read_data_1 			: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL read_data_2 			: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL Sign_Extend 			: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL Add_result 			: STD_LOGIC_VECTOR( change_size-1 DOWNTO 0 );
	SIGNAL ALU_result 			: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL read_data 			: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL ALUSrc 				: STD_LOGIC;
	SIGNAL Branch 				: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL Jump       			: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL RegDst 				: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL Regwrite 			: STD_LOGIC;
	SIGNAL Zero 				: STD_LOGIC;
	SIGNAL MemWrite 			: STD_LOGIC;
	SIGNAL MemtoReg 			: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL MemRead 				: STD_LOGIC;
	SIGNAL ALUop 				: STD_LOGIC_VECTOR( AluOpSize-1 DOWNTO 0 );
	SIGNAL Instruction			: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL JumpAdress			: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL read_data_mem 		: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 ); 
	SIGNAL INTA_insert,INTA_local			: STD_LOGIC;
	SIGNAL reset_local_mips   	: STD_LOGIC;
	SIGNAL reqType				: STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	SIGNAL clr_req_local        : STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL INTA_L : STD_LOGIC;
	alias address is ALU_Result(address_size_orig-1 DOWNTO 0);
	alias isGPIO  is address(address_size_orig-1);
BEGIN
	clr_req 		<= clr_req_local;	
    MemRead_out		<= MemRead  when INTA_local='1' else '1';	
    MemWrite_out 	<= MemWrite;	
    Address_Bus     <= address  when INTA_local='1' else X"82E";
    Data_Bus		<= read_data_2 when (MemWrite='1' and isGPIO='1' and INTA_local='1') else (others=>'Z'); -- if we're in GPIO and want to write data - insert data' else - high z
    read_data		<= read_data_mem when isGPIO='0' else Data_Bus;
	reset_local 	<= reset_local_mips;
	
	INTA <= INTA_local;
	
	clk_INTR_proc:process(clock)
		BEGIN
			if(clock'EVENT AND clock='1')then
				INTA_local<=INTA_insert;
			END IF;
	END process;
	
	
	INTA_insert<='0' WHEN INTR='1' else '1';

				
	
	
--------------------------- connect the 5 MIPS components----------------------------------------------------------   
  IFE :Ifetch GENERIC MAP(isModelSim,adress_size) PORT MAP (	
				Instruction 	=> Instruction,
    	    	PC_plus_4_out 	=> PC_plus_4,
				read_data_mem   => read_data_mem,
				Add_result 		=> Add_result,
				Branch 			=> Branch,
				Zero 			=> Zero,     		
				clock 			=> clock,  
				data_reg 	    => read_data_1,
				Jump            => Jump,
				INTA			=> INTA_local,
				reqType         => reqType,
				clr_req         => clr_req_local,
				reset_local    	=> reset_local_mips,
				JumpAdress		=> JumpAdress
				);


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
				GIE				=> GIE,
				INTA			=> INTA_local,
				clr_req			=> clr_req_local,	
				reset_local 	=> reset_local_mips );


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
                clock 			=> clock
				 );

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
                Clock			=> clock
				 );

   MEM: dmemory generic MAP(isModelSim,adress_size) PORT MAP (	
				read_data 		=> read_data_mem,
				address 		=> address,--- address to write/read
				write_data 		=> read_data_2, -- data to write
				MemRead 		=> MemRead, 
				Memwrite 		=> MemWrite, 
				INTA			=> INTA_local,
				Data_Bus        => Data_Bus,
				reqType         => reqType,
                clock 			=> clock 
				 );
				
	Jmp :  jmp_unit 
	PORT MAP (
			instruction 	=> Instruction( 25 DOWNTO 0 ),
			PC_plus_4_out   => PC_plus_4(3 DOWNTO 0 ),
			JumpAdress		=> JumpAdress
			);


END structure;

