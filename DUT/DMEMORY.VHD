						--  Dmemory module (implements the data
						--  memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
LIBRARY work;
USE work.aux_package.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY dmemory IS
	generic (isModelSim  : boolean;
			 address_size  : positive ;
			 AluOpSize : positive := 9;
			 ResSize       : positive := 32;
			 address_size_orig :positive:=12
		); 
	PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			reqType				: OUT 	STD_LOGIC_VECTOR( 2 DOWNTO 0 );
        	address 			: IN 	STD_LOGIC_VECTOR( address_size_orig-1 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
            clock				: IN 	STD_LOGIC;
			INTA				: IN	STD_LOGIC;
			Data_Bus   			: IN   STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 )	
			);
		
END dmemory;

ARCHITECTURE behavior OF dmemory IS
SIGNAL write_clock    		 : STD_LOGIC;
SIGNAL w_enable       		 : STD_LOGIC;
SIGNAL address_to_mem 		 : STD_LOGIC_VECTOR(address_size-1 DOWNTO 0);
SIGNAL address_INTA 		 : STD_LOGIC_VECTOR(7 DOWNTO 0);
alias isGPIO  is address(address_size_orig-1);
alias TYPEx is Data_Bus(4 DOWNTO 0 );
BEGIN

-------------------------------type req------------------------------------
	reqType<= "000" when INTA = '0' and TYPEx= "00000" else
			  "001" when INTA = '0' and TYPEx= "10000" else
			  "010" when INTA = '0' and TYPEx= "10100" else
			  "011" when INTA = '0' and TYPEx= "11000" else
			  "100" when INTA = '0' and TYPEx= "11100" else
			  "ZZZ";
	

----------------------------------------choose between address and Type------------------- 	
	address_INTA<=address(9 DOWNTO 2) when INTA='1' else "00000"&TYPEx(4 DOWNTO 2);
	
---------------------------------choose between ModelSim and Quartus----------------------
	ModelSim_D: if (isModelSim=TRUE) generate --- insert condition to modelsim 
		address_to_mem <=address_INTA;
	END generate ModelSim_D;
	
	Quartus_D: if (isModelSim=FALSE) generate --- insert condition to quartus
		address_to_mem <=address_INTA&"00";
	END generate Quartus_D;

	
	w_enable <= '1' when (Memwrite='1' and isGPIO='0') else '0'; -- make sure isn't GPIO
	
	data_memory : altsyncram
	GENERIC MAP  (
		operation_mode => "SINGLE_PORT",
		width_a => 32,
		widthad_a => address_size,
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "D:\finalProjectCpu-master_1556\finalProjectCpu-master\L1_Caches\dmemory.hex",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		wren_a => w_enable,
		clock0 => write_clock,
		address_a => address_to_mem,
		data_a => write_data,
		q_a => read_data);
-- Load memory address register with write clock
		write_clock <= NOT clock;
END behavior;

