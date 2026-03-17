function orthospectrum = compute_orthospectrum(to_music, index_curve, chi_sigma, how_many_values, draw, number_sample_points_approximate_density_single_homotopy_class)
%COMPUTE_ORTHOSPECTRUM Computes the orthospectrum by iteratively
%   identifying and subtracting cumulative functions from the empirical CDF.
%
%   For each element of the spectrum:
%     1. Use binary search (guess_minimum_length) to find the smallest
%        distance s whose expected CDF fits under the empirical CDF.
%     2. Compute the expected CDF at full resolution and subtract it.

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
    
    x_vals_backup = x_vals;
    f_vals_backup = f_vals;
    
    % Find minimum length via binary search
    min_length = guess_minimum_length(x_vals, f_vals, length_geodesic);
    
    orthospectrum(element_spectrum_index) = min_length;
    
    % Compute the expected CDF at full resolution for subtraction
    [x_one_homclass, f_one_homclass] = expected_cumufun_one_homotopy_class( ...
        min_length, length_geodesic, number_sample_points_approximate_density_single_homotopy_class);
    
    % Align endpoints for smoother subtraction
    if x_one_homclass(end) < x_vals(end)
        x_one_homclass(end) = x_vals(end);
    else
        x_vals(end) = x_one_homclass(end);
    end
    
    [x_vals, f_vals] = subtract_cumufuns(x_one_homclass, f_one_homclass, x_vals, f_vals);
    
    if draw
        fig = figure('Visible', 'on');
        plot(x_one_homclass, f_one_homclass)
        hold on
        plot(x_vals_backup, f_vals_backup)
        plot(x_vals, f_vals)
        hold off
        title(sprintf('Spectrum element %d (min\\_length=%.4f)', ...
            element_spectrum_index, min_length));
        legend('Candidate CF', 'Previous residual', 'After subtraction');
        drawnow;
    end
end

end