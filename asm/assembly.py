import argparse
import converter
import tests
import serial

def get_lines(file):
    try:
        with open(file, 'r') as f:
            lines = f.readlines()
        return lines
    except FileNotFoundError:
        print("File '" + file + "' does not exist")
    except PermissionError:
        print("File '" + file + "' could not be opened, permission denied")
    raise RuntimeError


def get_file_bytes(file):
    try:
        with open(file, 'rb') as f:
            file_bytes = f.read()
        return file_bytes
    except FileNotFoundError:
        print("File '" + file + "' does not exist")
    except PermissionError:
        print("File '" + file + "' could not be opened, permission denied")
    raise RuntimeError


def output_result(res, file_dest = None, add_bootinfo = False):
    if add_bootinfo:
        try:
            with serial.Serial(port = '/dev/ttyUSB0', baudrate = 115200, write_timeout = 10) as ser:
                ser.write("S".encode())
                ser.write(res.encode())
                ser.write("R".encode())
        except serial.serialutil.SerialException:
            print("Could not send boot data")
            raise RuntimeError
    if file_dest:
        try:
            with open(file_dest, 'w') as file:
                file.write(res)
                return
        except FileNotFoundError:
            print("File '" + file_dest + "' does not exist")
        except PermissionError:
            print("File '" + file_dest + "' could not be opened, permission denied")
        raise RuntimeError
    elif not add_bootinfo:
        print(res)


def reverse_inline(line, hex = True, vhdl = None, file_dest = None, add_bootinfo = False):
    try:
        print(converter.reverse(line, hex))
    except ValueError as e:
        print(str(e))
        raise RuntimeError
    

def parse_inline(line, vhdl = True, hex = True, file_dest = None, add_bootinfo = False):
    try:
        line = [s.upper() for s in line]
        (r, w) = converter.convert(line, hex)
    except ValueError as e:
        print(str(e))
        raise RuntimeError
    if vhdl:
        r = converter.to_vhdl(r, 'x', hex)
    for warning in w:
        print("Warning: " + warning)
    print(r)

        
def reverse_file(file_name, hex = True, vhdl = None, file_dest = None, add_bootinfo = None):
    res = ''
    n = 0
    lines = get_lines(file_name)
    for line in lines:
        try:
            instr = converter.reverse(line.strip(), hex)
            res = res + instr + "\n"
        except ValueError as e:
            print(str(e) + " at line " + str(n))
            raise RuntimeError
        n += 1
    output_result(res, file_dest)


def compile_file(indata, vhdl = False, hex = True, file_dest = None, add_bootinfo = False):
    n_rel = 1
    n = 1
    labels = dict()
    lines = get_lines(indata[0])
    next_lines = []
    for l in lines:
        line = l.strip().upper()
        if line:
            parts = line.split(':')
            if len(parts) > 1 and not any(map(lambda c : c in parts[0], converter.comment_literals)):
                labels[parts[0].strip()] = n_rel
            elif not line[0] in converter.comment_literals:
                n_rel += 1
                next_lines.append((line, n))
        n += 1
    res = ('0 => X"0000",\n' if hex else '0 => "0000000000000000",\n') if vhdl else ('0000\n' if hex else "0000000000000000\n")
    n = 1
    for line in next_lines:
        try:
            words = line[0].split()
            (r, warnings) = converter.convert(words, hex, labels)
            res = res + (converter.to_vhdl(r, n, hex) if vhdl else r) + "\n"
            for warning in warnings:
                print("Warning: " + warning + " at line " + str(line[1]))
        except ValueError as e:
            print(str(e) + " at line " + str(line[1]))
            raise RuntimeError
        n += 1
    output_result(res, file_dest, add_bootinfo)
    
    
        
def parse_file(indata, vhdl = True, hex = True, file_dest = None, add_bootinfo = False):
    file_name = indata[0]
    res = None
    res = ('0 => X"0000",\n' if hex else '0 => "0000000000000000",\n') if vhdl else ('0000\n' if hex else "0000000000000000\n")
    n = 1
    lines = get_lines(indata[0])
    for line in lines:
        op = line.strip().upper().split()
        try:
            (r, warnings) = converter.convert(op, hex)
            res = res + (converter.to_vhdl(r, n, hex) if vhdl else r) + "\n"
            for warning in warnings:
                print("Warning: " + warning + " at line " + str(n))
        except ValueError as e:
            print(str(e) + " at line " + str(n))
            raise RuntimeError
        n += 1
    output_result(res, file_dest, add_bootinfo)

def boot_file(indata, vhdl = False, hex = True, file_dest = None, add_bootinfo = False):
    data = get_file_bytes(indata)
    try:
        with serial.Serial(port = '/dev/ttyUSB0', baudrate = 115200, write_timeout = 10) as ser:
            ser.write("S".encode())
            ser.write(data)
            ser.write("R".encode())
    except serial.serialutil.SerialException:
        print("Could not send boot data")
        raise RuntimeError

    
def run_all_tests(indata, vhdl, hex, file_dest, add_bootinfo):
    tests.run_tests()
    

def main():
    parser = argparse.ArgumentParser()
    
    parser.set_defaults(func = lambda data, vhdl, hex, file_dest, add_bootinfo : print("No action specified"))
    parser.set_defaults(indata = None)
    parser.set_defaults(vhdl = False)
    parser.set_defaults(binary = False)
    parser.set_defaults(file = None)
    parser.set_defaults(boot = False)
    subparsers = parser.add_subparsers(metavar = '{reverse, convert, boot}')
   
    parser_reverse = subparsers.add_parser('reverse', aliases = ['r'])
    parser_compile = subparsers.add_parser('parse', aliases = ['convert', 'compile', 'p', 'c'])
    parser_boot = subparsers.add_parser('boot', aliases = ['b'])
    parser_tests = subparsers.add_parser('test', aliases = ['t'])
    
    parser_reverse.set_defaults(func = reverse_inline)
    parser_reverse.add_argument('-f', '--file_in', dest ='func', action = 'store_const', const = reverse_file,
        help = "reverse an in-line instruction instead of a file")
    parser_reverse.add_argument('-b', '--binary', action = 'store_true', default = False, help = "expect binary input instead of hex")
    parser_reverse.add_argument('-o', '--file', help = "put output in file")
    parser_reverse.add_argument('indata')
    
    parser_compile.set_defaults(func = parse_file)
    parser_compile.add_argument('-l', '--literal', dest ='func', action = 'store_const', const = parse_inline, 
        help = "parse an in-line instruction instead of a file")
    parser_compile.add_argument('-c', '--compile', dest = 'func', action = 'store_const', const = compile_file, 
        help =  "compile input with labels")
    parser_compile.add_argument('--boot', action = 'store_true', help = "Add booting info to output")
    parser_compile.add_argument('-b', '--binary', action = 'store_true', default = False, help = "output binary instead of hex")
    parser_compile.add_argument('-v', '--vhdl', action = 'store_true', default = False, help = "output vhdl-code to put in pm")
    parser_compile.add_argument('-o', '--file', help = "put output in file")
    parser_compile.add_argument('indata', nargs = '+')
    
    parser_boot.set_defaults(func = boot_file)
    parser_boot.add_argument('indata')

    parser_tests.set_defaults(func = run_all_tests)
    
    args = parser.parse_args()
    try:
        args.func(args.indata, hex = not args.binary, vhdl = args.vhdl, file_dest = args.file, add_bootinfo = args.boot)
    except RuntimeError:
        print("Exiting with error")
        exit(1)

if __name__ == "__main__":
    main()
