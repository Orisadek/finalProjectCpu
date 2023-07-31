				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY IV IS
	generic (
			ResSize : positive := 32;
			address_size_orig :positive:=12
			); 
	PORT(  
			Address_Bus      	 : IN 	 STD_LOGIC_VECTOR( address_size_orig-1 DOWNTO 0 );
			memRead,memWrite 	 : IN 	 STD_LOGIC;
			reqSrcKey1			 : IN	 STD_LOGIC;
			reqSrcKey2			 : IN	 STD_LOGIC;
			reqSrcKey3			 : IN	 STD_LOGIC;
			reqSrcBT 			 : IN	 STD_LOGIC;
			INTA				 : IN	 STD_LOGIC;
			GIE 				 : IN	 STD_LOGIC;
			INTR			 	 : OUT	 STD_LOGIC;
			Data_Bus    		 : INOUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 )
		   );
END 	IV;

ARCHITECTURE behavior OF IV IS
signal IE,IFG,_TYPE 				    : 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );	
signal CS10 		 					:  STD_LOGIC;
signal reqKey1,reqKey2,reqKey3,reqBT 	:  STD_LOGIC;


alias BTIE 	 is IE(2);
alias KEY1IE is IE(3);
alias KEY2IE is IE(4);
alias KEY3IE is IE(5);

alias BTIFG is 	 IFG(2);
alias KEY1IFG is IFG(3);
alias KEY2IFG is IFG(4);
alias KEY3IFG is IFG(5);

alias A11 is Address_Bus(11);
alias A5  is Address_Bus(5);
alias A4  is Address_Bus(4);
alias A3  is Address_Bus(3);
alias A2  is Address_Bus(2);
alias A1  is Address_Bus(1);
alias A0  is Address_Bus(0);

alias _TYPEx is _TYPE(4 DOWNTO 1);
begin

	CS10<='1' when (A11='1' and A5='1' and A4='0' and A3='1' and A2='1') else '0'; --IE,IFG,TYPE
---------------------------------------------insert iv registers ------------------------------------------------	
	iv_insert_proc:process(reset,clock)
	BEGIN
		IF (reset = '1')THEN
			IE		<=(others=>'0');
			IFG		<=(others=>'0');
		elsif (clock'EVENT  AND clock = '0' and CS10='1' and memWrite='1')THEN
			if(A0='0'AND A1='0') THEN
				IE		<= Data_Bus(7 DOWNTO 0 );
			elsif(A0='1'AND A1='0') THEN
				IFG		<= Data_Bus(7 DOWNTO 0 );
			else
				NULL;
			end IF;
	END process;
---------------------------------------------read iv type ------------------------------------------------	
	Data_Bus<=X"000000"&_TYPE WHEN (CS10='1' AND A0='0'AND A1='1' and memRead = '1') else (others=>'Z');
--------------------------------------------	
	
	intr_handle:proc:process(reqSrcKey1,reqSrcKey2,reqSrcKey3,reqSrcBT)
	BEGIN
		IF 	  (reqSrcKey1'EVENT and reqSrcKey1 = '1')THEN
				reqKey1<='1';
		elsif (reqSrcKey2'EVENT and reqSrcKey2 = '1')THEN
			    reqKey2<='1';
		elsif (reqSrcKey3'EVENT and reqSrcKey3 = '1')THEN
				reqKey3<='1';
		elsif (reqSrcBT'EVENT 	and reqSrcBT = '1')THEN
				reqBT<='1';
		else
				NULL;
		END if;
	END process;
	
	BTIFG 	<= reqBT and BTIE;
	KEY1IFG <= reqKey1 and KEY1IE;
	KEY2IFG <= reqKey2 and KEY2IE;
	KEY3IFG <= reqKey3 and KEY3IE;		
	
	
	_TYPEx <= X"10" WHEN BTIFG='1'   else
			  X"14" WHEN KEY1IFG='1' else
			  X"18" WHEN KEY2IFG='1' else
			  X"1C" WHEN KEY3IFG='1' else
			  others=>'0';
	
	INTR <= ((reqBT and BTIE) or (reqKey1 and KEY1IE) or (reqKey2 and KEY2IE) or (reqKey3 and KEY3IE))and GIE;  --GIE is nothing
	
END behavior;

