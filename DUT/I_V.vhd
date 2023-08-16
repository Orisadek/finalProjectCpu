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
	PORT(  	reset,clock			 : IN	 STD_LOGIC;
			Address_Bus      	 : IN 	 STD_LOGIC_VECTOR( address_size_orig-1 DOWNTO 0 );
			memRead,memWrite 	 : IN 	 STD_LOGIC;
			reqSrcKey1			 : IN	 STD_LOGIC;
			reqSrcKey2			 : IN	 STD_LOGIC;
			reqSrcKey3			 : IN	 STD_LOGIC;
			reqSrcBT 			 : IN	 STD_LOGIC;
			INTA				 : IN	 STD_LOGIC;
			GIE 				 : IN	 STD_LOGIC;
			clr_req				 : IN   STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			INTR			 	 : OUT	 STD_LOGIC;
			Data_Bus    		 : INOUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 )
		   );
END 	IV;

ARCHITECTURE behavior OF IV IS
signal IE,IFG,TYPE_V 				    : STD_LOGIC_VECTOR( 7 DOWNTO 0 );	
signal CS10,flag 		 						:  STD_LOGIC;
signal reqKey1,reqKey2,reqKey3,reqBT,reqReset 	:  STD_LOGIC;
--signal BTIFG_local,KEY1IFG_local,KEY2IFG_local,KEY3IFG_local :  STD_LOGIC;
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

alias clrReset is clr_req(0);
alias clrBT    is clr_req(1);
alias clrKey1  is clr_req(2);
alias clrKey2  is clr_req(3);
alias clrKey3  is clr_req(4);

alias TYPEx is TYPE_V(4 DOWNTO 0);
begin

	CS10<='1' when (A11='1' and A5='1' and A4='0' and A3='1' and A2='1') else '0'; --IE,IFG,TYPE
---------------------------------------------insert iv registers ------------------------------------------------	
	iv_insert_proc:process(reqReset,clock)
	BEGIN
		IF (reqReset = '1')THEN
			IE		<=(others=>'0');
			IFG		<=(others=>'0');	
		elsif (clock'EVENT  AND clock = '0')THEN
			if(CS10='1' and memWrite='1') THEN
				if(A0='0'AND A1='0') THEN
					IE		<= Data_Bus(7 DOWNTO 0 );
				elsif(A0='1'AND A1='0') THEN
					IFG		<= Data_Bus(7 DOWNTO 0 );
				else
					NULL;
				end IF;
			else
				BTIFG   <= (reqBT and BTIE);
				if(reqKey1='1' and KEY1IE='1') THEN
					KEY1IFG <= (reqKey1 and KEY1IE);
				elsif(reqKey2='1' and KEY2IE='1') THEN 
					KEY2IFG <= '1' ; 
				elsif(reqKey3='1' and KEY3IE='1') THEN 
					KEY3IFG <= '1';
				else
					null;
				end IF;
			end IF;
		else 
			null;
		end IF;
	END process;
---------------------------------------------read iv type ------------------------------------------------	
	Data_Bus<=X"000000"&TYPE_V WHEN (CS10='1' AND A0='0'AND A1='1' and memRead = '1' and INTA='0' AND (GIE='1' or reqReset='1')) else 
			unaffected when (CS10='1' AND A0='0'AND A1='1' and memRead = '1' and INTA='0'and  GIE='0' and reqReset='0')else
			  X"000000"&IFG when (CS10='1' and memRead='1' and A0='1'AND A1='0') else
			(others=>'Z');	
----------------------------------------------rise and fall of the requests-----------------------------------------------------------	
	
	reset_handle_proc:process(reset,clrReset)
	BEGIN
		if(clrReset='1') THEN
				reqReset 	<='0';
		elsif(reset'EVENT and reset = '0') THEN
				reqReset 	<= '1';
		else
				NULL;
		END if;
	END process;

	key1_handle_proc:process(reqSrcKey1,clrKey1,clrReset)
	BEGIN
		if (clrKey1 = '1' or clrReset='1')THEN
			reqKey1		<='0';
		elsif (reqSrcKey1'EVENT and reqSrcKey1 = '0')THEN
				reqKey1		<='1';
		else
				NULL;
		END if;
	END process;
	
	key2_handle_proc:process(reqSrcKey2,clrKey2,clrReset)
	BEGIN
		if (clrKey2 = '1' or clrReset='1' )THEN
			reqKey2		<='0';
		elsif (reqSrcKey2'EVENT and reqSrcKey2 = '0')THEN
			    reqKey2		<='1';
		else
				NULL;
		END if;
	END process;
	
	
	key3_handle_proc:process(reqSrcKey3,clrKey3,clrReset)
	BEGIN
		if (clrKey3 = '1' or clrReset='1')THEN
			reqKey3		<='0';
		elsif (reqSrcKey3'EVENT and reqSrcKey3 = '0')THEN
				reqKey3		<='1';
		else
				NULL;
		END if;
	END process;
	
	bt_handle_proc:process(reqSrcBT,clrBT,clrReset)
	BEGIN
		if(clrBT = '1' or clrReset='1')THEN
			reqBT	<= '0';
		elsif (reqSrcBT'EVENT and reqSrcBT = '1')THEN
			reqBT		<='1';
		else
				NULL;
		END if;
	END process;
	
---------------------------------------Type of request----------------------------------------------	
	
	TYPEx <=  "00000" WHEN reqReset='1' else --00h
			  "10000" WHEN (BTIFG='1'   and reqReset='0')  else -- 10h
			  "10100" WHEN (KEY1IFG='1' and BTIFG='0'   and reqReset='0') else --14h
			  "11000" WHEN (KEY2IFG='1' and KEY1IFG='0' and BTIFG='0'   and reqReset='0') else --18h
			  "11100" WHEN (KEY3IFG='1' and KEY2IFG='0' and KEY1IFG='0' and BTIFG='0' and reqReset='0') else --1Ch
			  (others=>'X');
	
	TYPE_V(7 DOWNTO 5)<= (others=>'0');

---------------------------------------INTR----------------------------------------------	
	INTR <= ((BTIFG or KEY1IFG or KEY2IFG or KEY3IFG) and GIE) or reqReset;  
	

	
END behavior;

