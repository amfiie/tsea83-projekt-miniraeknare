    MOVI r1 8
    SWAP r1
WAIT_KEY:
    WAIT_K
    NOP
    MOV r2 r15
    MOV r3 r15
    SHR r2
    SHR r2
    SHR r2
    SHR r2
    MOVI r4 15
    AND r3 r4
    STORE r2 r1
    ADDI r1 1
    STORE r3 r1
    JMPI WAIT_KEY
    ADDI r1 2
