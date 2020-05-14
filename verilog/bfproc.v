//*********************************************************
// IEEE STD 1364-1995 Verilog file: bfproc.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
//`include "220model.v"
//`include "ccmul.v"

module bfproc (clk, Are_in, Aim_in, Bre_in, Bim_in, c_in, 
       cps_in, cms_in, Dre_out, Dim_out, Ere_out, Eim_out);

  parameter W2 = 17,   // Multiplier bit width
            W1 = 9,    // Bit width c+s sum
            W  = 8;    // Input bit width 
  input clk;  // Clock for the output register
  input [W-1:0] Are_in, Aim_in;        // 8-bit inputs
  input [W-1:0] Bre_in, Bim_in, c_in;  // 8-bit inputs
  input [W1-1:0]  cps_in, cms_in;  // 9-bit coefficients
  output [W-1:0]  Dre_out, Dim_out, Ere_out, Eim_out;  
  reg    [W-1:0]  Dre_out, Dim_out;  // 8-bit registered 
                                     // results 
  reg  [W-1:0] dif_re, dif_im;      // Bf out
  reg  [W-1:0] Are, Aim, Bre, Bim;  // Inputs as integers
  reg  [W-1:0] c;                   // Input
  reg  [W1-1:0] cps, cms;           // Coefficient in
            
  always @(posedge clk)   // Compute the additions of the 
  begin                   // butterfly using integers 
    Are     <= Are_in;    // and store inputs
    Aim     <= Aim_in;    // in flip-flops 
    Bre     <= Bre_in;
    Bim     <= Bim_in;
    c       <= c_in;            // Load from memory cos
    cps     <= cps_in;          // Load from memory cos+sin
    cms     <= cms_in;          // Load from memory cos-sin
    Dre_out <= ({Are[W-1],Are} + {Bre[W-1],Bre}) >> 1;
                                      // i.e. Are/2 + Bre/2
    Dim_out <= ({Aim[W-1],Aim} + {Bim[W-1],Bim}) >> 1;
  end                                 // i.e. Aim/2 + Bim/2
   
     // No FF because butterfly difference "diff" is not an
  always @(Are or Bre or Aim or Bim)         // output port
  begin 
    dif_re = ({Are[W-1],Are} - {Bre[W-1],Bre}) >> 1;
                                      // i.e. Are/2 - Bre/2
    dif_im = ({Aim[W-1],Aim} - {Bim[W-1],Bim}) >> 1; 
  end                                 // i.e. Aim/2 - Bim/2
  
  //*** Instantiate the complex twiddle factor multiplier
  ccmul ccmul_1                    // Multiply (x+jy)(c+js)
  ( .clk(clk), .x_in(dif_re), .y_in(dif_im),  .c_in(c), 
    .cps_in(cps), .cms_in(cms), .r_out(Ere_out), 
                                          .i_out(Eim_out));
                      
endmodule
