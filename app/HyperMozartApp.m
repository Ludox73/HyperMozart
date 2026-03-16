classdef HyperMozartApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure

        % --- Left panel: Parameters ---
        ParametersPanel              matlab.ui.container.Panel
        InfoButton                   matlab.ui.control.Button
        DrawHexButton                matlab.ui.control.Button

        L1Label                      matlab.ui.control.Label
        L1Spinner                    matlab.ui.control.Spinner
        L2Label                      matlab.ui.control.Label
        L2Spinner                    matlab.ui.control.Spinner
        L3Label                      matlab.ui.control.Label
        L3Spinner                    matlab.ui.control.Spinner

        T1Label                      matlab.ui.control.Label
        T1Spinner                    matlab.ui.control.Spinner
        T2Label                      matlab.ui.control.Label
        T2Spinner                    matlab.ui.control.Spinner
        T3Label                      matlab.ui.control.Label
        T3Spinner                    matlab.ui.control.Spinner

        MaxLenLabel                  matlab.ui.control.Label
        MaxLenSpinner                matlab.ui.control.Spinner

        Curve1CheckBox               matlab.ui.control.CheckBox
        Curve2CheckBox               matlab.ui.control.CheckBox
        Curve3CheckBox               matlab.ui.control.CheckBox

        % Visualization options
        VisualizationPanel           matlab.ui.container.Panel
        VisualizeCheckBox            matlab.ui.control.CheckBox
        PointsDrawLabel              matlab.ui.control.Label
        PointsDrawSpinner            matlab.ui.control.Spinner
        SpeedDrawLabel               matlab.ui.control.Label
        SpeedDrawSpinner             matlab.ui.control.Spinner
        GreyAfterLabel               matlab.ui.control.Label
        GreyAfterSpinner             matlab.ui.control.Spinner
        DeleteAfterLabel             matlab.ui.control.Label
        DeleteAfterSpinner           matlab.ui.control.Spinner

        % Run button & status
        RunButton                    matlab.ui.control.Button
        StopButton                   matlab.ui.control.Button
        StatusLabel                  matlab.ui.control.Label
        ProgressGauge                matlab.ui.control.LinearGauge

        % --- Right panel: Orthospectrum ---
        OrthPanel                    matlab.ui.container.Panel
        CurveIndexLabel              matlab.ui.control.Label
        CurveIndexDropDown           matlab.ui.control.DropDown
        ChiSigmaLabel                matlab.ui.control.Label
        ChiSigmaSpinner              matlab.ui.control.Spinner
        HowManyLabel                 matlab.ui.control.Label
        HowManySpinner               matlab.ui.control.Spinner
        SamplePointsLabel            matlab.ui.control.Label
        SamplePointsSpinner          matlab.ui.control.Spinner
        DrawOrthCheckBox             matlab.ui.control.CheckBox
        ComputeOrthButton            matlab.ui.control.Button
        OrthStatusLabel              matlab.ui.control.Label
        OrthTable                    matlab.ui.control.Table

        % Axes for the 4 hexagons (embedded in app)
        HexPanel                     matlab.ui.container.Panel
        Ax1                          matlab.ui.control.UIAxes
        Ax2                          matlab.ui.control.UIAxes
        Ax3                          matlab.ui.control.UIAxes
        Ax4                          matlab.ui.control.UIAxes
    end

    % Internal state
    properties (Access = private)
        to_music                     % Result matrix from geodesic computation
        StopRequested logical = false
        IsRunning     logical = false
    end

    % =====================================================================
    %  CALLBACKS
    % =====================================================================
    methods (Access = private)

        function RunButtonPushed(app, ~)
            if app.IsRunning
                return;
            end
            app.IsRunning = true;
            app.StopRequested = false;
            app.StopButton.Enable = 'on';
            app.RunButton.Enable = 'off';
            app.ComputeOrthButton.Enable = 'off';
            app.StatusLabel.Text = 'Running...';
            app.OrthTable.Data = [];
            drawnow;

            try
                runGeodesicComputation(app);
            catch ME
                if strcmp(ME.identifier, 'HyperMozart:UserStop')
                    app.StatusLabel.Text = 'Stopped by user.';
                else
                    app.StatusLabel.Text = ['Error: ' ME.message];
                    rethrow(ME);
                end
            end

            app.IsRunning = false;
            app.StopButton.Enable = 'off';
            app.RunButton.Enable = 'on';
            if ~isempty(app.to_music)
                app.ComputeOrthButton.Enable = 'on';
            end
        end

        function StopButtonPushed(app, ~)
            app.StopRequested = true;
            app.StatusLabel.Text = 'Stopping...';
        end

        function VisualizeCheckBoxChanged(app, ~)
            if app.VisualizeCheckBox.Value
                % Visualization mode: short runs
                app.MaxLenSpinner.Limits = [10 100];
                app.MaxLenSpinner.Step = 5;
                app.MaxLenSpinner.Value = 50;
            else
                % Computation mode: long runs
                app.MaxLenSpinner.Limits = [100 1e8];
                app.MaxLenSpinner.Step = 100000;
                app.MaxLenSpinner.Value = 1000000;
            end
        end

        function InfoButtonPushed(app, ~)
            % Open a new figure showing the genus-2 surface topology
            % (adapted from draw_genus2_surface_separating_curve.m)

            Lib = curves_S2_styles();

            S.z0_Q1 = Lib{4}; S.z0_Q2 = Lib{6}; S.z0_H2 = Lib{5};
            S.z0_Q4 = Lib{1}; S.z0_H1 = Lib{3}; S.z0_Q3 = Lib{2};
            S.y0_C1 = Lib{7}; S.y0_C2 = Lib{8}; S.x1_C  = Lib{9};

            [x, y, z] = meshgrid(linspace(-0.6,2.6,150), linspace(-1.2,1.2,150), linspace(-1,1,100));
            f_x = x .* (x-1).^2 .* (x-2);
            r = 0.15;
            V = (f_x + y.^2).^2 + z.^2 - r^2;

            fig_info = figure('Color','w', 'Name','Genus 2 Surface — Topology Info', 'NumberTitle','off');
            p = patch(isosurface(x, y, z, V, 0));
            set(p, 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.2);
            hold on;

            % Curves on plane z = 0
            C_z = contourc(linspace(-0.6,2.6,150), linspace(-1.2,1.2,150), V(:,:,50), [0 0]);
            idx = 1; hole_styles = {S.z0_H1, S.z0_H2}; k_h = 1;
            while idx < size(C_z, 2)
                n = C_z(2, idx);
                xc = C_z(1, idx+1:idx+n); yc = C_z(2, idx+1:idx+n); zc = zeros(size(xc));
                if any(xc < 1) && any(xc > 1)
                    q1=xc; q1(xc<1|yc<0)=NaN; plot3(q1,yc,zc,'Color',S.z0_Q1{1},'LineStyle',S.z0_Q1{2},'LineWidth',S.z0_Q1{3});
                    q2=xc; q2(xc<1|yc>=0)=NaN; plot3(q2,yc,zc,'Color',S.z0_Q2{1},'LineStyle',S.z0_Q2{2},'LineWidth',S.z0_Q2{3});
                    q3=xc; q3(xc>=1|yc<0)=NaN; plot3(q3,yc,zc,'Color',S.z0_Q3{1},'LineStyle',S.z0_Q3{2},'LineWidth',S.z0_Q3{3});
                    q4=xc; q4(xc>=1|yc>=0)=NaN; plot3(q4,yc,zc,'Color',S.z0_Q4{1},'LineStyle',S.z0_Q4{2},'LineWidth',S.z0_Q4{3});
                else
                    st = hole_styles{mod(k_h-1,2)+1};
                    plot3(xc,yc,zc,'Color',st{1},'LineStyle',st{2},'LineWidth',st{3});
                    k_h = k_h + 1;
                end
                idx = idx + n + 1;
            end

            % Curves on plane y = 0
            slice_y0 = squeeze(V(75,:,:))';
            C_y = contourc(linspace(-0.6,2.6,150), linspace(-1,1,100), slice_y0, [0 0]);
            y_st = {S.y0_C1, S.y0_C2}; i_y = 1; c_y = 0;
            while i_y < size(C_y, 2) && c_y < 2
                n = C_y(2, i_y); xc_y = C_y(1, i_y+1:i_y+n); zc_y = C_y(2, i_y+1:i_y+n);
                st = y_st{c_y+1};
                plot3(xc_y, zeros(size(xc_y)), zc_y, 'Color',st{1},'LineStyle',st{2},'LineWidth',st{3});
                i_y = i_y + n + 1; c_y = c_y + 1;
            end

            % Curve on plane x = 1
            c_x1 = contourslice(x, y, z, V, 1, [], [], [0 0]);
            set(c_x1, 'EdgeColor', S.x1_C{1}, 'LineStyle', S.x1_C{2}, 'LineWidth', S.x1_C{3});

            daspect([1 1 1]); view(-55, 30); camlight; lighting gouraud; grid on;
            title('Genus 2 Surface with Separating Curve');
        end

        function DrawHexButtonPushed(app, ~)
            % Preview the 4 hexagons in the central panel using current L values
            lengths_curves = [app.L1Spinner.Value, app.L2Spinner.Value, app.L3Spinner.Value];
            points_draw = 200;

            polytopes = cell(1,4);
            polytopes{1} = rectangular_hexagon_centered(lengths_curves(1)/2, lengths_curves(2)/2, lengths_curves(2)/2);
            polytopes{2} = rectangular_hexagon_centered(lengths_curves(1)/2, lengths_curves(2)/2, lengths_curves(2)/2);
            polytopes{3} = rectangular_hexagon_centered(lengths_curves(1)/2, lengths_curves(3)/2, lengths_curves(3)/2);
            polytopes{4} = rectangular_hexagon_centered(lengths_curves(1)/2, lengths_curves(3)/2, lengths_curves(3)/2);

            Styles = curves_S2_styles();
            styleFunc = @(x,y) get_hexagon_style_separating(x,y);
            app.HexPanel.Visible = 'on';
            appAxes = {app.Ax1, app.Ax2, app.Ax3, app.Ax4};

            for pi_idx = 1:4
                ax = appAxes{pi_idx};
                cla(ax);
                hold(ax, 'on');
                axis(ax, 'equal');
                % Poincare disk
                theta_circ = linspace(0, 2*pi, 200);
                plot(ax, cos(theta_circ), sin(theta_circ), 'k-', 'LineWidth', 1);
                % Hexagon edges
                for s_idx = 1:6
                    if s_idx == 6, s_idx2 = 1; else, s_idx2 = s_idx + 1; end
                    seg_draw = segment(polytopes{pi_idx}{s_idx}, polytopes{pi_idx}{s_idx2});
                    [ctr, rad] = geodesic_circonference(seg_draw);
                    a1 = angleCW2D([1;0], seg_draw.startpoint - ctr, false);
                    a2 = angleCW2D([1;0], seg_draw.endpoint - ctr, false);
                    if abs(a1-a2)>pi
                        if a2>a1, a2=a2-2*pi; else, a1=a1-2*pi; end
                    end
                    th = linspace(a1, a2, points_draw);
                    sty = Styles{styleFunc(pi_idx, s_idx)};
                    plot(ax, ctr(1)+rad*cos(th), ctr(2)+rad*sin(th), ...
                        'Color', sty{1}, 'LineStyle', sty{2}, 'LineWidth', sty{3});
                end
                title(ax, sprintf('Polytope %d', pi_idx));
                xlim(ax, [-1.1 1.1]);
                ylim(ax, [-1.1 1.1]);
            end
            drawnow;
        end

        function ComputeOrthButtonPushed(app, ~)
            if isempty(app.to_music)
                app.OrthStatusLabel.Text = 'Run geodesic computation first.';
                return;
            end

            app.OrthStatusLabel.Text = 'Computing orthospectrum...';
            app.ComputeOrthButton.Enable = 'off';
            drawnow;

            try
                index_curve = str2double(app.CurveIndexDropDown.Value);
                chi_sigma   = app.ChiSigmaSpinner.Value;
                how_many    = app.HowManySpinner.Value;
                draw_flag   = app.DrawOrthCheckBox.Value;
                n_samples   = app.SamplePointsSpinner.Value;

                orthospectrum = compute_orthospectrum( ...
                    app.to_music, index_curve, chi_sigma, ...
                    how_many, draw_flag, n_samples);

                % Display in table
                app.OrthTable.Data = table( ...
                    (1:how_many)', orthospectrum, ...
                    'VariableNames', {'Index', 'Length'});

                app.OrthStatusLabel.Text = sprintf( ...
                    'Done. Shortest orthogeodesic: %.6f', orthospectrum(1));

            catch ME
                app.OrthStatusLabel.Text = ['Error: ' ME.message];
            end

            app.ComputeOrthButton.Enable = 'on';
        end

        % =================================================================
        %  MAIN GEODESIC COMPUTATION  (adapted from main_multiple_hexagons)
        % =================================================================
        function runGeodesicComputation(app)

            % --- Read parameters from UI ---
            lengths_curves    = [app.L1Spinner.Value, app.L2Spinner.Value, app.L3Spinner.Value];
            twisted_parameters = [app.T1Spinner.Value, app.T2Spinner.Value, app.T3Spinner.Value];
            Max_len_geodesic  = app.MaxLenSpinner.Value;
            visualize         = app.VisualizeCheckBox.Value;
            points_draw_geodesics = app.PointsDrawSpinner.Value;
            speed_drawing_geodesic = app.SpeedDrawSpinner.Value;
            make_geodesics_grey_after = app.GreyAfterSpinner.Value;
            delete_geodesics_after = app.DeleteAfterSpinner.Value;

            notes_frequency   = [440.00, 554.37, 659.25];
            how_long_note_played = 0.1;

            if app.Curve1CheckBox.Value
                combination_curve_count_intersections1 = [1,1; 2,1; 3,1; 4,1];
            else
                combination_curve_count_intersections1 = [0,0];
            end
            if app.Curve2CheckBox.Value
                combination_curve_count_intersections2 = [1,3; 1,5; 2,3; 2,5];
            else
                combination_curve_count_intersections2 = [0,0];
            end
            if app.Curve3CheckBox.Value
                combination_curve_count_intersections3 = [3,3; 3,5; 4,3; 4,5];
            else
                combination_curve_count_intersections3 = [0,0];
            end

            combination_noncoherent_orientation = [1,2; 1,4; 2,1; 2,3; 3,2; 3,4; 4,1; 4,3];

            % --- Build polytopes ---
            curves_intersected = zeros(1, Max_len_geodesic);
            to_music_local = zeros(Max_len_geodesic, 2);

            polytopes = cell(1,4);
            polytopes{1} = rectangular_hexagon_centered(lengths_curves(1)/2, lengths_curves(2)/2, lengths_curves(2)/2);
            polytopes{2} = rectangular_hexagon_centered(lengths_curves(1)/2, lengths_curves(2)/2, lengths_curves(2)/2);
            polytopes{3} = rectangular_hexagon_centered(lengths_curves(1)/2, lengths_curves(3)/2, lengths_curves(3)/2);
            polytopes{4} = rectangular_hexagon_centered(lengths_curves(1)/2, lengths_curves(3)/2, lengths_curves(3)/2);

            t1 = twisted_parameters(1);
            t2 = twisted_parameters(2);
            t3 = twisted_parameters(3);

            p_1 = barycenter_cell_of_points(polytopes{1});
            polytope_index = 1;

            a = rand(1)*2*pi;
            tg_1 = 20*(2/(1-norm(p_1)^2))^(-2)*[sin(a);cos(a)];
            p0 = point_and_tg_vector(p_1, tg_1);

            % --- Build collection of circles ---
            collection_of_collection_of_circles = cell(length(polytopes), 1);
            for index_collection = 1:length(polytopes)
                num_sides = size(polytopes{1}, 1);
                collection_of_circles = cell(1, num_sides);
                for ind = 1:num_sides
                    if ind == num_sides
                        ind2 = 1;
                    else
                        ind2 = ind + 1;
                    end
                    seg = segment(polytopes{index_collection}{ind}, polytopes{index_collection}{ind2});
                    [center, radius] = geodesic_circonference(seg);
                    collection_of_circles{ind} = {center, radius};
                end
                collection_of_collection_of_circles{index_collection} = collection_of_circles;
            end

            % --- Visualization setup ---
            if visualize
                cla(app.Ax1); cla(app.Ax2); cla(app.Ax3); cla(app.Ax4);
                app.HexPanel.Visible = 'on';
                appAxes = {app.Ax1, app.Ax2, app.Ax3, app.Ax4};
                Styles = curves_S2_styles();
                styleFunc = @(x,y) get_hexagon_style_separating(x,y);
                % Draw hexagons on the embedded axes
                for pi_idx = 1:4
                    ax = appAxes{pi_idx};
                    hold(ax, 'on');
                    axis(ax, 'equal');
                    % Draw Poincare disk
                    theta_circ = linspace(0, 2*pi, 200);
                    plot(ax, cos(theta_circ), sin(theta_circ), 'k-', 'LineWidth', 1);
                    % Draw hexagon edges (replicate arc computation inline)
                    for s_idx = 1:6
                        if s_idx == 6
                            s_idx2 = 1;
                        else
                            s_idx2 = s_idx + 1;
                        end
                        seg_draw = segment(polytopes{pi_idx}{s_idx}, polytopes{pi_idx}{s_idx2});
                        [ctr, rad] = geodesic_circonference(seg_draw);
                        a1 = angleCW2D([1;0], seg_draw.startpoint - ctr, false);
                        a2 = angleCW2D([1;0], seg_draw.endpoint - ctr, false);
                        if abs(a1-a2)>pi
                            if a2>a1, a2=a2-2*pi; else, a1=a1-2*pi; end
                        end
                        th = linspace(a1, a2, points_draw_geodesics);
                        sty = Styles{styleFunc(pi_idx, s_idx)};
                        plot(ax, ctr(1)+rad*cos(th), ctr(2)+rad*sin(th), ...
                            'Color', sty{1}, 'LineStyle', sty{2}, 'LineWidth', sty{3});
                    end
                    title(ax, sprintf('Polytope %d', pi_idx));
                    xlim(ax, [-1.1 1.1]);
                    ylim(ax, [-1.1 1.1]);
                end
                drawn_geodesics = {};
                drawnow;
            else
                app.HexPanel.Visible = 'off';
            end

            % --- Main loop ---
            point_and_vec_init = p0;
            travelled_since_last_intersection = 0;
            travelled_distance = 0;
            to_avoid = length(polytopes{1}) + 1;
            index_curves = 1;
            first_cycle = true;
            current_percentage = 0;

            while travelled_distance < Max_len_geodesic

                % Check for stop request
                if app.StopRequested
                    throw(MException('HyperMozart:UserStop', 'Stopped by user.'));
                end

                % Compute next intersection
                [point_and_vec_inters, side] = first_intersection_geodesic_fundamental_domain( ...
                    point_and_vec_init, collection_of_collection_of_circles{polytope_index}, to_avoid);

                % Visualization
                if visualize
                    ax = appAxes{polytope_index};
                    hold(ax, 'on');
                    % Compute arc for this geodesic segment
                    seg_vis = segment(point_and_vec_init.point, point_and_vec_inters.point);
                    [ctr, rad] = geodesic_circonference(seg_vis);
                    a1 = angleCW2D([1;0], seg_vis.startpoint - ctr, false);
                    a2 = angleCW2D([1;0], seg_vis.endpoint - ctr, false);
                    if abs(a1-a2)>pi
                        if a2>a1, a2=a2-2*pi; else, a1=a1-2*pi; end
                    end
                    th = linspace(a1, a2, points_draw_geodesics);
                    xarc = ctr(1) + rad*cos(th);
                    yarc = ctr(2) + rad*sin(th);

                    % Animated drawing with explicit parent axes
                    len_seg = distance_two_points(seg_vis.startpoint, seg_vis.endpoint);
                    h = animatedline(ax, 'Color', 'r', 'LineWidth', 1);
                    for k = 1:length(xarc)
                        addpoints(h, xarc(k), yarc(k));
                        drawnow limitrate;
                        pause((1/speed_drawing_geodesic)*(len_seg/points_draw_geodesics));
                    end

                    drawn_geodesics{end+1} = h;
                    if length(drawn_geodesics) > make_geodesics_grey_after
                        try
                            drawn_geodesics{end-make_geodesics_grey_after}.Color = [0.9, 0.9, 0.9];
                        catch
                        end
                    end
                    if length(drawn_geodesics) > delete_geodesics_after
                        try
                            delete(drawn_geodesics{end-delete_geodesics_after});
                        catch
                        end
                    end
                end

                % Distance bookkeeping
                dtp = distance_two_points(point_and_vec_init.point, point_and_vec_inters.point);
                travelled_distance = travelled_distance + dtp;
                travelled_since_last_intersection = travelled_since_last_intersection + dtp;

                % Check curve intersections
                intersects_curve_1 = is_row([polytope_index, side], combination_curve_count_intersections1);
                intersects_curve_2 = is_row([polytope_index, side], combination_curve_count_intersections2);
                intersects_curve_3 = is_row([polytope_index, side], combination_curve_count_intersections3);

                if intersects_curve_1 || intersects_curve_2 || intersects_curve_3
                    if ~first_cycle
                        if intersects_curve_1
                            which_curve = 1;
                        elseif intersects_curve_2
                            which_curve = 2;
                        elseif intersects_curve_3
                            which_curve = 3;
                        end
                        if visualize
                            try
                                play_note_marimba(notes_frequency, which_curve, how_long_note_played);
                            catch
                            end
                        end

                        to_music_local(index_curves, :) = [travelled_since_last_intersection, which_curve];
                        index_curves = index_curves + 1;
                    end
                    travelled_since_last_intersection = 0;
                    first_cycle = false;
                end

                % Compute pairing / next initial vector
                [out_fund_dom_index, out_side_index, isometry] = pairing_hexagon_standard_S2( ...
                    polytope_index, side, t1, t2, t3, point_and_vec_inters.point, polytopes);

                [new_point1, new_tg_vector1] = isometry.apply_poincare_point_and_vector( ...
                    point_and_vec_inters.point, point_and_vec_inters.tg_vector);

                if is_row([polytope_index, out_fund_dom_index], combination_noncoherent_orientation)
                    if out_side_index == 6
                        index2 = 1;
                    else
                        index2 = out_side_index + 1;
                    end
                    p1 = polytopes{out_fund_dom_index}{out_side_index};
                    p2 = polytopes{out_fund_dom_index}{index2};

                    z1_poinc = p1(1) + p1(2)*1i;
                    z2_poinc = p2(1) + p2(2)*1i;
                    z1 = 1i*(1+z1_poinc)/(1-z1_poinc);
                    z2 = 1i*(1+z2_poinc)/(1-z2_poinc);
                    x1 = real(z1); y1 = imag(z1);
                    x2 = real(z2); y2 = imag(z2);
                    c = (x1^2 + y1^2 - x2^2 - y2^2) / (2*(x1-x2));
                    r = sqrt((x1-c)^2 + y1^2);
                    alpha = c - r;
                    beta  = c + r;

                    M = [1 -alpha; 1 -beta];
                    J = [-1 0; 0 1];

                    np1_poinc = new_point1(1) + new_point1(2)*1i;
                    ntv1_poinc = new_tg_vector1(1) + new_tg_vector1(2)*1i;
                    np1 = 1i*(1+np1_poinc)/(1-np1_poinc);
                    ntv1 = 2i/(-np1_poinc + 1)^2 * ntv1_poinc;

                    aus_M = M \ J * M;
                    iso_R = hyp_isometry_2d([], aus_M);
                    [np, ntv] = iso_R.apply_upper_half_point_and_vector_orientation_reversing(np1, ntv1);

                    back_np  = (np - 1i)/(np + 1i);
                    back_ntv = (2i)/(1*np + 1i)^2 * ntv;

                    new_point     = [real(back_np); imag(back_np)];
                    new_tg_vector = [real(back_ntv); imag(back_ntv)];

                    if norm(new_point1 - new_point) > 1e-4
                        warning('Mirroring moved points on segment. Possible error.');
                    end

                    point_and_vec_init = point_and_tg_vector(new_point1, new_tg_vector);
                else
                    point_and_vec_init = point_and_tg_vector(new_point1, new_tg_vector1);
                end

                polytope_index = out_fund_dom_index;
                to_avoid = out_side_index;

                % Update progress
                new_pct = floor(100 * travelled_distance / Max_len_geodesic);
                if new_pct ~= current_percentage
                    current_percentage = new_pct;
                    app.ProgressGauge.Value = min(current_percentage, 100);
                    app.StatusLabel.Text = sprintf('Running... %d%%', current_percentage);
                    if visualize
                        drawnow;
                    else
                        drawnow limitrate;
                    end
                end
            end

            % --- Post-process to_music ---
            to_music_local = to_music_local(2:end, :);
            to_music_local = to_music_local(to_music_local(:,1) ~= 0, :);
            app.to_music = to_music_local;

            app.ProgressGauge.Value = 100;
            app.StatusLabel.Text = sprintf('Done. %d intersections recorded.', size(app.to_music, 1));
        end
    end

    % =====================================================================
    %  UI CONSTRUCTION
    % =====================================================================
    methods (Access = private)

        function createComponents(app)

            % --- Main figure ---
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [50 30 1300 900];
            app.UIFigure.Name = 'HyperMozart';
            app.UIFigure.Resize = 'on';

            % =============================================================
            %  LEFT COLUMN — Parameters Panel (x: 10..310)
            % =============================================================
            app.ParametersPanel = uipanel(app.UIFigure);
            app.ParametersPanel.Title = 'Surface Parameters';
            app.ParametersPanel.Position = [10 370 300 520];
            app.ParametersPanel.FontWeight = 'bold';

            % Info button — shows genus-2 surface topology
            app.InfoButton = uibutton(app.UIFigure, 'push');
            app.InfoButton.Text = char(9432);  % circled "i" character
            app.InfoButton.Position = [270 880 35 25];
            app.InfoButton.FontSize = 14;
            app.InfoButton.Tooltip = 'Show genus-2 surface topology';
            app.InfoButton.ButtonPushedFcn = createCallbackFcn(app, @InfoButtonPushed, true);

            % --- Curve lengths ---
            y = 460;
            app.L1Label = uilabel(app.ParametersPanel, 'Text', 'L1 (curve 1 length)', ...
                'Position', [10 y 140 22]);
            app.L1Spinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 5, ...
                'Limits', [0.1 100], 'Step', 0.5, 'ValueDisplayFormat', '%.2f');

            y = y - 35;
            app.L2Label = uilabel(app.ParametersPanel, 'Text', 'L2 (curve 2 length)', ...
                'Position', [10 y 140 22]);
            app.L2Spinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 3, ...
                'Limits', [0.1 100], 'Step', 0.5, 'ValueDisplayFormat', '%.2f');

            y = y - 35;
            app.L3Label = uilabel(app.ParametersPanel, 'Text', 'L3 (curve 3 length)', ...
                'Position', [10 y 140 22]);
            app.L3Spinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 3, ...
                'Limits', [0.1 100], 'Step', 0.5, 'ValueDisplayFormat', '%.2f');

            % --- Draw hexagons preview button ---
            y = y - 32;
            app.DrawHexButton = uibutton(app.ParametersPanel, 'push');
            app.DrawHexButton.Text = 'Draw Hexagons';
            app.DrawHexButton.Position = [55 y 170 25];
            app.DrawHexButton.FontSize = 11;
            app.DrawHexButton.ButtonPushedFcn = createCallbackFcn(app, @DrawHexButtonPushed, true);

            % --- Twist parameters ---
            y = y - 45;
            app.T1Label = uilabel(app.ParametersPanel, 'Text', 'T1 (twist param 1)', ...
                'Position', [10 y 140 22]);
            app.T1Spinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 0, ...
                'Limits', [0 2*pi-0.001], 'Step', 0.1, 'ValueDisplayFormat', '%.3f');

            y = y - 35;
            app.T2Label = uilabel(app.ParametersPanel, 'Text', 'T2 (twist param 2)', ...
                'Position', [10 y 140 22]);
            app.T2Spinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 0, ...
                'Limits', [0 2*pi-0.001], 'Step', 0.1, 'ValueDisplayFormat', '%.3f');

            y = y - 35;
            app.T3Label = uilabel(app.ParametersPanel, 'Text', 'T3 (twist param 3)', ...
                'Position', [10 y 140 22]);
            app.T3Spinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 0, ...
                'Limits', [0 2*pi-0.001], 'Step', 0.1, 'ValueDisplayFormat', '%.3f');

            % --- Active curves ---
            y = y - 40;
            app.Curve1CheckBox = uicheckbox(app.ParametersPanel, ...
                'Text', 'Curve 1', 'Position', [10 y 80 22], 'Value', true);
            app.Curve2CheckBox = uicheckbox(app.ParametersPanel, ...
                'Text', 'Curve 2', 'Position', [100 y 80 22], 'Value', false);
            app.Curve3CheckBox = uicheckbox(app.ParametersPanel, ...
                'Text', 'Curve 3', 'Position', [190 y 80 22], 'Value', false);

            % --- Max geodesic length ---
            y = y - 45;
            app.MaxLenLabel = uilabel(app.ParametersPanel, 'Text', 'Max geodesic length', ...
                'Position', [10 y 140 22]);
            app.MaxLenSpinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 100000, ...
                'Limits', [100 1e8], 'Step', 10000, 'ValueDisplayFormat', '%.0f');

            % =============================================================
            %  LEFT COLUMN — Visualization Panel (x: 10..310)
            % =============================================================
            app.VisualizationPanel = uipanel(app.UIFigure);
            app.VisualizationPanel.Title = 'Visualization';
            app.VisualizationPanel.Position = [10 150 300 210];
            app.VisualizationPanel.FontWeight = 'bold';

            y = 160;
            app.VisualizeCheckBox = uicheckbox(app.VisualizationPanel, ...
                'Text', 'Visualize geodesics while running', ...
                'Position', [10 y 270 22], 'Value', false, ...
                'ValueChangedFcn', createCallbackFcn(app, @VisualizeCheckBoxChanged, true));

            y = y - 35;
            app.PointsDrawLabel = uilabel(app.VisualizationPanel, 'Text', 'Points per geodesic', ...
                'Position', [10 y 140 22]);
            app.PointsDrawSpinner = uispinner(app.VisualizationPanel, ...
                'Position', [160 y 120 22], 'Value', 10, ...
                'Limits', [2 500], 'Step', 5);

            y = y - 35;
            app.SpeedDrawLabel = uilabel(app.VisualizationPanel, 'Text', 'Drawing speed', ...
                'Position', [10 y 140 22]);
            app.SpeedDrawSpinner = uispinner(app.VisualizationPanel, ...
                'Position', [160 y 120 22], 'Value', 2, ...
                'Limits', [0.1 100], 'Step', 0.5, 'ValueDisplayFormat', '%.1f');

            y = y - 35;
            app.GreyAfterLabel = uilabel(app.VisualizationPanel, 'Text', 'Grey-out after N', ...
                'Position', [10 y 140 22]);
            app.GreyAfterSpinner = uispinner(app.VisualizationPanel, ...
                'Position', [160 y 120 22], 'Value', 2, ...
                'Limits', [1 1000], 'Step', 1);

            y = y - 35;
            app.DeleteAfterLabel = uilabel(app.VisualizationPanel, 'Text', 'Delete after N (Inf=never)', ...
                'Position', [10 y 170 22]);
            app.DeleteAfterSpinner = uispinner(app.VisualizationPanel, ...
                'Position', [190 y 90 22], 'Value', Inf, ...
                'Limits', [1 Inf], 'Step', 5);

            % =============================================================
            %  LEFT COLUMN — Run controls (x: 10..310)
            % =============================================================
            app.RunButton = uibutton(app.UIFigure, 'push');
            app.RunButton.Text = 'Run Geodesic Computation';
            app.RunButton.Position = [10 100 200 35];
            app.RunButton.FontWeight = 'bold';
            app.RunButton.BackgroundColor = [0.3 0.7 0.3];
            app.RunButton.FontColor = [1 1 1];
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);

            app.StopButton = uibutton(app.UIFigure, 'push');
            app.StopButton.Text = 'Stop';
            app.StopButton.Position = [220 100 90 35];
            app.StopButton.FontWeight = 'bold';
            app.StopButton.BackgroundColor = [0.85 0.25 0.25];
            app.StopButton.FontColor = [1 1 1];
            app.StopButton.Enable = 'off';
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);

            app.ProgressGauge = uigauge(app.UIFigure, 'linear');
            app.ProgressGauge.Position = [10 65 300 25];
            app.ProgressGauge.Limits = [0 100];
            app.ProgressGauge.Value = 0;

            app.StatusLabel = uilabel(app.UIFigure);
            app.StatusLabel.Position = [10 35 300 25];
            app.StatusLabel.Text = 'Ready.';
            app.StatusLabel.FontColor = [0.2 0.2 0.6];

            % =============================================================
            %  MIDDLE — Hexagon axes panel (x: 320..870)
            % =============================================================
            app.HexPanel = uipanel(app.UIFigure);
            app.HexPanel.Title = 'Geodesic Visualization';
            app.HexPanel.Position = [320 10 550 880];
            app.HexPanel.FontWeight = 'bold';
            app.HexPanel.Visible = 'off';

            axW = 240; axH = 350;
            app.Ax1 = uiaxes(app.HexPanel, 'Position', [15,  470, axW, axH]);
            app.Ax2 = uiaxes(app.HexPanel, 'Position', [280, 470, axW, axH]);
            app.Ax3 = uiaxes(app.HexPanel, 'Position', [15,  50,  axW, axH]);
            app.Ax4 = uiaxes(app.HexPanel, 'Position', [280, 50,  axW, axH]);

            for ax = [app.Ax1, app.Ax2, app.Ax3, app.Ax4]
                ax.Box = 'on';
                axis(ax, 'equal');
                ax.XLim = [-1.1 1.1];
                ax.YLim = [-1.1 1.1];
            end

            % =============================================================
            %  RIGHT COLUMN — Orthospectrum Panel (x: 880..1290)
            % =============================================================
            app.OrthPanel = uipanel(app.UIFigure);
            app.OrthPanel.Title = 'Orthospectrum Computation';
            app.OrthPanel.Position = [880 10 410 880];
            app.OrthPanel.FontWeight = 'bold';

            y = 740;
            app.CurveIndexLabel = uilabel(app.OrthPanel, 'Text', 'Curve index', ...
                'Position', [10 y 120 22]);
            app.CurveIndexDropDown = uidropdown(app.OrthPanel, ...
                'Items', {'1','2','3'}, 'Value', '1', ...
                'Position', [140 y 80 22]);

            y = y - 35;
            app.ChiSigmaLabel = uilabel(app.OrthPanel, 'Text', 'Chi(Sigma) (Euler char.)', ...
                'Position', [10 y 160 22]);
            app.ChiSigmaSpinner = uispinner(app.OrthPanel, ...
                'Position', [180 y 80 22], 'Value', -2, ...
                'Limits', [-100 0], 'Step', 1);

            y = y - 35;
            app.HowManyLabel = uilabel(app.OrthPanel, 'Text', 'How many values', ...
                'Position', [10 y 120 22]);
            app.HowManySpinner = uispinner(app.OrthPanel, ...
                'Position', [140 y 80 22], 'Value', 5, ...
                'Limits', [1 100], 'Step', 1);

            y = y - 35;
            app.SamplePointsLabel = uilabel(app.OrthPanel, 'Text', 'Sample points (density)', ...
                'Position', [10 y 160 22]);
            app.SamplePointsSpinner = uispinner(app.OrthPanel, ...
                'Position', [180 y 80 22], 'Value', 100000, ...
                'Limits', [1000 5000000], 'Step', 50000, 'ValueDisplayFormat', '%.0f');

            y = y - 35;
            app.DrawOrthCheckBox = uicheckbox(app.OrthPanel, ...
                'Text', 'Draw intermediate CDF plots', ...
                'Position', [10 y 250 22], 'Value', false);

            y = y - 40;
            app.ComputeOrthButton = uibutton(app.OrthPanel, 'push');
            app.ComputeOrthButton.Text = 'Compute Orthospectrum';
            app.ComputeOrthButton.Position = [10 y 220 35];
            app.ComputeOrthButton.FontWeight = 'bold';
            app.ComputeOrthButton.BackgroundColor = [0.2 0.4 0.8];
            app.ComputeOrthButton.FontColor = [1 1 1];
            app.ComputeOrthButton.Enable = 'off';
            app.ComputeOrthButton.ButtonPushedFcn = createCallbackFcn(app, @ComputeOrthButtonPushed, true);

            y = y - 30;
            app.OrthStatusLabel = uilabel(app.OrthPanel);
            app.OrthStatusLabel.Position = [10 y 380 22];
            app.OrthStatusLabel.Text = 'Run geodesic computation first.';
            app.OrthStatusLabel.FontColor = [0.2 0.2 0.6];

            y = y - 25;
            app.OrthTable = uitable(app.OrthPanel);
            app.OrthTable.Position = [10 10 380 y];
            app.OrthTable.ColumnName = {'Index', 'Length'};
            app.OrthTable.ColumnWidth = {60, 300};

            % --- Show figure ---
            app.UIFigure.Visible = 'on';
        end
    end

    % =====================================================================
    %  APP LIFECYCLE
    % =====================================================================
    methods (Access = public)

        function app = HyperMozartApp
            createComponents(app);
            registerApp(app, app.UIFigure);
            if nargout == 0
                clear app;
            end
        end

        function delete(app)
            delete(app.UIFigure);
        end
    end
end