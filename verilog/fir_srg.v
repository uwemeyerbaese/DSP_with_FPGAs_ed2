//*********************************************************
// IEEE STD 1364-1995 Verilog file: fir_srg.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module fir_srg (clk, x, y);  //----> Interface

  input        clk;
  input  [7:0] x;
  output [7:0] y;
  reg    [7:0] y;
// Tapped delay line array of bytes
  reg    [7:0] tap0, tap1, tap2, tap3; 
// For bit access use single vectors in Verilog

  always @(posedge clk)  //----> Behavioral Style
  begin : p1
   // Compute output y with the filter coefficients weight.
   // The coefficients are [-1  3.75  3.75  -1]. 
   // Multiplication and division for Altera MaxPlusII can 
   // be done in Verilog with sign extensions and shifts! 
    y <= (tap1<<1) + tap1 + {tap1[7],tap1[7:1]} 
         + {tap1[7],tap1[7],tap1[7:2]} + (tap2<<1) + tap2
         + {tap2[7],tap2[7:1]} 
         + {tap2[7],tap2[7],tap2[7:2]} - tap3 - tap0;

    tap3 <= tap2;  // Tapped delay line: shift one 
    tap2 <= tap1;
    tap1 <= tap0;
    tap0 <= x;   // Input in register 0
  end

endmodule
