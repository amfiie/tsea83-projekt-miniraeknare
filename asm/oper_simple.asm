 

INIT_DM:
    -- FIRST NUMBER 12345e3
    MOVI r4 40
    MOVI r11 5      -- Numbers length
    STORE r11 r4
    ADDI r4 1 
    MOVI r11 0      -- Sign identifier 0 for +, 1 for -
    STORE r11 r4
    ADDI r4 1 
    MOVI r11 3      -- Number tenpotens
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

    -- SECOND NUMBER 987e11
    MOVI r4 80
    MOVI r11 3      -- Numbers length
    STORE r11 r4
    ADDI r4 1 
    MOVI r11 0      -- Sign identifier 0 for +, 1 for -
    STORE r11 r4
    ADDI r4 1 
    MOVI r11 11      -- Number tenpotens
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

INIT_HEAP:
    -- $0   operator
    -- $1   ptr1
    -- $2   L1
    -- $3   T1
    -- $4   ptr2
    -- $5   L2
    -- $6   T2
    -- $7   ptrA
    -- $8   LA
    -- $9   TA
    -- $10  signA

    MOVI r10 0
    MOVI r5 18
    STORE r5 r10    -- Store operator
    ADDI r10 1
    MOVI r5 40
    STORE r5 r10    -- Store ptr1
    ADDI r10 1
    MOVI r5 5
    STORE r5 r10    -- Store L1
    ADDI r10 1
    MOVI r5 3
    STORE r5 r10    -- Store T1
    ADDI r10 1
    MOVI r5  80
    STORE r5 r10    -- Store ptr2
    ADDI r10 1
    MOVI r5 3
    STORE r5 r10    -- Store L2
    ADDI r10 1
    MOVI r5 11
    STORE r5 r10    -- Store T2
    ADDI r10 1
    MOV0 120        -- 120 + 3 + max(L1+T1, L2+T2) - min(T1, T2) (+1 when add)
    MOV r5 r0
    STORE r5 r10    -- Store ptrA
    ADDI r10 1
    MOVI r5 11      -- max(L1+T1, L2+T2) - min(T1, T2) (+1 when add)
    STORE r5 r10    -- Store LA
    MOVI r4 120     
    STORE r5 r4     -- Store LA in ans
    ADDI r10 1
    MOVI r5 4       -- min(T1, T2)
    STORE r5 r10    -- Store TA
    MOVI r4 122
    STORE r5 r4      -- Store TA in ans

START:
    --JMPI SIGN
    --LOAD_PC r13
    JMPI SET_POINTERS
    LOAD_PC r13
    JMPI OPER
    LOAD_PC r13
    HALT


SIGN:
    PUSH r1
    PUSH r2
    PUSH r3
    PUSH r4
    PUSH r5
    PUSH r6
    PUSH r7
    PUSH r8
    PUSH r9
    PUSH r10    -- HEAP pointer
    PUSH r11
    PUSH r12
    PUSH r13
    MOVI r10 0
    LOAD r1 r10 -- r1 <= operator
    MOVI r10 1
    LOAD r2 r10 -- r2 <= ptr1
    MOVI r10 2
    LOAD r3 r10 -- r3 <= L1
    MOVI r10 3
    LOAD r3 r10 -- r4 <= T1
    ADDI r2 1   
    LOAD r5 r2  -- r5 <= sign1
    SUBI r2 1
    MOVI r10 4
    LOAD r6 r10 -- r6 <= ptr2
    MOVI r10 5
    LOAD r7 r10 -- r7 <= L2
    MOVI r10 6
    LOAD r8 r10 -- r8 <= T2
    ADDI r6 1
    LOAD r9 r4  -- r9 <= sign2
    SUBI r6 1
    ADD r5 r9   -- r5 <= sign1 + sign2

    CMPI r5 0
    JMPEQ SIGN_EXIT
SIGN_OPER:
    CMPI r1 18
    JMPEQ SIGN_ADD_COMPARE
    CMPI r1 19
    JMPEQ SIGN_SUB_COMPARE
    NOP
    -- more operations here
SIGN_ADD_COMPARE:
    CMPI r5 2
    JMPEQ SIGN_NEGATIVE_A_ADD_B     -- ((-a) + (-b))
    CMPI r9 1
    JMPEQ SIGN_A_MINUS_B            -- (a + (-b))
    NOP 
    JMPI SIGN_B_MINUS_A             -- ((-a) + b)
    NOP
SIGN_SUB_COMPARE:
    CMPI r5 2
    JMPEQ SIGN_B_MINUS_A            -- ((-a) - (-b))
    CMPI r9 1
    JMPEQ SIGN_A_PLUS_B             -- (a - (-b))
    NOP
    JMPI SIGN_NEGATIVE_A_ADD_B      -- ((-a) - b)
    NOP
SIGN_NEGATIVE:                      / -(a operator b)
    MOVI r10 10
    MOVI r11 1
    JMPI SIGN_EXIT
    STORE r11 r10                   -- signA <= -
SIGN_NEGATIVE_A_ADD_B:              / -(a + b)
    MOVI r10 0
    MOVI r11 18
    STORE r11 r10                   -- operator <= +
    MOVI r10 10
    MOVI r11 1
    JMPI SIGN_EXIT
    STORE r11 r10                   -- signA <= -
SIGN_B_MINUS_A:                     / (b - a)
    MOVI r10 0
    MOVI r11 19
    STORE r11 r10                   -- operator <= -
    -- switch numbers
    MOVI r10 1
    STORE r6 r10
    MOVI r10 2
    STORE r7 r10
    MOVI r10 3
    STORE r8 r10
    MOVI r10 4
    STORE r2 r10
    MOVI r10 5
    STORE r3 r10
    MOVI r10 6
    JMPI SIGN_EXIT
    STORE r4 r10
SIGN_A_MINUS_B:                     / (a - b)
    MOVI r10 0
    MOVI r11 19
    JMPI SIGN_EXIT
    STORE r11 r10
SIGN_A_PLUS_B:                      / (a + b)
    MOVI r10 0
    MOVI r11 18
    JMPI SIGN_EXIT
    STORE r11 r10
SIGN_EXIT:
    POP r13
    POP r12
    POP r11
    POP r10
    POP r9
    POP r8
    POP r7
    POP r6
    POP r5
    POP r4
    POP r3
    POP r2
    JMP r13
    POP r1


SET_POINTERS:
    -- $0   operator
    -- $1   ptr1
    -- $2   L1
    -- $3   T1
    -- $4   ptr2
    -- $5   L2
    -- $6   T2
    -- $7   ptrA
    -- $8   LA
    -- $9   TA
    -- $10  signA
    -- r2 = ptr1
    -- r3 = ptr2
    -- r5 = start of ans (first free in nums)


    -- r2 = ptr1
    -- r3 = ptr2
    -- r4 = operand
    -- r5 = ans
    -- r6 = L1
    -- r7 = L2
    -- r8 = T1
    -- r9 = T2






    PUSH r13

    LOAD r8 r2    -- r8 <= L1
    ADDI r2 2     -- r2 <= ptr1 + 2
    LOAD r10 r12   -- r10 <= T1
    ADD r2 r8     -- r2 <= ptr1 + 2 + L1

    LOAD r9 r3    -- r9 <= L2
    ADDI r3 2     -- r3 <= ptr2 + 2
    LOAD r11 r3   -- r11 <= T2
    ADD r3 r9     -- r3 <= ptr2 + 2 + L2



    -- TA = min(T1, T2)
    JMPI MIN
    LOAD_PC r13
    MOVI r1 9
    STORE r12 r1
    MOV r1 r12

    -- LA = max(T1 + L1, T2 + L2) - TA
    ADD r10 r8      -- r10 <= T1 + L1
    ADD r11 r9      -- r11 <= T2 + L2
    JMPI MAX
    LOAD_PC r13
    SUB r12 r1
    MOVI r1 8
    STORE r12 r1

    -- ptrA
    MOVI r1 7
    LOAD r10 r1     -- r10 <= ptrA
    ADDI r10 3
    ADD r10 r12
    POP r13
    JMP r13
    STORE r10 r1


MAX:    -- r12 = max(r10, r11)
    CMP r10 r11
    JMPGE MAX_EXIT
    MOV r12 r10
    MOV r12 r11
MAX_EXIT:
    JMP r13


MIN:    -- r12 = min(r10, r11)
    CMP r10 r11
    JMPN MIN_EXIT
    MOV r12 r10
    MOV r12 r11
MIN_EXIT:
    JMP r13
    NOP



OPER:
    PUSH r4
    PUSH r5
    PUSH r6
    PUSH r7
    PUSH r8
    PUSH r9
    PUSH r10
    PUSH r11
    PUSH r12
    PUSH r13
    PUSH r14    -- carry
    MOVI r14 0  -- initiate carry
OPER_BCD:
    MOVI r4 1
    LOAD r5 r4  -- r5 <= ptr1
    MOVI r4 2
    LOAD r6 r4  -- r6 <= L1
    MOVI r4 3
    LOAD r7 r4  -- r7 <= T1
    MOVI r4 4
    LOAD r8 r4  -- r8 <= ptr2
    MOVI r4 5
    LOAD r9 r4  -- r9 <= L2
    MOVI r4 6
    LOAD r10 r4 -- r10 <= T2
OPER_BCD_PADD_SIDE:
    CMPI r6 0
    JMPEQ OPER_BCD_PADD_FRONT_FIRST
    CMPI r9 0
    JMPEQ OPER_BCD_PADD_FRONT_SECOND
OPER_BCD_PADD_BACK:
    CMP r7 r10  -- T1 = T2
    JMPEQ OPER_BCD_PADD_NONE
    CMP r7 r10  -- T1 < T2
    JMPN OPER_BCD_PADD_SECOND
    NOP
    JMPI OPER_BCD_PADD_FIRST
    NOP
OPER_BCD_PADD_FRONT_SECOND:
    CMP r10 r7  -- T2 < T1
    JMPN OPER_BCD_PADD_BOTH
    ADDI r10 1  -- T2++
    JMPI OPER_BCD_PADD_SECOND
    NOP
OPER_BCD_PADD_FRONT_FIRST:
    CMP r7 r10  -- T1 < T2
    JMPN OPER_BCD_PADD_BOTH
    ADDI r7 1   -- T1++
OPER_BCD_PADD_FIRST:
    SUBI r9 1   -- L2--
    ADDI r10 1  -- T2++
    MOVI r11 0  -- Padd first
    LOAD r12 r8 -- r12 <= DM(ptr2)
    JMPI OPER_BCD_STORE
    SUBI r8 1   -- ptr2--
OPER_BCD_PADD_NONE:
    SUBI r6 1   -- L1--
    SUBI r9 1   -- L2--
    LOAD r11 r5 -- r11 <= DM(ptr1)
    SUBI r5 1   -- ptr1--
    LOAD r12 r8 -- r12 <= DM(ptr2)
    JMPI OPER_BCD_STORE
    SUBI r8 1   -- ptr2--
OPER_BCD_PADD_BOTH:
    MOVI r11 0  -- Padd first
    JMPI OPER_BCD_STORE
    MOVI r12 0  -- Padd second
OPER_BCD_PADD_SECOND:
    SUBI r6 1   -- L1--
    ADDI r7 1   -- T1++
    LOAD r11 r5 -- r11 <= DM(ptr1)
    SUBI r5 1   -- ptr1--
    MOVI r12 0  -- Padd second
OPER_BCD_STORE:
    MOVI r4 1
    STORE r5 r4  -- r5 <= ptr1
    MOVI r4 2
    STORE r6 r4  -- r6 <= L1
    MOVI r4 3
    STORE r7 r4  -- r7 <= T1
    MOVI r4 4
    STORE r8 r4  -- r8 <= ptr2
    MOVI r4 5
    STORE r9 r4  -- r9 <= L2
    MOVI r4 6
    STORE r10 r4 -- r10 <= T2
OPER_VAL:
    MOVI r4 7
    LOAD r5 r4     -- Get ptrA
    SUBI r5 1      -- ptrA--
    STORE r5 r4    -- Store ptr2 in HEAP
    MOVI r4 8
    LOAD r6 r4     -- Get LA  
    SUBI r6 1      -- LA--
    STORE r6 r4    -- Store LA in HEAP 
    MOVI r4 0
    LOAD r7 r4  -- Get operator
    CMPI r7 18
    JMPEQ OPER_ADD
    CMPI r7 19
    JMPEQ OPER_SUB
    NOP
OPER_ADD:
    MOV0 ADD
    MOV r8 r0    -- Save subrutine ADD addr in r8
    CMPI r6 0
    JMPGE OPER_EXEC
    NOP
    JMPI OPER_EXIT
    STORE r14 r5   -- Store carry in DM(ptrA)
OPER_SUB:
    MOV0 SUB
    MOV r8 r0    -- Save subrutine SUB addr in r8
    CMPI r6 0
    JMPGE OPER_EXEC
    MOVI r7 120       -- Pointer to answer
    CMPI r14 1
    JMPEQ COMPLEMENT
    LOAD_PC r13
    MOVI r4 121
    JMPI OPER_EXIT
    STORE r14 r4      -- Store negative sign in ans
OPER_EXEC:
    JMP r8        -- Call operation subrutine
    LOAD_PC r13
    JMPI OPER_BCD
    STORE r11 r5   -- Store answer at DM(ptrA)
OPER_EXIT:
    POP r14
    POP r13
    POP r12
    POP r11
    POP r10
    POP r9
    POP r8
    POP r7
    POP r6
    POP r5
    JMP r13
    POP r4


COMPLEMENT:
    -- r7 = ptr (pointer to number that will be complemented)
    PUSH r6
    PUSH r7
    PUSH r11
    PUSH r12
    PUSH r13
    PUSH r14
    MOVI r14 0      -- Initate carry
    LOAD r6 r7      -- Get number length L
    ADDI r7 3
    ADD r7 r6      -- Make pointer point on last decimal
COMPLEMENT_ITER:
    MOVI r11 0       
    LOAD r12 r7     -- Get decimal
    JMPI SUB        -- Make subtraction
    LOAD_PC r13
    STORE r11 r7    -- Store complemented decimal
    SUBI r6 1       -- L--
    CMPI r6 0
    JMPGE COMPLEMENT_ITER
    SUBI r7 1       -- ptr--
COMPLEMENT_EXIT:
    POP r14
    POP r13
    POP r12
    POP r11
    POP r7
    JMP r13
    POP r6


ADD:
    ADD r11 r12     -- Addition
    ADD r11 r14     -- Add carry
    CMPI r11 10
    JMPGE ADD_CARRY
    NOP
    MOVI r14 0      -- Unset carry
    JMPI ADD_EXIT
    NOP
ADD_CARRY:
    MOVI r14 1      -- Set carry
    SUBI r11 10     -- Make one digit
ADD_EXIT:
    JMP r13
    NOP
    
SUB:
    SUB r11 r12     -- Subtraction
    SUB r11 r14     -- Sub carry
    CMPI r11 0
    JMPN SUB_CARRY
    NOP
    MOVI r14 0      -- Unset carry
    JMPI SUB_EXIT
    NOP
SUB_CARRY:
    MOVI r14 1      -- Set carry
    ADDI r11 10     -- Make number positive
SUB_EXIT:
    JMP r13
    NOP