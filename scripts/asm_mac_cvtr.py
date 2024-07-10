# Library imports
import os
import sys
import re


# See if a file exits
def file_exists(filepath):
    return os.path.isfile(filepath)


# trim the number to 6 binary digits
def trimNum(num):
    num = num & 0x3F
    return f"{num:06b}"


# holds the lines read from input file
lines = []
# holds the binary equivalent of lines
bins = []

# Check if sufficient number of inputs have been provided
if len(sys.argv) < 2:
    print("INSUFFICIENT INPUTS")
    print("\033[1;31mpython asm_mac_cvtr.py <input_file>\033[0m\033[1;33m <output_file> <base_addr>\033[0m")
    sys.exit()

# Check if the input file actually exists
if not (file_exists(sys.argv[1])):
    print("Input file does not exist..!")
    sys.exit()

# Add lines to lines array after formatting
with open(sys.argv[1], "r") as read_file:
    for line in read_file:
        line = re.sub("#.*", "", line)
        line = re.sub("\n*", "", line)
        line = line.replace(",", " ")
        line = line.replace(".", " ")
        line = line.replace("-", " ")
        line = line.replace("\t", " ")
        line = re.sub("^ *", "", line)
        line = re.sub(" *$", "", line)
        line = line.upper()
        while "  " in line: line = line.replace("  ", " ")
        if not(line == ""): lines.append(line)

# for each line, convert it to binary
for i in range(len(lines)):

    # split into indexable words
    words = lines[i].split(" ")

    # evaluate each word
    for j in range(len(words)):
        # replace register with address
        if words[j] == "ZERO": words[j] = "000"
        elif words[j] == "X0": words[j] = "000"
        elif words[j] == "X1": words[j] = "001"
        elif words[j] == "X2": words[j] = "010"
        elif words[j] == "X3": words[j] = "011"
        elif words[j] == "X4": words[j] = "100"
        elif words[j] == "X5": words[j] = "101"
        elif words[j] == "X6": words[j] = "110"
        elif words[j] == "X7": words[j] = "111"
        # format immediate
        elif words[j][0:2] == "0B":
            num = int(words[j][2:], 2)
            words[j] = trimNum(num)
        elif words[j][0:2] == "0X":
            num = int(words[j][2:], 16)
            words[j] = trimNum(num)
        elif not words[j] in [
            "ADDI", "ADD", "SUB", "AND", "OR", "XOR", "NOT", "LOAD", "STORE", "SLL", "SLR", "SLLI", "SLRI"]:
            try:
                num = int(words[j])
                words[j] = trimNum(num)
            except:
                print(f"Error on line {i+1}: \033[1;31m{words[j]}\033[0m in \033[1;36m{lines[i]}\033[0m")
                sys.exit()


    # Encode
    if   words[0] == "ADDI"  : bins.append(f"{words[1]}{words[2]}{words[3]}0001")
    elif words[0] == "ADD"   : bins.append(f"{words[1]}{words[2]}{words[3]}0000011")
    elif words[0] == "SUB"   : bins.append(f"{words[1]}{words[2]}{words[3]}0001011")
    elif words[0] == "AND"   : bins.append(f"{words[1]}{words[2]}{words[3]}0000101")
    elif words[0] == "OR"    : bins.append(f"{words[1]}{words[2]}{words[3]}0001101")
    elif words[0] == "XOR"   : bins.append(f"{words[1]}{words[2]}{words[3]}0001111")
    elif words[0] == "NOT"   : bins.append(f"{words[1]}{words[2]}0000000111")
    elif words[0] == "LOAD"  : bins.append(f"{words[1]}{words[2]}0000000010")
    elif words[0] == "STORE" : bins.append(f"000{words[2]}{words[1]}0001010")
    elif words[0] == "SLL"   : bins.append(f"{words[1]}{words[2]}{words[3]}0000110")
    elif words[0] == "SLR"   : bins.append(f"{words[1]}{words[2]}{words[3]}0000100")
    elif words[0] == "SLLI"  : bins.append(f"{words[1]}{words[2]}{words[3]}1110")
    elif words[0] == "SLRI"  : bins.append(f"{words[1]}{words[2]}{words[3]}1100")

# holds finalized bytes
BYTES = []

# Base address 
ADDR = ""
try:    ADDR = sys.argv[3]
except: ADDR = "00001000"

print(f"ADDRESS___    BIN________________    ASM____________")
for i in range(len(bins)):
    print(
        f"0x{(2*i+int(ADDR,16)):08x}    {bins[i][0:3]} {bins[i][3:6]} {bins[i][6:12]} {bins[i][12:]}    {lines[i]}"
    )
    BYTES.append(int(bins[i][8:],2))
    BYTES.append(int(bins[i][:8],2))

# Output file
OUT = ""
try:    OUT = sys.argv[2]
except: OUT = sys.argv[1]
OUT = re.sub("\..*", ".hex", OUT)

# write to hex file
with open(OUT, "w") as file:
    file.write(f"@{ADDR}")
    for i in range(len(BYTES)):
        if (i%16==0): file.write("\n")
        file.write(f"{BYTES[i]:02x} ")
    file.write("\n")

# print success and output file path
print(f"File '{OUT}' created successfully.")
