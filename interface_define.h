
interface immul #(parameter M = 7, N = 8, P = 9) ;
//2D array for A, B and R
logic [0:M-1] [0:N-1][31:0] A;
logic [0:N-1] [0:P-1][31:0] B;
logic [0:M-1] [0:P-1][31:0] R;
endinterface: immul

interface imadd #(parameter M = 7, N = 8) ;
//2D array for A, B and R
logic [0:M-1] [0:N-1][31:0] A;
logic [0:M-1] [0:N-1][31:0] B;
logic [0:M-1] [0:N-1][31:0] R;
endinterface: imadd

interface isum_tr #(parameter M = 7, N = 8) ;
logic [0:M-1] [0:N-1][31:0] Q;
logic [0:M-1][31:0] X;
logic [0:M-1][31:0] P;
logic [0:N-1][31:0] R;
endinterface: isum_tr

interface iqr #(parameter M = 7, N = 8) ;
//2D array for A, Q and R
logic [0:M-1] [0:N-1][31:0] A;
logic [0:M-1] [0:N-1][31:0] Q;
logic [0:N-1] [0:N-1][31:0] R;
endinterface: iqr
