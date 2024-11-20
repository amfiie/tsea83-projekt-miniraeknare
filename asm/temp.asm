MUL:
    -- r7 = ans 2nd decimal
    -- r8 = ans 1st decimal
    -- r9 = number_1
    -- r10 = number_2 (loop counter)
    PUSH r13
    PUSH r14
    MOVI r7 0
    MOVI r14 0
    MOV r11 r9
MUL_LOOP:
    MOV r12 r9
    JMPI ADD
    LOAD_PC r13
    ADD r7 r14
    MOVI r14 0
    MOV r8 r11
    SUBI r10 1
    CMPI r10 2
    JMPGE MUL_LOOP
    NOP
MUL_EXIT:
    POP r14
    POP r13
    JMP r13
    NOP