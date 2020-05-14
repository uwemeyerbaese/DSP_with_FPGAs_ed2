//*********************************************************
// IEEE STD 1364-1995 Verilog file: fir_lms.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
// This is a generic FIR filter generator 
// It uses W1 bit data/coefficients bits
module fir_lms 
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
  reg  [W1-1:0] x, x0, x1, f0, f1; // Coefficient array 
  reg  [W1-1:0] d;
  wire [W1-1:0] emu;
  wire [W2-1:0] p0, p1, xemu0, xemu1; // Product array
  wire  [W2-1:0]  y, sxty, e, sxtd; 

  wire  clken, aclr;
  wire  [W2-1:0] sum;  // Auxilary signals


  assign sum=0; assign aclr=0; // Default for mult
  assign clken=0;

  
  // 16 bit signed extension for input d
  assign  sxtd = {{8{d[7]}}, d};

  always @(posedge clk) // Store these data or coefficients
    begin: Store
      d <= d_in; // Store desired signal in register 
      x0 <= x_in; // Get one data sample at a time 
      x1 <= x0;   // shift 1
      f0 <= f0 + xemu0[15:8]; // implicit divide by 2
      f1 <= f1 + xemu1[15:8]; 
  end

// Instantiate L pipelined multiplier
// Multiply p(i) = f(i) * x(i);

  lpm_mult mul_0            // Multiply  x0*f0 = p0  
    ( .dataa(x0), .datab(f0), .result(p0)); 
//   .clock(clk), .sum(sum),
//   .clken(clken), .aclr(aclr)); // Unused ports
    defparam mul_0.lpm_widtha = W1;  
    defparam mul_0.lpm_widthb = W1;
    defparam mul_0.lpm_widthp = W2;  
    defparam mul_0.lpm_widths = W2;
//    defparam mul_0.lpm_pipeline = Delay;
    defparam mul_0.lpm_representation = "SIGNED";

  lpm_mult mul_1            // Multiply  x1*f1 = p1  
    ( .dataa(x1), .datab(f1), .result(p1)); 
//   .clock(clk), .sum(sum),
//   .clken(clken), .aclr(aclr)); // Unused ports
    defparam mul_1.lpm_widtha = W1;  
    defparam mul_1.lpm_widthb = W1;
    defparam mul_1.lpm_widthp = W2;  
    defparam mul_1.lpm_widths = W2;
//    defparam mul_1.lpm_pipeline = Delay;
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
    ( .dataa(x0), .datab(emu), .result(xemu0)); 
//   .clock(clk), .sum(sum),
//   .clken(clken), .aclr(aclr)); // Unused ports
    defparam mul_3.lpm_widtha = W1;  
    defparam mul_3.lpm_widthb = W1;
    defparam mul_3.lpm_widthp = W2;  
    defparam mul_3.lpm_widths = W2;
//    defparam mul_3.lpm_pipeline = Delay;
    defparam mul_3.lpm_representation = "SIGNED";

  lpm_mult mul_4            // Multiply xemu1 = emu * x1;  
    ( .dataa(x1), .datab(emu), .result(xemu1)); 
//   .clock(clk), .sum(sum),
//   .clken(clken), .aclr(aclr)); // Unused ports
    defparam mul_4.lpm_widtha = W1;  
    defparam mul_4.lpm_widthb = W1;
    defparam mul_4.lpm_widthp = W2;  
    defparam mul_4.lpm_widths = W2;
//    defparam mul_4.lpm_pipeline = Delay;
    defparam mul_4.lpm_representation = "SIGNED";


  assign  y_out  = y;    // Monitor some test signals
  assign  e_out  = e;
  assign  f0_out = f0;
  assign  f1_out = f1;

endmodule
