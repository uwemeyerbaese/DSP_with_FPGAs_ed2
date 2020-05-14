//*********************************************************
// IEEE STD 1364-1995 Verilog file: fir_gen.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
// This is a generic FIR filter generator 
// It uses W1 bit data/coefficients bits
module fir_gen (clk, Load_x, x_in, c_in, y_out);  

  parameter W1 = 9,   // Input bit width
            W2 = 18,  // Multiplier bit width 2*W1
            W3 = 19,  // Adder width = W2+log2(L)-1
            W4 = 11,  // Output bit width
            L  = 4,   // Filter length 
            Mpipe = 3; // Pipeline steps of multiplier
  input clk, Load_x;  // std_logic 
  input [W1-1:0] x_in, c_in;  // Inputs
  output [W3-1:0] y_out;  // Results

  reg [W1-1:0]  x;
  wire [W3-1:0]  y;
// 2D array types i.e. memories not supported by MaxPlusII
// in Verilog, use therefore single vectors
  reg  [W1-1:0] c0, c1, c2, c3; // Coefficient array 
  wire [W2-1:0] p0, p1, p2, p3; // Product array
  reg  [W3-1:0] a0, a1, a2, a3; // Adder array

  wire  [W2-1:0] sum;  // Auxilary signals
  wire  clken, aclr;

  assign sum=0; assign aclr=0; // Default for mult
  assign clken=0;
                                                
//----> Load Data or Coefficient
  always @(posedge clk) 
    begin: Load
    if (! Load_x) begin
      c3 <= c_in; // Store coefficient in register 
      c2 <= c3;   // Coefficients shift one 
      c1 <= c2;
      c0 <= c1;
      end
    else begin
      x <= x_in; // Get one data sample at a time
    end
  end

//----> Compute sum-of-products
  always @(posedge clk) 
    begin: SOP
  // Compute the transposed filter additions
    a0 <= {p0[W2-1], p0} + a1;
    a1 <= {p1[W2-1], p1} + a2;
    a2 <= {p2[W2-1], p2} + a3;
    a3 <= {p3[W2-1], p3}; // First TAP has only a register
  end
  assign y = a0;

// Instantiate L pipelined multiplier
  lpm_mult mul_0            // Multiply  x*c0 = p0  
    (.clock(clk), .dataa(x), .datab(c0), .result(p0)); 
//   .sum(sum), .clken(clken), .aclr(aclr)); // Unused ports
    defparam mul_0.lpm_widtha = W1;  
    defparam mul_0.lpm_widthb = W1;
    defparam mul_0.lpm_widthp = W2;  
    defparam mul_0.lpm_widths = W2;
    defparam mul_0.lpm_pipeline = Mpipe;
    defparam mul_0.lpm_representation = "SIGNED";

  lpm_mult mul_1            // Multiply  x*c1 = p1  
    (.clock(clk), .dataa(x), .datab(c1), .result(p1));  
//   .sum(sum), .clken(clken), .aclr(aclr)); // Unused ports
    defparam mul_1.lpm_widtha = W1;  
    defparam mul_1.lpm_widthb = W1;
    defparam mul_1.lpm_widthp = W2;  
    defparam mul_1.lpm_widths = W2;
    defparam mul_1.lpm_pipeline = Mpipe;
    defparam mul_1.lpm_representation = "SIGNED";

  lpm_mult mul_2            // Multiply  x*c2 = p2  
    (.clock(clk), .dataa(x), .datab(c2), .result(p2));  
//   .sum(sum), .clken(clken), .aclr(aclr)); // Unused ports
    defparam mul_2.lpm_widtha = W1;  
    defparam mul_2.lpm_widthb = W1;
    defparam mul_2.lpm_widthp = W2;  
    defparam mul_2.lpm_widths = W2;
    defparam mul_2.lpm_pipeline = Mpipe;
    defparam mul_2.lpm_representation = "SIGNED";

  lpm_mult mul_3            // Multiply  x*c3 = p3  
    (.clock(clk), .dataa(x), .datab(c3), .result(p3)); 
//   .sum(sum), .clken(clken), .aclr(aclr)); // Unused ports
    defparam mul_3.lpm_widtha = W1;  
    defparam mul_3.lpm_widthb = W1;
    defparam mul_3.lpm_widthp = W2;  
    defparam mul_3.lpm_widths = W2;
    defparam mul_3.lpm_pipeline = Mpipe;
    defparam mul_3.lpm_representation = "SIGNED";

   assign y_out = y[W3-1:W3-W4];

endmodule
