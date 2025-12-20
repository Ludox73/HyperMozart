function [point_and_tg_arrival, index_side] = first_intersection_geodesic_fundamental_domain(point_and_tg_vec,collection_circles, to_avoid)
%FIRST_INTERSECTION_GEODESIC_FUNDAMENTAL_DOMAIN 
% It finds the first intersection among a geodesic and the sides.
arguments
    point_and_tg_vec point_and_tg_vector
    collection_circles cell
    to_avoid int64 = -1
end

[c1, r1] = geodesic_circonference_tg_vec(point_and_tg_vec);

int_points = [];
indices_sides_intersection = [];

for ind=1:length(collection_circles)
    if ind ~= to_avoid
        s = find_intersection_circles(c1, r1, collection_circles{ind}{1}, collection_circles{ind}{2});
        int_points = [int_points, s];
        if ~isempty(s)
            indices_sides_intersection = [indices_sides_intersection,ind,ind];
        end
    end
end

if det([point_and_tg_vec.point-c1, point_and_tg_vec.tg_vector])>0
    dir = "counterclockwise";
else
    dir = "clockwise";
end

number_of_points = size(int_points, 2);
arc_lengths = zeros(1,number_of_points);

for i = 1:number_of_points
    arc_lengths(i) = angleCW2D(point_and_tg_vec.point-c1, int_points(:,i)-c1, dir);
end

[~, index_min] = min(arc_lengths);

point_and_tg_arrival_point = int_points(:, index_min);
assert( norm(point_and_tg_arrival_point)<=1 )

ray = point_and_tg_arrival_point-c1;
if strcmp(dir, "counterclockwise")
point_and_tg_arrival_vec = [-ray(2);ray(1)];
elseif strcmp(dir,"clockwise")
point_and_tg_arrival_vec = [ray(2);-ray(1)];
end
point_and_tg_arrival_vec = point_and_tg_arrival_vec/norm(point_and_tg_arrival_vec)* (2*(1-norm(point_and_tg_arrival_point)^2))^2;

point_and_tg_arrival=point_and_tg_vector(point_and_tg_arrival_point, point_and_tg_arrival_vec);

index_side=indices_sides_intersection(index_min);
end