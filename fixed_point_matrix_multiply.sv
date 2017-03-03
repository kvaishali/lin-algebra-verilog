
// A = mxn  B = nxp  R=AB (mxp)
//The scale of matrix (M,N,P) along with cycle time/process technology
//will determine the pipeline stages required.
//This module calculates this over 2 cycles.
//cycle1 - the M*N*P multiplications are calculated in cycle1
//cycle2 - the n additions for each of the m*p elements are done in cycle2

module fixed_point_matrix_multiply (input bit clk, interface mmul);
parameter M=8, N=8, P=9;

integer i,j,k,p;
integer i_f,j_f,k_f;
integer i_f2,j_f2,k_f2;
logic [M][P][N][32] R_tmp;
logic [M][P][32] R_elem;

//cycle1
always_ff @(posedge clk) begin
  for(k_f=0;k_f<M;k_f=k_f+1) begin
    for(i_f=0;i_f<P;i_f=i_f+1) begin
     for(j_f=0;j_f<N;j_f=j_f+1) begin
      R_tmp[k_f][i_f][j_f] <= fmult(mmul.A[k_f][j_f] , mmul.B[j_f][i_f]);
     end
    end
  end
end

always_comb begin 
 
    R_elem = {M*P{32'h0}};
    for(k=0;k<M;k=k+1) begin
      for(i=0;i<P;i=i+1) begin
       for(j=0;j<N;j=j+1) begin
        R_elem[k][i] = R_elem[k][i] + R_tmp[k][i][j];
    //pr_fval(mmul.A[k][j]);
    //pr_fval(mmul.B[j][i]);
    //pr_fval(mmul.R[k][i]);
       end
      end
    end

end //always

//cycle2
always_ff @(posedge clk) begin
    for(k_f2=0;k_f2<M;k_f2=k_f2+1) begin
      for(i_f2=0;i_f2<P;i_f2=i_f2+1) begin
        mmul.R[k_f2][i_f2] <= R_elem[k_f2][i_f2];
      end
    end
end


endmodule
