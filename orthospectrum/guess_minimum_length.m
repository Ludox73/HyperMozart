function min_length = guess_minimum_length(x_vals, f_vals, tol3, skip_count)
%GUESS_MINIMUM_LENGTH x_vals and f_vals represent the cumulative
%distribution function from which we are trying to get the length of the
%shortest orthogonal geodesics.
%
%   skip_count: number of threshold-crossing regions to skip before
%   accepting a candidate. This is used when a previous guess turned out
%   to be too small (subtraction produced negative residuals).
%
%   The guess is always constrained to be BEFORE f_vals reaches 0.1.

arguments
    x_vals 
    f_vals 
    tol3 = 0.1;
    skip_count = 0;
end

x_vals = x_vals(2:end);
f_vals = f_vals(2:end);

% 1. Define a new uniform x-axis
x_new = (min(x_vals) : 0.01 : max(x_vals))';
f_new = zeros(size(x_new));

% 2. Resample onto uniform grid
window = 0.001;
for i = 1:length(x_new)
    x0 = x_new(i);
    mask = (x_vals >= x0 - window) & (x_vals <= x0 + window);
    if any(mask)
        f_new(i) = mean(f_vals(mask));
    else
        f_new(i) = NaN;
    end
end

f_vals = f_new;
x_vals = x_new;

% 3. Find the upper bound: the first x where f_vals reaches 0.05.
%    The guess must come strictly before this point.
f_cutoff = 0.05;
upper_bound_idx = find(f_vals >= f_cutoff, 1, 'first');
if isempty(upper_bound_idx)
    upper_bound_idx = length(f_vals);
end

% 4. Empirical Derivative (only up to the upper bound)
dy = diff(f_vals(1:upper_bound_idx));
dx = diff(x_vals(1:upper_bound_idx));
df_dx = dy ./ dx;

% 5. Find threshold crossings — places where the derivative first exceeds tol3.
%    Each such crossing is a candidate for the minimum length.
above_tol = df_dx > tol3;

% Find all rising edges: transitions from below to above threshold
crossings_found = 0;
min_length = x_vals(upper_bound_idx);  % fallback: right at the cutoff

for idx = 1:length(above_tol)
    if above_tol(idx)
        % Check if this is the start of a new region
        % (first point, or previous point was below threshold)
        if idx == 1 || ~above_tol(idx - 1)
            crossings_found = crossings_found + 1;
            if crossings_found > skip_count
                min_length = x_vals(idx);
                return;
            end
        end
    end
end

% If we exhausted all crossings without finding enough to skip,
% fall back to the last crossing found within the allowed range.
if crossings_found > 0
    for idx = length(above_tol):-1:1
        if above_tol(idx) && (idx == 1 || ~above_tol(idx-1))
            min_length = x_vals(idx);
            return;
        end
    end
end

end