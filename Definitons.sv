//This file defines the parameters used in the alu
// CSE141L Spring '23
// import package into each module that needs it
//   packages very useful for declaring global variables
// need > 8 instructions?
// typedef enum logic[3:0] and expand the list of enums
package Definitions;
    
// enum names will appear in timing diagram
  typedef enum logic[3:0] {
      ADD = 4'b0000, 
      SUB = 4'b0001,
      AND = 4'b0010,
      OR  = 4'b0011,
      XOR = 4'b0100,
      SRL = 4'b0101,
      SLL = 4'b0110,
      XORR = 4'b0111,
      BEQ = 4'b1000,
      BNE = 4'b1001,
      BLT = 4'b1010
    } op_mne;
    
endpackage // definitions
