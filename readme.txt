This project aims to implement a RISC-V processor on the Nexys A7 board, supporting all the RV32I base integer instructions. This implementation features a pipelined architecture with effective hazard handling and utilizes a single memory for both instructions and data. The project includes rigorous testing, covering all 40 instructions and addressing potential hazard scenarios. Additionally, this project supports integer multiplication and division instructions, along with alternative solutions to mitigate structural hazards.

Submitted by: Fekry Mohamed, Mario Ghaly, and Freedy Amgad

Our implementation supported all the instructions correctly.

We verified the functionallity of the processor by writing various test cases to test each of instruction types.

We verified the functionallity of the program on the FPGA.

We implemented these bonus features and they work correctly:
1. Add support for integer multiplication and division to effectively support the full RV32IM instruction set.
2. Provide another solution to handle the structural hazard introduced by using a single single-ported memory.

We also tried to provide a test program generator, but it does not support all the instruction types. 
