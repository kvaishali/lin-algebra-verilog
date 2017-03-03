
//This module implements calculating the pk-1 vector where
//  pk-1 = SUM ( dot(qi,xk) * qi ), i=0, k-1
//There is logic for k vector dot products and k vector-scalar product.
//The sum of these is returned back as pk-1 vector
//The parent module ensures that the qi vectors when i > k-1 are
//initialized to 0 so no special casing is needed here.

//To DO - implement the numerically stable modified Gram Schimdt
//This Modified algorithm reqires sequential operation where by each
//projection is subtracted from X and then the updated X is used for
//next projection.


module projection_summary (input bit clk,
interface isum_tr
);

parameter M = 3;
parameter N = 3;
integer i1,i2,i3,j;
logic [0:N-1][0:M-1][31:0] Qvec, Qvec_c1;

//cycle 1
//calculate the vector dot products qi, xk
always_comb begin
  for(i1=0;i1<N-1;i1++) begin
    foreach (Qvec[i1][j]) Qvec[i1][j] = isum_tr.Q[j][i1];
  end
end

always_ff @(posedge clk) begin
  Qvec_c1 <= Qvec;
  for(i2=0;i2<N-1;i2++) begin
    isum_tr.R[i2] <= vecdot(isum_tr.X,Qvec[i2]);
  end

end


//cycle 2
//performs the vector-scalar and SUM operation over all N vectors
//May need additional pipelining,
always_comb begin
  isum_tr.P = {M{32'h0}};
  for(i3=0;i3<N-1;i3++) begin
    isum_tr.P = vecadd(isum_tr.P, vecscl(isum_tr.R[i3],Qvec_c1[i3]));
  end

end



function [31:0] vecdot;
input [0:M-1] [31:0] vec1;
input [0:M-1] [31:0] vec2;
integer i;

vecdot = 0;
foreach (vec1[i])
 vecdot = vecdot + fmult(vec1[i],vec2[i]);
endfunction

function [0:M-1][31:0] vecscl;
input [31:0] scalar;
input [0:M-1][31:0] vec;
integer i;

foreach (vec[i])
 vecscl[i] = fmult(vec[i],scalar);
endfunction

function [0:M-1][31:0] vecadd;
input [0:M-1][31:0] vec1;
input [0:M-1][31:0] vec2;
integer i;

foreach (vec1[i])
 vecadd = vec1[i]+vec2[i];
endfunction

endmodule
