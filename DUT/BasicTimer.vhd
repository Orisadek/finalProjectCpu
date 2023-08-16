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
			clock,reset_timer 		: IN	STD_LOGIC;
			CS7		 				: IN	STD_LOGIC;
			OUT_signal 				: OUT	STD_LOGIC;
			set_TBIFG 				: OUT	STD_LOGIC;
			BTCNT_Out 				: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 )
			);
END 	BasicTimer;

ARCHITECTURE behavior OF BasicTimer IS
signal BTCL1,BTCL0: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
signal BTCNT 						: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
signal flag_down,flag_up			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
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

flag_down <= BTCNT-BTCL1; -- BTCNT<BTCL1
flag_up   <= BTCL0-BTCNT; -- BTCNT>BTCL0

OUT_signal<='1' when ((flag_down(31)='1' or flag_up(31)='1') and BTOUTEN='1') else --- PWM
			'0';

-------------------TBIFG -------------------------------------
set_TBIFG<=	'1' when (Q0 ='1' AND BTIP="000" )else
			'1' when (Q3 ='1' AND BTIP="001") else
			'1' when (Q7 ='1' AND BTIP="010") else
			'1' when (Q11='1' AND BTIP="011") else
			'1' when (Q15='1' AND BTIP="100") else
			'1' when (Q19='1' AND BTIP="101") else
			'1' when (Q23='1' AND BTIP="110") else
			'1' when (Q25='1' AND BTIP="111") else
			'0';



timer_proc:process(clock,reset_timer)
	variable count : integer;
	variable BTCNT_tmp : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		BEGIN
			IF(reset_timer = '1')THEN --reset
					count:=0;
					BTCNT<=(others=>'0');
					BTCNT_Out<=(others=>'0');
			elsif(clock'EVENT  AND clock = '1') THEN
				if(CS7='1')THEN -- write to BTCNT
					BTCNT<=BTCNT_In;
					BTCNT_Out<=BTCNT_In;
					count:=0;
				elsif(BTHOLD='0') THEN -- start the clock
					count:=count+1;
					if(BTCNT =X"11111111") THEN -- overflow
						BTCNT_tmp:=(others=>'0');
					else
						BTCNT_tmp:=BTCNT+1; 
					end if;
					if((BTSSEL="01" and (count=2 or count>2)) or (BTSSEL="10" and (count=4 or count>4)) or (BTSSEL="11" and (count=8 or count>8)) or BTSSEL="00") THEN
						BTCNT<=BTCNT_tmp;
						BTCNT_Out<=BTCNT_tmp;
						count:=0;
					END IF;
				END IF;
			END IF;
	END process;

END behavior;

