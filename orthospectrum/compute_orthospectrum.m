function orthospectrum = compute_orthospectrum(to_music, index_curve, chi_sigma, how_many_values, draw, number_sample_points_approximate_density_single_homotopy_class, negativity_tolerance)
%COMPUTE_ORTHOSPECTRUM Computes the orthospectrum by iteratively
%   identifying and subtracting cumulative functions from the empirical CDF.
%
%   If subtracting a candidate produces significant negative values in the
%   residual, the guess was too small. In that case we retry with a larger
%   minimum length by searching further into the derivative.

arguments
    to_music 
    index_curve 
    chi_sigma 
    how_many_values = 10;
    draw = false
    number_sample_points_approximate_density_single_homotopy_class = 500000;
    negativity_tolerance = -0.02;  % how negative f_vals can go before we reject the guess
end

orthospectrum = zeros(how_many_values, 1);
length_geodesic = guess_length_geodesics_from_to_music(to_music, index_curve, chi_sigma);
[x_vals, f_vals] = compute_cumufun_from_to_music(to_music, index_curve);

for element_spectrum_index = 1:how_many_values
    
    % Save state before attempting subtraction, so we can retry
    x_vals_backup = x_vals;
    f_vals_backup = f_vals;
    
    success = false;
    search_start_index = 0;  % tells guess_minimum_length to skip this many candidates
    max_retries = 10;
    
    for attempt = 1:max_retries
        min_length = guess_minimum_length(x_vals, f_vals, 0.1, search_start_index);
        
        [x_one_homclass, f_one_homclass] = expected_cumufun_one_homotopy_class( ...
            min_length, length_geodesic, number_sample_points_approximate_density_single_homotopy_class);
        
        % Align endpoints for smoother subtraction
        if x_one_homclass(end) < x_vals(end)
            x_one_homclass(end) = x_vals(end);
        else
            x_vals(end) = x_one_homclass(end);
        end
        
        [x_trial, f_trial] = subtract_cumufuns(x_one_homclass, f_one_homclass, x_vals, f_vals);
        
        % Check if the residual has significant negative values
        min_residual = min(f_trial(isfinite(f_trial)));
        
        if min_residual >= negativity_tolerance
            % Subtraction is acceptable
            x_vals = x_trial;
            f_vals = f_trial;
            orthospectrum(element_spectrum_index) = min_length;
            success = true;
            break;
        else
            % The guess was too small: the candidate CF overshoots the data.
            % Restore state and retry, skipping past this candidate.
            if draw
                fprintf('Attempt %d: min_length=%.4f rejected (min residual=%.4f). Retrying...\n', ...
                    attempt, min_length, min_residual);
            end
            x_vals = x_vals_backup;
            f_vals = f_vals_backup;
            search_start_index = search_start_index + 5;
        end
    end
    
    if ~success
        warning('compute_orthospectrum:noValidGuess', ...
            'Could not find a valid minimum length after %d attempts for spectrum element %d. Using last candidate.', ...
            max_retries, element_spectrum_index);
        % Use the last attempted value as fallback
        orthospectrum(element_spectrum_index) = min_length;
        [x_one_homclass, f_one_homclass] = expected_cumufun_one_homotopy_class( ...
            min_length, length_geodesic, number_sample_points_approximate_density_single_homotopy_class);
        if x_one_homclass(end) < x_vals(end)
            x_one_homclass(end) = x_vals(end);
        else
            x_vals(end) = x_one_homclass(end);
        end
        [x_vals, f_vals] = subtract_cumufuns(x_one_homclass, f_one_homclass, x_vals, f_vals);
    else
        if draw
            % Use explicit figure() call to ensure a new standalone window
            % appears even when called from inside a uifigure app callback.
            fig = figure('Visible', 'on');
            plot(x_one_homclass, f_one_homclass)
            hold on
            plot(x_vals_backup, f_vals_backup)
            plot(x_vals, f_vals)
            hold off
            title(sprintf('Spectrum element %d, attempt %d (min\\_length=%.4f)', ...
                element_spectrum_index, attempt, min_length));
            legend('Candidate CF', 'Current residual', 'After subtraction');
            drawnow;
        end
    end
    
end

end