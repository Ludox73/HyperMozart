
function ang = angleCW2D(v1, v2)
% angleCW2D Returns the clockwise angle from v1 to v2 in degrees (0..360)
% v1, v2: 1x2 vectors

    % Validate input
    assert(numel(v1)==2 && numel(v2)==2, 'Inputs must be 1x2 vectors.');
    if norm(v1)==0 || norm(v2)==0
        error('Vectors must be non-zero.');
    end

    % Normalize to avoid scaling effects (optional but recommended)
    v1 = v1(:).' / norm(v1);
    v2 = v2(:).' / norm(v2);

    % Dot and 2D "cross" (determinant of [v1; v2])
    dp  = dot(v1, v2);
    det2 = v1(1)*v2(2) - v1(2)*v2(1);

    % Clockwise signed angle 
    ang = atan2(det2, dp);
end
