function [x_eval ,f_vals] = expected_cumufun_one_homotopy_class(distance, length_geodesic, number_sample_points_approximate_density_single_homotopy_class)
%EXPECTED_CUMUFUN_ONE_HOMOTPY_CLASS Summary of this function goes here
%   Detailed explanation goes here
    function_fixed_s = @(y,theta) dist_function(y, theta, distance);
    width_x =  4*length_geodesic;

    x = -width_x/2 + width_x * rand(number_sample_points_approximate_density_single_homotopy_class, 1);
    u = rand(number_sample_points_approximate_density_single_homotopy_class, 1);
    theta = asin(2*u - 1);
    
    vals1 = zeros(1, number_sample_points_approximate_density_single_homotopy_class);
    for ind = 1:number_sample_points_approximate_density_single_homotopy_class
        vals1(ind) = function_fixed_s(x(ind), theta(ind));
    end

    finitevals = vals1(isfinite(vals1));
    AL = width_x * pi;
    AB = length(finitevals)/number_sample_points_approximate_density_single_homotopy_class * AL;
    num_inf_to_add = round(((length_geodesic*pi)/AB)*length(finitevals))-length(finitevals);
    
    vals = [finitevals, Inf*ones(1,num_inf_to_add)];

    [f_vals, x_eval] = ecdf(vals);

    num_finite_values = sum(isfinite(x_eval));
    x_eval = x_eval(1:num_finite_values);
    f_vals = f_vals(1:num_finite_values);
end