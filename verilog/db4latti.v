//*********************************************************
// IEEE STD 1364-1995 Verilog file: db4latti.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module db4latti (clk, x_in, clk2, x_e, x_o, g, h); 

  input          clk;
  output         clk2;
  input  [7:0]  x_in;
  output [16:0]  x_e, x_o;
  output [8:0]   g, h;
  reg    [8:0]   g, h;

  reg  [7:0]  x_wait;
  wire [16:0] x_wait_sxt, x_in_sxt;
  reg  [16:0] sx_up, sx_low;
  wire [24:0] sx_up_sxt, sx_low_sxt;
  reg  clk_div2;
  wire [16:0] sxa0_up, sxa0_low;
  wire [16:0] up0, up1, low1;
  reg  [16:0] low0;
  wire [24:0] up0_sxt, low0_sxt;

  assign x_in_sxt = {{9{x_in[7]}},x_in};
  assign x_wait_sxt = {{9{x_wait[7]}},x_wait};

  always @(posedge clk)    // Split into even and odd
  begin : Multiplex        // samples at clk rate 
    parameter even=0, odd=1;
    reg [0:0] state;
    case (state) 
      even : begin
        // Multiply with 256*s=124
        sx_up   <= (x_in_sxt << 7) - (x_in_sxt << 2);
        sx_low  <= (x_wait_sxt << 7) - (x_wait_sxt << 2);
        clk_div2 <= 1;
        state <= odd;
      end
      odd : begin
        x_wait <= x_in;
        clk_div2 <= 0;
        state <= even;
      end
    endcase  
  end
  
//******** Multipy a[0] = 1.7321
  assign sx_up_sxt = {{8{sx_up[16]}},sx_up}; 
  assign sx_low_sxt = {{8{sx_low[16]}},sx_low}; 
                                    // i.e. sign extensions
// Compute: (2*sx_up  - sx_up /4)-(sx_up /64 + sx_up /256)
  assign sxa0_up  = ((sx_up_sxt << 1)  - (sx_up_sxt >> 2))
                  - ((sx_up_sxt >> 6) + (sx_up_sxt >> 8)); 
// Compute: (2*sx_low - sx_low/4)-(sx_low/64 + sx_low/256)
  assign sxa0_low = ((sx_low_sxt << 1) - (sx_low_sxt >> 2))
                 - ((sx_low_sxt >> 6) + (sx_low_sxt >> 8));
//******** First stage -- FF in lower tree
  assign up0 = sxa0_low + sx_up;
  always @(negedge clk_div2)
  begin: LowerTreeFF
      low0 <= sx_low - sxa0_up;         
  end

//******** Second stage: a[1]=0.2679
// Compute:   (up0 - low0/4) - (low0/64 + low0/256);
  assign up0_sxt = {{8{up0[16]}},up0};
  assign low0_sxt = {{8{low0[16]}},low0};
  assign up1  = (up0_sxt - (low0_sxt >> 2)) 
                 - ((low0_sxt >> 6) + (low0_sxt >> 8));
// Compute: (low0 + up0/4) + (up0/64  +  up0/256)
  assign low1 = (low0_sxt + (up0_sxt >> 2)) 
                       + ((up0_sxt >> 6) + (up0_sxt >> 8));

  assign x_e  = sx_up;       // Provide some extra 
  assign x_o  = sx_low;      // test signals 
  assign clk2 = clk_div2;

  always @(negedge clk_div2)
  begin: OutputScale
    g <= up1[16:8];      // i.e. up1 / 256
    h <= low1[16:8];     // i.e. low1 / 256;
  end

endmodule

