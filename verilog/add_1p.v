//*********************************************************
// IEEE STD 1364-1995 Verilog file: add_1p.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
//`include "220model.v"

module add_1p (x, y, sum, clk);  
  parameter WIDTH   = 15, // Total bit width
            WIDTH1  = 7,  // Bit width of LSBs 
            WIDTH2  = 8;  // Bit width of MSBs

  input  [WIDTH-1:0] x,y;  // Inputs
  output [WIDTH-1:0] sum;  // Result
  input              clk;  // Clock

  reg  [WIDTH1-1:0] l1, l2; // LSBs of inputs
  wire [WIDTH1-1:0] q1, r1; // LSBs of inputs
  reg  [WIDTH2-1:0] l3, l4; // MSBs of input
  wire [WIDTH2-1:0] r2, q2, u2; // MSBs of input
  reg  [WIDTH-1:0]  s;    // Output register
  wire cr1,cq1; // LSBs carry signal
  wire [WIDTH2-1:0] h2; // Auxiliary MSBs of input
     
  wire  clkena, ADD, ena, aset, sclr;  // Auxiliary signals
  wire sset, aload, sload, aclr, ovf1, cin1; 

// Default for add:
  assign cin1=0; assign aclr=0; assign ADD=1; 

  assign ena=1; assign aclr=0;            // Default for FF
  assign sclr=0; assign sset=0; assign aload=0; 
  assign sload=0; assign clkena=0; assign aset=0;

  // Split in MSBs and LSBs and store in registers
  always @(posedge clk) begin
    // Split LSBs from input x,y
    l1[WIDTH1-1:0] <= x[WIDTH1-1:0];
    l2[WIDTH1-1:0] <= y[WIDTH1-1:0];
    // Split MSBs from input x,y
    l3[WIDTH2-1:0] <= x[WIDTH2-1+WIDTH1:WIDTH1];
    l4[WIDTH2-1:0] <= y[WIDTH2-1+WIDTH1:WIDTH1];
  end
/************* First stage of the adder  *****************/
  lpm_add_sub add_1                  // Add LSBs of x and y
  ( .result(r1), .dataa(l1), .datab(l2), .cout(cr1)); 
                                              // Used ports
//  .overflow(ovl1), .clken(clkena), .add_sub(ADD),
//  .cin(cin1), .clock(clk), .aclr(aclr)); // Unused ports
    defparam add_1.lpm_width = WIDTH1;
    defparam add_1.lpm_direction = "add";

  lpm_ff reg_1                          // Save LSBs of x+y
  ( .data(r1), .q(q1), .clock(clk));          // Used ports
//  .enable(ena), .aclr(aclr), .aset(aset), .sclr(sclr), 
//  .sset(sset), .aload(aload), .sload(sload)); // Unused 
    defparam reg_1.lpm_width = WIDTH1;

  lpm_ff reg_2       // Save LSBs carry
  ( .data(cr1), .q(cq1), .clock(clk));        // Used ports
//  .enable(ena), .aclr(aclr), .aset(aset), .sclr(sclr), 
//  .sset(sset), .aload(aload), .sload(sload)); // Unused 
    defparam reg_2.lpm_width = 1;

  lpm_add_sub add_2                   // Add MSBs of x and y
  ( .dataa(l3), .datab(l4), .result(r2)     ); // Used ports
//  .add_sub(ADD), .cout(cout1), .cin(cin1), .clken(clkena),
//  .overflow(ovl1),  .clock(clk), .aclr(aclr)); // Unused 
   defparam add_2.lpm_width = WIDTH2;
   defparam add_2.lpm_direction = "add";

 lpm_ff reg_3                           // Save MSBs of x+y
 ( .data(r2), .q(q2), .clock(clk));           // Used ports
// .enable(ena), .aclr(aclr), .aset(aset), .sclr(sclr), 
// .sset(sset), .aload(aload), .sload(sload)); // Unused
    defparam reg_3.lpm_width = WIDTH2;


/************** Second stage of the adder ****************/
// One operand is zero
  assign h2 = {WIDTH2{1'b0}}; 

  lpm_add_sub add_3   // Add MSBs (x+y) and carry from LSBs
  ( .cin(cq1), .dataa(q2), .datab(h2), .result(u2)); 
                                              // Used ports
//  .cout(cout1), .overflow(ovl1), .clken(clkena),// Unused
//  .add_sub(ADD), .clock(clk), .aclr(aclr));     // ports
    defparam add_3.lpm_width = WIDTH2;
    defparam add_3.lpm_direction = "add";

  always @(posedge clk) begin  // Build a single registered
    s = {u2[WIDTH2-1:0],q1[WIDTH1-1:0]};     // output word 
  end                             // of WIDTH=WIDTH1+WIDTH2

  assign sum = s ;    // Connect s to output pins

endmodule
