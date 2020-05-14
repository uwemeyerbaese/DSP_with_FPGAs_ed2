//*********************************************************
// IEEE STD 1364-1995 Verilog file: csa7.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
//      7 bit carry save adder with register

//`include "220model.v"

module csa7 (a, b, clock, s, c);

  input  [6:0] a, b;
  input       clock;
  output [6:0]    s;
  output          c;

  wire [6:0]    r;  // Result adder
  wire         cr;  // Carry register

  wire  clkena, ADD, ena, aset, sclr, sset, aload, sload, 
                clk, aclr, ovf1, cin1; // Auxiliary signals

  assign ena=1; assign aclr=0; assign aset=0; assign sclr=0; 
                                          // Default for FF
  assign sset=0; assign aload=0; assign sload=0; 
  assign clkena=0; assign cin1=0; assign aclr=0; 
  assign ADD=1; assign clk=0;            // Default for add

  lpm_add_sub add_1                  // Add a and b
  ( .result(r), .dataa(a), .datab(b), .cout(cr)); // Used 
//  .add_sub(ADD),.overflow(ovl1), .clken(clkena), 
//  .cin(cin1), .clock(clk), .aclr(aclr)); // Unused ports 
    defparam add_1.lpm_width = 7;
    defparam add_1.lpm_direction = "add";

  lpm_ff reg_1          // Save a+b
  ( .data(r), .q(s), .clock(clock));  // Used ports
//  .enable(ena), .aclr(aclr), .aset(aset), .sclr(sclr), 
//  .sset(sset), .aload(aload), .sload(sload)); // Unused 
    defparam reg_1.lpm_width = 7;

  lpm_ff reg_2          // Save carry
  ( .data(cr), .q(c), .clock(clock));  // Used ports
//  .enable(ena), .aclr(aclr), .aset(aset), .sclr(sclr), 
//  .sset(sset), .aload(aload), .sload(sload)); // Unused 
    defparam reg_2.lpm_width = 1;

endmodule
