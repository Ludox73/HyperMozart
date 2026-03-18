function [out_hex, out_side, isometry] = pairing_from_gluing(gluing, in_hex, in_side, twisted_params, intersection_point, polytopes)
%PAIRING_FROM_GLUING  Generic pairing lookup driven by a gluing struct.
%
% Given the current hexagon index and side index, returns the target
% hexagon, target side, and the isometry needed to continue the geodesic.
%
% Inputs:
%   gluing            - struct produced by create_gluing_standard_S2 (or similar)
%   in_hex            - index of the current fundamental domain (1-based)
%   in_side           - index of the side being crossed (1-based)
%   twisted_params    - vector of Fenchel-Nielsen twist parameters [t1, t2, t3]
%   intersection_point - 2D point (in Poincare disk) where the geodesic hits
%   polytopes         - cell array of polytope vertex cells
%
% Outputs:
%   out_hex  - index of the next fundamental domain
%   out_side - index of the entry side in the next fundamental domain
%   isometry - hyperbolic isometry to apply to continue the geodesic

p = gluing.pairings{in_hex, in_side};

if strcmp(p.type, 'simple')
    isometry = isometry_H2_two_points_poincare( ...
        polytopes{in_hex}{p.src_vtx(1)}, ...
        polytopes{in_hex}{p.src_vtx(2)}, ...
        polytopes{p.tgt_hex}{p.tgt_vtx(1)}, ...
        polytopes{p.tgt_hex}{p.tgt_vtx(2)});
    out_hex  = p.tgt_hex;
    out_side = p.tgt_side;

elseif strcmp(p.type, 'twisted')
    t = twisted_params(p.twist_param_index);
    if p.twist_sign == -1
        t = 2*pi - t;
    end
    [isometry, overshoot] = compute_isometry_with_twisted_parameter( ...
        intersection_point, ...
        polytopes{in_hex}{p.src_vtx(1)}, ...
        polytopes{in_hex}{p.src_vtx(2)}, ...
        polytopes{p.primary_tgt_hex}{p.primary_vtx(1)}, ...
        polytopes{p.primary_tgt_hex}{p.primary_vtx(2)}, ...
        polytopes{p.secondary_tgt_hex}{p.secondary_vtx(1)}, ...
        polytopes{p.secondary_tgt_hex}{p.secondary_vtx(2)}, ...
        t);
    if overshoot == 0 || overshoot == 2
        out_hex  = p.primary_tgt_hex;
        out_side = p.primary_tgt_side;
    else
        out_hex  = p.secondary_tgt_hex;
        out_side = p.secondary_tgt_side;
    end

else
    error('pairing_from_gluing: unknown pairing type ''%s'' at pairings{%d,%d}', ...
        p.type, in_hex, in_side);
end

end
