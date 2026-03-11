function d = dist_function_with_translates(y0, theta, s, length_geodesics)
%DIST_FUNCTION computes the distance from the point (0,y) and the
%intersection of the geodesics that starts from (0,y) with speed theta
%(theta is an angle in (-pi, pi) )
% and
%the geodesics that stays at distance s from x=0 and passes through
%(tanh(2s), 0).

param = 10;

L = zeros(param+1,1);

for k = -param/2:1:param/2
    L(k+param/2+1) = dist_function(y0+k*length_geodesics, theta, s);
end

d = min(L);
end