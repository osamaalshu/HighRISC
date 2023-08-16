// register file
// default address pointer width = 4, for 16 registers, each register 8-bits wide
module RegFile #(parameter regAddressWidth=4, regDataWidth=8)(
  input[regAddressWidth-1:0] write_register, 	      // write address pointer
  input[regDataWidth-1:0] write_data,			          // write data
  input[regAddressWidth-1:0] read_register,		      // read address pointers
  input[regDataWidth-1:0] R15_in,			          // data that goes in R15
  input      clk,								                    // clock
  input      reg_write,           				          // register write enable
  input      mem_read,                              // memory read enable
  output logic[regDataWidth-1:0]  R0_out, 		      // data in R0
                                  R1_out,						// data in R1
                                  R15_out,					// data in R15
					                        read_data_out);		// data in register selected by read_register

  logic[7:0] core[2**regAddressWidth];    		      // 2-dim array  8 wide  16 deep

  // reads are combinational
  assign R0_out = core[0];
  assign R1_out = core[1];
  assign R15_out = core[15];
  assign read_data_out = core[read_register];

  // writes are sequential (clocked)
  always_ff @(posedge clk) begin
    if(reg_write)				   				// if reg_write enabled, write data to register
      core[write_register] <= write_data;
    if(mem_read)
      core[15] <= R15_in;
  end

endmodule