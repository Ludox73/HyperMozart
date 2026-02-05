function point2 = apply_upp_half_matrix(M, point)
%APPLY_UPP_HALF_MATRIX Summary of this function goes here
%   Detailed explanation goes here
point2 =(M(1,1) * point + M(1,2))/(M(2,1) * point + M(2,2));
end