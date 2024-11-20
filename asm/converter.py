instr_map = {
    "NOP"     : ("00000",),
    "CMP"     : ("00001", 'r', 'r'),
    "LOAD"    : ("00010", 'wr', 'r'),
    "STORE"   : ("00011", 'r', 'r'),
    "WAIT_K"   : ("00100",),
    "MUL"     : ("00101", 'wr', 'r'),
    "SWAP"    : ("00110", 'wr'),
    "SHR"     : ("00111", 'wr'),
    "JMPI"    : ("01000", 'ji'),
    "JMP"     : ("01001", 'r'),
    "JMPEQ"   : ("01010", 'ji'),
    "JMPN"    : ("01011", 'ji'),
    "JMPGE"   : ("01100", 'ji'),
    "JMPNEQ"  : ("01101", 'ji'),
    #"CALL"    : ("01110", 'ji'),
    #"RET"     : ("01111",),
    "ADD"     : ("10000", 'wr', 'r'),
    "ADDC"    : 'C',
    "SUB"     : ("10001", 'wr', 'r'),
    "SUBC"    : 'C',
    "OR"      : ("10010",'wr', 'r'),
    "HALT"    : ("10011",),
    "AND"     : ("10100", 'wr', 'r'),
    "MULS"    : ("10101", 'wr', 'r'),
    "MOV"     : ("10110", 'wr', 'r'),
    "SHL"     : ("10111", 'wr'),
    "ADDI"    : ("11000", 'wr', 'i'),
    "SUBI"    : ("11001", 'wr', 'i'),
    "MOV0"    : ("11010", 'ai'),
    "MOVI"    : ("11011", 'wr', 'i'),
    "LOAD_PC" : ("11100", 'wr'),
    "CMPI"    : ("11101", 'r', 'i'),
    "POP"     : ("11110", 'wr'),
    "PUSH"    : ("11111", 'r')
}

comment_literals = {"/", "\\", "#", "-"}

def to_bin(i, n):
    b = str(bin(i))[2:]
    assert len(b) <= n
    b = (n - len(b)) * "0" + b 
    return b


def to_hex(b, n):
    if len(b) != 4 * n:
        print(b)
    assert(len(b) == 4 * n)
    res = ""
    for i in range(n):
        s = b[4* i : 4* i + 4]
        i = int(s, 2)
        res += hex(i)[2:]
    return res.upper()
    

def to_vhdl(instr, row, hex = True):
    if hex:
        return str(row) + " => " + 'X"' + instr + '",'
    return str(row) + ' => "' + instr + '",'


def get_reg(s):
    if s[0] != 'R':
        raise ValueError("Expected register, not: '" + s + "'")
    try:
        i = int(s[1:])
    except ValueError:
        raise ValueError("Invalid register: '" + s + "'")
    if i >= 16:
        raise ValueError("Too large register value: R" + str(i))
    return to_bin(i, 4)


def get_im(s, n):
    try:
        i = int(s)
    except ValueError:
        raise ValueError("Invalid immediate value: '" + s + "'")
    if i >= 2**n:
        raise ValueError("Too large immediate value: '" + s + "'")
    return to_bin(i, n)
    

def convert(instr, hex = True, addr_map = None):
    assert isinstance(instr, list)
    if not instr:
        raise ValueError("Empty line")
    if not instr[0] in instr_map:
        raise ValueError("Invalid instruction: " + instr[0])
    opcode = instr_map[instr[0]]
    c = "000"
    if opcode == 'C':
        c = "001"
        opcode = instr_map[instr[0][:-1]]
    res = opcode[0]
    if len(instr) < len(opcode):
        raise ValueError("Too few arguments")
    warnings = []
    for (i, v) in enumerate(opcode[1:]):
        if v[-1] == 'r':
            reg = get_reg(instr[i + 1])
            if v[0] == 'w' and reg == "1111":
                warnings.append("Writing to R15 is not supported")
            res += get_reg(instr[i + 1])
            if i == 1:
                res += c
        elif v == 'ji' and addr_map:
            try:
                res += to_bin(addr_map[instr[i + 1]], 11)
            except KeyError:
                raise ValueError("Invalid label '" + instr[i + 1] + "'")
        elif v == 'ai' and addr_map:
            try:
                res += to_bin(addr_map[instr[i + 1]], 11)
            except KeyError:
                res += get_im(instr[i + 1], 16 - len(res))
        else:
            try:
                res += to_bin(addr_map[instr[i + 1]], 11)
            except (KeyError, TypeError):
                res += get_im(instr[i + 1], 16 - len(res))
    if len(res) < 16:
            res = res + "0" * (16 - len(res))
    if instr[0] == "BCD_ADD" or instr[0] == "BCD_ADDC" or instr[0] == "BCD_SUB" or instr[0] == "BCD_SUBC":
        warnings.append("BCD instructions have been removed")
    elif instr[0] == "MUL" or instr[0] == "MULS":
        warnings.append("MUL instructions have been removed")
    if len(opcode) < len(instr) and not instr[len(opcode)][0] in comment_literals:
       warnings.append("Extra operand is not a comment")
    if hex:
        return (to_hex(res, 4), warnings)
    return (res, warnings)
    

def reverse(data, hex = True):
    if hex:
        if len(data) != 4:
            raise ValueError("Valid operation should be 2 bytes (16 bits)")
        try:
            i_data = int(data, 16)
        except ValueError:
            raise ValueError("Invalid hex code '" + data + "'")
        binary = to_bin(i_data, 16)
    else:
        if len (data) != 16:
            raise ValueError("Valid operation should be 2 bytes (16 bits)")
        if not all(map(lambda c : c == '1' or c == '0', data)):
            raise ValueError("Invalid binary '" + data + "'")
        binary = data
    for op, op_struct in instr_map.items():
        if op_struct == 'C':
            continue
        if op_struct[0] == binary[:5]:
            break
    else:
        raise ValueError("Invalid opcode '" + binary[:5] + "'")
    operands = ""
    for (i, operand) in enumerate(op_struct[1:]):
        if operand[-1] == 'r':
            operands += " R" + str(int(binary[5 + 4 * i: 5 + 4 * (i + 1)], 2))
            if i == 1 and binary[15] == '1':
                op += 'C'
                if not op in instr_map:
                    raise ValueError("Invalid carry in instruction")
        else:
            operands += " " + str(int(binary[5 + 4 * i:], 2))
    return op + operands