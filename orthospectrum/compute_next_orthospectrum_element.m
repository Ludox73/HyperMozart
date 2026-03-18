function [min_length, x_vals_out, f_vals_out] = compute_next_orthospectrum_element(x_vals, f_vals, length_geodesic, n_samples_subtraction, draw)
%COMPUTE_NEXT_ORTHOSPECTRUM_ELEMENT Find the next element of the
%   orthospectrum and return the updated residual CDF.
%
%   Inputs:
%     x_vals, f_vals       — current residual empirical CDF
%     length_geodesic      — guessed length of the closed geodesic
%     n_samples_subtraction — number of sample points for the full-resolution
%                            CDF used in subtraction (default 100000)
%     draw                 — whether to plot the subtraction (default false)
%
%   Outputs:
%     min_length           — the found orthospectrum element
%     x_vals_out, f_vals_out — the residual CDF after subtraction

arguments
    x_vals
    f_vals
    length_geodesic
    n_samples_subtraction = 100000;
    draw = false;
end

x_vals_backup = x_vals;
f_vals_backup = f_vals;

% Find minimum length via binary search
min_length = guess_minimum_length(x_vals, f_vals, length_geodesic, n_samples_subtraction);

% Compute the expected CDF at full resolution for subtraction
[x_one_homclass, f_one_homclass] = expected_cumufun_one_homotopy_class( ...
    min_length, length_geodesic, n_samples_subtraction);

% Align endpoints for smoother subtraction
if x_one_homclass(end) < x_vals(end)
    x_one_homclass(end) = x_vals(end);
else
    x_vals(end) = x_one_homclass(end);
end

[x_vals_out, f_vals_out] = subtract_cumufuns(x_one_homclass, f_one_homclass, x_vals, f_vals);

if draw
    fig = figure('Visible', 'on');
    plot(x_one_homclass, f_one_homclass)
    hold on
    plot(x_vals_backup, f_vals_backup)
    plot(x_vals_out, f_vals_out)
    hold off
    title(sprintf('Orthospectrum element (min\\_length=%.4f)', min_length));
    legend('Candidate CF', 'Previous residual', 'After subtraction');
    xlim([0 25]);
    ylim([-0.2 1]);
    drawnow;
end

end
