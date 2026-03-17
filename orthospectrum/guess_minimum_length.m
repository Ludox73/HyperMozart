function min_length = guess_minimum_length(x_vals, f_vals, length_geodesic)
%GUESS_MINIMUM_LENGTH Find the smallest distance s such that the expected
%   CDF for a single homotopy class of distance s is everywhere <= the
%   empirical cumulative distribution function (x_vals, f_vals).
%
%   Uses binary search over the interval [lowest x_val, first x where
%   f_vals > 0.2]. Sample points increase from 10000 to 100000 across
%   10 rounds of binary search for speed then accuracy.
%
%   Arguments:
%     x_vals, f_vals    — the current empirical CDF
%     length_geodesic   — guessed length of the closed geodesic

arguments
    x_vals
    f_vals
    length_geodesic
end

num_rounds = 15.;
n_samples_start = 200000;
n_samples_end   = 200000;

% --- Determine search interval ---
% Lower bound: first finite x value
finite_mask = isfinite(x_vals) & isfinite(f_vals);
x_finite = x_vals(finite_mask);
f_finite = f_vals(finite_mask);

s_low = x_finite(1);

% Upper bound: first x where f_vals > 0.2
idx_upper = find(f_finite > 0.2, 1, 'first');
if isempty(idx_upper)
    s_high = x_finite(end);
else
    s_high = x_finite(idx_upper);
end

% Safety: ensure interval is valid
if s_low >= s_high
    min_length = s_low;
    return;
end

% --- Prepare the empirical CDF for comparison ---
% Clean and deduplicate for interpolation
[x_emp_u, idx_u] = unique(x_finite, 'last');
f_emp_u = f_finite(idx_u);

% --- Binary search ---
for round = 1:num_rounds
    s_mid = (s_low + s_high) / 2;
    
    % Number of sample points increases linearly across rounds
    n_samples = round_val(n_samples_start + (n_samples_end - n_samples_start) * (round - 1) / (num_rounds - 1));
    
    % Compute the expected CDF for candidate distance s_mid
    [x_cand, f_cand] = expected_cumufun_one_homotopy_class(s_mid, length_geodesic, n_samples);
    
    % Check if f_cand <= f_empirical everywhere (on the candidate's x grid)
    % Interpolate the empirical CDF onto the candidate's x values
    f_emp_on_cand = interp1(x_emp_u, f_emp_u, x_cand, 'previous', 0);
    
    % The candidate CDF is valid if it is everywhere <= the empirical CDF
    % (with a small tolerance for noise)
    if all(f_cand <= f_emp_on_cand + 0.0001)
        % Candidate fits under the empirical CDF → s_mid is valid,
        % try to go smaller
        s_high = s_mid;
    else
        % Candidate exceeds the empirical CDF somewhere → s_mid is too small
        s_low = s_mid;
    end
end

min_length = (s_low + s_high) / 2;

end


function v = round_val(x)
    v = round(x);
end