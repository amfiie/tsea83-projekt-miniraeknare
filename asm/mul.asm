NOP
NOP
NOP
MOVI r4 0 --MUL_BCD(r2 = a, r3 = b, r4 destroyed r1 = return) => r2:r3 = a * b
MOVI r5 0
ADDI r3 0
JMPEQ 13 --LOOP BEGIN, JMP EXIT
SUBI r3 1
ADD_BCD r4 r2
ADDC r5 r0 --Zero register
JMPI 7 --LOOP
ADDI r3 0
MOV r2 r5 --EXIT BEGIN
MOV r3 r4
JMP r1

