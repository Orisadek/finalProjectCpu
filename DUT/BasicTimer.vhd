				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY BasicTimer IS
	PORT(	BTCCR1,BTCCR0 			: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			BTCNT_In 				: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			BTCTL 					: IN	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			clock 					: IN	STD_LOGIC;
			en_BTCNT 				: IN	STD_LOGIC;
			OUT_signal 				: OUT	STD_LOGIC;
			set_TBIFG 				: OUT	STD_LOGIC;
			BTCNT_Out 				: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			);
END 	BasicTimer;

ARCHITECTURE behavior OF BasicTimer IS
signal BTCCR0_Latch,BTCCR1_Latch	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
signal BTCNT 						: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
signal flag 						: STD_LOGIC_VECTOR( 31 DOWNTO 0 );


alias BTOUTEN is BTCTL(6);
alias BTHOLD is BTCTL(5);
alias BTSSEL is BTCTL(4 DOWNTO 3);
alias BTIP is BTCTL(2 DOWNTO 0);

alias Q0 is BTCNT(0);
alias Q3 is BTCNT(3);
alias Q7 is BTCNT(7);
alias Q11 is BTCNT(11);
alias Q15 is BTCNT(15);
alias Q19 is BTCNT(19);
alias Q23 is BTCNT(23);
alias Q25 is BTCNT(25);

BEGIN

BTCCR0_Latch<=BTCCR0;
BTCCR1_Latch<=BTCCR1;

flag<= BTCCR1-BTCNT;

--BTCTL_out<=BTCTL;
--BTCCR1_out<=BTCCR1_Latch;
--BTCCR0_out<=BTCCR0_Latch;
BTCNT_Out<=BTCNT;

OUT_signal<='1' when (flag(31)='0' and BTOUTEN='1') else
			'0';


set_TBIFG <= '1' when BTIP="000" and Q0='1' else
			 '1' when BTIP="001" and Q3='1' else
			 '1' when BTIP="010" and Q7='1' else
			 '1' when BTIP="011" and Q11='1' else
			 '1' when BTIP="100" and Q15='1' else
			 '1' when BTIP="101" and Q19='1' else
			 '1' when BTIP="110" and Q23='1' else
			 '1' when BTIP="111" and Q25='1' else
			 '0';


timer_proc:process(clock,BTSSEL,en_BTCNT)
	variable count : integer;
		BEGIN
			IF (reset = '1')THEN
				count:=0;
				BTCNT<=(others=>'0');
			elsif(en_BTCNT='1') THEN
				BTCNT<=BTCNT_In;
			elsif (clock'EVENT  AND clock = '1' and  BTHOLD='0')THEN
				count:=count+1;
				if((BTSSEL="01" and count=2) or (BTSSEL="10" and count=4) or (BTSSEL="11" and count=8) or BTSSEL="00") THEN
					if(BTCCR0=BTCNT)THEN
						BTCNT<=(others=>'0');
					else
						BTCNT<=BTCNT+1;
					end if;
					count:=0;
				END IF;
			END IF;
	END process;

END behavior;

