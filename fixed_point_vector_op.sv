

//vector dot product using fixed point arithmetic
function [31:0] vecdot;
input [0:M-1] [31:0] vec1;
input [0:M-1] [31:0] vec2;
integer i;

vecdot = 0;
foreach (vec1[i])
 vecdot = vecdot + fmult(vec1[i],vec2[i]);
endfunction



//vector scalar product using fixed point arithmetic
function [0:M-1][31:0] vecscl;
input [31:0] scalar;
input [0:M-1][31:0] vec;
integer i;

foreach (vec[i])
 vecscl[i] = fmult(vec[i],scalar);
endfunction




//vector add product using fixed point arithmetic
//vector subtraction can be done by negating the subtractor
function [0:M-1][31:0] vecadd;
input [0:M-1][31:0] vec1;
input [0:M-1][31:0] vec2;
integer i;

foreach (vec1[i])
 vecadd = vec1[i]+vec2[i];
endfunction


