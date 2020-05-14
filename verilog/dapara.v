//*********************************************************
// IEEE STD 1364-1995 Verilog file: dapara.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
`include "case3s.v" // User defined component

module dapara (clk, x_in, y); //----> Interface

  input         clk;
  input  [3:0]  x_in;
  output [6:0]  y;
  reg    [6:0]  y;

  reg  [2:0] x0, x1, x2, x3;
  wire [3:0] y0, y1, y2, y3;
  reg  [4:0] s0, s1;
  reg  [3:0] t0, t1, t2, t3;

  always @(posedge clk)  //----> DA in behavioral style
  begin : DA 
    integer k;
    for (k=0; k<=1; k=k+1) begin     // Shift all four bits
       x0[k] <= x0[k+1];
       x1[k] <= x1[k+1];
       x2[k] <= x2[k+1];
       x3[k] <= x3[k+1];
    end
    x0[2] <= x_in[0];    // Load x_in in the 
    x1[2] <= x_in[1];    // MSBs of register 2
    x2[2] <= x_in[2];
    x3[2] <= x_in[3];
    y <= {{3{y0[3]}},y0} + {{2{y1[3]}},y1,1'b0} 
         + {y2[3],y2,2'b00} - (y3 << 3);
// Sign extensions, pipeline register, and adder tree:
//  t0 <= y0; t1 <= y1; t2 <= y2; t3 <= y3;   
//  s0 <= {t0[3],t0} + (t1 << 1);  
//  s1 <= {t2[3],t2} - (t3 <<1);
//  y  <= {{2{s0[4]}},s0} + (s1 << 2);
  end

  case3s LC_Table0 ( .table_in(x0), .table_out(y0));
  case3s LC_Table1 ( .table_in(x1), .table_out(y1));
  case3s LC_Table2 ( .table_in(x2), .table_out(y2));
  case3s LC_Table3 ( .table_in(x3), .table_out(y3));

endmodule
