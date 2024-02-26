import random

def initialize():
    #example for a machine code in hexadecimal
    input_text = """3e802083 
3e800103
3e804183
3e801203
3e805283
3e102623
3e101823
3e100a23"""

    # Split the text into lines
    lines = input_text.split('\n')

    # Printing the instructions in a byte-addressable way
    for line in lines:
        print(line[6:8])
        print(line[4:6])
        print(line[2:4])
        print(line[:2])


initialize()