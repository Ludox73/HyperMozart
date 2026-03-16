
function ang = angleCW2D(v1, v2, going_clockwise)
% angleCW2D Returns the clockwise (or counterclockwise if the corresponding
%  flag is false) angle from v1 to v2 in radians in (0,...,2pi)
% v1, v2: 1x2 vectors
    arguments
        v1
        v2
        going_clockwise = true
    end

    % Validate input
    assert(numel(v1)==2 && numel(v2)==2, 'Inputs must be 2x1 vectors.');
    if norm(v1)==0 || norm(v2)==0
        error('Vectors must be non-zero.');
    end

    % I avoid normalizing since it takes time and should not be necessary.
    % v1 = v1 / norm(v1);
    % v2 = v2 / norm(v2);

    % Dot and 2D "cross" (determinant of [v1; v2])
    dp  = dot(v1, v2);
    det2 = v1(1)*v2(2) - v1(2)*v2(1);

    % Clockwise signed angle 
    if going_clockwise
        ang = 2*pi -  mod(atan2(det2, dp),2*pi);
    else
        ang = mod(atan2(det2, dp),2*pi);
    end

end
