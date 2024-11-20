-- r1 = cursor
-- r2 = free
-- r3 = number of characters typed
-- r4 = dm equation address
-- r5 dm cur_num free

INIT_DM:
    MOVI r4 0
    MOVI r10 1             
    STORE r10 r4            / store number identifier
    ADDI r4 1
    MOVI r10 20            
    STORE r10 r4            / store number pointer to DM(20)
    MOVI r4 20
    MOVI r10 5
    STORE r10 r4            / store number value 1 on DM(20)
    ADDI r4 1
    MOVI r10 5
    STORE r10 r4

    MOVI r4 2
    MOVI r10 19             
    STORE r10 r4            / store operand +

    MOVI r4 4
    MOVI r10 1             
    STORE r10 r4            / store number identifier
    ADDI r4 1
    MOVI r10 30            
    STORE r10 r4            / store number pointer to DM(30)
    MOVI r4 30
    MOVI r10 2
    STORE r10 r4            / store number value 2 on DM(30)
    ADDI r4 1
    MOVI r10 3
    STORE r10 r4

    MOVI r4 10
    MOVI r14 50
    STORE r14 r4            / store answer pointer on DM(10) to DM(50)

    MOVI r4 0

    JMPI INIT_OPER
    LOAD_PC r13
    HALT

INIT_OPER:
    ADDI r4 1
    LOAD r9 r4              / save first number pointer to r9
    ADDI r4 1
    LOAD r8 r4              / save operand to r8
    ADDI r4 3
    LOAD r10 r4             / save second number pointer to r10
EXEC_OPER:
    CMPI r8 19
    JMPGE SUB_OPER           / if r8 = '+' do add operation
    CMPI r8 18
    JMPGE ADD_OPER           / if r8 = '-' do sub operation
    NOP
ADD_OPER: -- TODO: iterate from least significant to most significant!!!!
    LOAD r11 r9             / save first decimal of first number in r11
    LOAD r12 r10            / save first decimal of second number in r12
    ADD r11 r12             / calc addition and save answer in r11
    MOV r4 r14
    JMPI OPER_ITER
    STORE r11 r4
SUB_OPER:
    LOAD r11 r9
    LOAD r12 r10
    SUB r11 r12
    MOV r4 r14
    JMPI OPER_ITER
    STORE r11 r4
OPER_ITER:
    ADDI r9 1
    ADDI r10 1
    ADDI r14 1
    CMPI r9 22              / TEMPORARY: later we need to iterate number length
    JMPN EXEC_OPER
    NOP
OPER_EXIT:
    JMP r13
    NOP
    
    
    
