function orthospectrum = compute_orthospectrum(to_music, index_curve, chi_sigma, how_many_values, draw, number_sample_points_approximate_density_single_homotopy_class)
%COMPUTE_ORTHOSPECTRUM Computes the orthospectrum by iteratively
%   identifying and subtracting cumulative functions from the empirical CDF.
%
%   This is a convenience wrapper that calls compute_next_orthospectrum_element
%   in a loop. For interactive use (e.g. from the app), call
%   compute_next_orthospectrum_element directly.

arguments
    to_music 
    index_curve 
    chi_sigma 
    how_many_values = 5;
    draw = false
    number_sample_points_approximate_density_single_homotopy_class = 100000;
end

orthospectrum = zeros(how_many_values, 1);
length_geodesic = guess_length_geodesics_from_to_music(to_music, index_curve, chi_sigma);
[x_vals, f_vals] = compute_cumufun_from_to_music(to_music, index_curve);

for element_spectrum_index = 1:how_many_values
    [min_length, x_vals, f_vals] = compute_next_orthospectrum_element( ...
        x_vals, f_vals, length_geodesic, ...
        number_sample_points_approximate_density_single_homotopy_class, draw);
    
    orthospectrum(element_spectrum_index) = min_length;
end

end