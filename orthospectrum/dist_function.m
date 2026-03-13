function d = dist_function(y0, theta, s)
%DIST_FUNCTION computes the distance from the point (0,y) and the
%intersection of the geodesics that starts from (0,y) with speed theta
%(theta is an angle in (-pi, pi) )
% and
%the geodesics that stays at distance s from x=0 and passes through
%(tanh(2s), 0).


y = tanh(y0/2);


pv = point_and_tg_vector([0;y],[cos(theta); sin(theta)]);
[center, radius] = pv.geodesic_circonference_tg_vec;

sv = point_and_tg_vector([tanh(s/2);0],[0; 1]);
[center2, radius2] = sv.geodesic_circonference_tg_vec;

s = find_intersection_circles(center, radius, center2, radius2);

if isempty(s)
    d = Inf;
elseif ~isempty(s)
    found = false;
    for h = 1:size(s,2)
        point = s(:,h);
        if norm(point)<1
            found = 1;
            break
        end
    end
    if ~found
        throw(MException("unexpected", "There is an intersection but not in the plane. This is strange."))
    end
    d = distance_two_points([0;y], point);
end

end