//*********************************************************
// IEEE STD 1364-1995 Verilog file: cic3s32.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module cic3s32 (clk, x_in, clk2, y_out); //----> Interface

  input        clk;
  input  [7:0] x_in;
  output [9:0] y_out;
  output clk2;
  reg  clk2;

  parameter hold=0, sample=1;
  reg [1:0] state;
  reg [4:0]  count;
  reg  [7:0]  x;                     // Registered input
  wire [25:0] sxtx;                  // Sign extended input
  reg  [25:0] i0;                    // I section 0
  reg  [20:0] i1;                    // I section 1
  reg  [15:0] i2;                    // I section 2
  reg  [13:0] i2d1, i2d2, i2d3, i2d4, c1, c0; // I + COMB 0
  reg  [12:0] c1d1, c1d2, c1d3, c1d4, c2; // COMB section 1
  reg  [11:0] c2d1, c2d2, c2d3, c2d4, c3; // COMB section 2
      
  always @(posedge clk)
  begin : FSM
    if (count == 31) begin
        count <= 0;
        state <= sample;
        clk2  <= 1; 
      end
    else begin
        count <= count + 1;
        state <= hold;
        clk2  <= 0;
      end
  end

  assign sxtx = {{18{x[7]}},x};

  always @(posedge clk) 
  begin : Int
      x   <= x_in;
      i0  <= i0 + sxtx;        
      i1  <= i1 + i0[25:5];        
      i2  <= i2 + i1[20:5];  
  end

  always @(posedge clk) 
  begin : Comb
    if (state == sample) begin
      c0   <= i2[15:2];
      i2d1 <= c0;
      i2d2 <= i2d1;
      c1   <= c0 - i2d2;
      c1d1 <= c1[13:1];
      c1d2 <= c1d1;
      c2   <= c1[13:1] - c1d2;
      c2d1 <= c2[12:1];
      c2d2 <= c2d1;
      c3   <= c2[12:1] - c2d2;
    end
  end

  assign y_out = c3[11:2];

endmodule

