function [f, x] = my_ecdf(data)
%MY_ECDF Empirical cumulative distribution function.
%   [F, X] = MY_ECDF(DATA) returns the empirical CDF of DATA evaluated at
%   the sorted data points. Output matches MATLAB's built-in ecdf:
%     X has n+1 elements (first data value repeated to anchor F at 0)
%     F has n+1 elements, starting at 0 and ending at 1
%
%   Drop-in replacement for ecdf (Statistics and Machine Learning Toolbox).

data = data(:);
x = sort(data);
n = numel(x);
f = [0; (1:n)' / n];
x = [x(1); x];
end
