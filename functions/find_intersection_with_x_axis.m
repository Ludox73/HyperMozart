function intersectionPoint = find_intersection_with_x_axis(point_and_tg_vec, width_x_axis)
    
    [c1, r1] = geodesic_circonference_tg_vec(point_and_tg_vec);

    % Check if circles intersect
    if abs(c1(2)) > r1
        intersectionPoint = []; % No intersection
        return;    
    end

    x_of_intersection_1 = c1(1) - sqrt(r1*r1 - c1(2)*c1(2));
    x_of_intersection_2 = c1(1) + sqrt(r1*r1 - c1(2)*c1(2));
    
    if (x_of_intersection_1 < width_x_axis) && (x_of_intersection_1 > -width_x_axis)
        intersectionPoint = [x_of_intersection_1; 0];
    elseif (x_of_intersection_2 < width_x_axis) && (x_of_intersection_2 > -width_x_axis)
        intersectionPoint = [x_of_intersection_2; 0];
    else
        intersectionPoint = []; % No intersection
    end
end