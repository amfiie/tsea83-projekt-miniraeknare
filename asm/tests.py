import converter
import unittest


class ConvertTestCase(unittest.TestCase):
    def test_reg_reg(self):
        self.assertEqual(converter.convert(["ADD", "R0", "R1"]), ("8008", []))
        self.assertEqual(converter.convert(["SUB", "R12", "R13"]), ("C668", []))
        self.assertEqual(converter.convert(["CMP", "R8", "R9"], {"Main", 5}), ("0C48", []))
        self.assertEqual(converter.convert(["MOV", "R12", "R12"]), ("B660", []))
        
    def test_reg_im(self):
        self.assertEqual(converter.convert(["ADDI", "R12", "24"]), ("8E18", []))
        self.assertEqual(converter.convert(["SUBI", "R0", "127", "//comment"]), ("C87F", []))
        self.assertEqual(converter.convert(["CMPI", "R4", "0"], addr_map = {"0", 2}), ("AA00", []))
        self.assertEqual(converter.convert(["MOVI", "R7", "99"]), ("BBE3", []))
        
    def test_one_reg(self):
        self.assertEqual(converter.convert(["SWAP", "R3"]), ("3180", []))
        self.assertEqual(converter.convert(["SHR", "R2"]), ("E100", []))
        
    def test_one_im(self):
        self.assertEqual(converter.convert(["MOV0", "2047"], addr_map = {"2047", 13}), ("2FFF", []))
        
    def test_jmp(self):
        self.assertEqual(converter.convert(["JMPI", "40"]), ("4028", []))
        self.assertEqual(converter.convert(["JMPEQ", "FN_START"], addr_map = {"FN_START" : 12, "FN_END" : 24}), ("500C", []))
        
    def test_empty(self):
        self.assertEqual(converter.convert(["NOP", "--Wait a while"], {"NICE" : 5}), ("0000", []))
        self.assertEqual(converter.convert(["WAIT_K", "#get key"]), ("2000", []))
        
    def test_carry(self):
        self.assertEqual(converter.convert(["ADDC", "R0", "R1"]), ("8009", []))
        self.assertEqual(converter.convert(["SUBC", "R12", "R13"]), ("C669", []))


    def test_to_few_arguments(self):
        with self.assertRaises(ValueError, msg = "Too few arguments"):
            converter.convert(["AND", "R0"])
        with self.assertRaises(ValueError, msg = "Too few arguments"):
            converter.convert(["ADDI", "R12"])
        with self.assertRaises(ValueError, msg = "Too few arguments"):
            converter.convert(["SHL"])

    def test_bad_register(self):
        with self.assertRaises(ValueError, msg = "Expected register, not: '12'"):
            converter.convert(["OR", "R5", "12"])
        with self.assertRaises(ValueError, msg = "Invalid register 'RX'"):
            converter.convert(["LOAD", "RS", "R15"])
        with self.assertRaises(ValueError, msg = "Expected register, not: '88'"):
            converter.convert(["MOVI", "88", "R13"])
        with self.assertRaises(ValueError, msg = "Expected register, not: '88'"):
            converter.convert(["SHL", "88"])
            
    def test_bad_immediate(self):
        with self.assertRaises(ValueError, msg = "Invalid immediate value: 'R2'"):
            converter.convert(["CMPI", "R1", "R2"])
        with self.assertRaises(ValueError, msg = "Too large immediate value: '128'"):
            converter.convert(["CMPI", "R1", "128"])
        with self.assertRaises(ValueError, msg = "To large immediate value : '2048'"):
            converter.convert(["MOV0", "2048"])
        
    def test_to_many_args(self):
        self.assertEqual(converter.convert(["ADD", "R13", "R4", "25"]), ("86A0", ["Extra operand is not a comment"]))
        self.assertEqual(converter.convert(["MOV0", "254", "R4", "25"]), ("28FE", ["Extra operand is not a comment"]))
        self.assertEqual(converter.convert(["NOP", "R3", "R4", "25"]), ("0000", ["Extra operand is not a comment"]))
        
    def test_depricated(self):
        self.assertEqual(converter.convert(["MUL", "R1", "R1"]), ("D088", ["MUL instructions have been removed"]))
        self.assertEqual(converter.convert(["BCD_ADD", "R12", "R13"], addr_map = {"NONE" : 2}), ("9668", ["BCD instructions have been removed"]))
        
    def test_r15(self):
        self.assertEqual(converter.convert(["ADD", "R15", "R0"]), ("8780", ["Writing to R15 is not supported"]))
        self.assertEqual(converter.convert(["CMP", "R15", "R0"]), ("0F80", []))
        
    def test_multiple_warnings(self):
        self.assertEqual(
            converter.convert(["BCD_ADDC", "R15", "R12", "2"]), 
            ("97E1", ["Writing to R15 is not supported", "BCD instructions have been removed", "Extra operand is not a comment"])
        )
    
    def test_bad_input(self):
        with self.assertRaises(ValueError, msg = "Empty line"):
            converter.convert([])
        with self.assertRaises(ValueError, msg = "Invalid instruction: ADD_BCD"):
            converter.convert(["ADD_BCD", "R12", "R3"])

     
class ReverseTestCase(unittest.TestCase):
    def test_valid(self):
        self.assertEqual(converter.reverse("0000"), "NOP")
        self.assertEqual(converter.reverse("B881"), "MOVI R1 1")
        self.assertEqual(converter.reverse("B902"), "MOVI R2 2")
        self.assertEqual(converter.reverse("BC8A"), "MOVI R9 10")
        self.assertEqual(converter.reverse("1011111000001010", False), "MOVI R12 10")		
        self.assertEqual(converter.reverse("BD8C"), "MOVI R11 12")
        self.assertEqual(converter.reverse("85E0"), "ADD R11 R12")
        self.assertEqual(converter.reverse("0E58"), "CMP R12 R11")
        self.assertEqual(converter.reverse("601F"), "JMPGE 31")
        self.assertEqual(converter.reverse("0001011101100000", False), "LOAD R14 R12")
        

    def test_bad_size(self):
        with self.assertRaises(ValueError, msg = "Valid operation should be 2 bytes (16 bits)"):
            converter.reverse("000A0")
        with self.assertRaises(ValueError, msg = "Valid operation should be 2 bytes (16 bits)"):
            converter.reverse("00000", hex = False)
    
   
    def test_bad_opcode(self):
        with self.assertRaises(ValueError, msg = "Invalid opcode '01111'"):
            converter.reverse("7811")
            

    def test_bad_data(self):
        with self.assertRaises(ValueError, msg = "Invalid hex code 'G'"):
            converter.reverse("00G0")
        with self.assertRaises(ValueError, msg = "Invalid binary '2'"):
            converter.reverse("0100101001020101", hex = False)
    

def run_tests():
    unittest.main(module = 'tests', argv = "n")