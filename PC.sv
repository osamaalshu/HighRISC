// program counter
// supports both absolute jumps
module PC #(parameter D=9)(
  input start,
        clk,
        zero,
        branch,
  input       [D-1:0] target,	// absolute address of where to jump
  output logic[D-1:0] prog_ctr
);

  always_ff @(posedge clk)
  if(start)
    prog_ctr <= 0;
  else if(branch && zero)
    prog_ctr <= target;
  else
    prog_ctr <= prog_ctr + 'b1;

endmodule