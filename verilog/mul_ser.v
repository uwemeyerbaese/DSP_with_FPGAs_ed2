//*********************************************************
// IEEE STD 1364-1995 Verilog file: mul_ser.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module mul_ser (clk, x, a, y);  //----> Interface

  input         clk;
  input  [7:0]  x, a;
  output [15:0] y;
  reg    [15:0] y;


  always @(posedge clk) //-> Multiplier in behavioral style
  begin : States
    parameter s0=0, s1=1, s2=2;
    reg [2:0] count;
    reg [1:0] state;
    reg  [15:0] p, t;        // Double bit width
    reg  [7:0] a_reg;
    case (state) 
      s0 : begin         // Initialization step 
        a_reg <= a;
        state <= s1;
        count = 0;
        p <= 0;             // Product register reset
        t <= {{8{x[7]}},x}; // Set temporary shift register
      end                                           // to x
      s1 : begin          // Processing step
        if (count == 7)   // Multiplication ready
          state <= s2;
        else         // Note that MaxPlusII does not does 
          begin      // not allow variable bit selects, 
          if (a_reg[0] == 1) // see (LRM Sec. 4.2.1)
            p <= p + t;      // Add 2^k
          a_reg <= a_reg >> 1;// Use LSB for the bit select
          t <= t << 1;
          count = count + 1;
          state <= s1;
        end
      end
      s2 : begin       // Output of result to y and
        y <= p;        // start next multiplication
        state <= s0;
      end
    endcase  
  end

endmodule
