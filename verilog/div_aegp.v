//*********************************************************
// IEEE STD 1364-1995 Verilog file: div_aegp.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
// Convergence division after 
//                 Anderson, Earle, Goldschmidt, and Powers
// Bit width:  WN         WD           WN            WD
//         Nominator / Denumerator = Quotient and Remainder
// OR:       Nominator = Quotient * Denumerator + Remainder

module div_aegp(clk, n_in, d_in, q_out);

  input         clk;
  input  [8:0] n_in;
  input  [8:0] d_in;
  output [8:0] q_out;
  reg    [8:0] q_out;

  always @(posedge clk) //-> Divider in behavioral style
  begin : States
    parameter s0=0, s1=1, s2=2;
    reg [1:0] count;
    reg [1:0] state;
    reg [9:0] x, t, f;        // one guard bit 
    case (state) 
      s0 : begin              // Initialization step 
        state <= s1;
        count = 0;
        t <= {1'b0, d_in};    // Load denumerator
        x <= {1'b0, n_in};    // Load nominator
      end                                           
      s1 : begin            // Processing step 
        f = 512 - t;        // TWO - t
        x <= (x * f) >> 8;  // Factional f
        t <= (t * f) >> 8;  // Scale by 256
        count = count + 1;
        if (count == 2)     // Division ready ?
          state <= s2;
        else             
          state <= s1;
      end
      s2 : begin       // Output of result
        q_out <= x[8:0]; 
        state <= s0;   // Start next division
      end
    endcase  
  end

endmodule
