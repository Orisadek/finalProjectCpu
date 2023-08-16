-- Ifetch module (provides the PC and instruction 
--memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY work;
USE work.aux_package.all;


LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY Ifetch IS
--									*********Constants Delclaration**********
generic ( isModelSim  : boolean;
		address_size  : positive ;
		ResSize : positive := 32;
		PC_size : positive := 10;
		change_size: positive := 8
		); 
	PORT(	 Instruction 		: OUT	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        	 PC_plus_4_out  	: OUT	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
			 PC_out 			   : OUT	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
			 reset_local		: OUT	STD_LOGIC;
			 clr_req			: OUT   STD_LOGIC_VECTOR( 4 DOWNTO 0 );
        	 Add_result 		: IN 	STD_LOGIC_VECTOR( change_size-1 DOWNTO 0 );
        	 Branch 			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
        	 Zero 			    : IN 	STD_LOGIC;
        	 clock		  		: IN 	STD_LOGIC;
			 data_reg 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			 Jump       		: IN    STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			 JumpAdress			: IN    STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			 read_data_mem   	: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			 reqType			: IN 	STD_LOGIC_VECTOR( 2 DOWNTO 0 );
			 INTA				: IN	STD_LOGIC
			 );
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
	SIGNAL PC, PC_plus_4 	 : STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); --note that we set an additional signal for pc+4 for convinience 
	SIGNAL next_PC , MUXres  : STD_LOGIC_VECTOR( change_size-1 DOWNTO 0 );
	SIGNAL Mem_Addr 	     : STD_LOGIC_VECTOR( address_size-1 DOWNTO 0 );
	SIGNAL Instruction_local : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	--SIGNAL flag				 : STD_LOGIC;
	alias clrReset is clr_req(0);
	alias clrBT    is clr_req(1);
	alias clrKey1  is clr_req(2);
	alias clrKey2  is clr_req(3);
	alias clrKey3  is clr_req(4);
BEGIN
						--ROM for Instruction Memory
inst_memory: altsyncram
	
	GENERIC MAP (
		operation_mode => "ROM",
		width_a => 32,
		widthad_a => address_size,
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "D:\finalProjectCpu-master_1556\finalProjectCpu-master\L1_Caches\program.hex",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		clock0     => clock,
		address_a 	=> Mem_Addr, 
		q_a 			=> Instruction_local );
		
		Instruction<= Instruction_local WHEN not (INTA = '0') ELSE
					 (others=>'0');
					-- Instructions always start on word address - not byte
		PC(1 DOWNTO 0) <= "00";
					-- copy output signals - allows read inside module
		PC_out 			<= PC;
		PC_plus_4_out 	<= PC_plus_4;
						-- send address to inst. memory address register
						
		---------------------------------choose between ModelSim and Quartus----------------------
				
		ModelSim_I: if (isModelSim=TRUE) generate --- insert condition to modelsim 
						Mem_Addr <=next_PC;
		END generate ModelSim_I;
		
		Quartus_I: if (isModelSim=FALSE) generate --- insert condition to quartus
						Mem_Addr <=next_PC&"00";
		END generate Quartus_I;
					
						-- Adder to increment PC by 4        
      	PC_plus_4( PC_size-1 DOWNTO 2 )  <= PC( PC_size-1 DOWNTO 2 ) + 1 ;
       	PC_plus_4( 1 DOWNTO 0 )  <= "00";
						-- Mux to select Branch Address or PC + 4        
		MUXres  <= Add_result  WHEN ( (( Branch(0) = '1' ) AND ( Zero = '1' )) or(( Branch(1) = '1' ) AND ( Zero = '0' )) )
					ELSE   PC_plus_4( PC_size-1 DOWNTO 2 );
		---------------------------------choose the next PC----------------------
		next_PC <= MUXres when (Jump = "00" and  INTA='1') else 
				   data_reg(PC_size-1 DOWNTO 2 ) when (Jump = "01" and  INTA='1') else --jr 
				   JumpAdress( PC_size-1 DOWNTO 2 ) when ((Jump = "10" or Jump = "11") and  INTA='1') else --jal,j
				   read_data_mem(PC_size-1 DOWNTO 2) when INTA='0' ELSE
				   (others=>'0');
				   
		reset_local<='1' WHEN (reqType="000" AND INTA = '0') ELSE '0';			
		--------------------------------------------clear req--------------------------------------------------------------------------------
		clr_proc:process(clock)
		BEGIN
			if( clock'EVENT  AND clock = '1') then
					if(INTA = '0') then
						case reqType IS
							WHEN "000" => clrReset <='1';
							WHEN "001" => clrBT    <='1';
							WHEN "010" => clrKey1  <='1';
							WHEN "011" => clrKey2  <='1';
							WHEN "100" => clrKey3  <='1';
							WHEN OTHERS	=> clr_req<=(OTHERS=>'0');
						END case;
					ELSE
						clr_req<=(OTHERS=>'0');
					END IF;
			END IF;
		END process;
		------------------------------------insert PC ----------------------------------
		fetch_proc:process(clock)
		BEGIN
			if( clock'EVENT  AND clock = '1') then
				   PC(PC_size-1 DOWNTO 2 ) <= next_PC;
			END IF;
	END process;
END behavior;


