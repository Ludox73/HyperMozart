function [new_ptv, new_poly, new_to_avoid, inters_ptv, side] = geodesic_step( ...
    ptv, poly, to_avoid, circles, gluing, twisted_params, polytopes)
%GEODESIC_STEP  One complete step of geodesic propagation on the surface.
%
%   [new_ptv, new_poly, new_to_avoid, inters_ptv, side] = geodesic_step(
%       ptv, poly, to_avoid, circles, gluing, twisted_params, polytopes)
%
%   Finds the first intersection of the geodesic with the boundary of the
%   current fundamental domain, then calls apply_pairing to carry the state
%   into the adjacent domain.
%
%   Inputs:
%     ptv           - point_and_tg_vector (current position and direction)
%     poly          - current fundamental-domain index (1-based)
%     to_avoid      - side index to skip (the side just entered from);
%                     use length(polytopes{poly})+1 to avoid nothing
%     circles       - precomputed circle data (from build_circles_from_polytopes)
%     gluing        - gluing struct (from create_gluing_*_S2)
%     twisted_params - [t1, t2, t3] Fenchel-Nielsen twist parameters
%     polytopes     - cell array of polytope vertex cells
%
%   Outputs:
%     new_ptv      - point_and_tg_vector after pairing (state for next step)
%     new_poly     - index of the next fundamental domain
%     new_to_avoid - side index to avoid on the subsequent step
%     inters_ptv   - point_and_tg_vector at the crossing (before pairing)
%     side         - index of the side that was crossed

[inters_ptv, side] = first_intersection_geodesic_fundamental_domain( ...
    ptv, circles{poly}, to_avoid);

[new_ptv, new_poly, new_to_avoid] = apply_pairing( ...
    inters_ptv, poly, side, gluing, twisted_params, polytopes);

end
