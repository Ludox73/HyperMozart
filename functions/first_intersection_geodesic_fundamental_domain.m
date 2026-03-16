function [point_and_tg_arrival, index_side] = first_intersection_geodesic_fundamental_domain(point_and_tg_vec,collection_circles, to_avoid)
%FIRST_INTERSECTION_GEODESIC_FUNDAMENTAL_DOMAIN 
% It finds the first intersection among a geodesic and the sides.
arguments
    point_and_tg_vec point_and_tg_vector
    collection_circles cell
    to_avoid = -1
end

[c1, r1] = geodesic_circonference_tg_vec(point_and_tg_vec);

int_points = zeros(2, 20); %If we work with hexagons, 12 should be ok.
indices_sides_intersection = zeros(2, 20);

num_intersections_found = 0;
for ind=1:length(collection_circles)
    if ind ~= to_avoid
        s = find_intersection_circles(c1, r1, collection_circles{ind}{1}, collection_circles{ind}{2});
        if ~isempty(s)
            num_intersections_found = num_intersections_found + 2;
            int_points(:, num_intersections_found-1:num_intersections_found) = s;
            if size(s, 2) ~= 2
                throw(MException("Unexpected_output", "We expect two circles to intersect in 2 or zero point. This does not look to be the case."))
            end
            indices_sides_intersection(num_intersections_found - 1) = ind;
            indices_sides_intersection(num_intersections_found) = ind;
        end
    end
end

int_points = int_points(:, 1:num_intersections_found);
indices_sides_intersection = indices_sides_intersection(1:num_intersections_found);

if det([point_and_tg_vec.point-c1, point_and_tg_vec.tg_vector])>0
    go_clockwise = false;
else
    go_clockwise = true;
end

number_of_points = size(int_points, 2);
arc_lengths = zeros(1,number_of_points);

for i = 1:number_of_points
    arc_lengths(i) = angleCW2D(point_and_tg_vec.point-c1, int_points(:,i)-c1, go_clockwise);
end

[~, index_min] = min(arc_lengths);

point_and_tg_arrival_point = int_points(:, index_min);
assert( norm(point_and_tg_arrival_point)<=1 )

ray = point_and_tg_arrival_point-c1;
if ~go_clockwise
    point_and_tg_arrival_vec = [-ray(2);ray(1)];
else
    point_and_tg_arrival_vec = [ray(2);-ray(1)];
end
point_and_tg_arrival_vec = point_and_tg_arrival_vec/norm(point_and_tg_arrival_vec)* (2*(1-norm(point_and_tg_arrival_point)^2))^2;

point_and_tg_arrival=point_and_tg_vector(point_and_tg_arrival_point, point_and_tg_arrival_vec);

index_side=indices_sides_intersection(index_min);
end