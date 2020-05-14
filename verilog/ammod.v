//*********************************************************
// IEEE STD 1364-1995 Verilog file: ammod.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module ammod (clk, r_in , phi_in, 
                   x_out, y_out, eps); //----> Interface

  parameter W = 8;  // Bit width - 1
  input        clk;
  input  [W:0] r_in, phi_in;
  output [W:0] x_out, y_out, eps;
  reg    [W:0] x_out, y_out, eps;
  reg    [W:0] r, phi;

  reg [W:0] x0, y0, z0; // There is no bit access in 2D 
  reg [W:0] x1, y1, z1; // array types in Verilog, 
  reg [W:0] x2, y2, z2; // therefore use single vectors 
  reg [W:0] x3, y3, z3; 

  always @(posedge clk) begin //----> Infer register
    if (phi_in > 90)           // Test for |phi_in| > 90
      begin                    // Rotate 90 degrees 
      x0 <= 0;                 
      y0 <= r_in;              // Input in register 0
      z0 <= phi_in -'d90;
      end
    else if ((phi_in > 331) && (phi_in < 423))
      begin
      x0 <= 0;
      y0 <= - r_in;
      z0 <= phi_in + 'd90;
      end
    else
      begin
      x0 <= r_in;
      y0 <= 0;
      z0 <= phi_in;
     end

    if (z0 > 0)                  // Rotate 45 degrees
      begin
      x1 <= x0 - y0;
      y1 <= y0 + x0;
      z1 <= z0 - 'd45;
      end
    else
      begin
      x1 <= x0 + y0;
      y1 <= y0 - x0;
      z1 <= z0 + 'd45;
      end

    if (z1 > 0)                 // Rotate 26 degrees
      begin
      x2 <= x1 - {y1[W],y1[W:1]}; // i.e. x1 - y1 /2
      y2 <= y1 + {x1[W],x1[W:1]}; // i.e. y1 + x1 /2
      z2 <= z1 - 'd26;
      end
    else
      begin
      x2 <= x1 + {y1[W],y1[W:1]}; // i.e. x1 + y1 /2
      y2 <= y1 - {x1[W],x1[W:1]}; // i.e. y1 - x1 /2
      z2 <= z1 + 'd26;
      end

    if (z2 > 0)                        // Rotate 14 degrees
      begin
        x3 <= x2 - {y2[W],y2[W],y2[W:2]}; // i.e. x2 - y2/4
        y3 <= y2 + {x2[W],x2[W],x2[W:2]}; // i.e. y2 + x2/4
        z3 <= z2 - 'd14;
      end
    else
      begin
        x3 <= x2 + {y2[W],y2[W],y2[W:2]}; // i.e. x2 + y2/4
        y3 <= y2 - {x2[W],x2[W],x2[W:2]}; // i.e. y2 - x2/4
        z3 <= z2 + 'd14;
      end

    x_out <= x3;
    eps   <= z3;
    y_out <= y3;
  end                

endmodule

