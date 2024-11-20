-- r1 = cursor
-- r2 = start of current line
-- r3 = end of current line
-- r4 = dm equation address
-- r5 dm cur_num free
-- r8 operand
-- r9 first number
-- r10 second number
-- r13 return address
-- r15 key input

INIT_DM:
    -- EQ
    MOVI r4 20
    MOVI r11 1      -- First number identifier
    STORE r11 r4
    ADDI r4 1
    MOVI r11 40     -- Pointer to first number
    STORE r11 r4
    ADDI r4 1
    MOVI r11 18     -- + operand
    STORE r11 r4
    ADDI r4 2
    MOVI r11 1      -- Second number identifier
    STORE r11 r4
    ADDI r4 1
    MOVI r11 50     -- Pointer to second number
    STORE r11 r4

    -- FIRST NUMBER
    MOVI r4 40
    MOVI r11 3      -- Numbers length
    STORE r11 r4
    ADDI r4 1 
    MOVI r11 0      -- Sign identifier 0 for +, 1 for -
    STORE r11 r4
    ADDI r4 1 
    MOVI r11 4      -- Number tenpotens
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

    -- SECOND NUMBER
    MOVI r4 50
    MOVI r11 3      -- Numbers length
    STORE r11 r4
    ADDI r4 1 
    MOVI r11 0      -- Sign identifier 0 for +, 1 for -
    STORE r11 r4
    ADDI r4 1 
    MOVI r11 2      -- Number tenpotens
    STORE r11 r4
    ADDI r4 1
    MOVI r11 4      -- First number decimal
    STORE r11 r4
    ADDI r4 1
    MOVI r11 5      -- Second number decimal
    STORE r11 r4
    ADDI r4 1
    MOVI r11 6      -- Third number decimal
    STORE r11 r4


-- TODO: rewrite using subrutines!!!
OPER:
    MOVI r10 0      -- heap pointer
    MOVI r4 20

    -- Store first number
    ADDI r4 1
    JMPI STORE_NUM_IN_HEAP
    LOAD_PC r13

    -- Store second number
    ADDI r4 4  
    ADDI r10 1
    JMPI STORE_NUM_IN_HEAP
    LOAD_PC r13
OPER_ANSWER:
    MOVI r4 6
    MOVI r11 60
    PUSH r11    -- push answer pointer on stack
OPER_ANSWER_PROPERTIES:
    JMPI ANSWER_PROPERTIES
    LOAD_PC r13


STORE_EQ_IN_HEAP:
    PUSH r13

    MOVI r10 0      -- r10 HEAP pointer
    MOVI r4 20      -- r4 EQ pointer
    -- Store first number
    STORE r4 r10    -- Store first number pointer at HEAP addr = 0
    ADDI r10 1
    LOAD r11 r4     -- r11 = first number length
    STORE r11 r10   -- Store first number length at HEAP addr = 1
    ADDI r10 1
    
    -- TODO: take into account the numbers sign
    ADDI r4 1
    
    -- TODO: continue implementation here!!!!
    ADDI r4 1




    LOAD r11
    POP r13
    JMPI r13
    NOP


-- This subrutine is being reimplemented!!!!
STORE_NUM_IN_HEAP:  -- TODO store number addr and current number addr
    PUSH r4
    PUSH r8
    PUSH r9
    PUSH r10
    PUSH r11
    PUSH r13
    LOAD r8 r4
    MOV r9 r8
    LOAD r11 r9     -- get first number length
    ADDI r10 1
    STORE r11 r10   -- store first number length in heap
    ADDI r8 2
    ADD r8 r11
    SUBI r10 1
    STORE r8 r10    -- store first number pointer in heap (pointing on last decimal)
    ADDI r9 2
    LOAD r11 r9     -- get first number tenpotens
    ADDI r10 2
    STORE r11 r10   -- store first number tenpoten in heap
    POP r13
    POP r11
    POP r10
    POP r9
    POP r8
    JMP r13
    POP r4


ANSWER_PROPERTIES:
    PUSH r4
    PUSH r8
    PUSH r9
    PUSH r10
    PUSH r11
    PUSH r12
    PUSH r13
    -- Get the two numbers properties
    MOVI r4 1
    LOAD r8 r4  -- get first number length
    MOVI r4 2
    LOAD r9 r4  -- get first number tenpotens
    MOVI r4 4
    LOAD r10 r4 -- get second number length
    MOVI r4 5
    LOAD r11 r4 -- get second number tenpotens
ANSWER_PROPERTIES_TENPOTENS:
    -- answer tenpotens = min(T1, T2) 
    PUSH r10
    PUSH r11
    MOV r10 r9
    JMPI MIN        -- r12 = min(T1, T2) 
    LOAD_PC r13
    POP r11
    POP r10
    MOVI r4 7
    STORE r12 r4    -- store answer tenpotens in HEAP
ANSWER_PROPERTIES_LENGTH:
    -- answer length = max(T1 + L1, T2 + L2) - min(T1, T2) 
    PUSH r12        -- stack = min(T1, T2)
    ADD r11 r10     -- r11 = T2 + L2
    MOV r10 r8      -- r10 = L1
    ADD r10 r9      -- r10 = L1 + T1
    JMPI MAX        -- r12 = max(T1 + L1, T2 + L2)
    LOAD_PC r13
    POP r10         -- r10 = min(T1, T2)
    SUB r12 r10     -- r12 = max(T1 + L1, T2 + L2) - min(T1, T2)
    MOVI r4 6
    STORE r12 r4    -- store answer length in HEAP
ANSWER_PROPERTIES_EXIT:
    POP r13
    POP r12
    POP r11
    POP r10
    POP r9
    POP r8
    JMPI r13
    POP r4


MAX:    -- r12 = max(r10, r11)
    PUSH r13
    CMP r10 r11
    JMPGE MAX_EXIT
    MOV r12 r11
    MOV r12 r10
MAX_EXIT:
    POP r13
    JMPI r13
    NOP


MIN:    -- r12 = min(r10, r11)
    PUSH r13
    CMP r10 r11
    JMPGE MIN_EXIT
    MOV r12 r10
    MOV r12 r11
MIN_EXIT:
    POP r13
    JMPI r13
    NOP


OPER_ANSWER_TENPOTENS_STORE:
    STORE r9 r4     -- store answer length
    MOVI r11 62     -- addr in DM to store answer tenpotens
    STORE r9 r11    -- store answer length in DM(ans)
OPER_ANSWER_LENGTH:
    MOVI r4 1
    LOAD r8 r4      -- Get first number length
    MOVI r4 4
    LOAD r10 r4     -- Get second number length
    CMP r9 r10
    JMPGE OPER_ANSWER_LENGTH_STORE
    MOVI r4 7       -- where to store answer length in HEAP
    MOV r8 r10     -- r10 > r8 (second number length > first number length)
OPER_ANSWER_LENGTH_STORE:
    ADDI r8 1       -- add carry number space, TODO: can differ due to operator! 
    ADDI r8 r9      -- add number differ
    STORE r8 r4     -- store answer length in HEAP 
    MOVI r11 60     -- addr in DM to store answer length
    STORE r8 r11    -- store answer length in DM(ans)


OPER_EXEC:
    MOVI r4 22
    LOAD r8 r4          -- save operator in r8
    
    JMPI GET_NUMBERS
    LOAD_PC r13
    
    CMPI r8 18
    JMPEQ OPER_ADD
    NOP
OPER_ADD:


GET_NUMBERS:
    PUSH r13
    
    -- TODO save the numbers to be calculated in regster r9 and r10

    POP r13
    JMP r13
    NOP 