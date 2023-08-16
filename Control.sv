import Definitions::*;

// control decoder
module Control #(parameter opwidth = 3, aluOpWidth = 4, funcwidth = 2, regSelectWidth = 2)(
  input [opwidth-1:0] op_code,              // 3-bit opcode
  input [funcwidth-1:0] func,               // 2-bit function code
  input                 movFunc,             // 8-bit ALU operation code
  output logic Branch, MemRead, MemWrite, 
    RegWrite,
  output logic[regSelectWidth-1:0] dataSelect,
  output logic[regSelectWidth-1:0] regSelect,
  output logic[regSelectWidth-1:0] readRegSelect,
  output logic[aluOpWidth-1:0] ALUOp);	    // for up to 8 ALU operations

op_mne op_mnemonic;	

always_comb begin
  // defaults
  Branch = 1'b0;        // 1: branch (jump)
  MemRead = 1'b0;       // 1: load from data memory 0: don't load
  MemWrite = 1'b0;      // 1: store to data memory  0: don't store
  RegWrite = 1'b0;      // 1: write to reg_file  0: don't write
  ALUOp = 4'b0000;      // alu ops: 0: add, 1: sub, 2: and, 3: or, ... look at Definitions.sv
  regSelect = 2'b00;    // selects between three different sources providing a register location
  readRegSelect = 2'b00;// selects between three different sources providing a register read location
  dataSelect = 2'b00;   // selects between three different sources providing what data to write to a register location 

  // override defaults with exceptions
  case(op_code)    
    'b000:  begin					// R-type instruction
              RegWrite = 1'b1;
              regSelect = 2'b00;
              dataSelect = 2'b10;
              // determine ALUOp from func
              case(func) 
                'b00: ALUOp = ADD; // ADD
                'b01: ALUOp = SUB; // SUB
                'b10: ALUOp = AND; // AND
                'b11: ALUOp = OR; // OR
              endcase
            end
    'b001:  begin					// R-type instruction
              RegWrite = 1'b1;
              regSelect = 2'b00;
              dataSelect = 2'b10;
              // determine ALUOp from func
              case(func) 
                'b00: ALUOp = XOR; // XOR
                'b01: ALUOp = SRL; // SRL
                'b10: ALUOp = SLL; // SLL
                'b11: ALUOp = XORR; // XORR
              endcase
            end
    'b010:  begin				  // load
              // regWrite = 1'b1; Not necessary since we know R15 receives the memory 
              MemRead = 1'b1;
            end
    'b011:  begin				  // store
              MemWrite = 1'b1;
            end
    'b100:  begin				  // set
              RegWrite = 1'b1;
              regSelect = 2'b01;
              dataSelect = 2'b00;
            end
    'b101:  begin				  // branch
              Branch = 1'b1;
              // determine branch type from func
              case(func) 
                'b00: ALUOp = BEQ; // BEQ
                'b01: ALUOp = BNE; // BNE
                'b10: ALUOp = BLT; // BLT
              endcase
            end
    'b110:  begin				  // mov1 and mov2
              RegWrite = 1'b1;
              dataSelect = 2'b01;
              case(movFunc) 
                'b0: begin // MOV1
                  regSelect = 2'b10; 
                  readRegSelect = 2'b10;
                end
                'b1: begin // MOV2
                  regSelect = 2'b01; 
                  readRegSelect = 2'b01;
                end
              endcase
            end
  endcase

end

always_comb
  op_mnemonic = op_mne'(ALUOp);
	
endmodule