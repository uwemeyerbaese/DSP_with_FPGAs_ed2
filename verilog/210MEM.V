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
// LPM Simulation Models 
//------------------------------------------------------------------------
// Version 1.0    Date 07/09/97
//
//------------------------------------------------------------------------
// Functions Included:
//
// LPM_RAM_DQ, LPM_RAM_IO, and LPM_ROM
//
//------------------------------------------------------------------------
// Modification History:
//
//------------------------------------------------------------------------
//   This Verilog file was developed by Altera Corporation.  It may be freely
// copied and/or distributed at no cost.  Any persons using this file for
// any purpose do so at their own risk, and are responsible for the results
// of such use.  Altera Corporation does not guarantee that this file is
// complete, correct, or fit for any particular purpose.  NO WARRANTY OF
// ANY KIND IS EXPRESSED OR IMPLIED.  This notice must accompany any copy
// of this file.
//------------------------------------------------------------------------
module lpm_ram_dq ( q, data, inclock, outclock, we, address) ;

  parameter lpm_type = "lpm_ram_dq" ;
  parameter lpm_width  = 1 ;
  parameter lpm_widthad = 1 ;
  parameter lpm_numwords = 1<< lpm_widthad ;
  parameter lpm_file       = "UNUSED" ;
  parameter lpm_indata   = "REGISTERED" ;
  parameter lpm_outdata  = "REGISTERED" ;
  parameter lpm_address_control  = "REGISTERED" ;

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

  always @(posedge outclock)
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
//   This Verilog file was developed by Altera Corporation.  It may be freely
// copied and/or distributed at no cost.  Any persons using this file for
// any purpose do so at their own risk, and are responsible for the results
// of such use.  Altera Corporation does not guarantee that this file is
// complete, correct, or fit for any particular purpose.  NO WARRANTY OF
// ANY KIND IS EXPRESSED OR IMPLIED.  This notice must accompany any copy
// of this file.
//------------------------------------------------------------------------
module lpm_ram_io ( dio, inclock, outclock, we, memenab, outenab, address) ;

  parameter lpm_type = "lpm_ram_io" ;
  parameter lpm_width  = 1 ;
  parameter lpm_widthad = 1 ;
  parameter lpm_numwords = 1<< lpm_widthad ;
  parameter lpm_file       = "UNUSED" ;
  parameter lpm_indata     = "REGISTERED" ;
  parameter lpm_outdata    = "REGISTERED" ;
  parameter lpm_address_control = "REGISTERED" ;

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
  reg [8*256:1] ram_initf ;
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
//   This Verilog file was developed by Altera Corporation.  It may be freely
// copied and/or distributed at no cost.  Any persons using this file for
// any purpose do so at their own risk, and are responsible for the results
// of such use.  Altera Corporation does not guarantee that this file is
// complete, correct, or fit for any particular purpose.  NO WARRANTY OF
// ANY KIND IS EXPRESSED OR IMPLIED.  This notice must accompany any copy
// of this file.
//------------------------------------------------------------------------
module lpm_rom ( q, inclock, outclock, memenab, address) ;

  parameter lpm_type = "lpm_rom" ;
  parameter lpm_width    = 1 ;
  parameter lpm_widthad = 1 ;
  parameter lpm_numwords = 1<< lpm_widthad ;
  parameter lpm_file       = "rom.hex" ;
  parameter lpm_outdata    = "REGISTERED" ;
  parameter lpm_address_control = "REGISTERED" ;

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
  reg [8*256:1] rom_initf ;
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
 
