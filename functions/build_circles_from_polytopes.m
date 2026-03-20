function circles = build_circles_from_polytopes(polytopes)
%BUILD_CIRCLES_FROM_POLYTOPES  Pre-compute the geodesic circle for every side.
%
%   circles = build_circles_from_polytopes(polytopes)
%
%   For each fundamental domain and each consecutive pair of vertices,
%   computes the unique geodesic arc (a Euclidean circle orthogonal to the
%   unit circle) that spans the side, and returns its centre and radius.
%
%   Input:
%     polytopes - 1×N cell array; each entry is a 1×S cell of 2×1 vertex
%                 column vectors (as returned by rectangular_hexagon_centered
%                 or build_polytopes_from_gluing).
%
%   Output:
%     circles - 1×N cell array; circles{i} is a 1×S cell array where
%               circles{i}{s} = {centre, radius} for side s of polytope i.

num_poly  = length(polytopes);
num_sides = length(polytopes{1});
circles   = cell(num_poly, 1);

for i = 1:num_poly
    coll = cell(1, num_sides);
    for s = 1:num_sides
        s2  = mod(s, num_sides) + 1;
        seg = segment(polytopes{i}{s}, polytopes{i}{s2});
        [centre, radius] = geodesic_circonference(seg);
        coll{s} = {centre, radius};
    end
    circles{i} = coll;
end

end
