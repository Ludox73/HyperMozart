function polytopes = build_polytopes_from_gluing(gluing, lengths_curves)
%BUILD_POLYTOPES_FROM_GLUING  Construct hexagon polytopes from gluing data.
%
% Uses gluing.hex_curve_indices to determine which curve lengths feed into
% each hexagon's rectangular_hexagon_centered call.
%
% Inputs:
%   gluing        - gluing struct (must have .hex_curve_indices field)
%   lengths_curves - vector of curve lengths [L1, L2, L3, ...]
%
% Output:
%   polytopes - cell array of hexagon vertex cells

n = size(gluing.hex_curve_indices, 1);
polytopes = cell(1, n);
for i = 1:n
    idx = gluing.hex_curve_indices(i, :);
    polytopes{i} = rectangular_hexagon_centered( ...
        lengths_curves(idx(1))/2, ...
        lengths_curves(idx(2))/2, ...
        lengths_curves(idx(3))/2);
end

end
