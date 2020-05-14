//*********************************************************
// IEEE STD 1364-1995 Verilog file: cordic.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module cordic (clk, x_in , y_in, r, phi, eps); 

  parameter W = 7;  // Bit width - 1
  input        clk;
  input  [W:0] x_in, y_in;
  output [W:0] r, phi, eps;
  reg    [W:0] r, phi, eps;

// There is no bit access in 2D array types 
// in Verilog, therefore use single vectors 
  reg [W:0] x0, y0, z0; 
  reg [W:0] x1, y1, z1; 
  reg [W:0] x2, y2, z2; 
  reg [W:0] x3, y3, z3; 
 
  always @(posedge clk) begin //----> Infer register
    if (x_in > 0)             // Test for x_in < 0 rotate
      begin                   // 0, +90, or -90 degrees
      x0 <= x_in; // Input in register 0
      y0 <= y_in;
      z0 <= 0;
      end
    else if (y_in > 0) 
      begin
      x0 <= y_in;
      y0 <= - x_in;
      z0 <= 90;
      end
    else
      begin
      x0 <= - y_in;
      y0 <= x_in;
      z0 <= -90;
      end

    if (y0 > 0)                 // Rotate 45 degrees
      begin
      x1 <= x0 + y0;
      y1 <= y0 - x0;
      z1 <= z0 + 45;
      end
    else
      begin
      x1 <= x0 - y0;
      y1 <= y0 + x0;
      z1 <= z0 - 45;
      end

    if (y1 > 0)                 // Rotate 26 degrees
      begin
      x2 <= x1 + {y1[W],y1[W:1]}; // i.e. x1 + y1 /2
      y2 <= y1 - {x1[W],x1[W:1]}; // i.e. y1 - x1 /2
      z2 <= z1 + 26;
      end
    else
      begin
      x2 <= x1 - {y1[W],y1[W:1]}; // i.e. x1 - y1 /2
      y2 <= y1 + {x1[W],x1[W:1]}; // i.e. y1 + x1 /2
      z2 <= z1 - 26;
      end

    if (y2 > 0)                        // Rotate 14 degrees
      begin
        x3 <= x2 + {y2[W],y2[W],y2[W:2]}; // i.e. x2 + y2/4
        y3 <= y2 - {x2[W],x2[W],x2[W:2]}; // i.e. y2 - x2/4
        z3 <= z2 + 14;
      end
    else
      begin
        x3 <= x2 - {y2[W],y2[W],y2[W:2]}; // i.e. x2 - y2/4
        y3 <= y2 + {x2[W],x2[W],x2[W:2]}; // i.e. y2 + x2/4
        z3 <= z2 - 14;
      end

    r   <= x3;
    phi <= z3;
    eps <= y3;
  end                

endmodule
