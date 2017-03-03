

// Approximation  of  Alippi  and  Storti  Gajani:
//https://www.researchgate.net/profile/Giancarlo_Gajani/publication/224655702_Simple_approximation_of_sigmoidal_functions_realistic_design_of_digital_neural_networks_capable_of_learning/links/0deec52c74ba740d9b000000.pdf

function [31:0] fixed_point_sigmoid;
input [31:0] val;

logic [31:0] val_ext, val_int, val_t, val_half, val_one, fsig;

parameter I = 16;
parameter F = 15;

// val_t is decimal part of val with it's own sign
// val_t = val + |(val)|; (val) is defined as integer part of val
// y = (1/2 + val_t/4) / (2^|(val)|) when x <= 0


  val_ext = val[31] ? ~val + 32'h1 : val;
  val_int = 32'h0;
  val_int[I-1:0] = val[30:F];

  val_t = val + val_int;

  val_half = 32'h0;
  val_one = 32'h0;
  val_half[F-1] = 1'b1;
  val_one[F] = 1'b1;

  fsig = val_half + (val_t >> 2);
  fsig = fsig >> val_int;

  pr_fval(fsig);

  fixed_point_sigmoid = val[31] ? fsig : (val_one - fsig);

endfunction
