classdef test_geodesic_reversibility < matlab.unittest.TestCase
% TEST_GEODESIC_REVERSIBILITY
%   Verifies the time-reversal symmetry of geodesics on the genus-2 surface.
%
%   Strategy: run a geodesic forward for n intersections, recording the
%   surface state (position, velocity, polytope) *after* each pairing
%   isometry.  Then negate the velocity at the final state and run
%   backward for the same number of steps.  At reverse step m the
%   resulting state must coincide with the forward state n - m steps
%   earlier, with the velocity sign flipped.

    methods (Test)

        function testReversal(test)
            %% Parameters
            rng(42);                          % fixed seed → reproducible angle
            n_forward          = 5;           % intersections to run forward
            tol_point          = 1e-8;        % absolute tolerance on position
            tol_vel_rel        = 1e-6;        % relative tolerance on velocity

            lengths_curves     = [5, 1.5, 3];
            twisted_parameters = [0, 0, 0];   % zero twist keeps the algebra clean

            %% Build the surface
            gluing    = create_gluing_nonseparating_S2();
            polytopes = build_polytopes_from_gluing(gluing, lengths_curves);
            num_sides = length(polytopes{1});
            no_avoid  = num_sides + 1;        % sentinel meaning "avoid nothing"

            %% Pre-compute the geodesic circles for every polytope
            circles = build_circles_from_polytopes(polytopes);

            %% Initial state: barycenter of polytope 1, random direction
            p0 = barycenter_cell_of_points(polytopes{1});
            a  = rand() * 2 * pi;
            v0 = 20 * (2 / (1 - norm(p0)^2))^(-2) * [sin(a); cos(a)];

            %% Forward pass
            % fwd_p(:,k), fwd_v(:,k), fwd_h(k): surface state *after* k-1 steps.
            % Index k=1 is the initial state; index k=n+1 is after n steps.
            fwd_p = zeros(2, n_forward + 1);
            fwd_v = zeros(2, n_forward + 1);
            fwd_h = zeros(1, n_forward + 1);

            fwd_p(:, 1) = p0;
            fwd_v(:, 1) = v0;
            fwd_h(1)    = 1;

            cp = p0;  cv = v0;  ch = 1;  cav = no_avoid;

            for k = 1:n_forward
                [new_ptv, oh, os] = geodesic_step( ...
                    point_and_tg_vector(cp, cv), ch, cav, circles, gluing, twisted_parameters, polytopes);

                fwd_p(:, k+1) = new_ptv.point;
                fwd_v(:, k+1) = new_ptv.tg_vector;
                fwd_h(k+1)    = oh;

                cp = new_ptv.point;  cv = new_ptv.tg_vector;  ch = oh;  cav = os;
            end

            %% Reverse pass
            % Start from the last forward state with negated velocity.
            % Do NOT exclude any side (no_avoid): the reversed geodesic
            % must be free to immediately cross back through the entry side.
            rp  = fwd_p(:, n_forward + 1);
            rv  = -fwd_v(:, n_forward + 1);
            rh  = fwd_h(n_forward + 1);
            rav = no_avoid;

            for m = 1:n_forward
                [new_ptv_r, oh_r, os_r] = geodesic_step( ...
                    point_and_tg_vector(rp, rv), rh, rav, circles, gluing, twisted_parameters, polytopes);

                %% Check against the matching forward state
                ei = n_forward + 1 - m;   % expected forward-state index

                test.verifyEqual(oh_r, fwd_h(ei), ...
                    sprintf('Polytope mismatch at reverse step %d ', ...
                            '(expected %d, got %d)', m, fwd_h(ei), oh_r));

                err_p = norm(new_ptv_r.point - fwd_p(:, ei));
                test.verifyLessThanOrEqual(err_p, tol_point, ...
                    sprintf('Position error %.2e exceeds %.2e at reverse step %d', ...
                            err_p, tol_point, m));

                err_v = norm(new_ptv_r.tg_vector + fwd_v(:, ei)) / norm(fwd_v(:, ei));
                test.verifyLessThanOrEqual(err_v, tol_vel_rel, ...
                    sprintf('Velocity relative error %.2e exceeds %.2e at reverse step %d', ...
                            err_v, tol_vel_rel, m));

                rp = new_ptv_r.point;  rv = new_ptv_r.tg_vector;  rh = oh_r;  rav = os_r;
            end
        end

    end % methods (Test)

end
