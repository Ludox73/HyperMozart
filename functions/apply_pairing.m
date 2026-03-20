function [new_ptv, new_poly, new_to_avoid] = apply_pairing( ...
    inters_ptv, poly, side, gluing, twisted_params, polytopes)
%APPLY_PAIRING  Advance the geodesic state across a fundamental-domain boundary.
%
%   [new_ptv, new_poly, new_to_avoid] = apply_pairing(
%       inters_ptv, poly, side, gluing, twisted_params, polytopes)
%
%   Given a point_and_tg_vector at a boundary crossing, applies the gluing
%   isometry to carry the state into the adjacent fundamental domain.
%   For non-coherently oriented pairs the tangent vector additionally
%   undergoes the orientation-reversing correction (the point is left
%   unchanged, as verified by the warning below).
%
%   Inputs:
%     inters_ptv    - point_and_tg_vector at the crossing point (before pairing)
%     poly          - current fundamental-domain index (1-based)
%     side          - index of the side being crossed (1-based)
%     gluing        - gluing struct (from create_gluing_*_S2)
%     twisted_params - [t1, t2, t3] Fenchel-Nielsen twist parameters
%     polytopes     - cell array of polytope vertex cells
%
%   Outputs:
%     new_ptv      - point_and_tg_vector in the next fundamental domain
%     new_poly     - index of the next fundamental domain
%     new_to_avoid - side index to avoid on the subsequent intersection call

[new_poly, new_to_avoid, isometry] = pairing_from_gluing( ...
    gluing, poly, side, twisted_params, inters_ptv.point, polytopes);

[new_point, new_tvec] = isometry.apply_poincare_point_and_vector( ...
    inters_ptv.point, inters_ptv.tg_vector);

if is_row([poly, new_poly], gluing.noncoherent_pairs)
    num_sides = length(polytopes{new_poly});
    index2    = mod(new_to_avoid, num_sides) + 1;
    p1 = polytopes{new_poly}{new_to_avoid};
    p2 = polytopes{new_poly}{index2};

    z1_poinc = p1(1) + p1(2)*1i;
    z2_poinc = p2(1) + p2(2)*1i;
    z1 = 1i*(1 + z1_poinc)/(1 - z1_poinc);
    z2 = 1i*(1 + z2_poinc)/(1 - z2_poinc);
    x1 = real(z1);  y1 = imag(z1);
    x2 = real(z2);  y2 = imag(z2);
    c = (x1^2 + y1^2 - x2^2 - y2^2) / (2*(x1 - x2));
    r = sqrt((x1 - c)^2 + y1^2);

    M = [1, -(c - r); 1, -(c + r)];
    J = [-1, 0; 0, 1];

    np1_poinc  = new_point(1) + new_point(2)*1i;
    ntv1_poinc = new_tvec(1)  + new_tvec(2)*1i;
    np1  = 1i*(1 + np1_poinc)/(1 - np1_poinc);
    ntv1 = 2i/(-np1_poinc + 1)^2 * ntv1_poinc;

    iso_R = hyp_isometry_2d([], M \ J * M);
    [np, ntv] = iso_R.apply_upper_half_point_and_vector_orientation_reversing(np1, ntv1);

    back_np  = (np - 1i)/(np + 1i);
    back_ntv = (2i)/(np + 1i)^2 * ntv;

    new_point_corrected = [real(back_np); imag(back_np)];
    new_tvec_corrected  = [real(back_ntv); imag(back_ntv)];

    if norm(new_point - new_point_corrected) > 1e-4
        warning('apply_pairing: mirroring moved the point on the boundary. Possible error.');
    end

    % The point is invariant under the orientation reversal; use the
    % isometry output (new_point) rather than the back-converted value.
    new_ptv = point_and_tg_vector(new_point, new_tvec_corrected);
else
    new_ptv = point_and_tg_vector(new_point, new_tvec);
end

end
