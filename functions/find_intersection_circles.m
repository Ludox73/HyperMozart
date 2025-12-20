function intersectionPoints = find_intersection_circles(center1, radius1, center2, radius2)
    
    % Calculate the distance between the centers
    d = norm(center2 - center1);
    
    % Check if circles intersect
    if d > (radius1 + radius2) || d < abs(radius1 - radius2)
        intersectionPoints = []; % No intersection
        return;
    end
    
    % Calculate the intersection points
    a = (radius1^2 - radius2^2 + d^2) / (2 * d);
    h = sqrt(radius1^2 - a^2);
    
    % Find the midpoint between the two centers
    midpoint = center1 + (a / d) * (center2 - center1);
    
    % Calculate the intersection points
    intersection1 = midpoint + (h / d) * [center2(2) - center1(2); center1(1) - center2(1)];
    intersection2 = midpoint - (h / d) * [center2(2) - center1(2); center1(1) - center2(1)];
    
    intersectionPoints = [intersection1, intersection2];
end