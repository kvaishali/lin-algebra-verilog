
// A = mxn  B = mxn  R=A+B (mxn)


module fixed_point_matrix_add(input bit clk, interface imadd);
parameter M = 7;
parameter N = 8;

integer j,k;

always_ff @(posedge clk) begin
 for(k=0;k<M;k=k+1) begin //row
   for(j=0;j<N;j=j+1) begin  //column
    imadd.R[k][j] <= imadd.A[k][j] + imadd.B[k][j];
   end
 end
end //always

endmodule
