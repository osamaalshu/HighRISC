
// includes package "Definitions"
// be sure to adjust "Definitions" to match your final set of ALU opcodes
import Definitions::*;

module ALU #(parameter W=8)(
  input        [W-1:0]  InputA,       // This is R0 (Except for XORR where this is rt)
                        InputB,       // This is R1 
  input        [3:0]    ALU_OP,     // ALU opcode, part of microcode
  output logic [W-1:0]  ALU_OUT,      // data output (This is some Rs but in XORR its the rt(InputA))
  output logic          Zero          // output = zero flag    !(Out)
);

  // One thing I prefered from the encrypt_proj version was the use of definitions
  // for the ALU commands. I think it makes the code more readable and easier to
  // understand. 


  // THINGS WE NEED TO FIGURE OUT
  // 1. How to setup opcodes in our definitions file
  // 2. Check the logic for our R-Type commands
  // 3. Check our Shifting commands

op_mne op_mnemonic;	

always_comb begin
// No Op = default
// add desired ALU ops, delete or comment out any you don't need
  ALU_OUT = 8'b1; 						
  Zero = 1'b0;									    // default Zero flag is false
  case(ALU_OP)

    ADD:  ALU_OUT = InputA + InputB;

    SUB:  ALU_OUT = InputA - InputB;

    AND:  ALU_OUT = InputA & InputB;

    OR:   ALU_OUT = InputA | InputB;

    XOR:  ALU_OUT = InputA ^ InputB;

    SRL:  ALU_OUT = InputA >> InputB;

    SLL:  ALU_OUT = InputA << InputB;

    XORR: ALU_OUT = ^InputA;

    // Branching commands basically set the zero flag 
    BEQ: if(InputA == InputB) Zero = 1'b1;

    BNE: if(InputA != InputB) Zero = 1'b1;

    BLT: if(InputA < InputB) Zero = 1'b1;

  endcase
end

always_comb
    op_mnemonic = op_mne'(ALU_OP);
   
endmodule