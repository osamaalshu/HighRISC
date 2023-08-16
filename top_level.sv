// sample top level design
module top_level(		            // you will have the same 3 ports
    input             Start,    // start next program
	                    Clk,	    // clock -- posedge used inside design
    output logic      Done	      // done flag from DUT
    );

  parameter           pc_width = 9,                           // program counter width
                      opcode_width = 3,                       // Opcode bit width
                      aluOpWidth = 4;                         // ALU operation bit width

  wire[pc_width-1:0]  target, 			                          // branch target 
                      prog_ctr;

  // branch LUT stuff
  logic[3:0] branch_imm;

  // register wires
  wire                RegWrite;
  logic[3:0]          mux_reg_write_reg,
                      mux_reg_read_reg;                         // mux output to control which register to write to and what data to write in it
  logic[7:0]          mux_reg_write_data;                  
  wire[7:0]           R0_out, R1_out, R15_out, register_out,	 // from RegFile                         
                      R15_in;
  
  // ALU wires
  wire[7:0]           ALU_OUT;                                // alu output
  wire[8:0]           prog_ctr_target;                         // program counter target
  wire                zero;

  // Control wires
  wire                branch,
                      MemRead,
                      MemWrite,
                      ALUSrc;		                // immediate switch
  wire[1:0]           regSelect,               // selects between three different sources providing a register location
                      dataSelect,               // selects between three different sources providing what data to write to a register location 
                      readRegSelect;
  logic[2:0] op_code;
  logic[1:0] func;
  logic movFunc;

  
  // for Write Reg MUX
  wire[3:0]           write_reg_mux_option_0,
                      write_reg_mux_option_1,
                      write_reg_mux_option_2;     

  // for Write Data MUX
  wire[7:0]           write_data_mux_option_0,
                      write_data_mux_option_1,
                      write_data_mux_option_2; 

  // for Read Reg MUX
  wire[3:0]           read_reg_mux_option_0,
                      read_reg_mux_option_1,
                      read_reg_mux_option_2;       

  wire[aluOpWidth-1:0] ALUOp;                   // which ALU operation to perform
  wire[8:0]           mach_code;                // machine code
  wire[2:0]           read_register;            // address pointer to reg_file  

  // PC subassembly
  assign branch_imm = mach_code[5:2];
  Branch_LUT Branch_LUT1( 
    .Addr         (branch_imm ) ,
    .Target       (prog_ctr_target  )
  );
  PC PC1 (
    .start      (Start            ),
    .clk        (Clk              ),
    .zero       (zero             ),
    .branch     (branch           ),   
    .target     (prog_ctr_target  ),
    .prog_ctr   (prog_ctr         )
  );

  // contains machine code
  InstrRom INSTR_ROM1(
    .prog_ctr   (prog_ctr),
    .mach_code  (mach_code)
  );

  // Control Decoder
  assign op_code = mach_code[8:6];
  assign func = mach_code[1:0];
  assign movFunc = mach_code[0];
  Control CTRL1(
    .op_code      (op_code),
    .func         (func), 
    .movFunc      (movFunc), 
    .Branch       (branch), 
    .MemRead      (MemRead), 
    .MemWrite     (MemWrite), 
    .RegWrite     (RegWrite),
    .dataSelect   (dataSelect),     
    .regSelect    (regSelect),
    .readRegSelect(readRegSelect),
    .ALUOp        (ALUOp)
  );

  // Write Reg MUX
  assign write_reg_mux_option_0 = mach_code[5:2];
  assign write_reg_mux_option_1 = {3'b0, mach_code[5]};
  assign write_reg_mux_option_2 = mach_code[4:1];
  always_comb begin
    case (regSelect)
      2'b00: mux_reg_write_reg = write_reg_mux_option_0;
      2'b01: mux_reg_write_reg = write_reg_mux_option_1;
      2'b10: mux_reg_write_reg = write_reg_mux_option_2;
      default: mux_reg_write_reg = 4'b0000; // Output default value if select is not valid
    endcase
  end

  // Write Data MUX
  assign write_data_mux_option_0 = {3'b0, mach_code[4:0]};
  assign write_data_mux_option_1 = register_out;
  assign write_data_mux_option_2 = ALU_OUT;
  always_comb begin
    case (dataSelect)
      2'b00: mux_reg_write_data = write_data_mux_option_0;
      2'b01: mux_reg_write_data = write_data_mux_option_1;
      2'b10: mux_reg_write_data = write_data_mux_option_2;
      default: mux_reg_write_data = 8'h00; // Output default value if select is not valid
    endcase
  end

  // Read Register MUX
  assign read_reg_mux_option_0 = mach_code[5:2];
  assign read_reg_mux_option_1 = mach_code[4:1];
  assign read_reg_mux_option_2 = {3'b0, mach_code[5]};
  always_comb begin
    case (readRegSelect)
      2'b00: mux_reg_read_reg = read_reg_mux_option_0;
      2'b01: mux_reg_read_reg = read_reg_mux_option_1;
      2'b10: mux_reg_read_reg = read_reg_mux_option_2;
      default: mux_reg_read_reg = 8'h00; // Output default value if select is not valid
    endcase
  end

  // Register File Subassembly
  assign read_reg = mach_code[5:2];
  RegFile RegFile1(
    .write_register   (mux_reg_write_reg),
    .write_data       (mux_reg_write_data),
    .read_register    (mux_reg_read_reg),
    .R15_in           (R15_in),
    .clk              (Clk),
    .reg_write        (RegWrite),
    .mem_read         (MemRead),
    .R0_out           (R0_out),
    .R1_out           (R1_out),
    .R15_out          (R15_out),
    .read_data_out    (register_out)
  ); 

  // initialize all register values to 0
  always_comb begin
    if (Start == 1'b1) begin
      for (int i = 0; i < 16; i = i + 1) begin
        RegFile1.core[i] = 0;
      end
    end
  end

  // ALU Subassembly
  ALU ALU1  (
    .InputA         (R0_out),
    .InputB         (R1_out), 
    .ALU_OP         (ALUOp),
    .ALU_OUT        (ALU_OUT),
    .Zero           (zero)
  );

  // Data Memory Subassembly
  // How do we get the address of the data we want to read from memory? LUT?
  DataMem DM(
    .dat_in       (R15_out), 
		.clk          (Clk), 
    .wr_en         (MemWrite),
		.addr        (register_out), 
    .dat_out 		  		(R15_in)
	);

  // Set done flag when program is done
  assign Done = prog_ctr == 300;
 
endmodule