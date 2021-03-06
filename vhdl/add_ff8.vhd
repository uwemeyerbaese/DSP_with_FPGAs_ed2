--*********************************************************
-- IEEE STD 1076-1987/1993 VHDL file: add_ff8.vhd
-- Author-EMAIL: Uwe.Meyer-Baese@ieee.org
--*********************************************************
-- 8 bit adder with register without cin
LIBRARY lpm;
USE lpm.lpm_components.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY add_ff8 IS
  PORT ( a, b  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0); 
         clock : IN  STD_LOGIC;
         s     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END add_ff8;   

ARCHITECTURE pins OF add_ff8 IS

  SIGNAL r : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Result adder

BEGIN

  add_0: lpm_add_sub                  -- Add a and b
    GENERIC MAP ( LPM_WIDTH => 8,
--                  LPM_REPRESENTATION => "UNSIGNED",
                  LPM_DIRECTION => "ADD")  
    PORT MAP ( dataa => a, datab => b, result => r);
    
  reg_0: lpm_ff                    -- Save of x+y and carry
    GENERIC MAP ( LPM_WIDTH => 8 )  
    PORT MAP ( data => r, q => s, clock => clock );
    
END pins;
