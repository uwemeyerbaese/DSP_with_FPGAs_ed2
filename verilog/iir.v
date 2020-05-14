//*********************************************************
// IEEE STD 1364-1995 Verilog file: iir.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module iir ( x_in,      // Input
             y_out,     // Result
             clk);
  parameter W = 14;    // Bit width - 1
  input  [W:0] x_in;
  output [W:0] y_out;
  input         clk;

  reg [W:0] x, y;

// initial begin
//  y=0;
//  x=0;
// end

// Use FFs for input and recursive part 
always @(posedge clk) begin    // Note: there is no signed
  x  <= x_in;                  // integer in Verilog 
  y  <= x + {y[W],y[W:1]} + {{2{y[W]}},y[W:2]}; 
                                 // i.e. x + y / 2 + y / 4;
end

assign  y_out = y;           // Connect y to output pins

endmodule
