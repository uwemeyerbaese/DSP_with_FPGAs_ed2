//*********************************************************
// IEEE STD 1364-1995 Verilog file: rader7.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module rader7 (clk, x_in, y_real, y_imag); //---> Interface

  input         clk;
  input  [7:0]  x_in;
  output [10:0] y_real, y_imag;
  reg    [10:0] y_real, y_imag;

  reg [10:0]  accu;                      // Signal for X[0]
  // Note: No direct bit access of 2D vector in Verilog
  // use auxiliary signal for this purpose
  reg [18:0]  imag0, imag1, imag2, imag3, imag4, imag5, 
              real0, real1, real2, real3, real4, real5;  
                                 // Tapped delay line array
  reg [18:0]  x57, x111, x160, x200, x231, x250 ; 
                                 // The filter coefficients
  reg [18:0]  x5, x25, x110, x125, x256; 
                           // Auxiliary filter coefficients
  reg [7:0]   x, x_0;                   // Signals for x[0]
  wire [18:0] x_sxt, x_0_sxt;

  assign x_sxt = {{9{x[7]}},x}; // Sign extension of input
  assign x_0_sxt = {{9{x_0[7]}},x_0};          // and x[0]

  always @(posedge clk)  // State machine for RADER filter
  begin : States
    parameter Start=0, Load=1, Run=2;
    reg [1:0] state;
    reg [4:0] count;
    case (state) 
      Start : begin        // Initialization step 
        state <= Load;
        count <= 1;
        x_0 <= x_in;       // Save x[0]
        accu <= 0 ;        // Reset accumulator for X[0]
        y_real  <= 0;
        y_imag  <= 0;
      end
      Load : begin   // Apply x[5],x[4],x[6],x[2],x[3],x[1]
        if (count == 8)     // Load phase done ?
          state <= Run;
        else begin
          state <= Load;
          accu <= accu + x_sxt;
        end
        count <= count + 1;
      end
      Run : begin   // Apply again x[5],x[4],x[6],x[2],x[3]
        if (count == 15) begin // Run phase done ?
          y_real  <= accu;       // X[0]
          y_imag  <= 0;  // Only re inputs i.e. Im(X[0])=0
          state <= Start;      // Output of result 
        end                    // and start again 
        else begin
          y_real  <= (real0 >> 8) + x_0_sxt; 
                                  // i.e. real[0]/256+x[0]
          y_imag  <= (imag0 >> 8);     // i.e. imag[0]/256
          state <= Run;
        end
        count <= count + 1;
      end
    endcase  
  end

  always @(posedge clk)    // Structure of the two FIR
  begin : Structure        // filters in transposed form
    x <= x_in;
    // Real part of FIR filter in transposed form
    real0 <= real1 + x160  ;   // W^1
    real1 <= real2 - x231  ;   // W^3
    real2 <= real3 - x57   ;   // W^2
    real3 <= real4 + x160  ;   // W^6
    real4 <= real5 - x231  ;   // W^4
    real5 <= -x57;             // W^5
    
    // Imaginary part of FIR filter in transposed form
    imag0 <= imag1 - x200  ;   // W^1
    imag1 <= imag2 - x111  ;   // W^3
    imag2 <= imag3 - x250  ;   // W^2
    imag3 <= imag4 + x200  ;   // W^6
    imag4 <= imag5 + x111  ;   // W^4
    imag5 <= x250;             // W^5
  end

  always @(posedge clk)
  begin : Coeffs //Note that all signals are globally defined
  // Compute the filter coefficients and use FFs
    x160   <= x5 << 5;        // i.e. 160 = 5 * 32;
    x200   <= x25 << 3;       // i.e. 200 = 25 * 8;
    x250   <= x125 << 1;      // i.e. 250 = 125 * 2;
    x57    <= x25 + (x << 5); // i.e. 57 = 25 + 32;
    x111   <= x110 + x;       // i.e. 111 = 110 + 1;
    x231   <= x256 - x25;     // i.e. 231 = 256 - 25;
  end

  always  @(x_sxt or x5 or x25)    // Note that all signals
  begin : Factors                  // are globally defined 
  // Compute the auxiliary factor for RAG without an FF
    x5     = (x_sxt << 2) + x_sxt;  // i.e. 5 = 4 + 1;
    x25    = (x5 << 2) + x5;        // i.e. 25 = 5*4 + 5;
    x110   = (x25 << 2) + (x5 << 2);// i.e. 110 = 25*4+5*4;
    x125   = (x25 << 2) + x25;      // i.e. 125 = 25*4+25;
    x256   = x_sxt << 8;            // i.e. 256 = 2 ** 8;  
  end

endmodule
