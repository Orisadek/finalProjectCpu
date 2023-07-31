				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
LIBRARY work;
USE work.aux_package.all;

ENTITY BasicTimer IS
	PORT(	
			BTCCR1,BTCCR0 			: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			BTCNT_In 				: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			BTCTL 					: IN	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			clock,reset 			: IN	STD_LOGIC;
			CS7		 				: IN	STD_LOGIC;
			OUT_signal 				: OUT	STD_LOGIC;
			set_TBIFG 				: OUT	STD_LOGIC;
			BTCNT_Out 				: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 )
			);
END 	BasicTimer;

ARCHITECTURE behavior OF BasicTimer IS
signal BTCL1,BTCL0: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
signal BTCNT 						: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
signal flag 						: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
-----------------------------------------------------------
alias BTOUTEN is BTCTL(6);
alias BTHOLD  is BTCTL(5);
alias BTSSEL  is BTCTL(4 DOWNTO 3);
alias BTIP 	  is BTCTL(2 DOWNTO 0);
------------------------------------------------------------
alias Q0  is BTCNT(0);
alias Q3  is BTCNT(3);
alias Q7  is BTCNT(7);
alias Q11 is BTCNT(11);
alias Q15 is BTCNT(15);
alias Q19 is BTCNT(19);
alias Q23 is BTCNT(23);
alias Q25 is BTCNT(25);
----------------------------------------------------------
BEGIN 

BTCL0<=BTCCR0;
BTCL1<=BTCCR1;

flag<= BTCNT-BTCL1;



OUT_signal<='1' when (flag(31)='1' and BTOUTEN='1') else
			'0';


set_TBIFG <= '1' when BTIP="000" and Q0  = '1' else
			 '1' when BTIP="001" and Q3  = '1' else
			 '1' when BTIP="010" and Q7  = '1' else
			 '1' when BTIP="011" and Q11 = '1' else
			 '1' when BTIP="100" and Q15 = '1' else
			 '1' when BTIP="101" and Q19 = '1' else
			 '1' when BTIP="110" and Q23 = '1' else
			 '1' when BTIP="111" and Q25 = '1' else
			 '0';


timer_proc:process(clock)
	variable count : integer;
	variable BTCNT_tmp : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		BEGIN
			IF (reset = '1')THEN
				count:=0;
				BTCNT<=(others=>'0');
				BTCNT_Out<=BTCNT;
			elsif(clock'EVENT  AND clock = '1') THEN
				if(CS7='1')THEN
					BTCNT<=BTCNT_In;
					BTCNT_Out<=BTCNT;
					count:=0;
				elsif(BTHOLD='0') THEN
					count:=count+1;
					if(BTCL0=BTCNT) THEN
						BTCNT_tmp:=(others=>'0');
					else
						BTCNT_tmp:=BTCNT+1;
					end if;
					if((BTSSEL="01" and count=2) or (BTSSEL="10" and count=4) or (BTSSEL="11" and count=8) or BTSSEL="00") THEN
						BTCNT<=BTCNT_tmp;
						BTCNT_Out<=BTCNT_tmp;
						count:=0;
					END IF;
				END IF;
			END IF;
	END process;

END behavior;

