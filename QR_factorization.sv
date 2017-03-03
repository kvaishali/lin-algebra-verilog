

//This module takes a full ranked matrix A (mxn) and return two factor matrices Q (mxn orthonormal matrix) and R (nxn) upper traingular matrix.
//It uses Gram-Schimdt algorithm.
// A = mxn  Q = mxn  R=nxn
// Q is orthonormal matrix, QtQ = I (Qt is Q transpose)
// R is upper traingular matrix of dimension nxn

////////
///Let A = [x0  x1  x2  ... xn-1] where xn-1 is a column vector of size mx1
///Let Q = [q0  q1  q2  ... qn-1] where qn-1 is a column vector of size mx1
///Let P = [p0  p1  p2  ... pn-1] where pn-1 is a column vector of size mx1

//There are many methods for computing the QR factorization. 
//This will focus on the method that uses the Gram-Schmidt algorithm 
//for orthogonalizing a full-rank matrix. We use this algorithm 
//to create Q. Let {xi}ni=1 be a basis for the inner product space V. 
//Let
//
//q1 = x1 / ||x1|| 
//and define q2,q3,...,qn recursively by
//qk= (xk - pk-1) / ||xk-pk-1|| , k=2,...,n,
//
//where
//
//pk-1 = SUM ( dot(qi,xk) * qi ), i=0, k-1
//
//and p0 = 0. Then the set {qi}ni=1 is an orthonormal basis for V .
//
//For the above algorithm,let rjk = <qj,xk> when j<k and rkk = ||xk-pk-1||

//This algorithm is implemented using state machine.
//Each state calculates qi and few elements of the R matrix.
//The calculation of qi happens over 2 cycles but for larger scale
//matrix, this can be pipelined more if required.



module QR_factorization (input bit clk, input bit reset, input bit start, interface qr_if);
parameter M = 3;
parameter N = 3;

logic sum_if_vld;

isum_tr #(.N(N), .M(M)) sum_if();


//This module calculates the pk-1 during each state.
projection_summary #(M,N) projection_summary(
.clk (clk),
.isum_tr(sum_if)
);




parameter [1:0] 
IDLE = 2'd0,
S0 = 2'd1,
SN = 2'd2,
WAIT = 2'd3;


logic [1:0] state ;
logic [31:0] index, index_r, vnorm ,count;
logic [0:M-1][31:0] qvec;
logic [31:0] n_minus1;

assign n_minus1 = N - 1;

always_ff @(posedge clk) begin
  if(reset) begin
    count <= 0;
    qr_if.R <= {(N*N){32'h0}};
    sum_if.Q <= {(M*N){32'h0}};
    index_r <= 'h0;;
  end
  else begin 
    count <= count + 1;
    index_r <= index;

    if((index_r == n_minus1) && (index == 0))
      qr_if.Q <= sum_if.Q;

    if(state == SN) begin

     //$write("========count = %d state = %d, index=%d======\n",count, state,index);
     $write("vnorm  and qpnorm qvec\n");
      pr_fval(vnorm);
      foreach (qvec[j]) pr_fval(qvec[j],1'b0); //$write("0x%h ",qvec[j]);
     $write("qpnorm done\n");


     foreach (qvec[j]) sum_if.Q[j][index] <= qvec[j];
     foreach (sum_if.R[j]) begin
      if(j < index) qr_if.R[j][index] <= sum_if.R[j];
      else if (j==index) qr_if.R[index][index] <= vnorm;
      else qr_if.R[j][index] <= 32'd0;
     end

    end
  end
end

always_comb begin
 if(state == SN) begin

   //call qpnorm to calculate q and r vector
   //{qvec, vnorm} = qpnorm(sum_if.X,sum_if.P); 
   qpnorm(sum_if.X,sum_if.P, qvec, vnorm); 

 end
end

always_ff @(posedge clk) begin
 if(reset) begin
   state <= IDLE;
   foreach (sum_if.X[j]) sum_if.X[j] <= 32'h0;
 end
 else begin
  case(state) 

    IDLE: begin
      if(start) begin 
        state <= WAIT;
	index <= 'h0;
	sum_if_vld <= 1;
        foreach (sum_if.X[j]) sum_if.X[j] <= qr_if.A[j][0];
      end
      else begin
        state <= IDLE;
	sum_if_vld <= 0;
      end
    end

    SN: begin
      foreach (sum_if.X[j]) sum_if.X[j] <= qr_if.A[j][index + 'h1];
      if(index == n_minus1) begin
        state <= IDLE;
	index = 0;
	sum_if_vld <= 0;
      end
      else begin
        state <= WAIT;
      end
    end

    WAIT: begin
       index = index + 'h1;
       state <= SN;
    end

  endcase
 end
end




//calculate the norm of vec diff ||vec1-vec2||

function void qpnorm (
input logic [0:M-1][31:0] vec1,
input logic [0:M-1][31:0] vec2,
output logic [0:M-1][31:0] qvec,
output logic [31:0] vnorm
);
integer i;
logic [31:0] norm, vnorm_recip;
logic [0:M-1][31:0] ovec;

 norm = 32'h0;
 $display("Ovec\n");
 foreach (vec1[i]) begin
   ovec[i] = vec1[i] - vec2[i];
   norm = norm + fmult(ovec[i],ovec[i]);
   pr_fval(ovec[i]);
   pr_fval(norm);
 end


 vnorm = vsqrt(norm);
 vnorm_recip = fdiv(32'h8000,vnorm);

 $display("inside function qpnorm\n");
 pr_fval(norm);
 pr_fval(vnorm);
 pr_fval(vnorm_recip);

 foreach (ovec[i]) begin
   qvec[i] = fmult(ovec[i],vnorm_recip);
 end

endfunction



//Uses approximation to calculate the sqrt

function [31:0] vsqrt;
input [31:0] val;
logic [31:0] square = 32'h8000; //1.0 
logic [31:0] delta = 32'h18000; //3.0 

  while (square <= val) begin 
     square = square + delta; 
     delta = delta + 32'h10000;  //2.0
  end 
  //vsqrt = (delta/2 - 1); 
  vsqrt = fdiv(delta, 32'h10000) - 32'h8000; 
endfunction


`include "fixed_point_vector_op.sv"
//`include "mfunc.sv"

endmodule
