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
// Version 1.0    Date 07/09/97
//
//------------------------------------------------------------------------
// Excluded Functions:
//
//  LPM_RAM_DQ, LPM_RAM_IO, LPM_ROM, and LPM_FSM, and LPM_TTABLE.
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
// ports are implemented as one dimensional signal of (lpm_size * lpm_width)
// bits wide.
//
//------------------------------------------------------------------------
// Synthesis Issues:
// 
// 1.lpm_counter 
//
// Currently synthesis tools do not allow mixing of level and edge
// sensetive signals. To overcome that problem the "data" signal is
// removed from the clock always block of lpm_counter, however the
// synthesis result is accurate. For correct simulation add the "data"
// pin to the sensetivity list as follows:
//
//  always @( posedge clock or posedge aclr or posedge aset or 
//		posedge aload  or data)
//------------------------------------------------------------------------
// Modification History:
//
//------------------------------------------------------------------------
module lpm_abs ( result, overflow, data ) ;

  parameter lpm_type = "lpm_abs" ;
  parameter lpm_width = 1 ;

  input  [lpm_width-1:0] data ;
  output [lpm_width-1:0] result ;
  output overflow ;

  reg    [lpm_width-1:0] a_int ;
  reg    [lpm_width-1:0] result ;
  reg	 overflow;
  integer i;

  always @(data)
    begin

	overflow = 0;
	if ( data[lpm_width-1] == 1)
	    begin
		a_int = 0;
		for(i = 0; i < lpm_width - 1; i = i + 1)
	                a_int[i] = data[i] ^ 1;
		result = (a_int + 1) ;
		overflow = (result == ( 1<<(lpm_width -1))) ;
            end
	else result = data;
    end

endmodule // lpm_abs

module lpm_add_sub (  result, cout, overflow,
        add_sub, cin, dataa, datab, clock, aclr ) ;

  parameter lpm_type = "lpm_add_sub" ;
  parameter lpm_width = 1 ;
  parameter lpm_pipeline = 0 ;
  parameter lpm_representation = "UNSIGNED" ;
  parameter lpm_direction  = "UNUSED" ;

  input  [lpm_width-1:0] dataa, datab ;
  input  add_sub, cin ;
  input  clock ;
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
	else begin
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

module lpm_and ( result, data ) ;

  parameter lpm_type = "lpm_and" ;
  parameter lpm_width = 1 ;
  parameter lpm_size = 1 ;

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

module lpm_bipad ( result, pad, data, enable ) ;

  parameter lpm_type = "lpm_bipad" ;
  parameter lpm_width = 1 ;

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

module lpm_bustri ( result, tridata, data, enabledt, enabletr ) ;

  parameter lpm_type = "lpm_bustri" ;
  parameter lpm_width = 1 ;

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

module lpm_clshift ( result, overflow,
        underflow, data,
        direction, distance) ;

  parameter lpm_type        = "lpm_clshift" ;
  parameter lpm_width       = 1 ;
  parameter lpm_widthdist   = 1 ;
  parameter lpm_shifttype   = "LOGICAL" ;

  input  [lpm_width-1:0] data ;
  input  [lpm_widthdist-1:0] distance ;
  input  direction ;
  output [lpm_width-1:0] result;
  output overflow ;
  output underflow;

  reg    [lpm_width-1:0] ONES ;
  reg    [lpm_width-1:0] result ;
  reg 	 overflow, underflow;
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
	  if((direction) && (dist > 0))	// shift right
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

	  if(direction && (dist > 0))	// shift right
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
	  if((direction) && (dist > 0))	// shift right
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

module lpm_compare (  alb, aeb, agb, aleb, aneb, ageb, dataa, datab, clock, aclr ) ;


  parameter lpm_type = "lpm_compare" ;
  parameter lpm_width = 1 ;
  parameter lpm_pipeline = 0 ;
  parameter lpm_representation = "UNSIGNED" ;

  input  [lpm_width-1:0] dataa, datab ;
  input  clock ;
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
	else
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

module lpm_constant ( result ) ;

  parameter lpm_type = "lpm_constant" ;
  parameter lpm_width = 1 ;
  parameter lpm_cvalue = 0 ;
  parameter lpm_strength = "UNUSED";

  output [lpm_width-1:0] result ;

  assign result = lpm_cvalue ;

endmodule // lpm_constant


module lpm_counter ( q, eq, 
        data, clock,
        clk_en, cnt_en, updown,
        aset, aclr, aload, 
        sset, sclr, sload) ;

  parameter lpm_type	 = "lpm_counter";
  parameter lpm_width    = 1 ;
  parameter lpm_modulus  = 1<<lpm_width ;
  parameter lpm_avalue   = "UNUSED" ;
  parameter lpm_svalue   = "UNUSED" ;
  parameter lpm_pvalue   = "UNUSED" ;
  parameter lpm_direction  = "UNUSED" ;

  output [lpm_width-1:0] q ;
  output [lpm_modulus-1:0] eq ;
  input  [lpm_width-1:0] data ;
  input  clock, clk_en, cnt_en, updown ;
  input  aset, aclr, aload ;
  input  sset, sclr, sload ;

  reg  [lpm_width-1:0] tmp_count ;
  reg  [lpm_width-1:0] re_start ;
  integer up_limit ;

//---------------------------------------------------------------//
  function [lpm_width-1:0] NextBin ;
        input [lpm_width-1:0] count ;
    begin 
	  up_limit = (updown == 1)?(lpm_modulus - 1):0 ;
	  re_start = (updown == 1)?0:(lpm_modulus - 1) ;
	  if(((count >= up_limit) && updown)
		|| ((count == up_limit) && !updown))
		NextBin = re_start ;
	  else
	  	NextBin = (updown == 1)?count+1:count-1 ;
    end 
  endfunction

//---------------------------------------------------------------//
//  function [(1<<lpm_width)-1:0] CountDecode ;
//---------------------------------------------------------------//
  function [lpm_modulus:0] CountDecode ;
    input [lpm_width-1:0] count ;
    integer eq_index ;
    begin
	  CountDecode = 0 ;
	  eq_index = 0;
	  if(count < lpm_modulus)
	  begin
		  eq_index = count ;
	  	  CountDecode[eq_index] = 1'b1 ;
	  end
    end
  endfunction

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

  always @( posedge clock or posedge aclr or posedge aset or 
		posedge aload  )
    begin :asyn_block
      if (aclr)
        begin
          tmp_count = 0 ;
        end
      else if (aset)
        begin
        if (lpm_avalue == "UNUSED")
                tmp_count = {lpm_width{1'b1}};
        else
          	tmp_count = str_to_int(lpm_avalue) ;
        end
      else if (aload)
        begin
          tmp_count = data ;
        end
    else
    begin :syn_block
	  if( clk_en )
	    begin
	      if (sclr)
			begin :syn_clr
				 tmp_count = 0 ;
			end
	      else if (sset)
			begin :syn_set
                                 if (lpm_svalue == "UNUSED")
                                 	tmp_count = {lpm_width{1'b1}};
                                 else
					tmp_count = str_to_int(lpm_svalue) ;
			end
	      else if (sload)
			begin :syn_load
					tmp_count = data ;
			end
	      else if( cnt_en)
		begin
			tmp_count = NextBin(tmp_count) ;
	        end
	    end
    end
    end 

  assign q =  tmp_count ;
  assign eq = CountDecode(tmp_count) ;

 endmodule // lpm_counter

module lpm_decode ( eq, data, enable, clock, aclr) ;

  parameter lpm_type     = "lpm_decode" ;
  parameter lpm_width    = 1 ;
  parameter lpm_decodes  = 1 << lpm_width ;
  parameter lpm_pipeline = 0 ;


  input  [lpm_width-1:0] data ;
  input  enable ;
  input  clock ;
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
   	else 
	begin
        tmp_eq2[lpm_pipeline] = tmp_eq ;
        for(j = 0; j < lpm_pipeline; j = j +1)
            tmp_eq2[j] = tmp_eq2[j+1] ;
	end
      end

  assign eq = (lpm_pipeline > 0) ? tmp_eq2[0] : tmp_eq;

endmodule // lpm_decode

module lpm_ff ( q,
        data, clock, enable,
        aclr, aset,
        sclr, sset,
        aload, sload) ;

  parameter lpm_type = "lpm_ff" ;
  parameter lpm_fftype = "DFF" ;
  parameter lpm_width  = 1 ;
  parameter lpm_avalue = "UNUSED" ;
  parameter lpm_svalue = "UNUSED" ;

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
 
module lpm_inpad ( result, pad ) ;

  parameter lpm_type = "lpm_inpad" ;
  parameter lpm_width = 1 ;

  input  [lpm_width-1:0] pad ;
  output [lpm_width-1:0] result ;

  reg    [lpm_width-1:0] result ;

  always @(pad)
    begin
      result = pad ;
    end

endmodule // lpm_inpad

module lpm_inv ( result, data ) ;

  parameter lpm_type = "lpm_inv" ;
  parameter lpm_width = 1 ;

  input  [lpm_width-1:0] data ;
  output [lpm_width-1:0] result ;

  reg    [lpm_width-1:0] result ;

  always @(data)
    begin
      result = ~data ;
    end

endmodule // lpm_inv

module lpm_latch ( q, data, gate, aset, aclr );

  parameter lpm_type = "lpm_latch" ;
  parameter lpm_width = 1 ;
  parameter lpm_avalue = "UNUSED" ;
  parameter lpm_pvalue = "UNUSED" ;

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

module lpm_mult ( result, dataa, datab, sum, clock, aclr ) ;

  parameter lpm_type       = "lpm_mult" ;
  parameter lpm_widtha     = 1 ;
  parameter lpm_widthb     = 1 ;
  parameter lpm_widths     = 1 ;
  parameter lpm_widthp     = 2 ;
  parameter lpm_pipeline   = 0 ;
  parameter lpm_representation  = "UNSIGNED" ;

  input  clock ;
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
	  else
	  begin :syn_block
	  	tmp_result2[lpm_pipeline] = tmp_result ;
		for(n = 0; n < lpm_pipeline; n = n +1)
			tmp_result2[n] = tmp_result2[n+1] ;
	  end
	end

  assign result = (lpm_pipeline > 0) ? tmp_result2[0] : tmp_result ;

 endmodule // lpm_mult

module lpm_mux ( result, clock, data, aclr, sel ) ;

  parameter lpm_type = "lpm_mux" ;
  parameter lpm_width =1 ;
  parameter lpm_size =1 ;
  parameter lpm_widths = 1;
  parameter lpm_pipeline = 0;

  input  [(lpm_size * lpm_width)-1:0] data;
  input aclr;
  input clock;
  input [lpm_widths-1:0] sel;
  output [lpm_width-1:0] result ;

  integer i, j, m, n;
  reg 	[lpm_width-1:0] tmp_result;
  reg	[lpm_width-1:0] tmp_result2 [lpm_pipeline:0];

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
        else
        begin
        	tmp_result2[lpm_pipeline] = tmp_result ;
        	for(j = 0; j < lpm_pipeline; j = j +1)
            		tmp_result2[j] = tmp_result2[j+1] ;
        end
      end

  assign result = (lpm_pipeline > 0) ? tmp_result2[0] : tmp_result;
endmodule // lpm_mux

module lpm_or ( result, data ) ;

  parameter lpm_type = "lpm_and" ;
  parameter lpm_width = 1 ;
  parameter lpm_size = 1 ;

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

endmodule // lpm_and

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

module lpm_shiftreg ( q, shiftout,
        data, clock, enable,
        aclr, aset, 
        sclr, sset,
        shiftin, load) ;

  parameter lpm_type = "lpm_shiftreg" ;
  parameter lpm_width  = 1 ;
  parameter lpm_avalue = "UNUSED" ;
  parameter lpm_svalue = "UNUSED" ;
  parameter lpm_direction = "LEFT" ;

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
 
module lpm_xor ( result, data ) ;

  parameter lpm_type = "lpm_and" ;
  parameter lpm_width = 1 ;
  parameter lpm_size = 1 ;

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

endmodule // lpm_and
