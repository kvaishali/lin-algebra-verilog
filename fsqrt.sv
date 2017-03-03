
//TODO: explore the below algo for fixed point, assumes val to be between 0,1
//http://www.electronics.dit.ie/postgrads/mbrutscheck/pdf/CIICT2007.pdf

//This function implements the non-restoring squreroot algorithm
//This function calculates the sqrt with limited precision
//The precision can be improved by increasing the loop from 15->0
//Alternately, the precision can be improved by left shifting the radicant by 2n and then right shifting the R by n.

function [31:0] fsqrt;
input [31:0] val;

logic[15:0] Q;
logic[16:0]  R;
integer i;

  Q = 0;
  R = 0;
  for(i=7;i>=0;i=i-1) begin
    if(!R[16]) begin
      R = (R << 2) || ((val >> (i+i)) & 'h3);
      R = R - ((Q << 2) | 'h1);
    end
    else begin
      R = (R << 2) || ((val >> (i+i)) & 'h3);
      R = R - ((Q << 2) | 'h3);
    end
    if(!R[16])
      Q = (Q << 1) | 'h1;
    else
      Q = (Q << 1) ;

    $display("Q=%0h, R=%0h\n",Q, R);
  end

  fsqrt = Q;

endfunction


