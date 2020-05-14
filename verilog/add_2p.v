//*********************************************************
// IEEE STD 1364-1995 Verilog file: add_2p.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
// 22-bit adder with two pipeline stages
// uses four components: csa7.v; csa7cin.v; 
//                    add_ff8.v; add_ff8cin.v     

//`include "220model.v"
//`include "csa7.v"
//`include "csa7cin.v"
//`include "add_ff8.v"
//`include "add_ff8cin.v"

module add_2p (x, y, sum, clk);  
  parameter WIDTH   = 22, // Total bit width
            WIDTH1  = 7,  // Bit width of LSBs 
            WIDTH2  = 7,  // Bit width of middle s
            WIDTH12 = 14,  // Sum WIDTH1+WIDTH2
            WIDTH3  =  8;  // Bit width of MSBs

  input  [WIDTH-1:0] x,y;  // Inputs
  output [WIDTH-1:0] sum;  // Result
  input              clk;  // Clock

  reg  [WIDTH1-1:0] l1, l2; // LSBs of inputs
  wire [WIDTH1-1:0] q1, v1, s1; // LSBs of inputs
  reg  [WIDTH2-1:0] l3, l4; // Middle bits
  wire [WIDTH2-1:0] q2, h2, v2, s2; // Middle bits
  reg  [WIDTH3-1:0] l5, l6; // MSBs of input 
  wire [WIDTH3-1:0] q3, h3, v3, s3; // MSBs of input
  wire [WIDTH-1:0]  s;    // Output register
  wire cq1, cq2, cv2; // Carry signals
  wire ena, aset, sclr, sset, aload, sload, aclr; 
                                    // Auxiliary FF signals
  assign ena=1; assign aclr=0; assign aset=0; 
  assign sclr=0; assign sset=0; assign aload=0; 
  assign sload=0;                         // Default for FF

  // Split in MSBs and LSBs and store in registers
  always @(posedge clk) begin
    // Split LSBs from input x,y
    l1[WIDTH1-1:0] <= x[WIDTH1-1:0];
    l2[WIDTH1-1:0] <= y[WIDTH1-1:0];
    // Split middle bits from input x,y
    l3[WIDTH2-1:0] <= x[WIDTH2-1+WIDTH1:WIDTH1];
    l4[WIDTH2-1:0] <= y[WIDTH2-1+WIDTH1:WIDTH1];
    // Split MSBs from input x,y
    l5[WIDTH3-1:0] <= x[WIDTH3-1+WIDTH12:WIDTH12];
    l6[WIDTH3-1:0] <= y[WIDTH3-1+WIDTH12:WIDTH12];
  end
				
//************** First stage of the adder  ****************
  csa7 add_1       // Add LSBs of x and y
  ( .a(l1), .b(l2), .clock(clk), .s(q1), .c(cq1));

  csa7 add_2       // Add LSBs of x and y
  ( .a(l3), .b(l4), .clock(clk), .s(q2), .c(cq2) );

	add_ff8 add_3             // Add MSBs of x and y
	( .a(l5), .b(l6), .clock(clk), .s(q3));

//************* Second stage of the adder *****************
  // Two operands are zero
  assign h2 = {WIDTH2{1'b0}}; 
  assign h3 = {WIDTH3{1'b0}}; 

  lpm_ff reg_1                  // Save q1
  ( .data(q1), .q(v1), .clock(clk));  // Used ports
//    .enable(ena), .aclr(aclr), .aset(aset), .sclr(sclr),
//    .sset(sset), .aload(aload), .sload(sload)); // Unused
  defparam reg_1.lpm_width = WIDTH1;

// Add result of middle bits (x+y) and carry from LSBs 
  csa7cin add_4 
  (.a(q2), .b(h2), .cin(cq1), .clock(clk), .s(v2),.c(cv2));

// Add result of MSBs bits (x+y) and carry from middle 
  add_ff8cin add_5 
  ( .a(q3), .b(h3), .cin(cq2), .clock(clk), .s(v3));

//************* Third stage of the adder ******************
  lpm_ff reg_2                  // Save v1
  ( .data(v1), .q(s1), .clock(clk));  // Used ports
//  .enable(ena), .aclr(aclr), .aset(aset), .sclr(sclr), 
//  .sset(sset), .aload(aload), .sload(sload)); // Unused 
    defparam reg_2.lpm_width = WIDTH1;

  lpm_ff reg_3                  // Save v2
  ( .data(v2), .q(s2), .clock(clk));  // Used ports
//  .enable(ena), .aclr(aclr), .aset(aset), .sclr(sclr), 
//  .sset(sset), .aload(aload), .sload(sload)); // Unused
    defparam reg_3.lpm_width = WIDTH1;

// Add result of MSBs bits (x+y) and 2. carry from middle
  add_ff8cin add_6 
  ( .a(v3), .b(h3), .cin(cv2), .clock(clk), .s(s3));

// Build a single output word of WIDTH=WIDTH1+WIDTH2+WIDTH3
  assign s ={s3[WIDTH3-1:0],s2[WIDTH2-1:0],s1[WIDTH1-1:0]};

  assign sum = s;    // Connect s to output pins

endmodule
