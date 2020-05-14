//*********************************************************
// IEEE STD 1364-1995 Verilog file: iir_par.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module iir_par (clk, x_in, clk2, y_out); //----> Interface

  parameter W = 14; // bit width - 1
  input          clk;
  input  [W:0]  x_in;
  output [W:0]  y_out;
  output         clk2;

  reg [W:0] x_even, x_odd, xd_odd, x_wait;
  reg [W:0] y_even, y_odd, y_wait, y;  
  reg [W:0] x_e, x_o, y_e, y_o;
  reg [W:0] sum_x_even, sum_x_odd;
  reg        clk_div2;

  always @(posedge clk)          // Clock divider by 2
  begin : clk_divider            // for input clk 
     clk_div2 <= ! clk_div2;
  end

  always @(posedge clk)          // Split x into even
  begin : Multiplex              // and odd samples; 
    parameter even=0, odd=1;     // recombine y at clk rate
    reg [0:0] state;
    case (state) 
      even : begin
          x_even <= x_in; 
          x_odd <= x_wait;
          y <= y_wait;
          state <= odd;
      end
      odd : begin
         x_wait <= x_in;
         y <= y_odd;
         y_wait <= y_even;
         state <= even;
      end
    endcase
  end

  assign y_out = y;
  assign clk2  = clk_div2;
 
  always @(negedge clk_div2)
  begin: Arithmetic                                      
    sum_x_even <= x_odd + {x_even[W],x_even[W:1]} 
                       + {x_even[W],x_even[W],x_even[W:2]};
                     // i.e. x_odd + x_even / 2 + x_even /4 
    y_even <= sum_x_even + {y_even[W],y_even[W:1]} 
                            + {{4{y_even[W]}},y_even[W:4]};
               // i.e. sum_x_even + y_even / 2 + y_even /16
    xd_odd <= x_odd;
    sum_x_odd <= x_even + {xd_odd[W],xd_odd[W:1]} 
                       + {xd_odd[W],xd_odd[W],xd_odd[W:2]};
                    // i.e. x_even + xd_odd / 2 + xd_odd /4
    y_odd  <= sum_x_odd + {y_odd[W],y_odd[W:1]} 
                              + {{4{y_odd[W]}},y_odd[W:4]};
                 // i.e. sum_x_odd + y_odd / 2 + y_odd / 16
  end
endmodule
