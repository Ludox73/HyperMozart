function [x_vals, f_vals] = compute_cumufun_from_to_music(to_music, index_curve)
%COMPUTE_CUMUFUN_FROM_TO_MUSIC Compute cumulative function.

values = to_music(to_music(:,2) == index_curve, 1);

[f_vals, x_vals] = my_ecdf(values);
end