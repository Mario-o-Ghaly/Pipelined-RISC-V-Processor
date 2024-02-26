import random

def generate_instruction():
    opcodes = ["add", "sub", "sll", "slt", "sltu", "xor", "srl", "sra", "or", "and", "addi", "slti", "sltiu", "xori", "ori", "andi", "slli", "srli", "srai"]
    R_type = ["add", "sub", "sll", "slt", "sltu", "xor", "srl", "sra", "or", "and"]
    I_type = ["addi", "slti", "sltiu", "xori", "ori", "andi", "slli", "srli", "srai"]
    random.randint(0, 31)
    opcode = random.choice(opcodes)
    if opcode in R_type:
        regrd = random.randint(0, 31)
        regrs1 = random.randint(0, 31)
        regrs2 = random.randint(0, 31)
        rd = to_binary(regrd)
        rs1 = to_binary(regrs1)
        rs2 = to_binary(regrs2)
        op = "0110011"
        #func7
        if opcode in ("sub", "sra"):
            func7 = "0100000"
        else:
            func7 = "0000000"
        
        #func3
        if opcode in ("add", "sub"):
            func3 = "000"
        elif opcode == "sll":
            func3 = "001"
        elif opcode == "slt":
            func3 = "010"
        elif opcode == "sltu":
            func3 = "011"
        elif opcode == "xor":
            func3 = "100"
        elif opcode in ("srl", "sra"):
            func3 = "101"
        elif opcode == "or":
            func3 = "110"
        elif opcode == "and":
            func3 = "111"
        
        return ( (func7 + rs2 + rs1 + func3 + rd + op), opcode + " x" + str(regrd) + " x" + str(regrs1) + " x" + str(regrs2))

    
    if opcode in I_type:
        regrd = random.randint(0, 31)
        regrs1 = random.randint(0, 31)
        regimm = random.randint(-2048, 2047)
        rd = to_binary(regrd)
        rs1 = to_binary(regrs1)
        imm = to_binary(regimm)
        if len(imm) < 12:
            imm = imm.zfill(12)
            
        op = "0010011"
        
        #func3
        if opcode == "addi":
            func3 = "000"
        elif opcode == "slli":
            func3 = "001"
            imm = "0000000" + imm[7:] 
            regimm = int(str(imm[7:]), 2)
        elif opcode == "slti":
            func3 = "010"
        elif opcode == "sltui":
            func3 = "011"
        elif opcode == "xori":
            func3 = "100"
        elif opcode in ("srli", "srai"):
            func3 = "101"
            if opcode == "srli":
                imm = "0000000" + imm[7:] 
                regimm = int(str(imm[7:]), 2)
            else:
                imm = "0100000" + imm[7:]
                regimm = int(str(imm[7:]), 2)
        elif opcode == "ori":
            func3 = "110"
        elif opcode == "andi":
            func3 = "111"
        else:
            func3 = "000"
        
        return ( (imm + rs1 + func3 + rd + op), opcode + " x" + str(regrd) + " x" + str(regrs1) + " " + str(regimm))
    

def twos_complement(binary_str, bit_width):
    # Convert binary string to integer
    number = int(binary_str, 2)

    # Calculate two's complement
    two_comp = (1 << bit_width) - number

    # Format the result as a 32-bit binary string
    result = format(two_comp, f'0{bit_width}b')
    return result


def to_binary(num):
    if num >=0:
        number = bin(num)[2:]
        number = number[-5:].rjust(5, '0')
    else:
        number = twos_complement(bin(-num), 32)
        number = number[-12:]
    return(number)

def program_generator():
    inp = int(input("Enter the number of instructions you want to generate: "))
    machine_codes = []
    codes = []
    for i in range(inp):
        (machine_code, code) = generate_instruction()
        machine_codes.append(machine_code)
        codes.append(code)
        
    for m in machine_codes:
        print(m)
    print("\n")
    for c in codes:
        print(c)

program_generator()