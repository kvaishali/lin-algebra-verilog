
//This module implements a limited precision division 
//The divident is shifted left by 8bit for application where 
//this module is used for fixed point reciprocal. This can be removed
//if the application is dealing with number spaces which need full
//16bit for the integer portion of the number.
//sign+16.15

//Division Algorithm 
//https://pdfs.semanticscholar.org/6de8/6662718d30aa9599dfebe08f01c18f3162b1.pdf

module fixed_point_div (
input [31:0] a,
input [31:0] b,
output logic [31:0] out,
input clk,
input reset
);

//sign16.15 format
parameter I = 16;
parameter F = 15;

logic [63:0] s, r;
logic [31:0] ci, cf, tmp, tmp_r1, fmult_out;
integer i;
logic [31:0] a_in;

fixed_point_mult #(I,F) fmult(ci,b,fmult_out);

// cycle1:
  always_comb begin
    a_in = {a[23:0],8'h0} ;
    ci = a_in / b ; 
    tmp = a_in - fmult_out ;
  end

  always_ff @(posedge clk) begin
    tmp_r1 <= tmp;
  end

// cycle2
// additional pipelining may be needed based on the process technology/cycle time

  always_comb begin

    s = tmp_r1;
    s =  (s << 32); 
    r = b;
    r = (r << 31) ; 
    cf = 0;
    for(i=1;i<I;i=i+1) begin 
      cf = cf << 1;
      s = s - r;    
      if  (s[63] == 0)   
        s = s + r;  
      else   
        cf = cf | 'h1 ; 
      s = (s << 1); 
    end

  end

  always_ff @(posedge clk) begin
     out <= ( (ci << 15) | cf) >> 8; 
  end

endmodule





