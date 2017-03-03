
//32bit signed fixed point - format = 1b sign+16.15
//This module calculates the product of 2 signed fixed point numbers in 16.15 format.
//The numbers are expected in 2's complement and result is saved back in 2's complement.
// The result which is 1+1, 16+16.15+15 format is truncted back to sign+16.15. This may need to be tuned for your application based on precision needed (consider rounding if required). 
 

module fixed_point_mult (
input [32-1:0] a,
input [32-1:0] b,
output logic [31:0] out);
	 
logic [2*32-1:0] a_ext;
logic [2*32-1:0] b_ext;
logic [2*32-1:0] r_ext;
	
logic [2*32-1:0] a_mux;
logic [2*32-1:0] b_mux;
logic [2*32-1:0] result;

parameter I = 16;
parameter F = 15;
	
   always_comb begin
        a_ext[31:0] = ~a[31:0] + 'h1;
        a_ext[63:32] = 32'h0; // {32{a[31]}};
        b_ext[31:0] =  ~b[31:0] + 'h1;
        b_ext[63:32] = 32'h0; // {32{b[31]}};

	a_mux = a[32-1] ? a_ext : {32'h0,a};
	b_mux = b[32-1] ? b_ext : {32'h0,b};

	result = a_mux * b_mux;
	r_ext = ~result + 64'h1;

        //result/r_ext produces a product which is 1+1, 16+16.15.15 format
	//Use truncation to fit into original 1,16.15 format
	//The code below uses the lower 16bits and upper 15 bits of
	//portion before and after the decimal point


	out = (a[32-1] ^ b[32-1]) ? {1'b1, r_ext[32-2+F:F]} :
	                              {1'b0, result[32-2+F:F]};
   end


endmodule


