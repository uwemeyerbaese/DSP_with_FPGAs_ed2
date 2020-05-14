//*********************************************************
// IEEE STD 1364-1995 Verilog file: add_3p.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
// 29-bit adder with three pipeline stage
// uses four components: csa7.v; csa7cin.v; 
//               add_ff8.v; add_ff8cin.v     

//`include "220model.v"
//`include "csa7.v"
//`include "csa7cin.v"
//`include "add_ff8.v"
//`include "add_ff8cin.v"

module add_3p (x, y, sum, clk);  
  parameter WIDTH    = 29, // Total bit width
            WIDTH0   = 7,  // Bit width of LSBs 
            WIDTH1   = 7,  // Bit width of 2. LSBs 
            WIDTH01  = 14, // Sum WIDTH0+WIDTH1
            WIDTH2   = 7,  // Bit width of 2. MSBs
            WIDTH012 = 21,  // Sum WIDTH0+WIDTH1+WIDTH2
            WIDTH3   =  8;  // Bit width of MSBs

  input  [WIDTH-1:0] x,y;  // Inputs
  output [WIDTH-1:0] sum;  // Result
  input              clk;  // Clock

  reg  [WIDTH0-1:0] l0, l1; // LSBs of inputs
  wire [WIDTH0-1:0] q0, v0, r0, s0; // LSBs of inputs
  reg  [WIDTH1-1:0] l2, l3; // 2. LSBs of input
  wire [WIDTH1-1:0] q1, v1, r1, s1; // 2. LSBs of input
  reg  [WIDTH2-1:0] l4, l5; // 2. MSBs bits 
  wire [WIDTH2-1:0] q2, v2, r2, s2, h7; // 2. MSBs bits
  reg  [WIDTH3-1:0] l6, l7; // MSBs of input 
  wire [WIDTH3-1:0] q3, v3, r3, s3, h8; // MSBs of input
  wire [WIDTH-1:0]  s;    // Output register
  wire cq0, cq1, cq2, cv1, cv2, cr2; // Carry signals
  wire ena, aset, sclr, sset, aload, sload, aclr; 
                                    // Auxiliary FF signals

  assign ena=1; assign aclr=0; assign aset=0; 
  assign sclr=0; assign sset=0; assign aload=0; 
  assign sload=0;                         // Default for FF

// Split in MSBs and LSBs and store in registers
always @(posedge clk) begin
  // Split LSBs from input x,y
  l0[WIDTH0-1:0] <= x[WIDTH0-1:0];
  l1[WIDTH0-1:0] <= y[WIDTH0-1:0];
  // Split 2. LSBs from input x,y
  l2[WIDTH1-1:0] <= x[WIDTH1-1+WIDTH0:WIDTH0];
  l3[WIDTH1-1:0] <= y[WIDTH1-1+WIDTH0:WIDTH0];
  // Split 2. MSBs from input x,y
  l4[WIDTH2-1:0] <= x[WIDTH2-1+WIDTH01:WIDTH01];
  l5[WIDTH2-1:0] <= y[WIDTH2-1+WIDTH01:WIDTH01];
  // Split MSBs from input x,y
  l6[WIDTH3-1:0] <= x[WIDTH3-1+WIDTH012:WIDTH012];
  l7[WIDTH3-1:0] <= y[WIDTH3-1+WIDTH012:WIDTH012];
end

//************* First stage of the adder  *****************
  csa7 add_0                  // Add LSBs of x and y
  ( .a(l0), .b(l1), .clock(clk), .s(q0), .c(cq0));
  csa7 add_1                  // Add 2. LSBs of x and y
  ( .a(l2), .b(l3), .clock(clk), .s(q1), .c(cq1) );
  csa7 add_2                  // Add 2. MSBs of x and y
  ( .a(l4), .b(l5), .clock(clk), .s(q2), .c(cq2) );
  add_ff8 add_3              // Add MSBs of x and y
  ( .a(l6), .b(l7), .clock(clk), .s(q3) );

//************* Second stage of the adder *****************
  // Two operands are zero
  assign h7 = {WIDTH2{1'b0}}; 
  assign h8 = {WIDTH3{1'b0}}; 

  lpm_ff reg_1                  // Save q0
  ( .data(q0), .q(v0), .clock(clk));  // Used ports
//  .enable(ena), .aclr(aclr), .aset(aset), .sclr(sclr), 
//  .sset(sset), .aload(aload), .sload(sload)); // Unused
    defparam reg_1.lpm_width = WIDTH0;

// Add result of 2. LSBs (x+y) and carry from LSBs
  csa7cin add_4 
  (.a(q1), .b(h7), .cin(cq0), .clock(clk), .s(v1),.c(cv1));

// Add result of 2. MSBs (x+y) and carry from 2. LSBs
  csa7cin add_5    
 (.a(q2), .b(h7), .cin(cq1), .clock(clk), .s(v2), .c(cv2));

// Add result of MSBs (x+y) and carry from 2. MSBs 
  add_ff8cin add_6 
  ( .a(q3), .b(h8), .cin(cq2), .clock(clk), .s(v3));

//************** Third stage of the adder *****************
lpm_ff reg_2                  // Save v0
( .data(v0), .q(r0), .clock(clk));  // Used ports
//  .enable(ena), .aclr(aclr), .aset(aset), .sclr(sclr), 
//  .sset(sset), .aload(aload), .sload(sload)); // Unused
    defparam reg_2.lpm_width = WIDTH0;

  lpm_ff reg_3                  // Save v1
  ( .data(v1), .q(r1), .clock(clk));  // Used ports
//  .enable(ena), .aclr(aclr), .aset(aset), .sclr(sclr), 
//  .sset(sset), .aload(aload), .sload(sload)); // Unused
    defparam reg_3.lpm_width = WIDTH1;

// Add result of 2. MSBs (x+y) and carry from 2. LSBs
csa7cin add_7 
( .a(v2), .b(h7), .cin(cv1), .clock(clk), .s(r2), .c(cr2));

// Add result of MSBs (x+y) and carry from 2. MSBs 
add_ff8cin add_8 
( .a(v3), .b(h8), .cin(cv2), .clock(clk), .s(r3) );

//************ Fourth stage of the adder ******************
  lpm_ff reg_4                  // Save r0
  ( .data(r0), .q(s0), .clock(clk)); // Used ports
//  .enable(ena), .aclr(aclr), .aset(aset), .sclr(sclr), 
//  .sset(sset), .aload(aload), .sload(sload)); //Unused 
    defparam reg_4.lpm_width = WIDTH0;

  lpm_ff reg_5                  // Save r1
  ( .data(r1), .q(s1), .clock(clk));  // Used ports
//  .enable(ena), .aclr(aclr), .aset(aset), .sclr(sclr), 
//  .sset(sset), .aload(aload), .sload(sload)); //Unused 
    defparam reg_5.lpm_width = WIDTH1;

  lpm_ff reg_6                  // Save r2
  ( .data(r2), .q(s2), .clock(clk));  // Used ports
//  .enable(ena), .aclr(aclr), .aset(aset), .sclr(sclr), 
//  .sset(sset), .aload(aload), .sload(sload)); //Unused
    defparam reg_6.lpm_width = WIDTH2;

// Add result of MSBs (x+y) and carry from 2. MSBs 
add_ff8cin add_9 
( .a(r3), .b(h8), .cin(cr2), .clock(clk), .s(s3));

// Build a single output word of 
// WIDTH = WIDTH0 + WIDTH1 + WIDTH2 + WIDTH3
assign s = {s3[WIDTH3-1:0], s2[WIDTH2-1:0],
                            s1[WIDTH1-1:0],s0[WIDTH0-1:0]};

assign sum = s ;    // Connect s to output pins

endmodule
