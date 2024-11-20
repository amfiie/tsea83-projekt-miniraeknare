-- r1(operand), r2(ptr1), r3(ptr2)

-- r1 - cursor 
-- r4 - eq end
-- r5 - end of nums

-- Set up DM for test
INIT_DM:
    MOVI r4 50

    -- EQ
    MOVI r6 40
    MOVI r11 1      -- First number identifier
    STORE r11 r6
    ADDI r6 1
    MOVI r11 0     -- Pointer to first number
    STORE r11 r6
    ADDI r6 1
    MOVI r11 18     -- + operand
    STORE r11 r6
    ADDI r6 2
    MOVI r11 1      -- Second number identifier
    STORE r11 r6
    ADDI r6 1
    MOVI r11 10     -- Pointer to second number
    STORE r11 r6
    ADDI r6 1
    MOVI r11 15     -- operand with lower prio than +
    STORE r11 r6
    ADDI r6 2
    MOVI r11 1      -- third number identifier
    STORE r11 r6
    ADDI r6 1
    MOVI r11 20     -- Pointer to third number
    STORE r11 r6



    -- FIRST NUMBER ON HEAP
    MOVI r7 0
    MOVI r11 3      -- Numbers length
    STORE r11 r7
    ADDI r7 1 
    MOVI r11 0      -- Sign identifier 0 for +, 1 for -
    STORE r11 r7
    ADDI r7 1 
    MOVI r11 4      -- Number exponent
    STORE r11 r7
    ADDI r7 1
    MOVI r11 1      -- First number decimal
    STORE r11 r7
    ADDI r7 1
    MOVI r11 2      -- Second number decimal
    STORE r11 r7
    ADDI r7 1
    MOVI r11 3      -- Third number decimal
    STORE r11 r7

    -- SECOND NUMBER
    MOVI r6 10
    MOVI r11 3      -- Numbers length
    STORE r11 r6
    ADDI r6 1
    MOVI r11 0      -- Sign identifier 0 for +, 1 for -
    STORE r11 r6
    ADDI r6 1
    MOVI r11 2      -- Number tenpotens
    STORE r11 r6
    ADDI r6 1
    MOVI r11 4      -- First number decimal
    STORE r11 r6
    ADDI r6 1
    MOVI r11 5      -- Second number decimal
    STORE r11 r6
    ADDI r6 1
    MOVI r11 6      -- Third number decimal
    STORE r11 r6

    -- THIRD NUMBER
    MOVI r6 20
    MOVI r11 2      -- Numbers length
    STORE r11 r6
    ADDI r6 1
    MOVI r11 1      -- Sign identifier 0 for +, 1 for -
    STORE r11 r6
    ADDI r6 1
    MOVI r11 80     -- Number tenpotens
    STORE r11 r6
    ADDI r6 1
    MOVI r11 8      -- First number decimal
    STORE r11 r6
    ADDI r6 1
    ADDI r11 1      -- Second number decimal (8 + 1)
    STORE r11 r6

    JMPI GET_ANS
    LOAD_PC r13
    NOP
    HALT
    NOP

-- Set up HEAP for calculations of type num, oper, num or num only
GET_ANS:
    PUSH r13
GET_ANS_BODY:
    MOVI r7 0
    JMPI GET_MOST_SIGN_OPER
    LOAD_PC r13
-- Decide what type of oper it is, if not oper put num in ANS
GET_ANS_DECIDE_OPER:
    CMPI r12 28 -- compare with 28 to check wheter or not operand still contains a parenthesis
    JMPN GET_ANS_DECIDE_OPER_BELOW_TWENTY_EIGHT 
    NOP
    SUBI r12 20 -- reduce oper size to remove paraenthesis
    JMPI GET_ANS_DECIDE_OPER
GET_ANS_DECIDE_OPER_BELOW_TWENTY_EIGHT: -- if is less store value and let Markus do CALC in oper_simple code
    CMPI r12 10
    JMPGE GET_ANS_DECIDE_OPER_STORE_EXPRESSION_IN_HEAP
    CMPI r12 10
    JMPN GET_ANS_DECIDE_OPER_STORE_SINGLE_NUMBER_IN_ANS
    NOP
GET_ANS_DECIDE_OPER_STORE_EXPRESSION_IN_HEAP:
    MOV r1 r12  -- store operand
    SUBI r11 1  -- ptr 1 in eq
    LOAD r2 r11 -- get pointer to first num 
    ADDI r11 4  -- ptr 2 in eq
    LOAD r3 r11 -- get pointer to second num 
    MOV r8 r5   -- save old end of nums
    -- Loop eq and repair eq from hole
    SUBI r11 3
    PUSH r11
    MOV r9 r11
    ADDI r9 4 
GET_ANS_DECIDE_OPER_REPAIR_EQ_LOOP:
    CMP r9 r4
    JMPEQ GET_ANS_DECIDE_OPER_REPAIR_EQ_END
    LOAD r10 r9
    STORE r10 r11
    ADDI r11 1
    JMPI GET_ANS_DECIDE_OPER_REPAIR_EQ_LOOP
    ADDI r9 1
GET_ANS_DECIDE_OPER_REPAIR_EQ_END:
    SUBI r4 4
    JMPI OPER_SIMPLE  
    LOAD_PC r13
    POP r11
    SUBI r11 1
    JMPI GET_ANS_BODY
    STORE r8 r11
GET_ANS_DECIDE_OPER_STORE_SINGLE_NUMBER_IN_ANS:
    MOV0 200
    ADDI r11 1
    LOAD r12 r11  -- r12 ptr to number
    LOAD r8 r12     -- r8 is length
    ADDI r8 3   -- length plus info length 
GET_ANS_DECIDE_OPER_STORE_NUMBER_IN_ANS_LOOP:
    LOAD r10 r12
    STORE r10 r0
    ADDI r12 1
    SUBI r8 1
    CMPI r8 0
    JMPNEQ GET_ANS_DECIDE_OPER_STORE_NUMBER_IN_ANS_LOOP 
    ADDI r0 1
GET_ANS_EXIT:
    POP r13
    JMP r13
    NOP
    

-- r12 will contain oper value 
-- r11 is pos in eq for largest operand
GET_MOST_SIGN_OPER: 
    MOVI r12 0
    MOVI r7 40  -- DM, EQ pos
    MOV r11 r7
    LOAD r12 r11 -- r12 contains biggest oper
GET_MOST_SIGN_OPER_LOOP:
    ADDI r7 2   -- first can not be oper, increase addr in eq
    CMP r7 r4  -- check if we are in eq
    JMPEQ GET_MOST_SIGN_OPER_EXIT
    LOAD r10 r7 -- save value in temp
    CMP r10 r12 
    JMPN GET_MOST_SIGN_OPER_LOOP
    NOP
    MOV r12 r10
    MOV r11 r7
    JMPI GET_MOST_SIGN_OPER_LOOP
    NOP
GET_MOST_SIGN_OPER_EXIT:
    JMP r13
    NOP
OPER_SIMPLE:
    MOV r8 r3
    JMP r13
    NOP