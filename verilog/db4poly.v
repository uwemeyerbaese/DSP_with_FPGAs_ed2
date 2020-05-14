//*********************************************************
// IEEE STD 1364-1995 Verilog file: db4poly.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module db4poly (clk, x_in, clk2, x_e, x_o, g0, g1, y_out);

  input          clk;
  output         clk2;
  input  [7:0]   x_in;
  output [16:0]  x_e, x_o, g0, g1; // Test signals
  output [8:0]   y_out;

  reg  [7:0] x_odd, x_even, x_wait;
  wire [16:0] x_odd_sxt, x_even_sxt;
  reg  clk_div2;

// Register for multiplier, coefficients, and taps
  reg  [16:0] m0, m1, m2, m3, r0, r1, r2, r3; 
  reg  [16:0] x33, x99, x107;
  reg  [16:0] y;

  always @(posedge clk)  // Split into even and odd
  begin : Multiplex      // samples at clk rate 
    parameter even=0, odd=1;
    reg [0:0] state;
    case (state) 
      even : begin
        x_even <= x_in; 
        x_odd  <= x_wait;
        clk_div2 = 1;
        state <= odd;
      end
      odd : begin
        x_wait <= x_in;
        clk_div2 = 0;
        state <= even;
      end
    endcase  
  end

  assign x_odd_sxt = {{9{x_odd[7]}},x_odd};
  assign x_even_sxt = {{9{x_even[7]}},x_even};

  always @(x_odd_sxt or x_even_sxt) 
  begin : RAG
// Compute auxiliary multiplications of the filter
    x33  = (x_odd_sxt << 5) + x_odd_sxt;            
    x99  = (x33 << 1) + x33;                  
    x107 = x99 + (x_odd_sxt << 3);
// Compute all coefficients for the transposed filter
    m0 = (x_even_sxt << 7) - (x_even_sxt << 2); // m0 = 124
    m1 = x107 << 1;                             // m1 = 214
    m2 = (x_even_sxt << 6) - (x_even_sxt << 3) 
                                  + x_even_sxt; // m2 =  57
    m3 = x33;                                   // m3 = -33
  end

  always @(negedge clk_div2) // Infer registers; 
  begin : AddPolyphase      // use non-blocking assignments
//---------- Compute filter G0             
    r0 <=  r2 + m0;        // g0 = 128
    r2 <=  m2;             // g2 = 57
//---------- Compute filter G1
    r1 <=  -r3 + m1;       // g1 = 214
    r3 <=  m3;             // g3 = -33
// Add the polyphase components 
    y <= r0 + r1; 
  end

// Provide some test signal as outputs 
  assign x_e = x_even; 
  assign x_o = x_odd;
  assign clk2 = clk_div2;
  assign g0 = r0;
  assign g1 = r1;

  assign y_out = y[16:8]; // Connect y / 256 to output

endmodule

