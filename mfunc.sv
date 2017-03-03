

function [32-1:0] fmult;
input [32-1:0] a;
input [32-1:0] b;
	 
logic [2*32-1:0] a_ext;
logic [2*32-1:0] b_ext;
logic [2*32-1:0] r_ext;
	
logic [2*32-1:0] a_mult;
logic [2*32-1:0] b_mult;
logic [2*32-1:0] result;

parameter F = 15;
	
        a_ext[31:0] = ~a[31:0] + 'h1;
        a_ext[63:32] = 32'h0; // {32{a[31]}};
        b_ext[31:0] =  ~b[31:0] + 'h1;
        b_ext[63:32] = 32'h0; // {32{b[31]}};

	a_mult = a[32-1] ? a_ext : {32'h0,a};
	b_mult = b[32-1] ? b_ext : {32'h0,b};

	result = a_mult * b_mult;
	r_ext = ~result + 64'h1;

        //result/r_ext produces a product which is 1+1, 16+16.15.15 format
	//Use truncation to fit into original 1,16.15 format
	//The code below uses the lower 16bits and upper 15 bits of
	//portion before and after the decimal point


	fmult = (a[32-1] ^ b[32-1]) ? {1'b1, r_ext[32-2+F:F]} :
	                              {1'b0, result[32-2+F:F]};

	//$display("result[63:62]=%h result[61:46]=%h result[32+F:F]=%h, result[F-1:0]=%0h\n",result[63:62], result[61:46], result[32-2+F:F],result[F-1:0]);
endfunction


//Division Algorithm 
//https://pdfs.semanticscholar.org/6de8/6662718d30aa9599dfebe08f01c18f3162b1.pdf
function [31:0] fdiv;
input [31:0] a;
input [31:0] b;

//sign16.15 format
parameter n = 32;
parameter F = 15;

logic [63:0] s, r;
logic [31:0] ci, cf, tmp;
integer i;

  a = {a[23:0],8'h0} ;
  ci = a / b ; 
  tmp = a - fmult(ci,b) ;
  s = tmp;
  s =  (s << 32); 
  r = b;
  r = (r << 31) ; 
  cf = 0;
  for(i=1;i<16;i=i+1) begin 
    cf = cf << 1;
    s = s - r;    
    if  (s[63] == 0)   
      s = s + r;  
    else   
      cf = cf | 'h1 ; 
    s = (s << 1); 
   end

   fdiv = ( (ci << 15) | cf); 
   fdiv = fdiv >> 8;

endfunction



