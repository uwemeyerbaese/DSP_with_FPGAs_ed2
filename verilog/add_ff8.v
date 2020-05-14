//*********************************************************
// IEEE STD 1364-1995 Verilog file: add_ff8.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
//`include "220model.v"

module add_ff8 (a, b, clock, s);

  input [7:0] a, b;
  input       clock;
  output [7:0]    s;

  wire [7:0 ] r	;  // Result adder

  wire  clkena, ADD, ena, aset, sclr, sset, aload, sload, 
                 clk, aclr, ovf1, cin1; // Auxiliary signals

  assign ena=1; assign aclr=0; assign aset=0; 
  assign sclr=0;                          // Default for FF
  assign sset=0; assign aload=0; assign sload=0; 
  assign clkena=0; assign cin1=0; assign aclr=0; 
  assign ADD=1; assign clk=0;            // Default for add

  lpm_add_sub add_1                  // Add a and b
  ( .result(r), .dataa(a), .datab(b)); // Used ports
//  .cout(cr1), .add_sub(ADD), .overflow(ovl1), .cin(cin1),
//  .clken(clkena),.clock(clk), .aclr(aclr)); // Unused 
    defparam add_1.lpm_width = 8;
    defparam add_1.lpm_direction = "add";

  lpm_ff reg_1          // Save a+b
  ( .data(r), .q(s), .clock(clock));  // Used ports
//  .enable(ena), .aclr(aclr), .aset(aset), .sclr(sclr), 
//  .sset(sset), .aload(aload), .sload(sload)); // Unused
    defparam reg_1.lpm_width = 8;

endmodule
