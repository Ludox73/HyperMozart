classdef test_geodesic_reversibility < matlab.unittest.TestCase
% TEST_GEODESIC_REVERSIBILITY
%   Verifies the time-reversal symmetry of geodesics on the genus-2 surface.
%
%   Strategy: run a geodesic forward for n steps, recording the PRE-PAIRING
%   intersection state (point, tangent, polytope, side) at each step.
%   Start the reversed geodesic from the last pre-pairing intersection with
%   to_avoid = that side and negated tangent (identical structure to every
%   forward step, so angleCW2D never sees a zero-arc-length situation).
%   After each reverse step the POST-PAIRING state must match the
%   PRE-PAIRING forward state at the corresponding index: same point,
%   negated tangent direction.  Tangent magnitudes are NOT compared because
%   first_intersection_geodesic_fundamental_domain renormalises them to
%   (2*(1-|p|^2))^2, so after a pairing that moves p to q the round-trip
%   tangent magnitude carries a factor (1-|q|^2)/(1-|p|^2) != 1 whenever
%   the twist is nonzero.  The direction (unit vector) is unaffected.

    methods (Test)

        function testReversal(test)
            %% Parameters
            rng(42);
            n_forward          = 10;   % forward intersections to record
            tol_point          = 1e-8;
            tol_vel_rel        = 1e-6;

            lengths_curves     = [5, 1.5, 3];
            twisted_parameters = rand(1, 3)*2*pi;   % random twist exercises all pairing branches

            %% Build the surface
            gluing    = create_gluing_separating_S2();
            polytopes = build_polytopes_from_gluing(gluing, lengths_curves);
            num_sides = length(polytopes{1});
            no_avoid  = num_sides + 1;   % sentinel: avoid nothing at the very first step

            %% Pre-compute the geodesic circles for every polytope
            circles = build_circles_from_polytopes(polytopes);

            %% Initial state: barycenter of polytope 1, random direction
            p0 = barycenter_cell_of_points(polytopes{1});
            a  = rand() * 2 * pi;
            v0 = 20 * (2 / (1 - norm(p0)^2))^(-2) * [sin(a); cos(a)];

            %% Forward pass — record PRE-PAIRING intersection states
            % fwd_p(:,k), fwd_v(:,k): raw intersection point/tangent in
            %   polytope fwd_h(k), crossing side fwd_s(k), at step k.
            fwd_p = zeros(2, n_forward);
            fwd_v = zeros(2, n_forward);
            fwd_h = zeros(1, n_forward);
            fwd_s = zeros(1, n_forward);

            cp = p0;  cv = v0;  ch = 1;  cav = no_avoid;

            for k = 1:n_forward
                [new_ptv, oh, os, pvi, side] = geodesic_step( ...
                    point_and_tg_vector(cp, cv), ch, cav, circles, gluing, twisted_parameters, polytopes);

                fwd_p(:, k) = pvi.point;
                fwd_v(:, k) = pvi.tg_vector;
                fwd_h(k)    = ch;
                fwd_s(k)    = side;

                cp = new_ptv.point;  cv = new_ptv.tg_vector;
                ch = oh;             cav = os;
            end

            %% Reverse pass
            % Start at the last pre-pairing intersection with reversed velocity
            % and to_avoid = that side.  This mirrors the forward convention:
            % the geodesic is on the boundary pointing inward, and to_avoid
            % prevents re-crossing it immediately.  This avoids the zero-arc
            % problem where angleCW2D would return 2*pi for the current side.
            rp  = fwd_p(:, n_forward);
            rv  = -fwd_v(:, n_forward);
            rh  = fwd_h(n_forward);
            rav = fwd_s(n_forward);

            % Run n_forward-1 steps; after reverse step m the post-pairing state
            % must equal the pre-pairing forward state at index n_forward-m.
            for m = 1:(n_forward - 1)
                [new_ptv_r, oh_r, os_r] = geodesic_step( ...
                    point_and_tg_vector(rp, rv), rh, rav, circles, gluing, twisted_parameters, polytopes);

                ei = n_forward - m;

                test.verifyEqual(oh_r, fwd_h(ei), ...
                    sprintf('Polytope mismatch at reverse step %d (expected %d, got %d)', ...
                            m, fwd_h(ei), oh_r));

                err_p = norm(new_ptv_r.point - fwd_p(:, ei));
                test.verifyLessThanOrEqual(err_p, tol_point, ...
                    sprintf('Position error %.2e at reverse step %d', err_p, m));

                v_rev = new_ptv_r.tg_vector / norm(new_ptv_r.tg_vector);
                v_fwd = fwd_v(:, ei)       / norm(fwd_v(:, ei));
                err_v = norm(v_rev + v_fwd);   % should be ~0: unit vectors must be antiparallel
                test.verifyLessThanOrEqual(err_v, tol_vel_rel, ...
                    sprintf('Velocity direction error %.2e at reverse step %d', err_v, m));

                rp = new_ptv_r.point;  rv = new_ptv_r.tg_vector;
                rh = oh_r;             rav = os_r;
            end
        end

    end % methods (Test)

end
