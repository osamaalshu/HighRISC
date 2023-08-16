# CSE 141L Spring 2023 
## Team highRISC
- Benjamin Scott, A16380204
- Osama Al-Shuaili, A16341658
- Samuel Liu, A15793529

## Important Note
- Our team has presented to Nishant Ravindra and all of our programs are passing

## Instructions
1. Use assembler.py to compile our assembly code (`Prog1(Updated).txt`, `Prog2(Updated).txt`, `Prog3(Updated).txt`). Alternatively, you can use our precompiled machine_code (`prog1_machine_code.txt`, `prog2_machine_code.txt`, `prog3_machine_code.txt`)
    - To compile the assembly, put the assembly code into a file called `assembly.txt` in the same directory as `assembler.py`
    - Change the `LABEL_IMM_OFFSET` constant in line 5 of `assembler.py` to be `0` if compiling program1, `1` if compiling program2, or `5` if compiling program3. 
    - Then, and run the assembler:
    ```
    python assembler.py
    ```
2. The assembler will output the machine code in a file called `machine_code.txt` (do not change this name). Now, you are free to run the test benches (`prog1_tb.sv`, `prog2_tb.sv`, `prog3_tb.sv`)
