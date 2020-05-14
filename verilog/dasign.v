//*********************************************************
// IEEE STD 1364-1995 Verilog file: dasign.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
`include "case3s.v" // User defined component

module dasign (clk, x_in0, x_in1, x_in2, y); //-> Interface

  input         clk;
  input  [3:0]  x_in0, x_in1, x_in2;
  output [6:0]  y;
  reg    [6:0]  y;
  reg    [3:0]  x0, x1, x2;
  wire   [2:0]  table_in;
  wire   [3:0]  table_out;

  reg [6:0] p;  // Temporary register

  assign table_in[0] = x0[0];
  assign table_in[1] = x1[0];
  assign table_in[2] = x2[0];

  always @(posedge clk)  //----> DA in behavioral style
  begin : DA
    parameter s0=0, s1=1;
    integer k;
    reg [0:0] state;
    reg [2:0] count;           // Counts the shifts
    case (state) 
      s0 : begin               // Initialization step
        state <= s1;
        count = 0;
        p  <= 0;           
        x0 <= x_in0;
        x1 <= x_in1;
        x2 <= x_in2;
      end
      s1 : begin               // Processing step
        if (count == 4) begin  // Is sum of product done?
          y <= p;              // Output of result to y and
          state <= s0;         // start next sum of product
        end
        else begin    // Subtract for last accumulator step
          if (count ==3)   // i.e. p/2 +/- table_out * 8
            p <= {p[6],p[6:1]} - (table_out << 3);  
          else          // Accumulation for all other steps
            p <= {p[6],p[6:1]} + (table_out << 3);
          for (k=0; k<=2; k= k+1) begin     // Shift bits
            x0[k] <= x0[k+1];
            x1[k] <= x1[k+1];
            x2[k] <= x2[k+1];
          end
          count = count + 1;
          state <= s1;
        end
      end
    endcase  
  end

  case3s LC_Table0 
  ( .table_in(table_in), .table_out(table_out));

endmodule

