function orthospectrum = compute_orthospectrum(to_music,index_curve, chi_sigma, how_many_values, draw, number_sample_points_approximate_density_single_homotopy_class)
%COMPUTE_ORTHOSPECTRUM Summary of this function goes here
%   Detailed explanation goes here
arguments
    to_music 
    index_curve 
    chi_sigma 
    how_many_values = 10;
    draw = false
    number_sample_points_approximate_density_single_homotopy_class = 100000;
end

orthospectrum = zeros(how_many_values, 1);
length_geodesic = guess_length_geodesics_from_to_music(to_music,index_curve, chi_sigma);
[x_vals, f_vals] = compute_cumufun_from_to_music(to_music, index_curve);

if draw
    plot(x_vals, f_vals)
end

for element_spectrum_index = 1:how_many_values

    min_length = guess_minimum_length(x_vals, f_vals);

    orthospectrum(element_spectrum_index) = min_length;
    [x_one_homclass, f_one_homclass] = expected_cumufun_one_homotopy_class(min_length, length_geodesic, number_sample_points_approximate_density_single_homotopy_class);
    
    [x_vals, f_vals] = subtract_cumufuns(x_one_homclass, f_one_homclass, x_vals, f_vals);

    if draw
        plot(x_vals, f_vals)
    end
end

    

end


