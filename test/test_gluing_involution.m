classdef test_gluing_involution < matlab.unittest.TestCase
%TEST_GLUING_INVOLUTION  Verify that the gluing map is an involution.
%
%   Mathematical property tested
%   ----------------------------
%   For every side (hex, s) of every hexagon, take a point P on that side.
%   Send it to Q = gluing(P) which lands on some side (hex', s').
%   Send Q back through the gluing to get P' = gluing(Q).
%   We require:  dist_hyp(P, P') < tol.
%
%   This test was written to diagnose the twist bug: when the twist
%   parameter is nonzero the round-trip P -> Q -> P' should still
%   recover P exactly.  A non-involutive gluing causes geodesics to
%   drift across hexagon boundaries and produces incorrect dynamics.
%
%   Coverage
%   --------
%   - Separating S2 and nonseparating S2 decompositions
%   - All 24 sides (6 sides x 4 hexagons), simple and twisted pairings
%   - 5 interior test points per side  (t = 0.1, 0.3, 0.5, 0.7, 0.9)
%   - 7 twist configurations  (140 point tests per decomp per config)
%
%   How to run
%   ----------
%   Via the test runner (shows PASS/FAIL per method, with diagnostics):
%       results = runtests('test_gluing_involution');
%       table(results)
%
%   Via a detailed human-readable table in the command window:
%       test_gluing_involution.print_report()
%
%   See also: test_geodesic_reversibility

    properties (Constant)
        TOL     = 1e-6                        % max allowed hyp. distance P to P'
        TEST_TS = [0.1, 0.3, 0.5, 0.7, 0.9]  % arc-fraction sample points
        LENGTHS = [2, 3, 4]                   % curve lengths L1, L2, L3
    end

    % =====================================================================
    methods (Static)

        function pt = point_on_side(v1, v2, t)
        %POINT_ON_SIDE  Point at arc-fraction t in (0,1) along the geodesic
        %   from v1 to v2 in the Poincare disk.
        %   Uses the arc-angle parametrisation of the supporting Euclidean
        %   circle (which is orthogonal to the unit circle).
        %   v1, v2 : [x ; y] column vectors.
            [center, radius] = test_gluing_involution.geocircle(v1, v2);
            a1 = atan2(v1(2) - center(2), v1(1) - center(1));
            a2 = atan2(v2(2) - center(2), v2(1) - center(1));
            da = a2 - a1;
            da = mod(da + pi, 2*pi) - pi;   % wrap to (-pi, pi] -- selects the arc inside the disk
            at = a1 + da * t;
            pt = [ center(1) + radius * cos(at) ;
                   center(2) + radius * sin(at) ];
        end

        function [center, radius] = geocircle(sp, ep)
        %GEOCIRCLE  Euclidean circle supporting the unique hyperbolic
        %   geodesic through sp and ep (column vectors in the Poincare disk).
        %   The circle is orthogonal to the unit circle.
        %
        %   Formula: centre lies on the perpendicular bisector of the chord
        %   (sp, ep) and satisfies |c|^2 - r^2 = 1 (orthogonality).
            mx = (sp(1) + ep(1)) / 2;  my = (sp(2) + ep(2)) / 2;
            dx =  ep(1) - sp(1);       dy =  ep(2) - sp(2);
            sl = sqrt(dx^2 + dy^2);
            px = -dy / sl;             py =  dx / sl;      % unit perpendicular
            ned = (sl^2/4 - mx^2 - my^2 + 1) / (2*(mx*px + my*py));
            cx  = mx + px*ned;         cy  = my + py*ned;
            center = [cx ; cy];
            radius = sqrt(max(0, cx^2 + cy^2 - 1));
        end

        % -----------------------------------------------------------------
        function rows = run_involution_check(gluing_name, gluing, lengths, twists)
        %RUN_INVOLUTION_CHECK  Core round-trip test for one configuration.
        %
        %   Returns a struct array (one entry per (hex, side, t) triple).
        %   Fields
        %     .gluing_name     string label
        %     .hex             hexagon index (1-4)
        %     .side            side index (1-6)
        %     .t               arc fraction tested
        %     .type            'simple' | 'twisted'
        %     .out_hex         hexagon after P->Q
        %     .out_side        side     after P->Q
        %     .back_hex        hexagon after Q->P'
        %     .back_side       side     after Q->P'
        %     .hex_side_match  true iff (back_hex,back_side) == (hex,side)
        %     .dist            dist_hyp(P, P')
        %     .pass            dist < TOL (and no error)
        %     .P               test point
        %     .Q               image of P under gluing
        %     .Pprime          image of Q under gluing
        %     .error_msg       non-empty string if an exception was caught

            polytopes = build_polytopes_from_gluing(gluing, lengths);
            n_hex = size(gluing.pairings, 1);   % always 4
            ts    = test_gluing_involution.TEST_TS;
            tol   = test_gluing_involution.TOL;

            % Pre-allocate an empty struct array with the right fields
            rows = struct( ...
                'gluing_name',{},'hex',{},'side',{},'t',{},'type',{}, ...
                'out_hex',{},'out_side',{},'back_hex',{},'back_side',{}, ...
                'hex_side_match',{},'dist',{},'pass',{}, ...
                'P',{},'Q',{},'Pprime',{},'error_msg',{});

            for hex = 1:n_hex
                for side = 1:6
                    p_data = gluing.pairings{hex, side};
                    if isempty(p_data), continue; end

                    v1 = polytopes{hex}{side};
                    v2 = polytopes{hex}{mod(side, 6) + 1};  % next vertex (wraps 6->1)

                    for ti = 1:numel(ts)
                        t = ts(ti);

                        r.gluing_name    = gluing_name;
                        r.hex            = hex;
                        r.side           = side;
                        r.t              = t;
                        r.type           = p_data.type;
                        r.out_hex        = -1;    r.out_side  = -1;
                        r.back_hex       = -1;    r.back_side = -1;
                        r.hex_side_match = false;
                        r.dist           = NaN;
                        r.pass           = false;
                        r.P              = [NaN; NaN];
                        r.Q              = [NaN; NaN];
                        r.Pprime         = [NaN; NaN];
                        r.error_msg      = '';

                        try
                            P   = test_gluing_involution.point_on_side(v1, v2, t);
                            r.P = P;

                            % ── Forward pass: P  ->  Q ──────────────────
                            [out_hex, out_side, iso1] = pairing_from_gluing( ...
                                gluing, hex, side, twists, P, polytopes);
                            Q          = iso1.apply_poincare(P);
                            r.out_hex  = out_hex;
                            r.out_side = out_side;
                            r.Q        = Q;

                            % ── Reverse pass: Q  ->  P' ─────────────────
                            [back_hex, back_side, iso2] = pairing_from_gluing( ...
                                gluing, out_hex, out_side, twists, Q, polytopes);
                            Pprime      = iso2.apply_poincare(Q);
                            r.back_hex  = back_hex;
                            r.back_side = back_side;
                            r.Pprime    = Pprime;

                            r.hex_side_match = (back_hex == hex) && (back_side == side);
                            r.dist           = distance_two_points(P, Pprime);
                            r.pass           = (r.dist < tol);

                        catch ME
                            r.error_msg = ME.message;
                        end

                        rows(end+1) = r; %#ok<AGROW>
                    end
                end
            end
        end

        % -----------------------------------------------------------------
        function print_report()
        %PRINT_REPORT  Run all configurations and print a full table.
        %
        %   Call from the command window:
        %       test_gluing_involution.print_report()
        %
        %   Every twist configuration is shown on one line.  If any tests
        %   fail that line is expanded with one detail row per failing point,
        %   showing hex, side, t, pairing type, the three points, and the
        %   hyperbolic distance dist(P, P').

            lengths = test_gluing_involution.LENGTHS;

            gluing_defs = { ...
                'Separating',    @create_gluing_separating_S2   ; ...
                'Nonseparating', @create_gluing_nonseparating_S2 };

            twist_configs = { ...
                'No twist              [0,       0,       0    ]', [0,        0,        0       ]; ...
                'T1 = pi/2             [pi/2,    0,       0    ]', [pi/2,     0,        0       ]; ...
                'T1 = pi               [pi,      0,       0    ]', [pi,       0,        0       ]; ...
                'Equal pi/2            [pi/2,    pi/2,    pi/2 ]', [pi/2,     pi/2,     pi/2    ]; ...
                'Equal pi              [pi,      pi,      pi   ]', [pi,       pi,       pi      ]; ...
                'Mixed  [pi/3, 2pi/3, pi]      ',                  [pi/3,     2*pi/3,   pi      ]; ...
                'Mixed  [0.7pi, 0.3pi, 1.1pi]  ',                  [0.7*pi,   0.3*pi,   1.1*pi  ]};

            SEP = repmat('=', 1, 66);
            sep = repmat('-', 1, 66);

            fprintf('\n%s\n', SEP);
            fprintf('  GLUING INVOLUTION TEST\n');
            fprintf('  L = [%.1f, %.1f, %.1f]    tolerance = %.0e\n', ...
                lengths(1), lengths(2), lengths(3), test_gluing_involution.TOL);
            fprintf('  Test: P --glue--> Q --glue--> P''   =>   dist_hyp(P, P'') < tol\n');
            fprintf('%s\n', SEP);

            grand_total = 0;
            grand_pass  = 0;

            for gi = 1:size(gluing_defs, 1)
                gname  = gluing_defs{gi, 1};
                g_fn   = gluing_defs{gi, 2};
                gluing = g_fn();

                fprintf('\n%s\n--- %s decomposition\n%s\n', sep, gname, sep);

                g_total = 0;
                g_pass  = 0;

                for ti = 1:size(twist_configs, 1)
                    t_label  = twist_configs{ti, 1};
                    t_values = twist_configs{ti, 2};

                    rows = test_gluing_involution.run_involution_check( ...
                        gname, gluing, lengths, t_values);

                    n_total = numel(rows);
                    n_pass  = sum([rows.pass]);
                    n_fail  = n_total - n_pass;
                    g_total = g_total + n_total;
                    g_pass  = g_pass  + n_pass;

                    if n_fail == 0
                        tag = 'PASS';
                    else
                        tag = 'FAIL';
                    end

                    fprintf('  [%s]  %-50s  %3d/%-3d\n', tag, t_label, n_pass, n_total);

                    % Expand each failing row
                    fail_idx = find(~[rows.pass]);
                    for k = fail_idx
                        r = rows(k);
                        if ~isempty(r.error_msg)
                            fprintf('         [%s] hex=%d side=%d t=%.1f  ERROR: %s\n', ...
                                r.type, r.hex, r.side, r.t, r.error_msg);
                        else
                            match_str = 'hex/side OK';
                            if ~r.hex_side_match
                                match_str = sprintf('hex/side WRONG -> (%d,%d)', ...
                                    r.back_hex, r.back_side);
                            end
                            fprintf(['         [%s] hex=%d side=%d t=%.1f  ' ...
                                'P->(%d,%d)  %s  ' ...
                                'P=[%.4f,%.4f]  Q=[%.4f,%.4f]  ' ...
                                'P''=[%.4f,%.4f]  dist=%.3e\n'], ...
                                r.type, r.hex, r.side, r.t, ...
                                r.out_hex, r.out_side, match_str, ...
                                r.P(1), r.P(2), r.Q(1), r.Q(2), ...
                                r.Pprime(1), r.Pprime(2), r.dist);
                        end
                    end
                end

                fprintf('%s\n', sep);
                fprintf('  %s subtotal:  %d/%d passed\n', gname, g_pass, g_total);

                grand_total = grand_total + g_total;
                grand_pass  = grand_pass  + g_pass;
            end

            fprintf('\n%s\n', SEP);
            if grand_pass == grand_total
                fprintf('  GRAND TOTAL: %d/%d  --  ALL PASSED\n', ...
                    grand_pass, grand_total);
            else
                fprintf('  GRAND TOTAL: %d/%d  --  %d FAILED\n', ...
                    grand_pass, grand_total, grand_total - grand_pass);
            end
            fprintf('%s\n\n', SEP);
        end

    end  % methods (Static)

    % =====================================================================
    methods (Test)

        % --- Separating decomposition ------------------------------------

        function testSeparating_NoTwist(tc)
            tc.check('Separating', create_gluing_separating_S2(), ...
                [0, 0, 0], 'no twist');
        end

        function testSeparating_T1pi2(tc)
            tc.check('Separating', create_gluing_separating_S2(), ...
                [pi/2, 0, 0], 'T1 = pi/2');
        end

        function testSeparating_T1pi(tc)
            tc.check('Separating', create_gluing_separating_S2(), ...
                [pi, 0, 0], 'T1 = pi');
        end

        function testSeparating_AllPi2(tc)
            tc.check('Separating', create_gluing_separating_S2(), ...
                [pi/2, pi/2, pi/2], 'T1=T2=T3 = pi/2');
        end

        function testSeparating_AllPi(tc)
            tc.check('Separating', create_gluing_separating_S2(), ...
                [pi, pi, pi], 'T1=T2=T3 = pi');
        end

        function testSeparating_Mixed1(tc)
            tc.check('Separating', create_gluing_separating_S2(), ...
                [pi/3, 2*pi/3, pi], 'T = [pi/3, 2pi/3, pi]');
        end

        function testSeparating_Mixed2(tc)
            tc.check('Separating', create_gluing_separating_S2(), ...
                [0.7*pi, 0.3*pi, 1.1*pi], 'T = [0.7, 0.3, 1.1]*pi');
        end

        % --- Nonseparating decomposition ---------------------------------

        function testNonseparating_NoTwist(tc)
            tc.check('Nonseparating', create_gluing_nonseparating_S2(), ...
                [0, 0, 0], 'no twist');
        end

        function testNonseparating_T1pi2(tc)
            tc.check('Nonseparating', create_gluing_nonseparating_S2(), ...
                [pi/2, 0, 0], 'T1 = pi/2');
        end

        function testNonseparating_T1pi(tc)
            tc.check('Nonseparating', create_gluing_nonseparating_S2(), ...
                [pi, 0, 0], 'T1 = pi');
        end

        function testNonseparating_AllPi2(tc)
            tc.check('Nonseparating', create_gluing_nonseparating_S2(), ...
                [pi/2, pi/2, pi/2], 'T1=T2=T3 = pi/2');
        end

        function testNonseparating_AllPi(tc)
            tc.check('Nonseparating', create_gluing_nonseparating_S2(), ...
                [pi, pi, pi], 'T1=T2=T3 = pi');
        end

        function testNonseparating_Mixed1(tc)
            tc.check('Nonseparating', create_gluing_nonseparating_S2(), ...
                [pi/3, 2*pi/3, pi], 'T = [pi/3, 2pi/3, pi]');
        end

        function testNonseparating_Mixed2(tc)
            tc.check('Nonseparating', create_gluing_nonseparating_S2(), ...
                [0.7*pi, 0.3*pi, 1.1*pi], 'T = [0.7, 0.3, 1.1]*pi');
        end

    end  % methods (Test)

    % =====================================================================
    methods (Access = private)

        function check(tc, gname, gluing, twists, twist_label)
        %CHECK  Run round-trip test and emit a single TestCase assertion.
        %   On failure the diagnostic message lists every failing point with
        %   its hexagon, side, t-fraction, pairing type, the three
        %   coordinates, and the hyperbolic distance dist(P, P').
            rows = test_gluing_involution.run_involution_check( ...
                gname, gluing, test_gluing_involution.LENGTHS, twists);

            pass_flags = [rows.pass];
            fail_rows  = rows(~pass_flags);

            if isempty(fail_rows)
                diag_msg = '';
            else
                parts    = cell(1, numel(fail_rows) + 1);
                parts{1} = sprintf('%s / %s : %d/%d cases FAILED (tol=%.0e):', ...
                    gname, twist_label, numel(fail_rows), numel(rows), ...
                    test_gluing_involution.TOL);
                for k = 1:numel(fail_rows)
                    r = fail_rows(k);
                    if ~isempty(r.error_msg)
                        parts{k+1} = sprintf( ...
                            '  [%s] hex=%d side=%d t=%.1f  ERROR: %s', ...
                            r.type, r.hex, r.side, r.t, r.error_msg);
                    else
                        parts{k+1} = sprintf( ...
                            ['  [%s] hex=%d side=%d t=%.1f  ' ...
                             'P->(%d,%d)->(%d,%d)  ' ...
                             'hex_side_match=%d  dist=%.3e'], ...
                            r.type, r.hex, r.side, r.t, ...
                            r.out_hex, r.out_side, ...
                            r.back_hex, r.back_side, ...
                            r.hex_side_match, r.dist);
                    end
                end
                diag_msg = strjoin(parts, sprintf('\n'));
            end

            tc.verifyTrue(all(pass_flags), diag_msg);
        end

    end  % methods (Access = private)

end
