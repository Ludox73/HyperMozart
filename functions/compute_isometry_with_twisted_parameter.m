function [isometry, overshoot] = compute_isometry_with_twisted_parameter(point, p1, p2, q1, q2, q3, q4, twisted_parameter, orientation)
%COMPUTE_ISOMETRY_WITH_TWISTED_PARAMETER TODO
if nargin < 9
    orientation = "preserving";
end

len_side = distance_two_points(p1,p2);

translation_amount = 2*len_side * (twisted_parameter / (2*pi));

if translation_amount > distance_two_points(point,p2) + len_side
    isometry = isometry_H2_two_points_with_translation_poincare(p1, p2, q1, q2, - (2*len_side-translation_amount), orientation);
    overshoot = 2;
elseif translation_amount > distance_two_points(point,p2)
    isometry = isometry_H2_two_points_with_translation_poincare(p1, p2, q3, q4, translation_amount-len_side, orientation);
    overshoot = 1;
else
    isometry = isometry_H2_two_points_with_translation_poincare(p1, p2, q1, q2, translation_amount, orientation);
    overshoot = 0;
end


end