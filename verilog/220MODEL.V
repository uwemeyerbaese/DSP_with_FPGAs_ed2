//------------------------------------------------------------------------
//   This Verilog file was developed by Altera Corporation.  It may be freely
// copied and/or distributed at no cost.  Any persons using this file for
// any purpose do so at their own risk, and are responsible for the results
// of such use.  Altera Corporation does not guarantee that this file is
// complete, correct, or fit for any particular purpose.  NO WARRANTY OF
// ANY KIND IS EXPRESSED OR IMPLIED.  This notice must accompany any copy
// of this file.
//------------------------------------------------------------------------
//
//------------------------------------------------------------------------
// LPM Synthesizable Models 
//------------------------------------------------------------------------
// Version 1.3 (lpm 220)  Date 06/23/99
//
// Corrected LPM_FIFO and LPM_FIFO_DC cout and empty/full flags.
// Implemented LPM_COUNTER cin/cout, and LPM_MODULUS is now working.
//
//------------------------------------------------------------------------
// Version 1.2 (lpm 220)  Date 06/16/99
//
// Added LPM_RAM_DP, LPM_RAM_DQ, LPM_IO, LPM_ROM, LPM_FIFO, LPM_FIFO_DC.
// Parameters and ports are added/discarded according to the spec.
//
//------------------------------------------------------------------------
// Version 1.1 (lpm 220)  Date 02/05/99
//
// Added LPM_DIVIDE module.
//
//------------------------------------------------------------------------
// Version 1.0    Date 07/09/97
//
//------------------------------------------------------------------------
// Excluded Functions:
//
//  LPM_FSM and LPM_TTABLE.
//
//------------------------------------------------------------------------
// Assumptions:
//
// 1. LPM_SVALUE, LPM_AVALUE, LPM_MODULUS, and LPM_NUMWORDS,
//    LPM_STRENGTH, LPM_DIRECTION, and LPM_PVALUE  default value is
//    string UNUSED.
//
//------------------------------------------------------------------------
// Verilog Language Issues:
//
// Two dimensional ports are not supported. Modules with two dimensional
// ports are implemented as one dimensional signal of (LPM_SIZE * LPM_WIDTH)
// bits wide.
//
//------------------------------------------------------------------------
// Synthesis Issues:
// 
// 1. LPM_COUNTER 
//
// Currently synthesis tools do not allow mixing of level and edge
// sensetive signals. To overcome that problem the "data" signal is
// removed from the clock always block of lpm_counter, however the
// synthesis result is accurate. For correct simulation add the "data"
// pin to the sensetivity list as follows:
//
//  always @( posedge clock or posedge aclr or posedge aset or 
//      posedge aload  or data)
//------------------------------------------------------------------------
// Modification History:
//
//------------------------------------------------------------------------

module lpm_constant ( result ) ;

  parameter lpm_type = "lpm_constant" ;
  parameter lpm_width = 1 ;
  parameter lpm_cvalue = 0 ;
  parameter lpm_strength = "UNUSED";
  parameter lpm_hint = "UNUSED" ;

  output [lpm_width-1:0] result ;

  assign result = lpm_cvalue ;

endmodule // lpm_constant

//------------------------------------------------------------------------

module lpm_inv ( result, data ) ;

  parameter lpm_type = "lpm_inv" ;
  parameter lpm_width = 1 ;
  parameter lpm_hint = "UNUSED" ;

  input  [lpm_width-1:0] data ;
  output [lpm_width-1:0] result ;

  reg    [lpm_width-1:0] result ;

  always @(data)
	begin
	  result = ~data ;
	end

endmodule // lpm_inv

//------------------------------------------------------------------------

module lpm_and ( result, data ) ;

  parameter lpm_type = "lpm_and" ;
  parameter lpm_width = 1 ;
  parameter lpm_size = 1 ;
  parameter lpm_hint = "UNUSED" ;

  input  [(lpm_size * lpm_width)-1:0] data;
  output [lpm_width-1:0] result ;

  reg    [lpm_width-1:0] result ;
  integer i, j, k;

  always @(data)
	begin
	for ( i=0; i<lpm_width; i=i+1)
	begin
		result[i] = data[i];
		for ( j=1; j<lpm_size; j=j+1)
		begin
			k = j * lpm_width + i;
			result[i] = result[i] & data[k];
		end
	end
	end

endmodule // lpm_and

//------------------------------------------------------------------------

module lpm_or ( result, data ) ;

  parameter lpm_type = "lpm_and" ;
  parameter lpm_width = 1 ;
  parameter lpm_size = 1 ;
  parameter lpm_hint  = "UNUSED" ;

  input  [(lpm_size * lpm_width)-1:0] data;
  output [lpm_width-1:0] result ;

  reg    [lpm_width-1:0] result ;
  integer i, j, k;

  always @(data)
	begin
	for ( i=0; i<lpm_width; i=i+1)
	begin
		result[i] = data[i];
		for ( j=1; j<lpm_size; j=j+1)
		begin
			k = j * lpm_width + i;
			result[i] = result[i] | data[k];
		end
	end
	end

endmodule // lpm_or

//------------------------------------------------------------------------

module lpm_xor ( result, data ) ;

  parameter lpm_type = "lpm_xor" ;
  parameter lpm_width = 1 ;
  parameter lpm_size = 1 ;
  parameter lpm_hint  = "UNUSED" ;

  input  [(lpm_size * lpm_width)-1:0] data;
  output [lpm_width-1:0] result ;

  reg    [lpm_width-1:0] result ;
  integer i, j, k;

  always @(data)
	begin
	for ( i=0; i<lpm_width; i=i+1)
	begin
		result[i] = data[i];
		for ( j=1; j<lpm_size; j=j+1)
		begin
			k = j * lpm_width + i;
			result[i] = result[i] ^ data[k];
		end
	end
	end

endmodule // lpm_xor

//------------------------------------------------------------------------

module lpm_bustri ( result, tridata, data, enabledt, enabletr ) ;

  parameter lpm_type = "lpm_bustri" ;
  parameter lpm_width = 1 ;
  parameter lpm_hint = "UNUSED" ;

  input  [lpm_width-1:0] data ;
  input  enabletr ;
  input  enabledt ;
  output [lpm_width-1:0] result ;
  inout  [lpm_width-1:0] tridata ;

  reg    [lpm_width-1:0] result ;
  reg  [lpm_width-1:0] tmp_tridata ;

  always @(data or tridata or enabletr or enabledt)
	begin
	if (enabledt == 0 && enabletr == 1)
	   begin
		result = tridata;
		tmp_tridata = 'bz;
	   end
		else
	if (enabledt == 1 && enabletr == 0)
		begin
		result = 'bz;
		tmp_tridata = data;
		end
	else
	if (enabledt == 1 && enabletr == 1)
		begin
		result = data;
		tmp_tridata = data;
		end
	else
		begin
		result = 'bz;
		tmp_tridata = 'bz;
		end
	end

  assign tridata = tmp_tridata;

endmodule // lpm_bustri

//------------------------------------------------------------------------

module lpm_mux ( result, clock, clken, data, aclr, sel ) ;

  parameter lpm_type = "lpm_mux" ;
  parameter lpm_width =1 ;
  parameter lpm_size =1 ;
  parameter lpm_widths = 1;
  parameter lpm_pipeline = 0;
  parameter lpm_hint  = "UNUSED" ;

  input  [(lpm_size * lpm_width)-1:0] data;
  input aclr;
  input clock;
  input clken;
  input [lpm_widths-1:0] sel;
  output [lpm_width-1:0] result ;

  integer i, j, m, n;
  reg   [lpm_width-1:0] tmp_result;
  reg   [lpm_width-1:0] tmp_result2 [lpm_pipeline:0];

  always @(data or sel)
	begin
	tmp_result = 0;
	for (m=0; m<lpm_width; m=m+1)
	begin
		n = sel * lpm_width + m;
		tmp_result[m] = data[n];
	end
	end

	always @(posedge clock or posedge aclr)
	begin
		if (aclr)
			begin
				for(i = 0; i <= lpm_pipeline; i = i + 1)
						tmp_result2[i] = 'b0 ;
			end
		else if (clken == 1)
		begin
			tmp_result2[lpm_pipeline] = tmp_result ;
			for(j = 0; j < lpm_pipeline; j = j +1)
					tmp_result2[j] = tmp_result2[j+1] ;
		end
	  end

  assign result = (lpm_pipeline > 0) ? tmp_result2[0] : tmp_result;
endmodule // lpm_mux

//------------------------------------------------------------------------

module lpm_decode ( eq, data, enable, clock, clken, aclr) ;

  parameter lpm_type = "lpm_decode" ;
  parameter lpm_width = 1 ;
  parameter lpm_decodes = 1 << lpm_width ;
  parameter lpm_pipeline = 0 ;
  parameter lpm_hint = "UNUSED" ;

  input  [lpm_width-1:0] data ;
  input  enable ;
  input  clock ;
  input  clken;
  input  aclr ;
  output [lpm_decodes-1:0] eq ;

  reg    [lpm_decodes-1:0] tmp_eq2 [lpm_pipeline:0] ;
  reg    [lpm_decodes-1:0] tmp_eq;
  integer i, j;


  always @( data or enable)
	begin
	tmp_eq = 0;
	if (enable)
			begin
				if( (data < lpm_decodes))
					begin
						tmp_eq[data] = 1'b1 ;
					end else
			tmp_eq = 0;
		end
	end
 
	always @(posedge clock or posedge aclr)
	begin
		if (aclr)
			begin 
				for(i = 0; i <= lpm_pipeline; i = i + 1)
					tmp_eq2[i] = 'b0 ;
			end
	else if (clken == 1) 
	begin
		tmp_eq2[lpm_pipeline] = tmp_eq ;
		for(j = 0; j < lpm_pipeline; j = j +1)
			tmp_eq2[j] = tmp_eq2[j+1] ;
	end
	  end

  assign eq = (lpm_pipeline > 0) ? tmp_eq2[0] : tmp_eq;

endmodule // lpm_decode

//------------------------------------------------------------------------

module lpm_clshift ( result, overflow,
		underflow, data,
		direction, distance) ;

  parameter lpm_type        = "lpm_clshift" ;
  parameter lpm_width       = 1 ;
  parameter lpm_widthdist   = 1 ;
  parameter lpm_shifttype   = "LOGICAL" ;
  parameter lpm_hint = "UNUSED" ;

  input  [lpm_width-1:0] data ;
  input  [lpm_widthdist-1:0] distance ;
  input  direction ;
  output [lpm_width-1:0] result;
  output overflow ;
  output underflow;

  reg    [lpm_width-1:0] ONES ;
  reg    [lpm_width-1:0] result ;
  reg    overflow, underflow;
  integer i;

//---------------------------------------------------------------//
  function [lpm_width+1:0] LogicShift ;
	input [lpm_width-1:0] data ;
	input [lpm_widthdist-1:0] dist ;
	input direction ;
	reg   [lpm_width-1:0] tmp_buf ;
	reg   overflow, underflow ;
	
	begin
	  tmp_buf = data ;
	  overflow = 1'b0 ;
	  underflow = 1'b0 ;
	  if((direction) && (dist > 0)) // shift right
		begin
			tmp_buf = data >> dist ;
			if((data != 0 ) && ((dist >= lpm_width) || (tmp_buf == 0) ))
				underflow = 1'b1;
		end
	  else if (dist > 0) // shift left
		begin
			tmp_buf = data << dist ;
			if((data != 0) && ((dist >= lpm_width)
				|| ((data >> (lpm_width-dist)) != 0)))
				overflow = 1'b1;
		end
	  LogicShift = {overflow,underflow,tmp_buf[lpm_width-1:0]} ;
	end
  endfunction

//---------------------------------------------------------------//
  function [lpm_width+1:0] ArithShift ;
	input [lpm_width-1:0] data ;
	input [lpm_widthdist-1:0] dist ;
	input direction ;
	reg   [lpm_width-1:0] tmp_buf ;
	reg   overflow, underflow ;
	begin
	  tmp_buf = data ;
	  overflow = 1'b0 ;
	  underflow = 1'b0 ;

	  if(direction && (dist > 0))   // shift right
		begin
			if(data[lpm_width-1] == 0) // positive number
			  begin
				tmp_buf = data >> dist ;
				if((data != 0) && ((dist >= lpm_width) || (tmp_buf == 0)))
					underflow = 1'b1 ;
			  end
			else // negative number
			  begin
				tmp_buf = (data >> dist) | (ONES << (lpm_width - dist)) ;
				if((data != ONES) && ((dist >= lpm_width-1) || (tmp_buf == ONES)))
					underflow = 1'b1 ;
			  end
		end
	  else if(dist > 0) // shift left
		begin
			tmp_buf = data << dist ;
			if(data[lpm_width-1] == 0) // positive number
			  begin
				if((data != 0) && ((dist >= lpm_width-1) 
				|| ((data >> (lpm_width-dist-1)) != 0)))
					overflow = 1'b1;
			  end
			else // negative number
			  begin
				if((data != ONES) 
				&& ((dist >= lpm_width) 
				 ||(((data >> (lpm_width-dist-1))|(ONES << (dist+1))) != ONES)))
					overflow = 1'b1;
			  end
		end
	  ArithShift = {overflow,underflow,tmp_buf[lpm_width-1:0]} ;
	end
  endfunction

//---------------------------------------------------------------//
  function [lpm_width-1:0] RotateShift ;
	input [lpm_width-1:0] data ;
	input [lpm_widthdist-1:0] dist ;
	input direction ;
	reg   [lpm_width-1:0] tmp_buf ;
	begin
	  tmp_buf = data ;
	  if((direction) && (dist > 0)) // shift right
		begin
			tmp_buf = (data >> dist) | (data << (lpm_width - dist)) ;
		end
	  else if (dist > 0) // shift left
		begin
			tmp_buf = (data << dist) | (data >> (lpm_width - dist)) ;
		end
	  RotateShift = tmp_buf[lpm_width-1:0] ;
	end
  endfunction
//---------------------------------------------------------------//

  initial
  begin
	for(i=0; i < lpm_width; i=i+1)
			ONES[i] = 1'b1 ;
  end

  always @(data or direction or distance)
	begin
		  // lpm_shifttype is optional and default to LOGICAL
		if ((lpm_shifttype == "LOGICAL") )
		  begin
				  {overflow,underflow,result} = LogicShift(data,distance,direction);
		  end
		else if (lpm_shifttype == "ARITHMETIC")
		  begin
					{overflow,underflow,result} = ArithShift(data,distance,direction);
		  end
		else if (lpm_shifttype == "ROTATE")
		  begin
					result = RotateShift(data, distance, direction) ;
			overflow = 1'b0;
			underflow = 1'b0;
		  end
		else
		  begin
					result = 'bx ;
			overflow = 1'b0;
			underflow = 1'b0;
		  end
 
	end

endmodule // lpm_clshift

//------------------------------------------------------------------------

module lpm_add_sub (  result, cout, overflow,
		add_sub, cin, dataa, datab, clock, clken, aclr ) ;

  parameter lpm_type = "lpm_add_sub" ;
  parameter lpm_width = 1 ;
  parameter lpm_direction  = "UNUSED" ;
  parameter lpm_representation = "UNSIGNED" ;
  parameter lpm_pipeline = 0 ;
  parameter lpm_hint = "UNUSED" ;

  input  [lpm_width-1:0] dataa, datab ;
  input  add_sub, cin ;
  input  clock ;
  input  clken;
  input  aclr ;
  output [lpm_width-1:0] result ;
  output cout, overflow ;

  reg  [lpm_width-1:0] tmp_result ;
  reg  [lpm_width-1:0] tmp_result2 [lpm_pipeline:0] ;
  reg  [lpm_pipeline:0] tmp_cout2 ;
  reg  [lpm_pipeline:0] tmp_overflow2 ;
  reg  tmp_cout ;
  reg  tmp_overflow ;
  reg  [lpm_width-2:0] tmp_a, tmp_b;
  integer i, j, k, n;
  integer dataa_int, datab_int, result_int, compare, borrow; 


  always @(  cin or dataa or datab or add_sub )
	begin

	begin
		borrow = cin?0:1 ;
		// cout is the same for both signed and unsign representation.  
		if (lpm_direction == "ADD" || add_sub == 1) 
				begin
						{tmp_cout,tmp_result} = dataa + datab + cin ;
						tmp_overflow = tmp_cout ;
				end
				else
		if (lpm_direction == "SUB" || add_sub == 0) 
				begin
						// subtraction
						{tmp_overflow, tmp_result} = dataa - datab - borrow ;
						tmp_cout = (dataa >= (datab+borrow))?1:0 ;
				end
	
		if(lpm_representation == "SIGNED")
		begin
			// convert to negative integer
			if(dataa[lpm_width-1] == 1)
			begin
				for(j = 0; j < lpm_width - 1; j = j + 1)
					tmp_a[j] = dataa[j] ^ 1;
				dataa_int = (tmp_a + 1) * (-1) ;
			end
			else dataa_int = dataa;

			// convert to negative integer
			if(datab[lpm_width-1] == 1)
			begin
				for(k = 0; k < lpm_width - 1; k = k + 1)
					tmp_b[k] = datab[k] ^ 1;
				datab_int = (tmp_b + 1) * (-1);
			end
			else datab_int = datab;

			// perform the addtion or subtraction operation
			if(lpm_direction == "ADD" || add_sub == 1)
				result_int = dataa_int + datab_int + cin ;
			else
			if(lpm_direction == "SUB" || add_sub == 0)
				result_int = dataa_int - datab_int - borrow ;
			tmp_result = result_int ;

			// set the overflow
			compare = 1 << (lpm_width -1);
			if((result_int > (compare - 1)) || (result_int < (-1)*(compare)))
				tmp_overflow = 1;
			else
				tmp_overflow = 0;
		end

	end
	end

  always @(posedge clock or posedge aclr )
	begin
		if(aclr)
		begin
		for(i = 0; i <= lpm_pipeline; i = i + 1)
		begin
			tmp_result2[i] = 'b0 ;
			tmp_cout2[i] = 1'b0 ;
			tmp_overflow2[i] = 1'b0 ;
		end
		end
	else if (clken == 1) begin
		tmp_result2[lpm_pipeline] = tmp_result ;
		tmp_cout2[lpm_pipeline] = tmp_cout ;
		tmp_overflow2[lpm_pipeline] = tmp_overflow ;
		for(n = 0; n < lpm_pipeline; n = n +1)
		begin
			tmp_result2[n] = tmp_result2[n+1] ;
			tmp_cout2[n] = tmp_cout2[n+1];
			tmp_overflow2[n] = tmp_overflow2[n+1];
		end
		end
	end


  assign result = (lpm_pipeline >0) ? tmp_result2[0]:tmp_result ;
  assign cout = (lpm_pipeline >0) ? tmp_cout2[0]  : tmp_cout;
  assign overflow = (lpm_pipeline >0) ? tmp_overflow2[0] : tmp_overflow ;

endmodule // lpm_add_sub

//------------------------------------------------------------------------

module lpm_compare (  alb, aeb, agb, aleb, aneb, ageb, dataa, datab, clock, clken, aclr ) ;

  parameter lpm_type = "lpm_compare" ;
  parameter lpm_width = 1 ;
  parameter lpm_representation = "UNSIGNED" ;
  parameter lpm_pipeline = 0 ;
  parameter lpm_hint = "UNUSED" ;

  input  [lpm_width-1:0] dataa, datab ;
  input  clock ;
  input  clken;
  input  aclr ;
  output alb, aeb, agb, aleb, aneb, ageb ;

  reg    tmp_alb, tmp_aeb, tmp_agb ;
  reg    tmp_aleb, tmp_aneb, tmp_ageb ;
  reg    [lpm_pipeline:0] tmp_alb2, tmp_aeb2, tmp_agb2 ;
  reg    [lpm_pipeline:0] tmp_aleb2, tmp_aneb2, tmp_ageb2 ;
  reg    [lpm_width-1:0] a_int;
  integer i, j, k, l, m, n, o, p, u, dataa_int, datab_int;

  always @( dataa or datab)
	begin
		if (lpm_representation == "UNSIGNED") 
				begin
			dataa_int = dataa[lpm_width-1:0];
			datab_int = datab[lpm_width-1:0];
				end
		else
		if (lpm_representation == "SIGNED")
			begin
			if ( dataa[lpm_width-1] == 1)
				begin
				a_int = 0;
				for(i = 0; i < lpm_width - 1; i = i + 1)
							a_int[i] = dataa[i] ^ 1;
				dataa_int = (a_int + 1) * (-1) ;
			end
			else dataa_int = dataa[lpm_width-1:0];

			if ( datab[lpm_width-1] == 1)
				begin
				a_int = 0;
				for(j = 0; j < lpm_width - 1; j = j + 1)
							a_int[j] = datab[j] ^ 1;
				datab_int = (a_int + 1) * (-1) ;
			end
			else datab_int = datab[lpm_width-1:0];
			end

		tmp_alb = (dataa_int < datab_int);
		tmp_aeb = (dataa_int == datab_int);
		tmp_agb = (dataa_int > datab_int);
		tmp_aleb = (dataa_int <= datab_int);
		tmp_aneb = (dataa_int != datab_int);
		tmp_ageb = (dataa_int >= datab_int);
	end

  always @( posedge clock or posedge aclr)
	begin
		if (aclr)
			begin 
			for(u = 0; u <= lpm_pipeline; u = u +1)
		begin
					tmp_aeb2[u] = 'b0 ;
					tmp_agb2[u] = 'b0 ;
					tmp_alb2[u] = 'b0 ;
					tmp_aleb2[u] = 'b0 ;
					tmp_aneb2[u] = 'b0 ;
					tmp_ageb2[u] = 'b0 ;
		end
			end
	else if (clken == 1)
		begin
				// Assign results to registers
				tmp_alb2[lpm_pipeline] = tmp_alb ;
				tmp_aeb2[lpm_pipeline] = tmp_aeb ;
				tmp_agb2[lpm_pipeline] = tmp_agb ;
				tmp_aleb2[lpm_pipeline] = tmp_aleb ;
				tmp_aneb2[lpm_pipeline] = tmp_aneb ;
				tmp_ageb2[lpm_pipeline] = tmp_ageb ;

			for(k = 0; k < lpm_pipeline; k = k +1)
					tmp_alb2[k] = tmp_alb2[k+1] ;
			for(l = 0; l < lpm_pipeline; l = l +1)
					tmp_aeb2[l] = tmp_aeb2[l+1] ;
			for(m = 0; m < lpm_pipeline; m = m +1)
					tmp_agb2[m] = tmp_agb2[m+1] ;
			for(n = 0; n < lpm_pipeline; n = n +1)
					tmp_aleb2[n] = tmp_aleb2[n+1] ;
			for(o = 0; o < lpm_pipeline; o = o +1)
					tmp_aneb2[o] = tmp_aneb2[o+1] ;
			for(p = 0; p < lpm_pipeline; p = p +1)
					tmp_ageb2[p] = tmp_ageb2[p+1] ;
	end
	end

  assign alb = (lpm_pipeline > 0) ? tmp_alb2[0] : tmp_alb;
  assign aeb = (lpm_pipeline > 0) ? tmp_aeb2[0] : tmp_aeb;
  assign agb = (lpm_pipeline > 0) ? tmp_agb2[0] : tmp_agb;
  assign aleb = (lpm_pipeline > 0) ? tmp_aleb2[0] : tmp_aleb;
  assign aneb = (lpm_pipeline > 0) ? tmp_aneb2[0] : tmp_aneb;
  assign ageb = (lpm_pipeline > 0) ? tmp_ageb2[0] : tmp_ageb;

endmodule // lpm_compare

//------------------------------------------------------------------------

module lpm_mult ( result, dataa, datab, sum, clock, clken, aclr ) ;

  parameter lpm_type       = "lpm_mult" ;
  parameter lpm_widtha     = 1 ;
  parameter lpm_widthb     = 1 ;
  parameter lpm_widths     = 1 ;
  parameter lpm_widthp     = 2 ;
  parameter lpm_representation  = "UNSIGNED" ;
  parameter lpm_pipeline   = 0 ;
  parameter lpm_hint = "UNUSED" ;

  input  clock ;
  input  clken ;
  input  aclr ;
  input  [lpm_widtha-1:0] dataa ;
  input  [lpm_widthb-1:0] datab ;
  input  [lpm_widths-1:0] sum ;
  output [lpm_widthp-1:0] result;

  // inernal reg
  reg   [lpm_widthp-1:0] tmp_result ;
  reg   [lpm_widthp-1:0] tmp_result2 [lpm_pipeline:0];
  reg   [lpm_widtha-2:0] a_int ;
  reg   [lpm_widthb-2:0] b_int ;
  reg   [lpm_widths-2:0] s_int ;
  reg   [lpm_widthp-2:0] p_reg ;
  integer p_int;
  integer i, j, k, m, n, p, maxs_mn ;
  integer int_dataa, int_datab, int_sum, int_result ;


  always @( dataa or datab or sum)
	begin
		if (lpm_representation == "UNSIGNED")
			begin
				int_dataa = dataa ;
				int_datab = datab ;
				int_sum = sum ;
			end
		else 
			if (lpm_representation == "SIGNED")
				begin
					// convert signed dataa
					if(dataa[lpm_widtha-1] == 1)
						begin
							int_dataa = 0 ;
							for(i = 0; i < lpm_widtha - 1; i = i + 1)
								a_int[i] = dataa[i] ^ 1;
							int_dataa = (a_int + 1) * (-1) ;
						end
					else int_dataa = dataa ;

					// convert signed datab
					if(datab[lpm_widthb-1] == 1)
						begin
							int_datab = 0 ;
							for(j = 0; j < lpm_widthb - 1; j = j + 1)
								b_int[j] = datab[j] ^ 1;
							int_datab = (b_int + 1) * (-1) ;
						end
					else int_datab = datab ;

					// convert signed sum
					if(sum[lpm_widths-1] == 1)
						begin
							int_sum = 0 ;
							for(k = 0; k < lpm_widths - 1; k = k + 1)
								s_int[k] = sum[k] ^ 1;
							int_sum = (s_int + 1) * (-1) ;
						end
					else int_sum = sum ;
				end
			else 
				begin
					int_dataa = {lpm_widtha{1'bx}} ;
					int_datab = {lpm_widthb{1'bx}} ;
					int_sum   = {lpm_widths{1'bx}} ;
				end

		p_int = int_dataa * int_datab + int_sum ;
		maxs_mn = ((lpm_widtha+lpm_widthb)>lpm_widths)?lpm_widtha+lpm_widthb:lpm_widths ;
		if(lpm_widthp >= maxs_mn)
			tmp_result = p_int ;
		else
			begin
				p_reg = p_int;
				for(m = 0; m < lpm_widthp; m = m +1)
					tmp_result[lpm_widthp-1-m] = p_reg[maxs_mn-1-m] ;
			end 
	end

	always @(posedge clock or posedge aclr)
	begin
	  if(aclr)
		begin
			for(p = 0; p <= lpm_pipeline; p = p + 1)
				tmp_result2[p] = 'b0;
		end
	  else if (clken == 1)
	  begin :syn_block
		tmp_result2[lpm_pipeline] = tmp_result ;
		for(n = 0; n < lpm_pipeline; n = n +1)
			tmp_result2[n] = tmp_result2[n+1] ;
	  end
	end

  assign result = (lpm_pipeline > 0) ? tmp_result2[0] : tmp_result ;

endmodule // lpm_mult

//------------------------------------------------------------------------

module lpm_divide ( quotient,remain, numer, denom, clock, clken, aclr ) ;

  parameter lpm_type       = "lpm_divide" ;
  parameter lpm_widthn     = 1 ;
  parameter lpm_widthd     = 1 ;
  //parameter lpm_widthq     = 1 ;
  //parameter lpm_widthr     = 1 ;
  parameter lpm_nrepresentation    = "UNSIGNED" ;
  parameter lpm_drepresentation    = "UNSIGNED" ;
  parameter lpm_pipeline   = 0 ;

  input  clock ;
  input  clken ;
  input  aclr ;
  input  [lpm_widthn-1:0] numer ;
  input  [lpm_widthd-1:0] denom ;
  output [lpm_widthn-1:0] quotient;
  output [lpm_widthd-1:0] remain;

  // inernal reg
  reg   [lpm_widthn-1:0] tmp_quotient [lpm_pipeline:0];
  reg   [lpm_widthd-1:0] tmp_remain [lpm_pipeline:0];
  reg   [lpm_widthn-1:0] ONES, ZEROS, UNKNOWN, HiZ ;
  reg   [lpm_widthd-1:0] DZEROS, DUNKNOWN ;
  reg   [lpm_widthn-1:0] NUNKNOWN ;
  reg   [lpm_widthd-1:0] RZEROS  ;
  integer i;
  integer int_numer, int_denom, int_quotient, int_remain ;

  initial
  begin


	// check if lpm_widthn > 0
	if(lpm_widthn <= 0)
		$display("%t: Error! LPM_WIDTHN must be greater than 0.\n", $time);
	// check if lpm_widthd > 0
	if(lpm_widthd <= 0)
		$display("%t: Error! LPM_WIDTHD must be greater than 0.\n", $time);
	// check if lpm_widthn > 0
	  //if(lpm_widthq <= 0)
	  //    $display("%t: Error! LPM_WIDTHQ must be greater than 0.\n", $time);
	// check if lpm_widthR > 0
	  //if(lpm_widthr <= 0)
	  //    $display("%t: Error! LPM_WIDTHR must be greater than 0.\n", $time);
	// check for valid lpm_nrep value
	if((lpm_nrepresentation !== "SIGNED") && (lpm_nrepresentation !== "UNSIGNED"))
		$display("%t: Error! LPM_NREPRESENTATION value must be \"SIGNED\" or \"UNSIGNED\".", $time);

	// check for valid lpm_drep value
	if((lpm_drepresentation !== "SIGNED") && (lpm_drepresentation !== "UNSIGNED"))
		$display("%t: Error! LPM_DREPRESENTATION value must be \"SIGNED\" or \"UNSIGNED\".", $time);

		// check if lpm_pipeline is > 1 and clock is not used
		if((lpm_pipeline >=1 ) && (clock === 1'bz) )
				$display("%t: Error! The clock pin is requied if lpm_pipeline is used\n", $time) ;
	else if((lpm_pipeline == 0 ) && (clock !== 1'bz) )
		$display("%t: Error! If the clock pin is used, lpm_pipeline must be greater than 0.\n", $time) ;
	
	for(i=0; i < lpm_widthn; i=i+1)
	  begin
			ONES[i] = 1'b1 ;
			ZEROS[i] = 1'b0 ;
			UNKNOWN[i] = 1'bx ;
			HiZ[i] = 1'bz ;
	  end

	for(i=0; i < lpm_widthd; i=i+1)
			DUNKNOWN[i] = 1'bx ;

	for(i=0; i < lpm_widthn; i=i+1)
			NUNKNOWN[i] = 1'bx ;

		for(i=0; i < lpm_widthd; i=i+1)
			RZEROS[i] = 1'b0 ;

  end

  always @(numer or denom)
		begin
			if (lpm_nrepresentation == "UNSIGNED")
					int_numer = numer ;
			else if (lpm_nrepresentation == "SIGNED")
				begin
				// convert signed numer
				if(numer[lpm_widthn-1] == 1)
				begin
					int_numer = 0 ;
					for(i = 0; i < lpm_widthn - 1; i = i + 1)
						int_numer[i] = numer[i] ^ 1;
					int_numer = -(int_numer + 1) ;
				end
				else int_numer = numer ;
			end
				else 
			int_numer = NUNKNOWN ;

		if (lpm_drepresentation == "UNSIGNED")
										int_denom = denom ;
		else if (lpm_drepresentation == "SIGNED")
						begin
				// convert signed denom
				if(denom[lpm_widthd-1] == 1)
				begin
					int_denom = 0 ;
					for(i = 0; i < lpm_widthd - 1; i = i + 1)
						int_denom[i] = denom[i] ^ 1;
					int_denom = -(int_denom + 1) ;
				end
				else int_denom = denom ;
			end
			else 
			int_denom = DUNKNOWN ;

		int_quotient = int_numer / int_denom ;
		int_remain = int_numer % int_denom ;

		tmp_quotient[lpm_pipeline] = int_quotient ;
		tmp_remain[lpm_pipeline] = int_remain ;
	end

	always @(posedge clock or aclr)
	begin :syn_block
			if(aclr)
		begin
			disable syn_block ;
			for(i = 0; i <= lpm_pipeline; i = i + 1)
				tmp_quotient[i] = ZEROS;
				tmp_remain[i] = RZEROS;
		end
		else
				   if (clken)
		   for(i = 0; i < lpm_pipeline; i = i +1)
		   begin
			tmp_quotient[i] = tmp_quotient[i+1] ;
			tmp_remain[i] = tmp_remain[i+1] ;
		   end
	end

  assign quotient = tmp_quotient[0] ;
  assign remain = tmp_remain[0] ;

endmodule // lpm_divide

//------------------------------------------------------------------------

module lpm_abs ( result, overflow, data ) ;

	parameter lpm_type = "lpm_abs" ;
	parameter lpm_width = 1 ;
	parameter lpm_hint = "UNUSED" ;

	input  [lpm_width-1:0] data ;
	output [lpm_width-1:0] result ;
	output overflow ;

	reg    [lpm_width-1:0] a_int ;
	reg    [lpm_width-1:0] result ;
	reg    overflow;
	integer i;

	always @(data)
		begin

			overflow = 0;
			if (data[lpm_width-1] == 1)
				begin
					a_int = 0;
					for(i = 0; i < lpm_width - 1; i = i + 1)
						a_int[i] = data[i] ^ 1;
					result = (a_int + 1);
					overflow = (result == ( 1<<(lpm_width -1)));
				end
			else
				result = data;
		end

endmodule // lpm_abs

//------------------------------------------------------------------------

module lpm_counter ( q, //eq, 
		data, clock, cin, cout,
		clk_en, cnt_en, updown,
		aset, aclr, aload, 
		sset, sclr, sload) ;

  parameter lpm_type = "lpm_counter";
  parameter lpm_width = 1 ;
  parameter lpm_modulus = 0 ;
  parameter lpm_direction = "UNUSED" ;
  parameter lpm_avalue = "UNUSED" ;
  parameter lpm_svalue = "UNUSED" ;
  parameter lpm_pvalue = "UNUSED" ;
  parameter lpm_hint = "UNUSED" ;

  output [lpm_width-1:0] q ;
  //output [lpm_modulus-1:0] eq ;
  output cout ;
  input  cin ;
  input  [lpm_width-1:0] data ;
  input  clock, clk_en, cnt_en, updown ;
  input  aset, aclr, aload ;
  input  sset, sclr, sload ;

  reg  [lpm_width-1:0] tmp_count ;
  reg  tmp_updown ;
  integer tmp_modulus ;

//---------------------------------------------------------------//
  function [lpm_width-1:0] NextBin ;
	input [lpm_width-1:0] count ;

	//reg  [lpm_width-1:0] re_start ;
	//reg  [lpm_width-1:0] tmp_nextbin ;
	//integer up_limit ;
	begin 
		if(tmp_updown == 1)
		begin
			if(cin == 1 && count == tmp_modulus-2)
				NextBin = 0 ;
			else
				NextBin = (count >= tmp_modulus-1) ? cin : count+1+cin;
		end
		else
		begin
			if(cin == 1 && count == 1)
				NextBin = tmp_modulus - 1 ;
			else
				NextBin = (count <= 0) ? tmp_modulus-1-cin : count-1-cin;
		end
	end 
  endfunction

//---------------------------------------------------------------//
//  function [(1<<lpm_width)-1:0] CountDecode ;
//---------------------------------------------------------------//
//  function [lpm_modulus:0] CountDecode ;
//    input [lpm_width-1:0] count ;
//    integer eq_index ;
//    begin
//      CountDecode = 0 ;
//      eq_index = 0;
//      if(count < lpm_modulus)
//      begin
//          eq_index = count ;
//          CountDecode[eq_index] = 1'b1 ;
//      end
//    end
//  endfunction

//---------------------------------------------------------------//
//  function integer str_to_int ;
//---------------------------------------------------------------//
  function integer str_to_int ;
	input  [8*16:1] s; 

	reg [8*16:1] reg_s;
	reg [8:1] digit;
	reg [8:1] tmp;
	integer m, ivalue;
	begin
		ivalue = 0;
		reg_s = s;
		for (m=1; m<=16; m=m+1)
		begin 
			tmp = reg_s[128:121];
			digit = tmp & 8'b00001111;
			reg_s = reg_s << 8; 
			ivalue = ivalue * 10 + digit; 
		end
		str_to_int = ivalue;
	end
  endfunction

//---------------------------------------------------------------//

  initial
  begin
	// check if lpm_modulus < 0
	if(lpm_modulus < 0)
		$display("%t: Error! LPM_MODULUS must be greater than 0.\n", $time);
	// check if lpm_modulus > 1<<lpm_width
	if(lpm_modulus > 1<<lpm_width)
		$display("%t: Error! LPM_MODULUS must be less than or equal to 1<<LPM_WIDTH.\n", $time);

	if(lpm_direction == "UNUSED")
		tmp_updown = (updown == 0) ? 0 : 1 ;
	else
		tmp_updown = (lpm_direction == "DOWN") ? 0 : 1 ;

	tmp_modulus = (lpm_modulus == 0) ? (1 << lpm_width) : lpm_modulus ;
	tmp_count = (lpm_pvalue == "UNUSED") ? 0 : str_to_int(lpm_pvalue) ;
  end

  always @( updown )
  begin
	if(lpm_direction == "UNUSED")
		tmp_updown = (updown == 0) ? 0 : 1 ;
	else
		$display("%t: Error! LPM_DIRECTION and UPDOWN cannot be used at the same time.\n", $time);
  end

  always @( posedge clock or posedge aclr or posedge aset or 
			posedge aload  )
  begin :asyn_block
	if (aclr)
		tmp_count = 0 ;
	else if (aset)
		tmp_count = (lpm_avalue == "UNUSED") ? {lpm_width{1'b1}}
											 : str_to_int(lpm_avalue) ;
	else if (aload)
		tmp_count = data ;
	else
	begin :syn_block
		if(clk_en)
		begin
			if (sclr)
				tmp_count = 0 ;
			else if (sset)
				tmp_count = (lpm_svalue == "UNUSED") ? {lpm_width{1'b1}}
													 : str_to_int(lpm_svalue) ;
			else if (sload)
				tmp_count = data ;
			else if (cnt_en)
				tmp_count = NextBin(tmp_count) ;
		end
	end
  end 

  assign q =  tmp_count ;
  //assign eq = CountDecode(tmp_count) ;
  assign cout = (((tmp_count >= tmp_modulus-1-cin) && tmp_updown)
				|| ((tmp_count <= cin) && !tmp_updown)) ? 1 : 0 ;


endmodule // lpm_counter

//------------------------------------------------------------------------

module lpm_latch ( q, data, gate, aset, aclr );

  parameter lpm_type = "lpm_latch" ;
  parameter lpm_width = 1 ;
  parameter lpm_avalue = "UNUSED" ;
  parameter lpm_pvalue = "UNUSED" ;
  parameter lpm_hint = "UNUSED" ;

  input  [lpm_width-1:0] data ;
  input  gate, aset, aclr ;
  output [lpm_width-1:0] q ;

  reg [lpm_width-1:0] q ;

//---------------------------------------------------------------//
//  function integer str_to_int ;
//---------------------------------------------------------------//
  function integer str_to_int ;
	input  [8*16:1] s; 
	reg [8*16:1] reg_s;
	reg [8:1]   digit ;
	reg [8:1] tmp;
	integer   m , ivalue ; 
	begin 
  
	ivalue = 0;
	reg_s = s;
		for (m=1; m<=16; m= m+1 ) 
		begin 
		tmp = reg_s[128:121];
		digit = tmp & 8'b00001111;
		reg_s = reg_s << 8; 
				ivalue = ivalue * 10 + digit; 
		end
	str_to_int = ivalue;
	end
  endfunction
//---------------------------------------------------------------//

  always @(data or gate or aclr or aset)
	begin
	if (aclr)
		q = 'b0;
	else if (aset)
		begin
		if (lpm_avalue == "UNUSED")
			q = {lpm_width{1'b1}};
		else    
			q = str_to_int(lpm_avalue);
		end
	else if (gate)
		q = data;
	
	end

endmodule // lpm_latch

//------------------------------------------------------------------------

module lpm_ff ( q,
		data, clock, enable,
		aclr, aset,
		sclr, sset,
		aload, sload) ;

  parameter lpm_type = "lpm_ff" ;
  parameter lpm_width  = 1 ;
  parameter lpm_avalue = "UNUSED" ;
  parameter lpm_svalue = "UNUSED" ;
  parameter lpm_pvalue = "UNUSED" ;
  parameter lpm_fftype = "DFF" ;
  parameter lpm_hint = "UNUSED" ;


  input  [lpm_width-1:0] data ;
  input  clock, enable ;
  input  aclr, aset ;
  input  sclr, sset ;
  input  aload, sload  ;
  output [lpm_width-1:0] q;

  reg   [lpm_width-1:0] tmp_q ;
  integer i ;

//---------------------------------------------------------------//
//  function integer str_to_int ;
//---------------------------------------------------------------//
  function integer str_to_int ;
	input  [8*16:1] s; 
	reg [8*16:1] reg_s;
	reg [8:1]   digit ;
	reg [8:1] tmp;
	integer   m , ivalue ; 
	begin 
  
	ivalue = 0;
	reg_s = s;
		for (m=1; m<=16; m= m+1 ) 
		begin 
		tmp = reg_s[128:121];
		digit = tmp & 8'b00001111;
		reg_s = reg_s << 8; 
				ivalue = ivalue * 10 + digit; 
		end
	str_to_int = ivalue;
	end
  endfunction
//---------------------------------------------------------------//

  always @( posedge clock or posedge aclr or posedge aset or posedge aload )
	begin :asyn_block // Asynchronous process

	  if (aclr)
	begin
			 tmp_q = 0 ;
	end
	  else if (aset)
	begin
		if (lpm_avalue == "UNUSED")
			tmp_q = {lpm_width{1'b1}};
		else
			tmp_q = str_to_int(lpm_avalue) ;
	end
	  else if (aload)
	begin
			 tmp_q = data ;
	end
	else

	begin :syn_block // Synchronous process
		if (enable)
		begin
		if(sclr)
		  begin
				tmp_q = 0;
		  end
			else if (sset )
		  begin
			if (lpm_svalue == "UNUSED") 
							tmp_q = {lpm_width{1'b1}}; 
					else
				tmp_q = str_to_int(lpm_svalue) ;
		  end
			else if (sload)  // Load data
		  begin
				tmp_q = data ;
		  end
		else
		  begin
			if(lpm_fftype == "TFF") // toggle
			  begin
					 for (i = 0 ; i < lpm_width; i=i+1)
						 begin
					if(data[i] == 1'b1) 
						tmp_q[i] = ~tmp_q[i];
						 end
			  end
			else 
			if(lpm_fftype == "DFF") // load data
					tmp_q = data ;
		  end
		end
	end
	end

	assign q = tmp_q;
endmodule // lpm_ff
 
//------------------------------------------------------------------------

module lpm_shiftreg ( q, shiftout,
		data, clock, enable,
		aclr, aset, 
		sclr, sset,
		shiftin, load) ;

  parameter lpm_type = "lpm_shiftreg" ;
  parameter lpm_width  = 1 ;
  parameter lpm_avalue = "UNUSED" ;
  parameter lpm_svalue = "UNUSED" ;
  parameter lpm_pvalue = "UNUSED" ;
  parameter lpm_direction = "LEFT" ;
  parameter lpm_hint  = "UNUSED" ;

  input  [lpm_width-1:0] data ;
  input  clock, enable ;
  input  aclr, aset;
  input  sclr, sset ;
  input  shiftin, load ;
  output [lpm_width-1:0] q;
  output shiftout ;

  reg   [lpm_width-1:0] tmp_q ;
  reg   abit ;
  integer i ;

  wire  tmp_shiftout;

//---------------------------------------------------------------//
//  function integer str_to_int ;
//---------------------------------------------------------------//
  function integer str_to_int ;
	input  [8*16:1] s; 
	reg [8*16:1] reg_s;
	reg [8:1]   digit ;
	reg [8:1] tmp;
	integer   m , ivalue ; 
	begin 
  
	ivalue = 0;
	reg_s = s;
		for (m=1; m<=16; m= m+1 ) 
		begin 
		tmp = reg_s[128:121];
		digit = tmp & 8'b00001111;
		reg_s = reg_s << 8; 
				ivalue = ivalue * 10 + digit; 
		end
	str_to_int = ivalue;
	end
  endfunction
//---------------------------------------------------------------//

  always @( posedge clock or posedge aclr or posedge aset )
	begin :asyn_block // Asynchronous process

	if (aclr)
		begin
			 tmp_q = 0 ;
		end
	else if (aset )
		begin
		if (lpm_avalue === "UNUSED")
						tmp_q = {lpm_width{1'b1}};
		else
				tmp_q = str_to_int(lpm_avalue) ;
		end
	else

	begin :syn_block // Synchronous process
		if (enable)
	  begin
		if(sclr)
		  begin
				tmp_q = 0;
		  end
			else if (sset)
		  begin
			if (lpm_svalue === "UNUSED")
				tmp_q = {lpm_width{1'b1}};
			else
					tmp_q = str_to_int(lpm_svalue) ;
		  end
			else if (load)  
		  begin
				tmp_q = data ;
		  end
			else if (!load)
			  begin
			if(lpm_direction === "LEFT")
				begin
					{abit,tmp_q} = {tmp_q,shiftin};
				end
			else if(lpm_direction === "RIGHT")
				begin
					{tmp_q,abit} = {shiftin,tmp_q};
				end
			  end
	  end
	end
  end


   assign tmp_shiftout = (lpm_direction === "LEFT")?tmp_q[lpm_width-1]:tmp_q[0];
   assign q = tmp_q ;
   assign shiftout = tmp_shiftout ;

endmodule // lpm_shiftreg
 
//------------------------------------------------------------------------

module lpm_ram_dq ( q, data, inclock, outclock, we, address ) ;

  parameter lpm_type = "lpm_ram_dq" ;
  parameter lpm_width = 1 ;
  parameter lpm_widthad = 1 ;
  parameter lpm_numwords = 1 << lpm_widthad ;
  parameter lpm_indata = "REGISTERED" ;
  parameter lpm_address_control = "REGISTERED" ;
  parameter lpm_outdata = "REGISTERED" ;
  parameter lpm_file = "UNUSED" ;
  parameter lpm_hint = "UNUSED" ;

  input  [lpm_width-1:0] data ;
  input  [lpm_widthad-1:0] address ;
  input  inclock, outclock, we ;
  output [lpm_width-1:0] q;


  // internal reg 
  reg   [lpm_width-1:0] mem_data [lpm_numwords-1:0];
  reg   [lpm_width-1:0] tmp_q ;
  reg   [lpm_width-1:0] pdata ;
  reg   [lpm_width-1:0] in_data ;
  reg   [lpm_widthad-1:0] paddress ;
  reg   pwe;
  reg   [lpm_width-1:0]  ZEROS, UNKNOWN ;
  reg   [8*256:1] ram_initf ;
  integer i ;

  function ValidAddress ;
	input [lpm_widthad-1:0] paddress ;
	begin
		ValidAddress = 1'b0 ;
		if(^paddress ==='bx)
			$display("%d:Error! Invalid address.\n", $time) ;
		else if(paddress >= lpm_numwords)
			$display("%d:Error! Address out of bound on RAM.\n", $time) ;
		else
			ValidAddress = 1'b1 ;
	end
  endfunction
		
  initial
  begin

	// Initialize the internal data register.
	pdata = 0;
	paddress = 0;
	pwe = 0;
	tmp_q = 0;

	if(lpm_width <= 0)
		$display("Error! lpm_width parameter must be greater than 0.");

	if(lpm_widthad <= 0)
		$display("Error! lpm_widthad parameter must be greater than 0.");
	// check for number of words out of bound
	if((lpm_numwords > (1 << lpm_widthad))
		||(lpm_numwords <= (1 << (lpm_widthad-1))))
	begin
		$display("Error! lpm_numwords must equal to the ceiling of log2(lpm_widthad).");
 
	end
 
	if((lpm_indata !== "REGISTERED") && (lpm_indata !== "UNREGISTERED"))
	begin
	$display("Error! lpm_indata must be REGISTERED (the default) or UNREGISTERED.");
	end
	
	if((lpm_address_control !== "REGISTERED") && (lpm_address_control !== "UNREGISTERED"))
	begin
		$display("Error! lpm_address_control must be REGISTERED (the default) or UNREGISTERED.");
	end
	
	if((lpm_outdata !== "REGISTERED") && (lpm_outdata !== "UNREGISTERED"))
	begin
		$display("Error! lpm_outdata must be REGISTERED (the default) or UNREGISTERED.");
	end  

	// check if lpm_indata or lpm_address_control is set to registered
	// inclock must be used.
	if(((lpm_indata === "REGISTERED") || (lpm_address_control === "REGISTERED")) && (inclock === 1'bz))
	begin
		$display("Error! inclock = 1'bz. Inclock pin must be used.\n");
	end

	// check if lpm_outdata, outclock must be used
	if((lpm_outdata === "REGISTERED") && (outclock === 1'bz))
	begin
		$display("Error! lpm_outdata = REGISTERED, outclock = 1'bz . Outclock pin must be used.\n");
	end

	for(i=0; i < lpm_width; i=i+1)
	begin
		ZEROS[i] = 1'b0 ;
		UNKNOWN[i] = 1'bX ;
	end 
	
	for(i = 0; i < lpm_numwords; i=i+1)
		mem_data[i] = ZEROS ;

	// load data to the RAM
	if(lpm_file != "UNUSED")
	begin
		$convert_hex2ver(lpm_file, lpm_width, ram_initf);
		$readmemh(ram_initf, mem_data);
	end 

  end

		
  always @(posedge inclock)
	begin
	  if((lpm_indata === "REGISTERED") && (lpm_address_control === "REGISTERED"))
	  begin
		paddress <= address;
		pdata <= data;
		pwe <= we;
	  end
	  else
	  begin
		if((lpm_indata === "REGISTERED") && (lpm_address_control === "UNREGISTERED"))
			pdata <= data;

		if((lpm_indata === "UNREGISTERED") && (lpm_address_control === "REGISTERED"))
		begin
			paddress <= address;
			pwe <= we;
		end
	  end
	end

  always @(data)
	begin
	  if(lpm_indata === "UNREGISTERED")
		pdata <= data;
	end
	
  always @(address)
  begin
	if(lpm_address_control === "UNREGISTERED")
		paddress <= address;
  end
	
  always @(we)
  begin
	if(lpm_address_control === "UNREGISTERED")
		pwe <= we;
  end
	
  always @( pdata or paddress or pwe )
	begin :unregistered_inclock
		if(ValidAddress(paddress))
		begin
			if((lpm_indata === "UNREGISTERED" && lpm_address_control === "UNREGISTERED") || (lpm_address_control === "UNREGISTERED"))
			begin
				if (pwe)
					mem_data[paddress] <= pdata ;
			end

		end
		else
		begin
			if(lpm_outdata === "UNREGISTERED")
				tmp_q <= UNKNOWN ;
		end
	end

  always @(posedge outclock )
	begin
		if(lpm_outdata === "REGISTERED")
		begin
			if(ValidAddress(paddress))
				tmp_q <= mem_data[paddress] ;
			else
				tmp_q <= UNKNOWN ;
		end
	end
 
  always @(negedge inclock )
	begin
		if (lpm_address_control === "REGISTERED")
		begin
			if (pwe)
				mem_data[paddress] <= pdata;
		end
	end

  assign q = ( lpm_outdata === "UNREGISTERED" ) ? mem_data[paddress] : tmp_q ;

endmodule // lpm_ram_dq
 
//------------------------------------------------------------------------

module lpm_ram_dp ( q, data, wraddress, rdaddress, rdclock, wrclock, rdclken, wrclken, rden, wren) ;

  parameter lpm_type = "lpm_ram_dp" ;
  parameter lpm_width = 1 ;
  parameter lpm_widthad = 1 ;
  parameter lpm_numwords = 1<< lpm_widthad ;
  parameter lpm_indata = "REGISTERED" ;
  parameter lpm_outdata = "REGISTERED" ;
  parameter lpm_rdaddress_control  = "REGISTERED" ;
  parameter lpm_wraddress_control  = "REGISTERED" ;
  parameter lpm_file = "UNUSED" ;
  parameter lpm_hint = "UNUSED" ;

  input  [lpm_width-1:0] data ;
  input  [lpm_widthad-1:0] rdaddress, wraddress ;
  input  rdclock, wrclock, rdclken, wrclken, rden, wren ;
  output [lpm_width-1:0] q;


  // internal reg 
  reg   [lpm_width-1:0] mem_data [lpm_numwords-1:0];
  reg   [lpm_width-1:0] tmp_q ;
  reg   [lpm_width-1:0] prev_q ;
  reg   [lpm_width-1:0] new_data ;
  reg   [lpm_widthad-1:0] new_raddress ;
  reg   [lpm_widthad-1:0] new_wraddress ;
  reg   wren_event, rden_event;
  reg   [lpm_width-1:0]  ZEROS, UNKNOWN ;
  reg [8*256:1] ram_initf ;
  integer i ;

  function ValidAddress ;
	input [lpm_widthad-1:0] paddress ;
	begin
		ValidAddress = 1'b0 ;
		if(^paddress ==='bx)
			$display("%d:Error! Invalid address.\n", $time) ;
		else if(paddress >= lpm_numwords)
			$display("%d:Error! Address out of bound on RAM.\n", $time) ;
		else
			ValidAddress = 1'b1 ;
	end
  endfunction
		
  initial
  begin

	// Initialize the internal data register.
	new_data = 0;
	new_raddress = 0;
	new_wraddress = 0;
	wren_event = 0;
	tmp_q = 0;

	if(lpm_width <= 0)
		$display("Error! lpm_width parameter must be greater than 0.");

	if(lpm_widthad <= 0)
		$display("Error! lpm_widthad parameter must be greater than 0.");
	// check for number of words out of bound
	if((lpm_numwords > (1 << lpm_widthad))
		||(lpm_numwords <= (1 << (lpm_widthad-1))))
	begin
		$display("Error! lpm_numwords must equal to the ceiling of log2(lpm_widthad).");
 
	end
 
	if((lpm_indata !== "REGISTERED") && (lpm_indata !== "UNREGISTERED"))
	begin
	$display("Error! lpm_indata must be REGISTERED (the default) or UNREGISTERED.");
	end
	
	if((lpm_rdaddress_control !== "REGISTERED") && (lpm_rdaddress_control !== "UNREGISTERED"))
	begin
		$display("Error! lpm_rdaddress_control must be REGISTERED (the default) or UNREGISTERED.");
	end
	
	if((lpm_wraddress_control !== "REGISTERED") && (lpm_wraddress_control !== "UNREGISTERED"))
	begin
		$display("Error! lpm_wraddress_control must be REGISTERED (the default) or UNREGISTERED.");
	end
	
	if((lpm_outdata !== "REGISTERED") && (lpm_outdata !== "UNREGISTERED"))
	begin
		$display("Error! lpm_outdata must be REGISTERED (the default) or UNREGISTERED.");
	end  

	// check if lpm_indata or lpm_wraddress_control is set to registered
	// wrclock and wrclken must be used.
	if(((lpm_indata === "REGISTERED") || (lpm_wraddress_control === "REGISTERED")) && ((wrclock === 1'bz) || (wrclken == 1'bz)))
	begin
		$display("Error! wrclock = 1'bz. wrclock and wrclken pins must be used.\n");
	end

	// check if lpm_rdaddress_control is set to registered
	// rdclock and rdclken must be used.
	if((lpm_rdaddress_control === "REGISTERED") && ((rdclock === 1'bz) || (rdclken == 1'bz)))
	begin
		$display("Error! rdclock = 1'bz. rdclock and rdclken pins must be used.\n");
	end

	// check if lpm_outdata, rdclock must be used
	if((lpm_outdata === "REGISTERED") && (rdclock === 1'bz))
	begin
		$display("Error! lpm_outdata = REGISTERED, rdclock = 1'bz . rdclock pnd rdclken pins must be used.\n");
	end

	for(i=0; i < lpm_width; i=i+1)
	begin
		ZEROS[i] = 1'b0 ;
		UNKNOWN[i] = 1'bX ;
	end 
	
	for(i = 0; i < lpm_numwords; i=i+1)
		mem_data[i] = ZEROS ;

	// load data to the RAM
	if(lpm_file != "UNUSED")
	begin
		$convert_hex2ver(lpm_file, lpm_width, ram_initf);
		$readmemh(ram_initf, mem_data);
	end 

  end

		
  always @(posedge wrclock)
	begin
	if (wrclken)
		begin
	  if((lpm_indata === "REGISTERED") && (lpm_wraddress_control === "REGISTERED"))
	  begin
		new_wraddress <= wraddress;
		new_data <= data;
		wren_event <= wren;
	  end
	  else
	  begin
		if((lpm_indata === "REGISTERED") && (lpm_wraddress_control === "UNREGISTERED"))
			new_data <= data;

		if((lpm_indata === "UNREGISTERED") && (lpm_wraddress_control === "REGISTERED"))
		begin
			new_wraddress <= wraddress;
			wren_event <= wren;
		end
	  end
	end
	end


  always @(data)
	begin
	  if(lpm_indata === "UNREGISTERED")
		new_data <= data;
	end
	
  always @(wraddress)
  begin
	if(lpm_wraddress_control === "UNREGISTERED")
		new_wraddress <= wraddress;
  end

  always @(rdaddress)
  begin
	if(lpm_rdaddress_control === "UNREGISTERED")
		new_raddress <= rdaddress;
  end
	
  always @(wren)
  begin
	if(lpm_wraddress_control === "UNREGISTERED")
		wren_event <= wren;
  end

  always @(rden)
  begin
	if(lpm_rdaddress_control === "UNREGISTERED")
		rden_event <= rden;
  end
	
  always @( new_data or new_wraddress or wren_event )
	begin 
		if(ValidAddress(new_wraddress))
		begin
				if ((wren_event) && (wrclken))
				mem_data[new_wraddress] <= new_data ;
		end
		else
		begin
			if(lpm_outdata === "UNREGISTERED")
				tmp_q <= UNKNOWN ;
		end
	end

  always @(posedge rdclock)
	begin
				if(lpm_rdaddress_control == "REGISTERED")
				if (rdclken)
		begin
						new_raddress <= rdaddress;
			rden_event <= rden;
		end
		if(lpm_outdata === "REGISTERED")
		begin
						if ((rdclken) && (rden_event))
						begin
			if(ValidAddress(new_raddress))
			begin
				tmp_q <= mem_data[new_raddress] ;
			end
			else
				tmp_q <= UNKNOWN ;
			
						end
		end
	end
 
  //assign q = ( lpm_outdata === "UNREGISTERED" ) ? mem_data[new_raddress] : tmp_q ;

  always @( mem_data[new_raddress] or tmp_q or rden )
	begin
		if (rden || lpm_outdata === "REGISTERED")
			prev_q <= ( lpm_outdata === "UNREGISTERED" ) ? mem_data[new_raddress] : tmp_q ;
	end

  assign q = prev_q;

endmodule // lpm_ram_dp

//------------------------------------------------------------------------

module lpm_ram_io ( dio, inclock, outclock, we, memenab, outenab, address ) ;

  parameter lpm_type = "lpm_ram_io" ;
  parameter lpm_width = 1 ;
  parameter lpm_widthad = 1 ;
  parameter lpm_numwords = 1<< lpm_widthad ;
  parameter lpm_indata = "REGISTERED" ;
  parameter lpm_address_control = "REGISTERED" ;
  parameter lpm_outdata = "REGISTERED" ;
  parameter lpm_file = "UNUSED" ;
  parameter lpm_hint = "UNUSED" ;

  input  [lpm_widthad-1:0] address ;
  input  inclock, outclock, we ;
  input  memenab ;
  input  outenab ;
  inout  [lpm_width-1:0] dio ;


  // inernal reg 
  reg   [lpm_width-1:0] mem_data [lpm_numwords-1:0];
  reg   [lpm_width-1:0] tmp_io ;
  reg   [lpm_width-1:0] tmp_q ;
  reg   [lpm_width-1:0] pdio ;
  reg   [lpm_widthad-1:0] paddress ;
  reg   pwe ;
  reg   [lpm_width-1:0] ZEROS, UNKNOWN, HiZ ;
  reg   [8*256:1] ram_initf ;
  integer i ;

  function ValidAddress ;
	input [lpm_widthad-1:0] paddress ;
	begin
		ValidAddress = 1'b0 ;
		if(^paddress ==='bx)
			$display("%d:Error: Invalid address.", $time) ;
		else if(paddress >= lpm_numwords)
			$display("%d:Error: Address out of bound on RAM.", $time) ;
		else
			ValidAddress = 1'b1 ;
	end
  endfunction
		
  initial
  begin

	if(lpm_width <= 0)
		$display("Error! lpm_width parameter must be greater than 0.");

	if(lpm_widthad <= 0)
		$display("Error! lpm_widthad parameter must be greater than 0.");

	// check for number of words out of bound
	if((lpm_numwords > (1 << lpm_widthad))
		||(lpm_numwords <= (1 << (lpm_widthad-1))))
	begin
		$display("Error! lpm_numwords must equal to the ceiling of log2(lpm_widthad).");
 
	end

	if((lpm_indata !== "REGISTERED") && (lpm_indata !== "UNREGISTERED")) 
	begin
		$display("Error! lpm_indata must be REGISTERED (the default) or UNREGISTERED.");
	end
	
	if((lpm_address_control !== "REGISTERED") && (lpm_address_control !== "UNREGISTERED")) 
	begin
		$display("Error! lpm_address_control must be REGISTERED (the default) or UNREGISTERED.");
	end
	
	if((lpm_outdata !== "REGISTERED") && (lpm_outdata !== "UNREGISTERED")) 
	begin
		$display("Error! lpm_outdata must be REGISTERED (the default) or UNREGISTERED.");
	end
	

	// check if lpm_indata or lpm_address_control is set to registered
	// inclock must be used.
	if(((lpm_indata === "REGISTERED") || (lpm_address_control === "REGISTERED")) && (inclock === 1'bz))
	begin
		$display("Error! inclock = 1'bz.  Inclock pin must be used.\n");
	end
 
	// check if lpm_outdata, outclock must be used
	if((lpm_outdata === "REGISTERED") && (outclock === 1'bz))
	begin
		$display("Error! lpm_outdata is REGISTERED, outclock = 1'bz.  Outclock pin must be used.\n");  
	end
 
	for(i=0; i < lpm_width; i=i+1)
	begin
		ZEROS[i] = 1'b0 ;
		UNKNOWN[i] = 1'bX ;
		HiZ[i] = 1'bZ ;
	end 
	
	for(i = 0; i < lpm_numwords; i=i+1)
		mem_data[i] = ZEROS ;

	// Initialize input/output 
	pdio = 0;
	paddress = 0;
	tmp_io = 0;
	tmp_q = 0;

	// load data to the RAM
	if(lpm_file != "UNUSED")
	begin
		$convert_hex2ver(lpm_file, lpm_width, ram_initf);
		$readmemh(ram_initf, mem_data);
	end
  end


  always @(dio)
	begin
	  if(lpm_indata === "UNREGISTERED")
		pdio <=  dio;
	end
	
  always @(address)
  begin
	if(lpm_address_control === "UNREGISTERED")
		paddress <=  address;
  end
	
	
  always @(we)
  begin
	if(lpm_address_control === "UNREGISTERED")
		pwe <=  we;
  end
	
  always @(posedge inclock)
  begin
	  if(lpm_indata === "REGISTERED")
		pdio <=  dio;

	  if(lpm_address_control === "REGISTERED")
		begin
			paddress <=  address;
			pwe <=  we;
		end
  end

  always @( pdio or paddress or pwe or memenab  )
  begin :block_a
	if(ValidAddress(paddress))
	begin

		if((lpm_indata === "UNREGISTERED" && lpm_address_control === "UNREGISTERED") || (lpm_address_control === "UNREGISTERED"))
				begin
			if (pwe && memenab)
			mem_data[paddress] <= pdio ;
		end

		if(lpm_outdata === "UNREGISTERED")
		begin
			tmp_q <= mem_data[paddress];
			tmp_q <= mem_data[paddress];
		end

	end
	else
	begin
		if(lpm_outdata === "UNREGISTERED")
			tmp_q <= UNKNOWN ;
	end
  end

  always @(negedge inclock  )
	begin
		if (lpm_address_control === "REGISTERED")
	begin
			if (pwe && memenab)
			mem_data[paddress] <= pdio ;
		end
	end

  always @(posedge outclock )
	begin
		if(lpm_outdata === "REGISTERED")
		begin
		tmp_q <= mem_data[paddress];
 
	
		end
	end

  always @( memenab or outenab or tmp_q)
  begin
	if(memenab && outenab)
		tmp_io <= tmp_q ;
	else if(!memenab || (memenab && !outenab))
		tmp_io <= HiZ ;
  end
 
  assign dio =  tmp_io ;

endmodule // lpm_ram_io
 
//------------------------------------------------------------------------

module lpm_rom ( q, inclock, outclock, memenab, address ) ;

  parameter lpm_type = "lpm_rom" ;
  parameter lpm_width = 1 ;
  parameter lpm_widthad = 1 ;
  parameter lpm_numwords = 1<< lpm_widthad ;
  parameter lpm_address_control = "REGISTERED" ;
  parameter lpm_outdata = "REGISTERED" ;
  parameter lpm_file = "rom.hex" ;
  parameter lpm_hint = "UNUSED" ;

  input  [lpm_widthad-1:0] address ;
  input  inclock, outclock ;
  input  memenab ;
  output [lpm_width-1:0] q;

  // inernal reg 
  reg   [lpm_width-1:0] mem_data [lpm_numwords-1:0];
  reg   [lpm_widthad-1:0] paddress ;
  reg   [lpm_width-1:0] tmp_q ;
  reg   [lpm_width-1:0] tmp_q_reg ;
  reg   [lpm_width-1:0] ZEROS, UNKNOWN, HiZ ;
  reg   [8*256:1] rom_initf ;
  integer i ;

  function ValidAddress ;
	input [lpm_widthad-1:0] address ;
	begin
		ValidAddress = 1'b0 ;
		if(^address =='bx)
			$display("%d:Error: Invalid address.", $time) ;
		else if(address >= lpm_numwords)
			$display("%d:Error: Address out of bound on ROM.", $time) ;
		else
			ValidAddress = 1'b1 ;
	end
  endfunction
		
  initial     
  begin
		// Initialize output
		tmp_q = 0;
		tmp_q_reg = 0;
	paddress = 0;
 
		if(lpm_file === "")
				$display("Error! rom module must have data file for initialization\n.");
 
	if(lpm_width <= 0)
			$display("Error! lpm_width parameter must be greater than 0.");
 
	if(lpm_widthad <= 0)
		$display("Error! lpm_widthad parameter must be greater than 0.");
 
 
	// check for number of words out of bound
	if((lpm_numwords > (1 << lpm_widthad))
		||(lpm_numwords <= (1 << (lpm_widthad-1))))
	begin
		$display("Error! lpm_numwords must equal to the ceiling of log2(lpm_widthad).");

	end   

	if((lpm_address_control !== "REGISTERED") && (lpm_address_control !== "UNREGISTERED"))
	begin
		$display("Error! lpm_address_control must be REGISTERED (the default) or UNREGISTERED.");
	end

	if((lpm_outdata !== "REGISTERED") && (lpm_outdata !== "UNREGISTERED"))
	begin
		$display("Error! lpm_outdata must be REGISTERED (the default) or UNREGISTERED.");
	end

	// check if lpm_address_control is set to registered
	// inclock must be used.
	if((lpm_address_control === "REGISTERED") && (inclock === 1'bz))
	begin
		$display("Error! inclock = 1'bz.  Inclock pin must be used.\n");
	end  

	// check if lpm_outdata, outclock must be used
	if((lpm_outdata === "REGISTERED") && (outclock === 1'bz))
	begin
		$display("Error! lpm_outdata is REGISTERED, outclock = 1'bz.  Outclock must be used.\n");
	end
 
	for(i=0; i < lpm_width; i=i+1)
	begin
		ZEROS[i] = 1'b0 ;
		UNKNOWN[i] = 1'bX ;
		HiZ[i] = 1'bZ ;
	end 
	
	for(i = 0; i < lpm_numwords; i=i+1)
		mem_data[i] = ZEROS ;

	// load data to the ROM
	if(lpm_file != "")
	begin
		$convert_hex2ver(lpm_file, lpm_width, rom_initf);
		$readmemh(rom_initf, mem_data);
	end
  end

  always @(posedge inclock)                                           
		begin
		  if(lpm_address_control === "REGISTERED")
				paddress <=  address;
		end
 
  always @(address)
  begin
		if(lpm_address_control === "UNREGISTERED")
				paddress <=  address;
  end

				   
  always @( paddress )
  begin 
	if(ValidAddress(paddress))
	begin
		if(lpm_outdata === "UNREGISTERED")
			tmp_q_reg <=  mem_data[paddress] ;
	end
	else
	begin
		if(lpm_outdata === "UNREGISTERED")
			tmp_q_reg <= UNKNOWN ;
	end
  end

  always @(posedge outclock)
  begin
	if(lpm_outdata === "REGISTERED")
	begin
		if(ValidAddress(paddress))
			tmp_q_reg <=  mem_data[paddress] ;
		else
			tmp_q_reg <= UNKNOWN ;
	end
  end
 
	
  always @(memenab or tmp_q_reg)
  begin
	if(memenab)
		tmp_q <= tmp_q_reg ;
	else if(!memenab)
		tmp_q <= HiZ ;
  end
 
  assign q = tmp_q ;

endmodule // lpm_rom
 
//------------------------------------------------------------------------

module lpm_fifo (data, clock, wrreq, rdreq, aclr, sclr, q, usedw, full, empty);

  parameter lpm_type = "lpm_fifo" ;
  parameter lpm_width  = 1 ;
  parameter lpm_widthu  = 1 ;
  parameter lpm_numwords = 2 ;
  parameter lpm_showahead = "OFF" ;
  parameter lpm_hint = "UNUSED" ;

  input [lpm_width-1:0] data;
  input clock;
  input wrreq;
  input rdreq;
  input aclr;
  input sclr;
  output [lpm_width-1:0] q;
  output [lpm_widthu-1:0] usedw;
  output full;
  output empty;


  // internal reg
  reg [lpm_width-1:0] mem_data [lpm_numwords-1:0];
  reg [lpm_width-1:0] tmp_q;
  reg [lpm_width-1:0] ZEROS;
  reg [lpm_widthu+1:0] count_id;
  reg [lpm_widthu-1:0] write_id;
  reg [lpm_widthu-1:0] read_id;
  reg empty_flag;
  reg full_flag;
  integer i;

  initial
  begin
  
	if(lpm_width <= 0)
		$display("Error! lpm_width must be greater than 0.");

	if(lpm_numwords <= 1)
		$display("Error! lpm_numwords must be greater than or equal to 2.");

	// check for number of words out of bound
	if ((lpm_widthu !=1 ) && (lpm_numwords > (1 << lpm_widthu)))
		 $display("Error! lpm_numwords MUST equal to the ceiling of log2(lpm_widthu).");

	if (lpm_numwords <= (1 << (lpm_widthu-1)))
	begin
		 $display("Error! lpm_widthu is too big for the specified lpm_numwords.");
 
	end

   for (i=0; i < lpm_width; i=i+1)
		  ZEROS[i] = 1'b0;

   for (i=0; i < lpm_widthu; i=i+1)
	  begin
		  count_id[i] = 1'b0;
		  write_id[i] = 1'b0;
		  read_id[i] = 1'b0;
	  end

   for(i = 0; i < lpm_numwords; i=i+1)
		 mem_data[i] = ZEROS;

   empty_flag = 1;
   full_flag = 0;
  end

  always @( posedge clock )
	if(lpm_showahead == "ON" && clock && aclr)
		tmp_q = data;

  always @( posedge clock or aclr )
  begin
	if (aclr)
	begin
		if (lpm_showahead != "ON")
			tmp_q = ZEROS;

		full_flag = 0;
		empty_flag  = 1;
		read_id  = 0;
		write_id  = 0;
		count_id = 0;
	end
	else 
		if (clock)
		begin
			if (sclr)
			begin   
				//tmp_q = ZEROS;
				if (rdreq && !empty)
					tmp_q = mem_data[read_id];
				if (lpm_showahead == "ON" && rdreq)
					tmp_q = data;
				 
				full_flag = 0;
				empty_flag  = 1;
				read_id  = 0;
				write_id  = 0;
				count_id = 0;
			end
			else
			begin
				// WRITE
				if (wrreq && !full)
				begin
					mem_data[write_id] = data;
					if (lpm_showahead == "ON")
						tmp_q = mem_data[read_id];
					count_id = count_id + 1;
					if (write_id == lpm_numwords - 1)
						write_id = 0;
					else
						write_id = write_id + 1;
				end
				
				// READ
				if (rdreq && !empty) 
				begin
					tmp_q = mem_data[read_id];
					count_id = count_id - 1;
					if (read_id == lpm_numwords - 1 )
						read_id = 0;
					else
						read_id = read_id + 1;
					if (lpm_showahead == "ON")
						tmp_q = mem_data[read_id];
				end

				if (!(wrreq && !full) && !(rdreq && !empty))
					if (lpm_showahead == "ON" && empty)
						tmp_q = data;

				if(count_id == lpm_numwords)
					full_flag = 1;
				else    
					full_flag = 0;
				 
				if(count_id == 0)
				begin
					empty_flag = 1;
					if (lpm_showahead == "ON")
						tmp_q = data;
				end
				else    
					empty_flag = 0;
			end
		end
  end

   //assign q = (lpm_showahead == "ON") ? mem_data[read_id] : tmp_q;
   assign q = tmp_q;
   assign full = full_flag;
   assign empty = empty_flag;
   assign usedw = count_id;

endmodule // lpm_fifo

//------------------------------------------------------------------------

module lpm_fifo_dc (data, rdclock, wrclock, aclr, rdreq, wrreq, rdfull, wrfull, rdempty, wrempty, rdusedw, wrusedw, q );

  parameter lpm_type = "lpm_fifo_dc" ;
  parameter lpm_width = 1 ;
  parameter lpm_widthu = 1 ;
  parameter lpm_numwords = 2 ;
  parameter lpm_showahead = "OFF" ;
  parameter lpm_hint = "UNUSED" ; 

  input [lpm_width-1:0] data;
  input rdclock;
  input wrclock;
  input wrreq;
  input rdreq;
  input aclr;
  output rdfull;
  output wrfull;
  output rdempty;
  output wrempty;
  output [lpm_width-1:0] q;
  output [lpm_widthu-1:0] rdusedw;
  output [lpm_widthu-1:0] wrusedw;
  

  // internal reg
  reg [lpm_width-1:0] mem_data [lpm_numwords-1:0];
  reg [lpm_width-1:0] tmp_q;
  reg [lpm_width-1:0] ZEROS;
  reg [lpm_widthu-1:0] wrcount_id;
  reg [lpm_widthu-1:0] rdcount_id;
  reg [lpm_widthu-1:0] ZEROSU;
  integer count_id;
  integer write_id;
  integer read_id;
  integer wrempty_count;
  integer rdempty_count;
  reg wrempty_flag;
  reg wrfull_flag;
  reg wrfull_f2;
  reg tmp_wrfull_flag;
  reg tmp_wrempty_flag;
  reg rdempty_flag;
  reg rdfull_flag;
  reg rdfull_f2;
  reg tmp_rdempty_flag;
  integer i;

  initial
  begin
  
	if(lpm_width <= 0)
		$display("Error! lpm_width must be greater than 0.");

	if(lpm_numwords <= 1)
		$display("Error! lpm_numwords must be greater than or equal to 2.");

	// check for number of words out of bound
	if ((lpm_widthu !=1 ) && (lpm_numwords > (1 << lpm_widthu)))
		 $display("Error! lpm_numwords MUST equal to the ceiling of log2(lpm_widthu).");

	if (lpm_numwords <= (1 << (lpm_widthu-1)))
		 $display("Error! lpm_widthu is too big for the specified lpm_numwords.");
	
	for (i=0; i < lpm_width; i=i+1)
		ZEROS[i] = 1'b0;

	for (i=0; i < lpm_widthu; i=i+1)
		ZEROSU[i] = 1'b0;

	// MEMORY INITIALIZATION
	for(i = 0; i < lpm_numwords; i=i+1)
		mem_data[i] = ZEROS;

	count_id = 0;
	write_id = 0;
	read_id = 0;

	wrcount_id = ZEROSU;
	rdcount_id = ZEROSU;

	wrempty_flag = 1;
	rdempty_flag = 1;
	wrfull_flag = 0;
	rdfull_flag = 0;
	wrfull_f2 = 0;
	rdfull_f2 = 0;

	wrempty_count = 0;
	rdempty_count = 0;

  end

  always @( aclr )
  begin
	if (aclr)
	begin
		tmp_q = ZEROS;
		rdfull_flag = 0;
		rdempty_flag  = 1;
		wrfull_flag = 0;
		wrempty_flag  = 1;
		read_id  = 0;
		write_id  = 0;
		count_id = 0;
		rdcount_id = 0; 
		wrcount_id = 0;
	end
  end

  always @( posedge wrclock )
  begin
	if (!aclr)
	begin
		// PREPARE FLAGS FOR DELAY
		tmp_wrfull_flag = wrfull_flag;
  
		// SET EMPTY FLAG
		if (wrempty_flag == 1 && wrcount_id > 0)
		begin
			wrempty_flag = 0;
			wrempty_count = 0;
		end
		else if (wrempty_flag == 0 && wrcount_id == 0)
		begin
			if (wrempty_count < 1)
				wrempty_count = wrempty_count + 1;
			else
			begin
				wrempty_flag = 1;
				wrempty_count = 0;
			end
		end
		else
			wrempty_count = 0;
  
		// SET FULL FLAG
		tmp_wrfull_flag = wrfull_f2;
		wrfull_f2 = (wrcount_id >= lpm_numwords-3) ? 1 : 0;

		// SET COUNTER
		wrcount_id = count_id;
  
		// if WRITE
		if (wrreq && !wrfull_flag)
		begin
			// WRITE DATA
			mem_data[write_id] = data;
  
			// SET OUTPUT
			if (lpm_showahead == "ON")
				tmp_q = mem_data[read_id];
  
			// SET FLAGS
			wrempty_flag = 0;
			wrempty_count = 0;
  
			// INC COUNTER
			wrcount_id = count_id + 1;
			count_id = count_id + 1;
  
			// INC POINTER
			write_id = (write_id < lpm_numwords-1) ? write_id+1 : 0;
		end

		// SET DELAYED FLAGS
		wrfull_flag = tmp_wrfull_flag;
	end
  end

  always @( posedge rdclock )
  begin    
	if (!aclr)
	begin
		// PREPARE FLAGS FOR DELAY
		tmp_rdempty_flag = rdempty_flag;
  
		// SET EMPTY FLAG
		if (rdempty_flag == 1 && rdcount_id > 0)
		begin
			if (rdempty_count >= 0)
				rdempty_count = rdempty_count - 1;
			else
			begin
				tmp_rdempty_flag = 0;
				rdempty_count = 0;
			end
		end
		else if (rdempty_flag == 0 && rdcount_id == 0)
		begin
			tmp_rdempty_flag = 1;
			rdempty_count = 0;
		end
		else
			rdempty_count = 0;

		// SET FULL FLAG
		rdfull_flag = rdfull_f2;
		rdfull_f2 = (rdcount_id >= lpm_numwords-3) ? 1 : 0;

		// SET COUNTER
		rdcount_id = count_id;

		// if READ
		if (rdreq && !rdempty_flag) 
		begin
			// READ DATA/SET OUTPUT
			tmp_q = mem_data[read_id];

			// SET FLAGS
			if (count_id-1 == 0)
			begin
				tmp_rdempty_flag = 1;
				rdempty_count = 0;
			end

			// INC COUNTER
			rdcount_id = count_id - 1;
			count_id = count_id - 1;

			// INC POINTER
			if (read_id == lpm_numwords - 1 )
			begin
				if (lpm_showahead == "ON")
					tmp_q = mem_data[0];
				read_id = 0;
			end
			else
			begin
				if (lpm_showahead == "ON")
					tmp_q = mem_data[read_id+1];
				read_id = read_id + 1;
			end
		end

		// SET DELAYED FLAGS
		rdempty_flag = tmp_rdempty_flag;
	end
  end
 
  assign q = tmp_q;
  assign wrfull = wrfull_flag;
  assign wrempty = wrempty_flag;
  assign rdfull = rdfull_flag;
  assign rdempty = rdempty_flag;
  assign wrusedw = wrcount_id;
  assign rdusedw = rdcount_id;

endmodule // lpm_fifo_dc

//------------------------------------------------------------------------

module lpm_inpad ( result, pad ) ;

  parameter lpm_type = "lpm_inpad" ;
  parameter lpm_width = 1 ;
  parameter lpm_hint = "UNUSED" ;

  input  [lpm_width-1:0] pad ;
  output [lpm_width-1:0] result ;

  reg    [lpm_width-1:0] result ;

  always @(pad)
	begin
	  result = pad ;
	end

endmodule // lpm_inpad

//------------------------------------------------------------------------

module lpm_outpad ( data, pad ) ;

  parameter lpm_type = "lpm_outpad" ;
  parameter lpm_width = 1 ;

  input [lpm_width-1:0] data ;
  output  [lpm_width-1:0] pad ;

  reg   [lpm_width-1:0] pad ;

  always @(data)
	begin
	  pad = data ;
	end

endmodule // lpm_outpad

//------------------------------------------------------------------------

module lpm_bipad ( result, pad, data, enable ) ;

  parameter lpm_type = "lpm_bipad" ;
  parameter lpm_width = 1 ;
  parameter lpm_hint = "UNUSED" ;

  input  [lpm_width-1:0] data ;
  input  enable ;
  inout  [lpm_width-1:0] pad ;
  output [lpm_width-1:0] result ;

  reg    [lpm_width-1:0] tmp_pad ;
  reg    [lpm_width-1:0] result ;

  always @(data or pad or enable)
	begin
	if (enable == 1)
	   begin
		tmp_pad = data;
		result = 'bz;
	   end
	else
	if (enable == 0)
	   begin
		result = pad;
		tmp_pad = 'bz;
	   end
	end
  assign pad = tmp_pad;

endmodule // lpm_bipad
