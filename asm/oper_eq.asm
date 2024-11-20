-- EQ
-- $20     +        | $20   +
-- $21     N1       | $21   +
-- $22     -        | $22   N1
-- $23     N2       | $23   N2
-- $24     N3       | $24   +
-- N1 + (N2 - N3)   | $25   N3
--                  | $26   N4
--                  | (N1 + N2) + (N3 + N2) 

-- HEAP
-- $0   

INIT_DM:
    -- FIRST NUMBER 12345e2
    MOVI r4 40
    MOVI r11 5      -- Numbers length
    STORE r11 r4
    ADDI r4 1 
    MOVI r11 0      -- Sign identifier 0 for +, 1 for -
    STORE r11 r4
    ADDI r4 1 
    MOVI r11 2      -- Number tenpotens
    STORE r11 r4
    ADDI r4 1
    MOVI r11 1      -- First number decimal
    STORE r11 r4
    ADDI r4 1
    MOVI r11 2      -- Second number decimal
    STORE r11 r4
    ADDI r4 1
    MOVI r11 3      -- Third number decimal
    STORE r11 r4
    ADDI r4 1
    MOVI r11 4      -- 4th number decimal
    STORE r11 r4
    ADDI r4 1
    MOVI r11 5      -- 5th number decimal
    STORE r11 r4

    -- SECOND NUMBER 987e4
    MOVI r4 80
    MOVI r11 3      -- Numbers length
    STORE r11 r4
    ADDI r4 1 
    MOVI r11 0      -- Sign identifier 0 for +, 1 for -
    STORE r11 r4
    ADDI r4 1 
    MOVI r11 4      -- Number tenpotens
    STORE r11 r4
    ADDI r4 1
    MOVI r11 9      -- First number decimal
    STORE r11 r4
    ADDI r4 1
    MOVI r11 8      -- Second number decimal
    STORE r11 r4
    ADDI r4 1
    MOVI r11 7      -- Third number decimal
    STORE r11 r4

INIT_HEAP
    




    MOVI r4 20
OPER:
    PUSH r4
    PUSH r5
    PUSH r6
    PUSH r13
    MOVI r5 0       -- HEAP begin
OPER_ITER:
    LOAD r6 r4
    CMPI r6 1       -- is it a number
    JMPE SETUP_HEAP_NUMBER
    CMPI r6 

OPER_NUMBER:


OPER_EXIT:
    POP r13
    POP r6
    POP r5
    JMPI r13
    POP r4


NUMBER_PROPERTIES:
