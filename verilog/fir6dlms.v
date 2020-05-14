//*********************************************************
// IEEE STD 1364-1995 Verilog file: fir6dlms.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
// This is a generic DFIR filter generator 
// It uses W1 bit data/coefficients bits
module fir6dlms 
           (clk, x_in, d_in, e_out, y_out, f0_out, f1_out);

  parameter W1 = 8,   // Input bit width
            W2 = 16,  // Multiplier bit width 2*W1
            L  = 2,   // Filter length 
            Delay = 3; // Pipeline steps of multiplier
  input clk;  // 1 bit input 
  input [W1-1:0] x_in, d_in;  // Inputs
  output [W2-1:0] e_out, y_out;  // Results
  output [W1-1:0] f0_out, f1_out;  // Results

// 2D array types i.e. memories not supported by MaxPlusII
// in Verilog, use therefore single vectors
  reg  [W1-1:0] x, x0, x1, x2, x3, x4, f0, f1;  
  reg  [W1-1:0] d0, d1, d2, d3; // Desired signal array
  wire [W1-1:0] emu;
  wire [W2-1:0] p0, p1, xemu0, xemu1; // Product array
  wire  [W2-1:0]  y, sxty, e, sxtd; 

  wire  clken, aclr;
  wire  [W2-1:0] sum;  // Auxilary signals


  assign sum=0; assign aclr=0; // Default for mult
  assign clken=0;

  
  // 16 bit signed extension for input d
  assign  sxtd = {{8{d3[7]}}, d3};

  always @(posedge clk) // Store these data or coefficients
    begin: Store
      d0 <= d_in; // Shift register for desired data 
      d1 <= d0;
      d2 <= d1;
      d3 <= d2;
      x0 <= x_in; // Shift register for data 
      x1 <= x0;   
      x2 <= x1;
      x3 <= x2;
      x4 <= x3;
      f0 <= f0 + xemu0[15:8]; // implicit divide by 2
      f1 <= f1 + xemu1[15:8]; 
  end

// Instantiate L pipelined multiplier
// Multiply p(i) = f(i) * x(i);
  lpm_mult mul_0            // Multiply  x0*f0 = p0  
    (.clock(clk), .dataa(x0), .datab(f0), .result(p0));    
//  .sum(sum), .clken(clken), .aclr(aclr)); // Unused ports
    defparam mul_0.lpm_widtha = W1;  
    defparam mul_0.lpm_widthb = W1;
    defparam mul_0.lpm_widthp = W2;  
    defparam mul_0.lpm_widths = W2;
    defparam mul_0.lpm_pipeline = Delay;
    defparam mul_0.lpm_representation = "SIGNED";

  lpm_mult mul_1            // Multiply  x1*f1 = p1  
    (.clock(clk), .dataa(x1), .datab(f1), .result(p1));
//  .sum(sum), .clken(clken), .aclr(aclr)); // Unused ports
    defparam mul_1.lpm_widtha = W1;  
    defparam mul_1.lpm_widthb = W1;
    defparam mul_1.lpm_widthp = W2;  
    defparam mul_1.lpm_widths = W2;
    defparam mul_1.lpm_pipeline = Delay;
    defparam mul_1.lpm_representation = "SIGNED";


  assign y = p0 + p1;  // Compute ADF output

  // Scale y by 128 because x is fraction
  assign  sxty = { {7{y[15]}}, y[15:7]};

  assign e = sxtd - sxty;
  assign emu = e[8:1];  // e*mu divide by 2 and 
                        // 2 from xemu makes mu=1/4
// Instantiate L pipelined multiplier
// Multiply xemu(i) = emu * x(i);
  lpm_mult mul_3            // Multiply xemu0 = emu * x0;  
    (.clock(clk), .dataa(x3), .datab(emu), .result(xemu0));
//  .sum(sum), .clken(clken), .aclr(aclr)); // Unused ports
    defparam mul_3.lpm_widtha = W1;  
    defparam mul_3.lpm_widthb = W1;
    defparam mul_3.lpm_widthp = W2;  
    defparam mul_3.lpm_widths = W2;
    defparam mul_3.lpm_pipeline = Delay;
    defparam mul_3.lpm_representation = "SIGNED";

  lpm_mult mul_4            // Multiply xemu1 = emu * x1;  
    (.clock(clk), .dataa(x4), .datab(emu), .result(xemu1));
//   .sum(sum),.clken(clken), .aclr(aclr)); // Unused ports
    defparam mul_4.lpm_widtha = W1;  
    defparam mul_4.lpm_widthb = W1;
    defparam mul_4.lpm_widthp = W2;  
    defparam mul_4.lpm_widths = W2;
    defparam mul_4.lpm_pipeline = Delay;
    defparam mul_4.lpm_representation = "SIGNED";


  assign  y_out  = y;    // Monitor some test signals
  assign  e_out  = e;
  assign  f0_out = f0;
  assign  f1_out = f1;

endmodule
