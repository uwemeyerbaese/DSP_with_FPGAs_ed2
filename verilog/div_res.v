//*********************************************************
// IEEE STD 1364-1995 Verilog file: div_res.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
// Restoring Division
// Bit width:  WN         WD           WN            WD
//         Nominator / Denumerator = Quotient and Remainder
// OR:       Nominator = Quotient * Denumerator + Remainder

module div_res(clk, n_in, d_in, r_out, q_out);

  input         clk;
  input  [7:0] n_in;
  input  [5:0] d_in;
  output [5:0] r_out;
  reg    [5:0] r_out;
  output [7:0] q_out;
  reg    [7:0] q_out;

  always @(posedge clk) //-> Divider in behavioral style
  begin : States
    parameter s0=0, s1=1, s2=2, s3=3;
    reg [3:0] count;
    reg [1:0] state;
    reg  [13:0] r, d;        // Double bit width
    reg  [7:0] q;
    case (state) 
      s0 : begin         // Initialization step 
        state <= s1;
        count = 0;
        q <= 0;           // Reset quotient register
        d <= d_in << 7;   // Load aligned denumerator
        r <= {6'B0, n_in}; // Remainder = nominator
      end                                           
      s1 : begin         // Processing step 
        r <= r - d;      // Subtract denumerator
        state <= s2;
      end
      s2 : begin          // Restoring step
        if (r[13] == 1) begin  // Check r < 0 
          r <= r + d;     // Restore previous remainder
          q <= q << 1;     // LSB = 0 and SLL
          end
        else
          q <= (q << 1) + 1; // LSB = 1 and SLL
        count = count + 1;
        d <= d >> 1;

        if (count == 8)   // Division ready ?
          state <= s3;
        else             
          state <= s1;
      end
      s3 : begin       // Output of result
        q_out <= q[7:0]; 
        r_out <= r[5:0]; 
        state <= s0;   // Start next division
      end
    endcase  
  end

endmodule
