function  b =  barycenter_cell_of_points(C)
% Written by AI
% Hyperbolic barycenter
    points = zeros(length(C), 1);
    for i = 1:length(C)
        points(i) = C{i}(1) + 1i * C{i}(2);
    end
    % points: N x 1 vector of complex numbers inside unit disk
    
    % Objective function: sum of squared hyperbolic distances
    distSq = @(z) sum(acosh(1 + 2 * abs(z - points).^2 ./ ...
        ((1 - abs(z).^2) .* (1 - abs(points).^2))) .^ 2);
    
    % Use Euclidean mean as initial guess
    initialGuess = mean(points);
    
    % Minimize
    options = optimset('Display','off');
    ba = fminsearch(distSq, initialGuess, options);
    b = [real(ba); imag(ba)];
end