INIT:
    MOVI r2 40
    MOVI r3 80
    MOVI r5 90
    JMPI BCD_DIV
    LOAD_PC r13
    MOVI r1 1
    NOP
    NOP
    NOP
    HALT
    NOP
    NOP
    NOP
    NOP
EXIT_2:
    MOVI r1 0
    NOP
    NOP
    NOP
    HALT
    NOP
    NOP
    NOP

-- r1 = operand
-- r2 = ptr1_start
-- r3 = ptr2_start
-- r5 = ptrA_start (first free in nums)
CALCULATE:
    PUSH r4
    PUSH r8
    PUSH r13
    JMPI SIGN
    LOAD_PC r13
    MOV0 CALCULATE_EXIT
    MOV r13 r0
    CMPI r1 22
    JMPEQ BCD_DIV
    CMPI r1 21
    JMPEQ CALCULATE_MUL
    CMPI r1 18
    JMPEQ CALCULATE_ADD_SUB
    CMPI r1 19
    JMPEQ CALCULATE_ADD_SUB
    NOP 
    HALT
    NOP
CALCULATE_EXIT:
    POP r13
    POP r8
    JMP r13
    POP r4



-- Check if number in mem(r2) is zero, return to r13 if true, else to r0
CHECK_ZERO:
	PUSH r2
	LOAD r10 r2		-- r10 = len
	ADDI r2 3		-- r2 = addr of first BCD
	ADD r10 r2		-- r10 = addr after last BCD
CHECK_ZERO_LOOP:
	LOAD r11 r2
	CMPI r11 0
	JMPNEQ CHECK_ZERO_EXIT
	ADDI r2 1
	CMP r2 r10 					-- assumes len >= 1
	JMPNEQ CHECK_ZERO_LOOP
	NOP
	MOV r0 r13 
CHECK_ZERO_EXIT:
	JMP r0
	POP r2
	
-- Check if number in mem(r2) is smaller than mem(r3), return to r13 if true, else to r0
-- assumes exp(r3) == 0
CHECK_SMALLER:
	PUSH r2
	PUSH r3
	LOAD r10 r2         -- r10 = len(r2)
	LOAD r11 r3         -- r11 = len(r3)
	CMP r10 r11
	JMPNEQ CHECK_SMALLER_EVALUATE
	ADDI r2 3
	ADDI r3 3
    MOV r12 r11
CHECK_SMALLER_LOOP:
	LOAD r10 r2
	LOAD r11 r3
	CMP r10 r11
	JMPNEQ CHECK_SMALLER_EVALUATE
    SUBI r12 1
    ADDI r3 1
    CMPI r12 1
    JMPGE CHECK_SMALLER_LOOP
    ADDI r2 1
    JMPI CHECK_SMALLER_FALSE
CHECK_SMALLER_EVALUATE:
    CMP r10 r11
    JMPN CHECK_SMALLER_EXIT
    NOP
CHECK_SMALLER_FALSE:
	MOV r13 r0
CHECK_SMALLER_EXIT:
	POP r3
	JMP r13
	POP r2

-- copies the BCD num in r2 to r5 and increments r5 to point after end, setting the copied sign and exponent to 0
BCD_COPY_DATA:
	PUSH r2
	LOAD r10 r2         -- r10 = len(num)
    PUSH r5
    MOVI r12 0
	ADDI r2 2           -- move in_ptr to exponent
	ADDI r5 1           -- move out_ptr to sign
	MOVI r11 0    
	STORE r11 r5    -- set sign of number to 0
	ADDI r5 1       -- move out_ptr to exponent
	STORE r11 r5    -- set exponent of number to 0
    MOVI r14 0
BCD_COPY_DATA_LOOP:
	ADDI r2 1
	LOAD r11 r2
    SUBI r10 1
    CMPI r14 0
    JMPNEQ BCD_COPY_DATA_LOOP_NO_ZERO
    CMPI r11 0
    JMPEQ BCD_COPY_DATA_LOOP
    NOP
BCD_COPY_DATA_LOOP_NO_ZERO:
    MOVI r14 1
    ADDI r5 1
	STORE r11 r5    -- store num of r2 in r5
	CMPI r10 1
	JMPGE BCD_COPY_DATA_LOOP
    ADDI r12 1
    ADDI r5 1
    POP r14
    STORE r12 r14
	JMP r13
	POP r2
	
	

	-- r2 = ptr1_start
	-- r3 = ptr2_start
	#	::num_1 / num_2 pseudo-code::
	#	 
	#	num_1 = copy of num_1 with exp = 0	

	 
	
	# 
BCD_DIV:
	PUSH r13

    MOV r4 r2               \
    MOV r2 r3               \
    MOV0 BCD_DIV_BY_ZERO    \ check for divide by zero
    MOV r13 r0              \
    JMPI CHECK_ZERO         \
    LOAD_PC r0              \
    MOV r2 r4               \

    ADDI r2 2       /
    ADDI r3 2       /
    ADDI r5 2       /
    LOAD r10 r2     /
    LOAD r11 r3     /
    SUB r10 r11     / Calculate the exponent
    STORE r10 r5    /
    SUBI r2 2       /
    SUBI r3 2       /
    SUBI r5 2       /

	MOV r4 r5
	ADDI r5 43 -- ans can take maximum 43 rows of memory
    MOV r6 r2
    MOV r2 r3
	MOV r3 r5
	JMPI BCD_COPY_DATA
	LOAD_PC r13
	MOV r2 r6
    MOV r6 r5
	JMPI BCD_COPY_DATA
	LOAD_PC r13
	MOV r2 r6
    LOAD r6 r2
    MOVI r7 1
    MOVI r8 0
    MOVI r1 41
				-- at this point: r2 = ptr to copy of num_1, r3 = ptr to copy of num_2, r4 = ptr to answer, r5 = ptr to free nums space
                -- r6 = original len(num_1), r7 = current len(num_1), r8 = ans leading zeroes
BCD_DIV_LOOP:
	STORE r7 r2
BCD_DIV_LOOP_CHECK_SMALLER:
    MOV0 BCD_DIV_LOOP_FITS
    JMPI CHECK_SMALLER
    LOAD_PC r13
BCD_DIV_LOOP_TO_SMALL:
    CMP r6 r7
    JMPEQ BCD_DIV_LOOP_TO_SMALL_MAX_SIZE
    NOP
    JMPI BCD_DIV_LOOP
    ADDI r7 1
BCD_DIV_LOOP_TO_SMALL_MAX_SIZE:
    CMPI r6 40
    JMPEQ BCD_DIV_DONE -- I hope this works as intended
    ADDI r7 1
    ADDI r6 1
    STORE r6 r2
    ADDI r2 2
    ADD r2 r6
    MOVI r0 0
    STORE r0 r2
    SUBI r2 2
    CMPI r1 41
    JMPNEQ BCD_DIV_LOOP_TO_SMALL_MAX_SIZE_HAS_POINT
    NOP
    LOAD r1 r4
BCD_DIV_LOOP_TO_SMALL_MAX_SIZE_HAS_POINT:
    ADDI r5 1
    ADDI r8 1
    JMPI BCD_DIV_LOOP_CHECK_SMALLER     
    SUB r2 r6
BCD_DIV_LOOP_FITS: 
    MOVI r9 0
BCD_DIV_LOOP_SUB:
    MOVI r10 0
    ADDI r5 1
    STORE r10 r5
    SUBI r5 1
    PUSH r1
    MOVI r1 19
    PUSH r2
    PUSH r3
    PUSH r4
    PUSH r5
    PUSH r6
    PUSH r7
    PUSH r8
    PUSH r9
    JMPI CALCULATE_ADD_SUB
    LOAD_PC r13
    POP r9
    POP r8
    POP r7
    POP r6
    POP r5
    POP r4
    POP r3
    POP r2
    POP r1
    ADDI r5 1
    LOAD r10 r5
    CMPI r10 1
    JMPEQ BCD_DIV_LOOP_STORE
    SUBI r5 1
    ADDI r9 1
    MOV r10 r2
    MOV r2 r5
    MOV r5 r10
    PUSH r5
    JMPI BCD_COPY_DATA
    LOAD_PC r13
    JMPI BCD_DIV_LOOP_SUB
    POP r2
BCD_DIV_LOOP_STORE:
    MOVI r11 3
    LOAD r10 r4
    ADD r11 r10
    ADDI r10 1
    ADD r10 r8
    CMPI r10 41
    JMPGE BCD_DIV_DONE
    NOP
    STORE r10 r4
    ADD r4 r11
BCD_DIV_LOOP_STORE_ZEROES:
    CMPI r8 1
    JMPN BCD_DIV_STORE_VALUE
    MOVI r12 0
    STORE r12 r4
    SUBI r8 1
    ADDI r11 1
    JMPI BCD_DIV_LOOP_STORE_ZEROES
    ADDI r4 1
BCD_DIV_STORE_VALUE:
    STORE r9 r4
    SUB r4 r11
    LOAD r10 r2             / 
    SUB r7 r10              / Decrease the maximum length to match the new num1
    SUB r6 r7               / 
    MOVI r7 1
    MOVI r8 0
    SUBI r8 1
    MOV0 BCD_DIV_LOOP
    JMPI CHECK_ZERO
    LOAD_PC r13
BCD_DIV_DONE:
    CMPI r1 41
    JMPEQ BCD_DIV_EXIT
    LOAD r10 r4
    ADDI r4 2
    LOAD r11 r4
    SUB r11 r10
    ADD r11 r1
    ADDI r11 1
    STORE r11 r4
    SUBI r4 2
BCD_DIV_EXIT:
    MOV r5 r4
    ADDI r5 3
	POP r13
	JMP r13
    ADD r5 r10
BCD_DIV_BY_ZERO:
    MOVI r10 1      \
    STORE r10 r5    \
    ADDI r5 2       \
    MOVI r10 127    \ put an overflow ans and return
    STORE r10 r5    \
    POP r13         \
    JMP r13         \
	ADDI r5 2       \
	
	

	
	
-- r10 answer
-- r11 answer
-- r12 (counter)
MUL:
    PUSH r11
    PUSH r12
    CMPI r12 0
    JMPEQ MUL_EXIT
    MOVI r10 0
MUL_LOOP:
    SUBI r12 1
    JMPNEQ MUL_LOOP
    ADD r10 r11
MUL_EXIT:
    POP r12
    JMP r13
    POP r11


-- r1 = operand
-- r2 = ptr1_start
-- r3 = ptr2_start
-- r5 = ptrA_start (first free in nums)
BCD_MUL:
    PUSH r13
    MOVI r14 0
    MOVI r11 37
    MOV r12 r5
    ADDI r12 3
BCD_MUL_ZERO:
    MOV0 0
    STORE r0 r12
    ADDI r12 1
    SUBI r11 1
    JMPNEQ BCD_MUL_ZERO
    NOP
    MOVI r12 1
    LOAD r6 r3      -- r6 = L2
    ADDI r3 2
    ADD r3 r6
BCD_MUL_COUNTER:
    LOAD r11 r3
    SUBI r3 1
    JMPI MUL
    LOAD_PC r13
    ADD r14 r10
    MOVI r11 10
    JMPI MUL 
    LOAD_PC r13
    MOV r12 r10
    SUBI r6 1
    JMPNEQ BCD_MUL_COUNTER
BCD_MUL_LOOP:
    CMPI r14 0
    JMPEQ BCD_MUL_EXIT
    SUBI r14 1
    MOVI r1 18
    MOV r3 r5
    PUSH r2
    PUSH r5
    PUSH r14
    JMPI CALCULATE_ADD_SUB
    LOAD_PC r13
    POP r14
    POP r5
    JMPI BCD_MUL_LOOP
    POP r2
BCD_MUL_EXIT:
    POP r13
    JMP r13
    NOP



-- r1 = operand
-- r2 = ptr1_start
-- r3 = ptr2_start
-- r5 = ptrA_start (first free in nums)
SIGN:
    ADDI r2 1
    ADDI r3 1
    LOAD r6 r2  -- r6 = S1
    LOAD r7 r3  -- r7 = S2
    SUBI r2 1
    SUBI r3 1
    CMPI r1 18
    JMPEQ SIGN_ADD
    CMPI r1 19
    JMPEQ SIGN_SUB
    CMPI r1 21
    JMPEQ SIGN_MUL_DIV
    CMPI r1 22
    JMPEQ SIGN_MUL_DIV
    NOP         # MORE OPERATIONS LATER
    HALT 
SIGN_ADD:
    CMPI r6 0
    JMPNEQ SIGN_ADD_A_NEGATIVE
SIGN_ADD_A_POSITIVE:
    CMPI r7 0
    JMPEQ SIGN_POSITIVE_ANS
    NOP
    JMPI SIGN_POSITIVE_ANS
    MOVI r1 19
SIGN_ADD_A_NEGATIVE:    
    CMPI r7 0
    JMPEQ SIGN_SWAP
    MOVI r1 19
    JMPI SIGN_NEGATIVE_ANS
    MOVI r1 18
SIGN_SUB:
    CMPI r6 0
    JMPNEQ SIGN_SUB_A_NEGATIVE
SIGN_SUB_A_POSITIVE:
    CMPI r7 0
    JMPEQ SIGN_POSITIVE_ANS
    NOP
    JMPI SIGN_POSITIVE_ANS
    MOVI r1 18
SIGN_SUB_A_NEGATIVE:    
    CMPI r7 0       # this runs on both negative?
    JMPNEQ SIGN_SWAP
    NOP
    JMPI SIGN_NEGATIVE_ANS
    MOVI r1 18
SIGN_MUL_DIV:
    CMP r6 r7
    JMPEQ SIGN_POSITIVE_ANS
    NOP
SIGN_NEGATIVE_ANS:
    JMPI SIGN_STORE
    MOVI r6 1
SIGN_POSITIVE_ANS:
    MOVI r6 0
SIGN_STORE:
    ADDI r5 1
    STORE r6 r5
    JMPI SIGN_EXIT
    SUBI r5 1
SIGN_SWAP:
    MOV r9 r2
    MOV r2 r3
    JMPI SIGN_EXIT
    MOV r3 r9
SIGN_EXIT:
    JMP r13
    NOP

-- r1 = operand
-- r2 = ptr1_start
-- r3 = ptr2_start
-- r5 = ptrA_start (first free in nums)
CALCULATE_ADD_SUB:
    PUSH r13
    JMPI SET_POINTERS
    LOAD_PC r13
    PUSH r4
    JMPI BCD_ADD_SUB
    LOAD_PC r13
    POP r4
    MOV r5 r4
    POP r13
    JMP r13
    ADDI r5 1


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


-- r1 = operand
-- r2 = ptr1_start
-- r3 = ptr2_start
-- r5 = ptrA_start (first free in nums)
SET_POINTERS:
    PUSH r13
    MOV r4 r5 
    LOAD r5 r2 -- r5 = L1
    LOAD r6 r3 -- r6 = L2
    ADDI r2 2
    ADDI r3 2
    LOAD r8 r2 -- r8 = T1
    LOAD r9 r3 -- r9 = T2
SET_POINTERS_ANS:
    -- TA = min(T1, T2)
    -- LA = max(T1 + L1, T2 + L2) - TA
    MOV r10 r8
    MOV r11 r9
    JMPI MIN
    LOAD_PC r13
    ADD r10 r5  -- r10 = T1 + L1
    ADD r11 r6  -- r11 = T2 + L2
    MOV r0 r12
    JMPI MAX
    LOAD_PC r13
    SUB r12 r0    
    CMPI r1 18
    JMPEQ SET_POINTERS_ANS_ADD
    CMPI r1 19
    JMPEQ SET_POINTERS_ANS_OVERFLOW
    NOP
SET_POINTERS_ANS_ADD:
    ADDI r12 1
SET_POINTERS_ANS_OVERFLOW:
    CMPI r12 40
    JMPN SET_POINTERS_ANS_STORE
    NOP
    MOV r14 r12
    SUBI r14 40
    ADD r0 r14      -- TA + overflow
    JMPI SET_POINTERS_ANS_STORE
    MOVI r12 40     -- LA = 40
SET_POINTERS_ANS_STORE:
    STORE r12 r4
    ADDI r4 2
    STORE r0 r4
    MOV r7 r12
    ADD r4 r12
    MOV r10 r0
SET_POINTERS_EXIT:
    ADD r2 r5
    ADD r3 r6
    POP r13
    JMP r13
    NOP


-- r1 = operand
-- r2 = ptr1
-- r3 = ptr2
-- r4 = ptrA
-- r5 = L1
-- r6 = L2
-- r7 = LA
-- r8 = T1
-- r9 = T2
-- r10 = TA
BCD_ADD_SUB:
-- r14 = carry
    PUSH r13
    MOVI r14 0 -- initiate carry
BCD_ADD_SUB_LOOP:
    CMPI r5 1
    JMPN BCD_ADD_SUB_PADD_FRONT_FIRST
    CMPI r6 1
    JMPN BCD_ADD_SUB_PADD_FRONT_SECOND
BCD_ADD_SUB_PADD_BACK:
    CMP r8 r9
    JMPEQ BCD_ADD_SUB_PADD_NONE
    CMP r8 r9
    JMPN BCD_ADD_SUB_PADD_SECOND
    NOP
    JMPI BCD_ADD_SUB_PADD_FIRST
    NOP
BCD_ADD_SUB_PADD_FRONT_SECOND:
    CMP r9 r8
    JMPN BCD_ADD_SUB_PADD_BOTH
    ADDI r9 1   -- T2++
    JMPI BCD_ADD_SUB_PADD_SECOND
    NOP
BCD_ADD_SUB_PADD_FRONT_FIRST:
    CMP r8 r9
    JMPN BCD_ADD_SUB_PADD_BOTH
    ADDI r8 1   -- T1++
BCD_ADD_SUB_PADD_FIRST:
    SUBI r6 1   -- L2--
    ADDI r9 1   -- T2++
    MOVI r11 0  -- Padd first
    LOAD r12 r3 -- r12 <= number_2(ptr2)
    JMPI BCD_ADD_SUB_COMPARE
    SUBI r3 1   -- ptr2--
BCD_ADD_SUB_PADD_SECOND:
    SUBI r5 1   -- L1--
    ADDI r8 1   -- T1++
    LOAD r11 r2 -- r12 <= number_1(ptr1)
    MOVI r12 0  -- Padd first
    JMPI BCD_ADD_SUB_COMPARE
    SUBI r2 1   -- ptr1--
BCD_ADD_SUB_PADD_NONE:
    SUBI r5 1   -- L1--
    SUBI r6 1   -- L2--
    ADDI r8 1   -- T1++
    ADDI r9 1   -- T2++
    LOAD r11 r2 -- r11 <= number_1(ptr1)
    LOAD r12 r3 -- r12 <= number_2(ptr2)
    SUBI r2 1   -- ptr1--
    JMPI BCD_ADD_SUB_COMPARE
    SUBI r3 1   -- ptr2--
BCD_ADD_SUB_PADD_BOTH:
    MOVI r11 0  -- Padd first
    MOVI r12 0  -- Padd second
BCD_ADD_SUB_COMPARE:
    CMPI r1 18
    JMPEQ BCD_ADD_SUB_ADD
    CMPI r1 19
    JMPEQ BCD_ADD_SUB_SUB
    NOP
BCD_ADD_SUB_ADD:
    CMPI r7 2
    JMPGE BCD_ADD_SUB_EXEC
    MOV0 BCD_ADD
    JMPI BCD_ADD_SUB_EXIT
    STORE r14 r4    -- store carry in ans
BCD_ADD_SUB_SUB:
    CMPI r7 1
    JMPGE BCD_ADD_SUB_EXEC
    MOV0 BCD_SUB
    SUBI r4 2
    CMPI r14 0
    JMPEQ BCD_ADD_SUB_EXIT
    NOP
    JMPI COMPLEMENT
    LOAD_PC r13
    SUBI r4 1
    LOAD r10 r4
    CMPI r10 1
    JMPNEQ BCD_ADD_SUB_SUB_STORE_SIGN
    ADDI r10 1
    SUBI r10 2
BCD_ADD_SUB_SUB_STORE_SIGN:
    JMPI BCD_ADD_SUB_EXIT
    STORE r10 r4    -- store negative sign in ans
BCD_ADD_SUB_EXEC:
    JMP r0          -- do operation
    LOAD_PC r13
    CMP r10 r8
    JMPGE BCD_ADD_SUB_LOOP
    CMP r10 r9
    JMPGE BCD_ADD_SUB_LOOP
    STORE r11 r4    -- store number in ans
    SUBI r4 1       -- ptrA--
    JMPI BCD_ADD_SUB_LOOP
    SUBI r7 1       -- LA--
BCD_ADD_SUB_EXIT:
    POP r13
    JMP r13
    NOP


COMPLEMENT:
    -- r4 = ptr (pointer to number that will be complemented)
    PUSH r14
    PUSH r13
    MOVI r14 0      -- Initate carry
    LOAD r6 r4     -- Get number length L
    ADDI r4 2
    ADD r4 r6      -- Make pointer point on last decimal
COMPLEMENT_ITER:
    MOVI r11 0       
    LOAD r12 r4    -- Get decimal
    JMPI BCD_SUB        -- Make Subtraction
    LOAD_PC r13
    STORE r11 r4   -- Store complemented decimal
    SUBI r6 1       -- L--
    CMPI r6 1
    JMPGE COMPLEMENT_ITER
    SUBI r4 1      -- ptr--
COMPLEMENT_EXIT:
    POP r13
    JMP r13
    POP r14


BCD_ADD:
    ADD r11 r12     -- Addition
    ADD r11 r14     -- Add carry
    CMPI r11 10
    JMPGE BCD_ADD_CARRY
    NOP
    MOVI r14 0      -- Unset carry
    JMPI BCD_ADD_EXIT
    NOP
BCD_ADD_CARRY:
    MOVI r14 1      -- Set carry
    SUBI r11 10     -- Make one digit
BCD_ADD_EXIT:
    JMP r13
    NOP


BCD_SUB:
    SUB r11 r12     -- Subtraction
    SUB r11 r14     -- Sub carry
    CMPI r11 0
    JMPN BCD_SUB_CARRY
    NOP
    MOVI r14 0      -- Unset carry
    JMPI BCD_SUB_EXIT
    NOP
BCD_SUB_CARRY:
    MOVI r14 1      -- Set carry
    ADDI r11 10     -- Make number positive
BCD_SUB_EXIT:
    JMP r13
    NOP
