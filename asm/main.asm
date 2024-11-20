    -- r1 = cursor, r2 = stack_ptr, r3 = written so far, r4 = dm equation address, r5 dm cur_num free
    MOVI r1 16              /
    SWAP r1                 / Set IOR to 3
    MOVI r2 3               /
    STORE r2 r1             /
    MOVI r1 0           \ set cursor and written to 0, 0  
    MOVI r3 0           \
    MOV0 200
    MOVI r10 1
    STORE r10 r0
    JMPI DRAW_GRAPHICS
    LOAD_PC r13
    MOVI r11 120
KEY_RESET:
    MOVI r4 40           / set begining of eq
    MOV0 392             \ set begining of cur_num
    MOV r5 r0            \
KEY_WAIT:
    WAIT_K               / Get key-ascii in r15
    NOP                  /
    CMPI r3 40                  \ check if input is full, then only check
    JMPGE CHECK_BACKSPACE       \  if key was backspace or enter
    MOV r14 r15                 / move key into r14 (r15 cannot be modified, always)
    CMPI r14 48                 \  
    JMPN CHECK_PLUS             \ 
    CMPI r14 58                 \ check if key is a number
    JMPGE CHECK_PLUS            \ if not, check other characters
    MOVI r10 1
    SUBI r14 48                 / Change ascii to bcd
    STORE r10 r4
    ADDI r4 1
    STORE r14 r4
    JMPI STORE_INPUT            / put number in pict_mem
    SUBI r4 1
CHECK_PLUS:
    CMPI r14 43
    JMPEQ PUT_PLUS
CHECK_MINUS:
    CMPI r14 45
    JMPEQ PUT_MINUS
CHECK_MUL:
    CMPI r14 42
    JMPEQ PUT_MUL
CHECK_DIV:
    CMPI r14 47
    JMPEQ PUT_DIV
CHECK_POINT:
    CMPI r14 46
    JMPEQ PUT_POINT
CHECK_NEGATIVE:
    CMPI r14 110
    JMPEQ PUT_NEGATIVE
CHECK_OPEN_PAR:
    CMPI r14 40
    JMPEQ PUT_OPEN_PAR
CHECK_CLOSE_PAR:
    CMPI r14 41
    JMPEQ PUT_CLOSE_PAR
CHECK_A:
    CMPI r14 97
    JMPEQ PUT_A
CHECK_BACKSPACE:            
    CMPI r14 8
    JMPEQ PUT_BACKSPACE
CHECK_ARROW_UP:
    CMPI r14 26
    JMPEQ PUT_ARROW_UP
CHECK_ENTER:
    CMPI r14 10
    JMPEQ PUT_ENTER
    NOP                     
    JMPI KEY_WAIT               \ No matching keys, just wait again
PUT_A:
    MOVI r14 10
    JMPI STORE_INPUT
    STORE r14 r4
PUT_PLUS:                       /
    MOVI r14 18                 / tm(18) = '+'                
    JMPI STORE_INPUT            / put plus in dm and pict_mem
    STORE r14 r4                
PUT_MINUS:
    MOVI r14 19
    JMPI STORE_INPUT
    STORE r14 r4
PUT_MUL:
    MOVI r14 21
    JMPI STORE_INPUT
    STORE r14 r4
PUT_DIV:
    MOVI r14 22
    JMPI STORE_INPUT
    STORE r14 r4
PUT_NEGATIVE:
    MOVI r14 30
    MOVI r10 3
    JMPI STORE_INPUT
    STORE r10 r4
PUT_POINT:
    MOVI r14 31
    MOVI r10 2
    JMPI STORE_INPUT
    STORE r10 r4
PUT_OPEN_PAR:
    MOVI r14 27
    MOVI r10 4
    JMPI STORE_INPUT
    STORE r10 r4
PUT_CLOSE_PAR:
    MOVI r14 29
    MOVI r10 5
    JMPI STORE_INPUT
    STORE r10 r4
PUT_BACKSPACE:
    MOVI r10 0                  \
    CMP r10 r3                  \ check that there is something to delete
    JMPGE KEY_WAIT              \
    MOVI r14 16                  / store empty tile (tm(16) = ' ')
    SUBI r1 1                      \  move back cursor
    SUBI r3 1                      \  reduce written so far
    JMPI PICT_STORE
    LOAD_PC r13 
    SUBI r4 2           \ remove from eq
    JMPI KEY_WAIT
PUT_ARROW_UP:
    MOVI r9 120
    MOVI r4 40
    MOV r8 r3
    SUB r1 r3
    MOVI r3 0
PUT_ARROW_UP_LOOP:
    CMP r9 r11
    JMPEQ PUT_ARROW_UP_CLEAR_REST
    ADDI r3 1
    LOAD r10 r9
    STORE r10 r4
    ADDI r9 1
    CMPI r10 1
    JMPNEQ PUT_ARROW_UP_NOT_NUMBER
    ADDI r4 1
    LOAD r10 r9
    STORE r10 r4
    MOV r14 r10
    JMPI PUT_ARROW_UP_PUT_PICT
PUT_ARROW_UP_NOT_NUMBER:
    CMPI r10 2
    JMPEQ PUT_ARROW_UP_PUT_PICT
    MOVI r14 31
    CMPI r10 3
    JMPEQ PUT_ARROW_UP_PUT_PICT
    MOVI r14 30
    CMPI r10 4
    JMPEQ PUT_ARROW_UP_PUT_PICT
    MOVI r14 27
    CMPI r10 5
    JMPEQ PUT_ARROW_UP_PUT_PICT
    MOVI r14 29
    MOV r14 r10
PUT_ARROW_UP_PUT_PICT:
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r1 1                               /
    MOV0 320                                /
    CMP r1 r0                               /
    JMPNEQ PUT_ARROW_UP_CORRECT_CURSOR      / Increment cursor position
    ADDI r9 1                               / and handle wraparound
    MOVI r1 0                               /
PUT_ARROW_UP_CORRECT_CURSOR:                /
    JMPI PUT_ARROW_UP_LOOP
    ADDI r4 1
PUT_ARROW_UP_CLEAR_REST:
    SUBI r3 1
    MOVI r14 16
    MOV r12 r1
PUT_ARROW_UP_CLEAR_REST_LOOP:
    CMP r3 r8
    JMPGE PUT_ARROW_UP_DONE
    SUBI r8 1
    JMPI PICT_STORE
    LOAD_PC r13
    JMPI PUT_ARROW_UP_CLEAR_REST_LOOP
    ADDI r1 1
PUT_ARROW_UP_DONE:
    MOV r1 r12
    JMPI KEY_WAIT
PUT_ENTER:
    MOVI r10 16             /
    SWAP r10                /
    LOAD r14 r10            / Add 3 to IOR
    ADDI r14 4              /
    STORE r14 r10           /
    MOV0 320                        \
    ADDI r1 80                     
    SUB r1 r3
    CMP r1 r0                       \
    JMPN PUT_ENTER_IN_BOUNDS        \
    MOVI r11 0                      \
    SUB r1 r0 
PUT_ENTER_IN_BOUNDS:
    MOVI r3 0
    MOVI r14 16
    PUSH r1
CLEAR_BOTTOM_LOOP:
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r1 1
    CMP r1 r0
    JMPN CLEAR_BOTTOM_IN_BOUNDS
    NOP
    SUB r1 r0
CLEAR_BOTTOM_IN_BOUNDS:
    CMPI r11 79
    JMPN CLEAR_BOTTOM_LOOP
    ADDI r11 1
COPY_EQ:                /
    MOVI r10 40         /
    MOVI r11 120        /
COPY_EQ_LOOP:           /
    CMP r10 r4         / Copy eq to old_eq
    JMPEQ COPY_EQ_DONE  /
    LOAD r12 r10        /
    STORE r12 r11       /
    ADDI r10 1          /
    JMPI COPY_EQ_LOOP   /
    ADDI r11 1          /
COPY_EQ_DONE:
    POP r1
    JMPI PARSE_EQ
    MOVI r4 40
SOLVE_EQ:
    JMPI GET_ANS
    LOAD_PC r13
    MOV r14 r5      /
    MOV0 200        / set r5 to ans pos, and save old r5 value in r14
    MOV r5 r0       /
    JMPI STRIP      
    LOAD_PC r13   
    MOV r5 r0       -- r5 to ans again
    JMPI REMOVE_ZEROS_AFTER
    LOAD_PC r13
    MOV r5 r14      -- reset r5 to old value
    JMPI CHECK_ANS_EXP
    LOAD_PC r13
    JMPI OUTPUT_ANS
    LOAD_PC r13
    JMPI DRAW_GRAPHICS
    LOAD_PC r13
    JMPI KEY_RESET
    NOP
STORE_INPUT:
    JMPI PICT_STORE
    LOAD_PC r13
    MOV0 320
    ADDI r1 1
    CMP r1 r0
    JMPN STORE_INPUT_EXIT
    ADDI r4 2               / Increment eq pos to next empty
    SUB r1 r0
STORE_INPUT_EXIT:
    JMPI KEY_WAIT
    ADDI r3 1

CALC_ANS: --ret = r13

PARSE_EQ: -- end_of_old_eq = r11
    MOVI r10 120
    MOVI r14 1      / States: 1 = num_start (num / n / '('), 2 = num_mid (num / '.' / oper / ')'), 3 = has_point (num / oper / ')'), 4 = oper (oper / ')')
    MOVI r9 0       \ Number of parentheses * 20
PARSE_EQ_LOOP:
    CMP r10 r11
    JMPGE PARSE_EQ_DONE
    LOAD r12 r10
    CMPI r14 1
    JMPEQ PARSE_EQ_NUM_START
    CMPI r14 2
    JMPEQ PARSE_EQ_NUM_MID
    CMPI r14 3
    JMPEQ PARSE_EQ_HAS_POINT
    CMPI r14 4
    JMPEQ PARSE_EQ_NUM_MID_CHECK_PAR    / make same par and oper checks as in NUM_MID state       
    ADDI r10 2                          \ make sure old_eq ptr is at same increment as it would be in NUM_MID state
    JMPI ERROR
PARSE_EQ_NUM_START:
    CMPI r12 4           
    JMPNEQ PARSE_EQ_NUM_START_CHECK_ANS
    MOVI r0 1
    ADDI r9 20           / Increment number of parentheses
    JMPI PARSE_EQ_LOOP
    ADDI r10 2
PARSE_EQ_NUM_START_CHECK_ANS:
    CMPI r12 10
    JMPNEQ PARSE_EQ_NUM_START_NUMBER
    NOP
    STORE r0 r4     / store 1 meaning number in eq
    ADDI r4 1
    MOV0 200
    STORE r0 r4     / store pointer to ans in eq
    ADDI r10 2
    JMPI PARSE_EQ_LOOP
    MOVI r14 4          / set state to oper
PARSE_EQ_NUM_START_NUMBER:
    STORE r0 r4         \ store 1 meaning number in eq
    ADDI r4 1           / Store ptr to number in eq
    STORE r5 r4         /
    STORE r0 r5         \ store length in cur_num
    ADDI r5 1           /
    MOVI r0 0           / store initial sign value 0
    STORE r0 r5         /
    CMPI r12 3
    JMPNEQ PARSE_EQ_NUM_START_CHECK_NUM
    MOVI r0 1                           \
    ADDI r10 2                          \ position was -, set - byte and skip to next
    STORE r0 r5                         \
    LOAD r12 r10                        \
PARSE_EQ_NUM_START_CHECK_NUM:
    CMPI r12 1                          / 
    JMPNEQ ERROR                   / Make sure start of number is number
    ADDI r5 1                           \ After: r5 -> exponent
    MOVI r0 0                           / store exponent 0
    STORE r0 r5                         /
    ADDI r5 1                           \
    ADDI r10 1                          \
    LOAD r12 r10                        \   Store the number
    STORE r12 r5                        \
    ADDI r5 1                           / After: r5 -> next free cur_num
    MOVI r14 2                          \ Set state to 2 (meaning num_mid)
    JMPI PARSE_EQ_LOOP
    ADDI r10 1
PARSE_EQ_NUM_MID:
    CMPI r12 1                              \ check if number, and increment old_eq ptr
    JMPNEQ PARSE_EQ_NUM_MID_CHECK_POINT     \ 
    ADDI r10 1                              \
    LOAD r8 r4                              /
    LOAD r0 r8                              / increment length in cur_num 
    ADDI r0 1                               /
    STORE r0 r8                             /
    LOAD r8 r10                             \ get number value
    STORE r8 r5                             / store number at end
    ADDI r5 1                               /
    JMPI PARSE_EQ_LOOP                      \ Loop again, with same state
    ADDI r10 1
PARSE_EQ_NUM_MID_CHECK_POINT:
    CMPI r12 2
    JMPNEQ PARSE_EQ_NUM_MID_CHECK_PAR
    ADDI r10 1                              \ increment old_eq ptr (allways)
    JMPI PARSE_EQ_LOOP                      / Loop again, with has_point state (3)
    MOVI r14 3                              /
PARSE_EQ_NUM_MID_CHECK_PAR:
    CMPI r12 5                              / check if parentheses
    JMPNEQ PARSE_EQ_NUM_MID_CHECK_OPER      /
    NOP
    SUBI r9 20                               / close one parentheses
    JMPN ERROR                     \ make sure were in open parentheses else invalid expression
    MOVI r14 4                              / state = oper
    JMPI PARSE_EQ_LOOP
PARSE_EQ_NUM_MID_CHECK_OPER:
    CMPI r12 11
    JMPN ERROR
    MOVI r14 1                              \ Set state to start_num
    ADD r12 r9                              / Increase operator priority
    ADDI r4 1
    STORE r12 r4
    ADDI r4 2
    JMPI PARSE_EQ_LOOP
PARSE_EQ_HAS_POINT:
    CMPI r12 1
    JMPNEQ PARSE_EQ_NUM_MID_CHECK_PAR   / if not num make same par and oper checks as in NUM_MID state
    ADDI r10 2                          \ make sure old_eq ptr is at same increment as it would be in NUM_MID state
    SUBI r10 1
    LOAD r12 r10
    ADDI r10 1
    LOAD r8 r4                              /
    LOAD r0 r8                              / increment length in cur_num 
    ADDI r0 1                               /
    STORE r0 r8                             /
    ADDI r8 2
    LOAD r0 r8                              / decrement exponent  in cur_num 
    SUBI r0 1                               /
    STORE r0 r8                             /
    STORE r12 r5
    JMPI PARSE_EQ_LOOP
    ADDI r5 1
PARSE_EQ_DONE:
    CMPI r9 0       -- ensure all paraenthesis are closed
    JMPNEQ ERROR
    LOAD_PC r13
    CMPI r14 1              \
    JMPEQ ERROR    \ if state = start_num => error
    ADDI r4 1
    JMPI SOLVE_EQ
    NOP


ERROR:
    PUSH r1
    PUSH r1
    SUBI r1 21
    JMPGE ERROR_OUTPUT
    NOP
    MOV0 320
    ADD r1 r0
ERROR_OUTPUT:
    MOVI r14 14
    JMPI PICT_STORE
    LOAD_PC r13
    POP r1
    JMPI DRAW_GRAPHICS
    LOAD_PC r13
    JMPI KEY_RESET
    POP r1

-- r5 is ptr to num
REMOVE_ZEROS_AFTER:
    MOV r10 r5      -- r10 is ptr to len
    LOAD r6 r10      -- r6 = len
    ADDI r10 2      -- r10 is ptr to exp      
    LOAD r7 r10      -- r7 = exp
    MOV r8 r10       -- r8 = ptr to exp
    ADDI r8 1       -- r8 = ptr to first
    ADD r10 r6       -- r10 ptr to last num
REMOVE_ZEROS_AFTER_LOOP:
    CMP r10 r8
    JMPEQ REMOVE_ZEROS_AFTER_EXIT   -- if at first exit
    LOAD r9 r10  -- r9 = last num
    CMPI r9 0
    JMPNEQ REMOVE_ZEROS_AFTER_EXIT  -- if last num != 0 exit
    NOP
    SUBI r6 1        -- len--
    SUBI r10 1       -- ptr to last --
    JMPI REMOVE_ZEROS_AFTER_LOOP
    ADDI r7 1        -- exp ++
REMOVE_ZEROS_AFTER_EXIT:
    STORE r6 r5        -- Update len
    ADDI r5 2
    STORE r7 r5         -- update exp
    JMP r13
    SUBI r5 1

CHECK_ANS_EXP:
    PUSH r13
    MOV0 202    -- r0 = ptr to ans exp
    LOAD r6 r0  -- r6 = ans exp
    SUBI r0 2
    LOAD r7 r0
    ADD r6 r7
    MOV0 101
    CMP r6 r0
    JMPGE ERROR     -- error if exp > 100
    MOV0 0
    SUBI r0 98
    --SUB r6 r7
    --SUB r6 r7
    CMP r6 r0
    JMPGE CHECK_ANS_EXP_EXIT     -- error if exp < -100
    MOV0 200
    MOV r5 r0
    JMPI SET_TO_ZERO
    LOAD_PC r13
CHECK_ANS_EXP_EXIT:
    POP r13
    JMP r13
    NOP

OUTPUT_ANS:
    PUSH r1
    PUSH r11
    PUSH r13
    SUBI r1 40
    JMPGE OUTPUT_ANS_POS_R1
    MOV0 320
    ADD r1 r0
OUTPUT_ANS_POS_R1:
    MOV0 200
    LOAD r9 r0     / r9 = len(ans)
    ADDI r0 1
    LOAD r11 r0     / r11 = sing(ans)
    ADDI r0 1
    LOAD r12 r0     / r12 = exp(ans)
    CMPI r11 1
    JMPNEQ OUTPUT_ANS_NO_MINUS
    MOVI r14 30
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r1 1
OUTPUT_ANS_NO_MINUS:
    CMPI r12 0
    JMPGE OUTPUT_ANS_POS_EXP
    ADDI r0 1
OUTPUT_ANS_NEG_EXP:
    MOVI r14 0
    ADDI r14 1      -- r14 = 1(POINT)
    ADD r14 r11     -- r14 = sign + 1(POINT)
    ADD r14 r9      -- r14 = sign + Len + 1(POINT)
    SUB r14 r12     -- r14 = sign + len - Exp(which is negative) + 1(point)
    CMPI r14 21     -- 20 fits on screen
    JMPN OUTPUT_ANS_FITS
    NOP
OUTPUT_ANS_TO_BIG:
    LOAD r14 r0         /
    JMPI PICT_STORE     / Write first number to pict_mem
    LOAD_PC r13         /
    ADDI r0 1           /
    ADDI r1 1           /
    CMPI r9 1
    JMPEQ OUTPUT_ANS_WRITE_EXP
    MOVI r14 31
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r1 1
    ADD r12 r9
    SUBI r12 1
    MOVI r8 13
    SUB r8 r11
    CMP r8 r9
    JMPN OUTPUT_ANS_TO_BIG_LOOP
    NOP
    MOV r8 r9
    SUBI r8 2
OUTPUT_ANS_TO_BIG_LOOP:
    LOAD r14 r0
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r0 1
    SUBI r8 1
    JMPGE OUTPUT_ANS_TO_BIG_LOOP
    ADDI r1 1
    JMPI OUTPUT_ANS_WRITE_EXP
    NOP
OUTPUT_ANS_POS_EXP:
    MOV r14 r12
    ADD r14 r9
    ADD r14 r11
    CMPI r14 21
    JMPGE OUTPUT_ANS_TO_BIG
OUTPUT_ANS_FITS:
    MOVI r8 0                                                               
    SUB r8 r12             -- r8 = - exp(ans)                        
    SUB r8 r9              -- r8 = - len(ans) - exp(ans)     
    JMPN OUTPUT_ANS_FITS_LOOP_PREP                                  
    NOP
    MOVI r14 0
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r1 1
    MOVI r14 31
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r1 1
OUTPUT_ANS_FITS_ZERO_LOOP:
    CMPI r8 0
    JMPEQ OUTPUT_ANS_FITS_LOOP_PREP
    MOVI r14 0
    JMPI PICT_STORE
    LOAD_PC r13
    SUBI r8 1
    JMPI OUTPUT_ANS_FITS_ZERO_LOOP
    ADDI r1 1
OUTPUT_ANS_FITS_LOOP_PREP:
    ADD r9 r0
    SUBI r9 1
OUTPUT_ANS_FITS_LOOP:
    LOAD r14 r0
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r1 1
    CMP r0 r9
    JMPEQ OUTPUT_ANS_FITS_END_ZEROS
    ADDI r8 1
    CMPI r8 0
    JMPNEQ OUTPUT_ANS_FITS_LOOP
    ADDI r0 1
    MOVI r14 31
    JMPI PICT_STORE
    LOAD_PC r13
    JMPI OUTPUT_ANS_FITS_LOOP
    ADDI r1 1
OUTPUT_ANS_FITS_END_ZEROS:
    CMPI r8 0
    JMPGE OUTPUT_ANS_EXIT
    ADDI r8 1
    MOVI r14 0
    JMPI PICT_STORE
    LOAD_PC r13
    JMPI OUTPUT_ANS_FITS_END_ZEROS
    ADDI r1 1
OUTPUT_ANS_WRITE_EXP:
    CMPI r12 0
    JMPEQ OUTPUT_ANS_EXIT
    MOVI r14 14                 /
    JMPI PICT_STORE             / Store E
    LOAD_PC r13                 /
    ADDI r1 1                   /
    CMPI r12 0                              \
    JMPGE OUTPUT_ANS_WRITE_EXP_NUMBER_PART  \
    MOVI r14 30                             \ Store '-' if negative exponent
    JMPI PICT_STORE                         \
    LOAD_PC r13                             \
    MOVI r0 0                                /
    SUB r0 r12                              / Make exponent positive
    MOV r12 r0                              /
    ADDI r1 1                               /
OUTPUT_ANS_WRITE_EXP_NUMBER_PART:
    MOVI r10 0                                  \
OUTPUT_ANS_WRITE_EXP_NUMBER_PART_LOOP:          \       
    ADDI r10 1                                  \
    SUBI r12 10                                 \
    JMPGE OUTPUT_ANS_WRITE_EXP_NUMBER_PART_LOOP \ convert r12 to BCD r10:r12
    NOP                                         \
    SUBI r10 1                                  \
    ADDI r12 10                                 \  
    MOV r14 r10
    JMPI PICT_STORE
    LOAD_PC r13
    MOV r14 r12
    ADDI r1 1
    JMPI PICT_STORE
    LOAD_PC r13
OUTPUT_ANS_EXIT:
    POP r13
    POP r11
    JMP r13
    POP r1


PICT_STORE: --pict_mem(r1) = r14, ret = r13, destroys r10
    MOVI r10 8
    SWAP r10
    ADD r10 r1
    JMP r13
    STORE r14 r10


DRAW_GRAPHICS: -- Draw a line of 20 separators and displays title, r1 is position after line
    PUSH r0
    PUSH r1
    PUSH r13
    MOVI r14 20 
    SUBI r1 20
    JMPGE DRAW_GRAPHICS_SEPARATORS
    CMPI r1 0
    JMPEQ DRAW_GRAPHICS_SEPARATORS
    MOV0 320
    ADD r1 r0
DRAW_GRAPHICS_SEPARATORS:
    MOV0 19     -- number of iterations (separators)
DRAW_GRAPHICS_SEPARATORS_LOOP:
    JMPI PICT_STORE
    LOAD_PC r13
    SUBI r0 1
    JMPGE DRAW_GRAPHICS_SEPARATORS_LOOP
    ADDI r1 1
DRAW_GRAPHICS_POSITION_TITLE:
    MOV0 255
    SUB r1 r0
    JMPGE DRAW_GRAPHICS_DRAW_TITLE
    CMPI r1 0
    JMPEQ DRAW_GRAPHICS_DRAW_TITLE
    MOV0 320
    ADD r1 r0
DRAW_GRAPHICS_DRAW_TITLE:
    MOVI r14 1     -- '1' 
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r1 1
    MOVI r14 3     -- '3'
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r1 1
    MOVI r14 3      -- '3' 
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r1 1
    MOVI r14 7     -- '7'
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r1 1
    MOVI r14 30     -- '-'
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r1 1
    MOVI r14 12      -- 'C'
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r1 1
    MOVI r14 10      -- 'A'
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r1 1
    MOVI r14 1      -- '1' 
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r1 1
    MOVI r14 12      -- 'C'
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r1 1
    MOVI r14 26     -- '!'
    JMPI PICT_STORE
    LOAD_PC r13
    ADDI r1 1
DRAW_GRAPHICS_EXIT:
    POP r13
    POP r1
    JMP r13
    POP r0


-- Set up HEAP for calculations of type num, oper, num or num only
GET_ANS:
    PUSH r13
    PUSH r11
    PUSH r1
    PUSH r2
    PUSH r3
    PUSH r4
    --PUSH r5
GET_ANS_BODY:
    MOVI r7 0
    JMPI GET_MOST_SIGN_OPER
    LOAD_PC r13
-- Decide what type of oper it is, if not oper put num in ANS
GET_ANS_DECIDE_OPER:
    CMPI r12 31 -- compare with 28 to check wheter or not operand still contains a parenthesis
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
    JMPI CALCULATE
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
    --POP r5
    POP r4
    POP r3
    POP r2
    POP r1
    POP r11
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


// Calculates numbers in r2 and r3 with operation in r1 and stores the answer at position r5 in DM
// r1 = operand
// r2 = pointer to first number
// r3 = pointer to second number
// r5 = pointer to answer
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
CALCULATE_EXIT:
    POP r13
    POP r8
    JMP r13
    POP r4


// Predetermine sign of answer and reconstruct operation to the simplest form
// r1 = operand
// r2 = pointer to first number
// r3 = pointer to second number
// r5 = pointer to answer
SIGN:
    ADDI r2 1
    ADDI r3 1
    LOAD r6 r2          -- r6 = sign of first number
    LOAD r7 r3          -- r7 = sign of second number
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
    NOP
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
    CMPI r7 0
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


// Calculates a bcd multiplication of two bcd singulars and returns answer in two registers
// r10 = (out) answer ten part
// r11 = (out) answer singular part, (in) first bcd singular
// r12 = (in) second bcd singular
BCD_MUL:
    PUSH r9
    PUSH r12
    MOVI r9 0
    CMPI r12 0
    JMPEQ BCD_MUL_EXIT
    MOVI r10 0
BCD_MUL_LOOP:
    CMPI r12 0
    JMPEQ BCD_MUL_EXIT
    NOP
    ADD r10 r11
    CMPI r10 10
    JMPN BCD_MUL_LOOP
    SUBI r12 1
    ADDI r9 1               / 
    JMPI BCD_MUL_LOOP       /   When overflow, format bcd and divide r10 into one singular and carry part
    SUBI r10 10             /
BCD_MUL_EXIT:
    MOV r11 r10
    MOV r10 r9
    POP r12
    JMP r13
    POP r9


-- r1 = operand
-- r2 = ptr1_start
-- r3 = ptr2_start
-- r5 = ptrA_start (first free in nums)
CALCULATE_MUL:
    PUSH r2
    PUSH r3
    PUSH r5
    PUSH r13
    JMPI SET_TO_ZERO
    LOAD_PC r13
CALCULATE_MUL_CHECK_ZERO:
    MOV0 CALCULATE_MUL_ZERO_EXIT
    MOV r13 r0
    JMPI CHECK_ZERO
    LOAD_PC r0
    MOV r6 r2
    MOV r2 r3
    JMPI CHECK_ZERO
    LOAD_PC r0
    MOV r2 r6
CALCULATE_MUL_SETUP:
    LOAD r6 r2      -- L1
    ADDI r2 2
    LOAD r7 r3      -- L2
    ADDI r3 2
    ADD r3 r7       -- r3 = addr to second number last bcd
    MOVI r9 0       -- second number decimal position
CALCULATE_MUL_LOOP_SECOND:
    MOVI r8 0       -- first number decimal position
    ADD r2 r6       -- r2 = addr to first number last bcd
    LOAD r12 r3      -- second number bcd
CALCULATE_MUL_LOOP_FIRST:
    LOAD r11 r2      -- first number bcd
    JMPI BCD_MUL
    LOAD_PC r13
    MOV r14 r8
    ADD r14 r9
    JMPI BCD_CONCATINATE
    LOAD_PC r13
    ADDI r8 1
    CMP r8 r6
    JMPN CALCULATE_MUL_LOOP_FIRST
    SUBI r2 1
    ADDI r9 1
    CMP r9 r7
    JMPN CALCULATE_MUL_LOOP_SECOND
    SUBI r3 1
CALCULATE_MUL_EXIT:
    POP r13
    POP r5
    POP r3
    POP r2
    ADDI r2 2
    LOAD r6 r2      -- T1
    ADDI r3 2
    LOAD r7 r3      -- T2
    ADDI r5 2
    LOAD r8 r5      -- TA
    ADD r6 r7
    ADD r6 r8
    STORE r6 r5
    SUBI r2 2
    SUBI r3 2
    SUBI r5 2
    LOAD r6 r5
    ADDI r5 3
    JMP r13
    ADD r5 r6
CALCULATE_MUL_ZERO_EXIT:
    POP r13
    POP r5
    POP r3
    POP r2
    ADDI r5 1
    MOV0 0
    STORE r0 r5
    SUBI r5 1
    LOAD r6 r5
    ADDI r5 3
    JMP r13
    ADD r5 r6


-- r5 = ptr to ans
-- r10 = most signicant decimal
-- r11 = least signicant decimal
-- r14 = number exponent
BCD_CONCATINATE:
    PUSH r2
    PUSH r3
    PUSH r5
    PUSH r6
    PUSH r7
    PUSH r8
    PUSH r9
    PUSH r12
    PUSH r13
    MOVI r4 0
    MOVI r6 2
    STORE r6 r4
    ADDI r4 1
    MOVI r6 0
    STORE r6 r4
    ADDI r4 1
    STORE r14 r4
    ADDI r4 1
    STORE r10 r4
    ADDI r4 1
    STORE r11 r4
BCD_CONCATINATE_ADD:
    MOVI r1 18
    MOVI r2 0
    MOV r3 r5
    PUSH r5
    JMPI CALCULATE_ADD_SUB
    LOAD_PC r13
    POP r5
    JMPI STRIP
    LOAD_PC r13
BCD_CONCATINATE_EXIT:
    POP r13
    POP r12
    POP r9
    POP r8
    POP r7
    POP r6
    POP r5
    POP r3
    JMP r13
    POP r2


-- r5 = ptr
STRIP:
    PUSH r4
    PUSH r6
    PUSH r7
    PUSH r8
    PUSH r9
    PUSH r5
    LOAD r6 r5      -- len
    MOVI r7 1       -- counter
    ADDI r5 3
    PUSH r5
STRIP_COUNT_ZEROS_LOOP:
    CMP r6 r7
    JMPEQ STRIP_MOVE
    LOAD r8 r5
    CMPI r8 0
    JMPNEQ STRIP_MOVE
    NOP
    ADDI r5 1
    JMPI STRIP_COUNT_ZEROS_LOOP
    ADDI r7 1
STRIP_MOVE:
    MOV r4 r5   -- first decimal
    POP r5      -- first Zero
    SUBI r7 1
    PUSH r7
STRIP_MOVE_LOOP:
    CMP r6 r7
    JMPN STRIP_EXIT
    NOP
    LOAD r9 r4
    STORE r9 r5
    ADDI r4 1
    ADDI r5 1
    JMPI STRIP_MOVE_LOOP
    ADDI r7 1
STRIP_EXIT:
    POP r7
    SUB r6 r7
    POP r5
    STORE r6 r5
    POP r9
    POP r8
    POP r7
    POP r6
    JMP r13
    POP r4


-- r5 = ptr
SET_TO_ZERO:
    PUSH r5
    MOV0 1
    STORE r0 r5
    MOV0 0
    ADDI r5 2
    STORE r0 r5
    ADDI r5 1
    STORE r0 r5
    SUBI r5 3
    JMP r13
    POP r5


-- check if number in mem addr r2 is Zero
-- return to r13 if true else return to r0
CHECK_ZERO:
    PUSH r2
    LOAD r10 r2     -- r10 = len
    ADDI r2 3       -- r2 = addr of first bcd
    ADD r10 r2      -- r10 = addr last bcd
CHECK_ZERO_LOOP:
    LOAD r11 r2 
    CMPI r11 0
    JMPNEQ CHECK_ZERO_EXIT
    ADDI r2 1
    CMP r2 r10      -- Assumes len >= 1
    JMPNEQ CHECK_ZERO_LOOP
    NOP
    MOV r0 r13
CHECK_ZERO_EXIT:
    JMP r0
    POP r2


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
    STORE r10 r5
	ADDI r2 2           -- move in_ptr to exponent
	ADDI r5 1           -- move out_ptr to sign
	MOVI r11 0    
	STORE r11 r5    -- set sign of number to 0
	ADDI r5 1       -- move out_ptr to exponent
	STORE r11 r5    -- set exponent of number to 0
BCD_COPY_DATA_LOOP:
	ADDI r2 1
    ADDI r5 1
	LOAD r11 r2
    STORE r11 r5    -- store num of r2 in r5
	CMPI r10 2
	JMPGE BCD_COPY_DATA_LOOP
    SUBI r10 1
    ADDI r5 1
	JMP r13
	POP r2
	
	

	-- r2 = ptr1_start
	-- r3 = ptr2_start
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

    MOVI r10 0
    STORE r10 r5

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
    MOV r10 r5
    MOV r5 r2
    JMPI STRIP
    LOAD_PC r13
    MOV r5 r3
    JMPI STRIP
    LOAD_PC r13
    MOV r5 r10

    LOAD r10 r3                 
    SUBI r10 39
    JMPN BCD_DIV_LOOP
    ADDI r10 1
    ADDI r4 2
    LOAD r11 r4
    SUB r11 r10
    STORE r11 r4
    SUBI r4 2
    MOVI r10 38
    STORE r10 r3

BCD_DIV_LOOP:
	STORE r7 r2
BCD_DIV_LOOP_CHECK_SMALLER:
    MOV0 BCD_DIV_LOOP_FITS
    JMPI CHECK_SMALLER
    LOAD_PC r13
BCD_DIV_LOOP_TO_SMALL:
    CMP r6 r7
    JMPEQ BCD_DIV_LOOP_TO_SMALL_MAX_SIZE
    ADDI r8 1
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
    ADD r1 r8
BCD_DIV_LOOP_TO_SMALL_MAX_SIZE_HAS_POINT:
    ADDI r5 1
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
    MOV r12 r5
    JMPI BCD_COPY_DATA
    LOAD_PC r13
    MOV r2 r12
    MOV r5 r2
    ADDI r5 3
    JMPI BCD_DIV_LOOP_SUB
    ADD r5 r6
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
    STORE r6 r2

    LOAD r11 r4
    MOV r5 r4
    JMPI STRIP
    LOAD_PC r13
    LOAD r10 r4
    SUB r11 r10

    MOV r5 r2
    JMPI STRIP
    LOAD_PC r13
    LOAD r11 r2
    SUB r6 r11
    SUB r7 r6
    MOV r6 r11
    ADDI r5 3
    ADD r5 r6

    MOVI r8 0
    SUBI r8 1
    CMP r6 r7
    JMPNEQ BCD_DIV_LOOP
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