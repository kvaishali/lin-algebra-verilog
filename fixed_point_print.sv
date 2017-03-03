
//print fixed point value (the fractional part is printed as fract/2^15).
//sign+16.15
//
function pr_fval ( input [31:0] val = 0, input nline =1);
 if(nline == 0)
     $write("(%0d)%0h.%0d/32768 ",val[31],val[30:15],val[14:0]);
 else begin
   $display("val = (%0d)0x%0h.%d/32768\n",val[31],val[30:15],val[14:0]);
 end
endfunction


//print matrix in rowxcolumn fixed point format (2's complement)
task pr_matrix;
parameter M=3;
parameter N=3;
input [0:M-1][0:N-1][31:0] matrix;
integer i,j;
begin
$display("printing matrix\n");
foreach (matrix[i]) begin
 foreach (matrix[,j]) begin
  pr_fval(matrix[i][j],1'b0);
 end
 $write("\n");
 end
end
endtask



