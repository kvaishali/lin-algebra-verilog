
`include "interface_define.h"
// A = mxn  B = mxn  R=A+B (mxn)


module test;
parameter M = 3;
parameter N = 3;

iqr #(.N(N), .M(M)) qr_if();

logic [31:0] T[0:M-1][0:N-1];

//assign qr_if.A = {(M*N){32'h11}};
initial begin
  $readmemh("amat.txt",T);
  foreach(T[i,j]) qr_if.A[i][j] = T[i][j];
  pr_matrix(qr_if.A);
end

bit clk;
bit reset;
bit start;

always begin
  #1 clk = ~clk;
end

initial begin
  clk = 0;
  start = 0;
  reset = 1;
  #4 reset = 0;
  #10 start = 1;
  #2 start = 0;

  #100 pr_matrix(qr_if.A);
  #100 pr_matrix(qr_if.Q);
  pr_matrix(qr_if.R);
  pr_matrix(mul_if.R);
  $finish;
end

QR_factorization #(M,N) factor_qr(
  .qr_if   (qr_if), 
  .clk     (clk), 
  .reset   (reset), 
  .start   (start)
);

immul #(.N(N), .M(M), .P(N)) mul_if();
fixed_point_matrix_multiply #(.N(N), .M(M), .P(N)) mmul(
  .mmul(mul_if), 
  .clk(1'b1)
);

always_comb begin
mul_if.A = qr_if.Q;
mul_if.B = qr_if.R;
add_if.A = qr_if.Q;
add_if.B = qr_if.Q;
end


imadd #(.N(7), .M(8)) add_if();
fixed_point_matrix_add #(8,7) madd(
  .clk(clk), 
   .imadd(add_if)
);


`include "mfunc.sv"

endmodule
