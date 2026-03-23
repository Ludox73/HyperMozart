classdef HyperMozartApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure

        % --- Left panel: Parameters ---
        ParametersPanel              matlab.ui.container.Panel
        GluingDropDown               matlab.ui.control.DropDown
        CurveDotL1                   matlab.ui.control.Label
        CurveDotL2                   matlab.ui.control.Label
        CurveDotL3                   matlab.ui.control.Label
        CurveDotT1                   matlab.ui.control.Label
        CurveDotT2                   matlab.ui.control.Label
        CurveDotT3                   matlab.ui.control.Label
        CurveDotC1                   matlab.ui.control.Label
        CurveDotC2                   matlab.ui.control.Label
        CurveDotC3                   matlab.ui.control.Label
        InfoParamsButton             matlab.ui.control.Button
        InfoVisButton                matlab.ui.control.Button
        InfoMusicButton              matlab.ui.control.Button
        InfoOrthButton               matlab.ui.control.Button
        DrawHexButton                matlab.ui.control.Button
        Draw3DButton                 matlab.ui.control.Button

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

        % Geodesic initial conditions panel
        GeodesicPanel                matlab.ui.container.Panel
        InfoGeodesicButton           matlab.ui.control.Button
        InitCondButton               matlab.ui.control.Button

        Curve1CheckBox               matlab.ui.control.CheckBox
        Curve2CheckBox               matlab.ui.control.CheckBox
        Curve3CheckBox               matlab.ui.control.CheckBox

        % Distribution plot panel
        DistributionPanel            matlab.ui.container.Panel
        InfoDistButton               matlab.ui.control.Button
        DrawDistButton               matlab.ui.control.Button
        DistributionStatusLabel      matlab.ui.control.Label

        % Visualization options
        VisualizationPanel           matlab.ui.container.Panel
        VisualizeCheckBox            matlab.ui.control.CheckBox
        VisDrawOptionsButton         matlab.ui.control.Button
        SaveArcFiltersButton         matlab.ui.control.Button

        % Run button & status
        RunButton                    matlab.ui.control.Button
        StopButton                   matlab.ui.control.Button
        StatusLabel                  matlab.ui.control.Label
        ProgressGauge                matlab.ui.control.LinearGauge

        % --- Right panel: Orthospectrum ---
        OrthPanel                    matlab.ui.container.Panel
        CurveIndexLabel              matlab.ui.control.Label
        CurveIndexDropDown           matlab.ui.control.DropDown
        RecallOtherCurvesCheckBox    matlab.ui.control.CheckBox
        OrthOptionsButton            matlab.ui.control.Button
        GuessSepButton               matlab.ui.control.Button
        ComputeOrthButton            matlab.ui.control.Button
        ResetOrthButton              matlab.ui.control.Button
        OrthStatusLabel              matlab.ui.control.Label
        OrthTable                    matlab.ui.control.Table

        % --- Right panel: Music ---
        MusicPanel                   matlab.ui.container.Panel
        SpeedMultLabel               matlab.ui.control.Label
        SpeedMultSpinner             matlab.ui.control.Spinner
        MaxSongDurLabel              matlab.ui.control.Label
        MaxSongDurSpinner            matlab.ui.control.Spinner
        PlayButton                   matlab.ui.control.Button
        StopMusicButton              matlab.ui.control.Button
        SaveWavButton                matlab.ui.control.Button
        MusicStatusLabel             matlab.ui.control.Label

        % Central area: tab group with multiple views
        CenterTabGroup               matlab.ui.container.TabGroup
        HexTab                       matlab.ui.container.Tab
        CDFTab                       matlab.ui.container.Tab
        SurfaceTab                   matlab.ui.container.Tab
        DistTab                      matlab.ui.container.Tab
        Ax1                          matlab.ui.control.UIAxes
        Ax2                          matlab.ui.control.UIAxes
        Ax3                          matlab.ui.control.UIAxes
        Ax4                          matlab.ui.control.UIAxes
        CDFAxes                      matlab.ui.control.UIAxes
        SurfaceAxes                  matlab.ui.control.UIAxes
        DistAxes                     matlab.ui.control.UIAxes

        RemarkLabel                  matlab.ui.control.Label

        % Short geodesics panel
        ShortGeoPanel                matlab.ui.container.Panel
        InfoShortGeoButton           matlab.ui.control.Button
        ShortGeoNLabel               matlab.ui.control.Label
        ShortGeoNSpinner             matlab.ui.control.Spinner
        ShortGeoFiltersButton        matlab.ui.control.Button
        ShortGeoSlowCheckBox         matlab.ui.control.CheckBox
        ShortGeoRunButton            matlab.ui.control.Button
        ShortGeoStopButton           matlab.ui.control.Button
        ShortGeoStatusLabel          matlab.ui.control.Label
    end

    % Internal state
    properties (Access = private)
        to_music                     % Result matrix from geodesic computation
        points_distribution          % Nx3 matrix [position, angle, travel_time] for distribution plot
        inter_crossing_arcs          % N×9 matrix: [px py vx vy to_avoid polytope length init_angle final_angle]
        arc_geo_context              % Struct with gluing/polytopes context needed to reconstruct arcs
        % Initial condition options (edited via dialog)
        initCondMode  = 'Barycenter, random speed after 1000s'
        initCondAngle = 0
        % Visualization drawing options (edited via dialog)
        visPointsPerGeo  = 10
        visDrawingSpeed  = 2
        visGreyAfterN    = 2
        visDeleteAfterN  = Inf
        % Draw-arc filter values (edited via dialog)
        drawArcMinLen      = 0
        drawArcMaxLen      = Inf
        drawArcInitAngMin  = 1.54
        drawArcInitAngMax  = 1.6
        drawArcFinalAngMin = 1.54
        drawArcFinalAngMax = 1.6
        % Save-arc filter values (edited via dialog)
        saveArcMaxCount    = 5000
        saveArcMinLen      = 0
        saveArcMaxLen      = Inf
        saveArcInitAngMin  = 1.54
        saveArcInitAngMax  = 1.6
        saveArcFinalAngMin = 1.54
        saveArcFinalAngMax = 1.6
        % Orthospectrum options (edited via dialog)
        orthChiSigma     = -2
        orthSamplePoints = 100000
        orthDrawCDF      = true
        orthSymmetric    = true
        orthArcSubset    = 'All arcs'
        StopRequested logical = false
        IsRunning     logical = false
        % Orthospectrum incremental state
        orth_x_vals                  % Current residual CDF x values
        orth_f_vals                  % Current residual CDF f values
        orth_length_geodesic         % Guessed geodesic length
        orth_results                 % Array of found orthospectrum values
        orth_percentages             % Array of homotopy class percentages
        orth_snapshots               % Cell array of saved CDF plot data per element
        orth_initialized logical = false
        StopMusicRequested logical = false
        ShortGeoStopRequested logical = false
        marimba_signals              % Precomputed marimba signals for each curve
    end

    % =====================================================================
    %  CALLBACKS
    % =====================================================================
    methods (Access = private)

        function GluingDropDownChanged(app, ~)
            updateCurveColors(app);
        end

        function updateCurveColors(app)
            if strcmp(app.GluingDropDown.Value, 'Separating S2')
                gluing = create_gluing_separating_S2();
            else
                gluing = create_gluing_nonseparating_S2();
            end
            Styles    = curves_S2_styles();
            styleFunc = gluing.hex_style;
            dots = {app.CurveDotL1, app.CurveDotT1, app.CurveDotC1; ...
                    app.CurveDotL2, app.CurveDotT2, app.CurveDotC2; ...
                    app.CurveDotL3, app.CurveDotT3, app.CurveDotC3};
            for k = 1:3
                combo    = gluing.curve_combinations{k};
                styleIdx = styleFunc(combo(1,1), combo(1,2));
                col      = Styles{styleIdx}{1};
                if ischar(col)
                    map = struct('r',[1 0 0],'g',[0 1 0],'b',[0 0 1], ...
                                 'm',[1 0 1],'k',[0 0 0],'y',[1 1 0], ...
                                 'c',[0 1 1],'w',[1 1 1]);
                    col = map.(col);
                end
                for j = 1:3
                    dots{k,j}.BackgroundColor = col;
                end
            end
        end

        function OrthOptionsButtonPushed(app, ~)
            % Dialog to edit orthospectrum computation options
            dlg = uifigure('Name', 'Orthospectrum Options', ...
                'Position', [500 400 360 258], 'Resize', 'off');

            y = 213;
            uilabel(dlg, 'Text', 'Chi(Sigma) (Euler char.)', ...
                'Position', [15 y 200 22]);
            chiSpinner = uispinner(dlg, 'Value', app.orthChiSigma, ...
                'Limits', [-100 0], 'Step', 1, ...
                'Position', [220 y 120 22]);

            y = y - 35;
            uilabel(dlg, 'Text', 'Sample points (subtraction)', ...
                'Position', [15 y 200 22]);
            sampSpinner = uispinner(dlg, 'Value', app.orthSamplePoints, ...
                'Limits', [1000 5000000], 'Step', 50000, ...
                'ValueDisplayFormat', '%.0f', ...
                'Position', [220 y 120 22]);

            y = y - 35;
            drawCheck = uicheckbox(dlg, 'Text', 'Draw intermediate CDF plots', ...
                'Value', app.orthDrawCDF, 'Position', [15 y 300 22]);

            y = y - 30;
            symCheck = uicheckbox(dlg, 'Text', 'Assume symmetric arcs (2x)', ...
                'Value', app.orthSymmetric, 'Position', [15 y 300 22]);

            y = y - 35;
            uilabel(dlg, 'Text', 'Initial CDF uses', ...
                'Position', [15 y 130 22]);
            subsetDD = uidropdown(dlg, ...
                'Items', {'All arcs', 'Even sounds only', 'Odd sounds only'}, ...
                'Value', app.orthArcSubset, ...
                'Position', [150 y 190 22]);

            y = y - 40;
            uibutton(dlg, 'Text', 'OK', 'Position', [80 y 80 28], ...
                'ButtonPushedFcn', @(~,~) acceptCb());
            uibutton(dlg, 'Text', 'Cancel', 'Position', [200 y 80 28], ...
                'ButtonPushedFcn', @(~,~) delete(dlg));

            uiwait(dlg);

            function acceptCb()
                app.orthChiSigma     = chiSpinner.Value;
                app.orthSamplePoints = sampSpinner.Value;
                app.orthDrawCDF      = drawCheck.Value;
                app.orthSymmetric    = symCheck.Value;
                app.orthArcSubset    = subsetDD.Value;
                delete(dlg);
            end
        end

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
                app.MaxLenSpinner.Limits = [10 10000];
                app.MaxLenSpinner.Step = 50;
                app.MaxLenSpinner.Value = 50;
            else
                % Computation mode: long runs
                app.MaxLenSpinner.Limits = [100 1e8];
                app.MaxLenSpinner.Step = 100000;
                app.MaxLenSpinner.Value = 100000;
            end
        end

        function InfoParamsButtonPushed(app, ~)
            msg = { ...
                'SURFACE PARAMETERS', '', ...
                'Define the Fenchel–Nielsen coordinates of a', ...
                'genus-2 hyperbolic surface with a separating curve.', '', ...
                'L1, L2, L3 — half-lengths of the three simple', ...
                'closed geodesics used in the decomposition.', '', ...
                'T1, T2, T3 — twist parameters in [0, 2π).', ...
                'They control how the pairs of pants are glued.', '', ...
                'Active curves — choose which curves are tracked', ...
                'for intersection counting and sonification.', '', ...
                'Draw Hexagons — preview the four right-angled', ...
                'hexagons (fundamental domains) in the Poincaré disk.', '', ...
                'Draw 3D Surface — render a 3D model of the', ...
                'genus-2 surface with the curves highlighted.'};
            uialert(app.UIFigure, strjoin(msg, newline), 'Surface Parameters', 'Icon', 'info');
        end

        function VisDrawOptionsButtonPushed(app, ~)
            dlg = uifigure('Name', 'Drawing Options', ...
                'Position', [500 400 350 210], 'Resize', 'off');

            uilabel(dlg, 'Text', 'Points per geodesic', 'Position', [10 168 140 22]);
            sp_pts = uispinner(dlg, 'Position', [160 168 170 22], ...
                'Value', app.visPointsPerGeo, 'Limits', [2 500], 'Step', 5);

            uilabel(dlg, 'Text', 'Drawing speed', 'Position', [10 128 140 22]);
            sp_spd = uispinner(dlg, 'Position', [160 128 170 22], ...
                'Value', app.visDrawingSpeed, 'Limits', [0.1 100], ...
                'Step', 0.5, 'ValueDisplayFormat', '%.1f');

            uilabel(dlg, 'Text', 'Grey-out after N', 'Position', [10 88 140 22]);
            sp_grey = uispinner(dlg, 'Position', [160 88 170 22], ...
                'Value', app.visGreyAfterN, 'Limits', [1 1000], 'Step', 1);

            uilabel(dlg, 'Text', 'Delete after N (Inf=never)', 'Position', [10 48 160 22]);
            sp_del = uispinner(dlg, 'Position', [180 48 160 22], ...
                'Value', app.visDeleteAfterN, 'Limits', [1 Inf], 'Step', 5);

            uibutton(dlg, 'push', 'Text', 'OK', ...
                'Position', [70 10 90 28], ...
                'ButtonPushedFcn', @(~,~) uiresume(dlg));
            uibutton(dlg, 'push', 'Text', 'Cancel', ...
                'Position', [190 10 90 28], ...
                'ButtonPushedFcn', @(~,~) close(dlg));

            uiwait(dlg);

            if isvalid(dlg)
                app.visPointsPerGeo = sp_pts.Value;
                app.visDrawingSpeed = sp_spd.Value;
                app.visGreyAfterN   = sp_grey.Value;
                app.visDeleteAfterN = sp_del.Value;
                close(dlg);
            end
        end

        function InfoVisButtonPushed(app, ~)
            msg = { ...
                'VISUALIZATION', '', ...
                'Enable real-time drawing of geodesic arcs in', ...
                'the Poincaré disk as the computation runs.', '', ...
                'Points per geodesic — number of sample points', ...
                'used to draw each arc (higher = smoother).', '', ...
                'Drawing speed — animation speed multiplier.', ...
                'Higher values make the arcs appear faster.', '', ...
                'Grey-out after N — after N new arcs are drawn,', ...
                'older arcs fade to light grey.', '', ...
                'Delete after N — arcs older than N steps are', ...
                'removed entirely to keep the display clean.', '', ...
                'ACHTUNG: drawing geodesics takes a lot of time.', ...
                'For this reason, the actual speed of the geodesic', ...
                'may not correspond to the one you selected.', ...
                'This is just for visualization and should not be', ...
                'considered numerically.', '', ...
                'SAVE ARCS FILTERS', '', ...
                'During the run, arcs between consecutive curve', ...
                'crossings can be saved for later drawing in the', ...
                '"Short Geodesic Arcs" panel. Use the filters to', ...
                'restrict which arcs are stored (by length, crossing', ...
                'angles, and maximum count).'};
            uialert(app.UIFigure, strjoin(msg, newline), 'Visualization', 'Icon', 'info');
        end

        function InfoMusicButtonPushed(app, ~)
            msg = { ...
                'MUSIC', '', ...
                'Sonify the geodesic: each time the geodesic', ...
                'crosses a curve, the corresponding note plays.', '', ...
                'Note assignment:', ...
                '  Curve 1 → A4  (440 Hz)', ...
                '  Curve 2 → C♯5 (554 Hz)', ...
                '  Curve 3 → E5  (659 Hz)', '', ...
                'Speed multiplier — scales playback speed.', ...
                'A value of 10 means 10× faster than the', ...
                'hyperbolic travel time between intersections.', '', ...
                'Save WAV — export the full song as a .wav file.', ...
                'Output is capped at 10 minutes.'};
            uialert(app.UIFigure, strjoin(msg, newline), 'Music', 'Icon', 'info');
        end

        function InfoOrthButtonPushed(app, ~)
            msg = { ...
                'ORTHOSPECTRUM COMPUTATION', '', ...
                'Iteratively extract orthogeodesic lengths from', ...
                'the empirical CDF of intersection distances.', '', ...
                'The orthospectrum is computed for arcs that', ...
                'emanate from the selected curve and lie in', ...
                'the surface cut along all curves that were', ...
                'active during the geodesic computation.', '', ...
                'Curve index — which curve to analyse.', ...
                'χ(Σ) — Euler characteristic (−2 for genus 2).', ...
                'Sample points — Monte Carlo resolution for', ...
                'the expected CDF of each homotopy class.', '', ...
                'Compute Next Element — finds the shortest', ...
                'remaining orthogeodesic via binary search,', ...
                'subtracts its CDF contribution, then moves on.', '', ...
                'Assume symmetric arcs (2×) — assumes every', ...
                'orthogeodesic has a twin of equal length.', ...
                'This is expected on a genus-2 surface, since', ...
                'each arc and its reverse count as two distinct', ...
                'orthogeodesics.', '', ...
                'Reset — clears all results and restarts the', ...
                'computation from the original empirical CDF.'};
            uialert(app.UIFigure, strjoin(msg, newline), 'Orthospectrum', 'Icon', 'info');
        end

        function Draw3DButtonPushed(app, ~)
            % Draw the genus-2 surface on the embedded SurfaceAxes
            app.CenterTabGroup.SelectedTab = app.SurfaceTab;

            ax3d = app.SurfaceAxes;
            cla(ax3d);
            hold(ax3d, 'on');

            if strcmp(app.GluingDropDown.Value, 'Nonseparating S2')
                draw_genus2_surface_nonseparating_curve(ax3d);
            else
                draw_genus2_surface_separating_curve(ax3d);
            end

            hold(ax3d, 'off');
            drawnow;
        end

        function DrawHexButtonPushed(app, ~)
            % Preview the 4 hexagons in the central panel using current L values
            lengths_curves = [app.L1Spinner.Value, app.L2Spinner.Value, app.L3Spinner.Value];
            points_draw = 200;
            if strcmp(app.GluingDropDown.Value, 'Separating S2')
                gluing_preview = create_gluing_separating_S2();
            else
                gluing_preview = create_gluing_nonseparating_S2();
            end
            polytopes = build_polytopes_from_gluing(gluing_preview, lengths_curves);

            Styles = curves_S2_styles();
            styleFunc = gluing_preview.hex_style;
            app.CenterTabGroup.SelectedTab = app.HexTab;
            appAxes = {app.Ax1, app.Ax2, app.Ax3, app.Ax4};

            for pi_idx = 1:4
                ax = appAxes{pi_idx};
                cla(ax);
                hold(ax, 'on');
                axis(ax, 'equal');
                % Poincare disk
                theta_circ = linspace(0, 2*pi, 200);
                plot(ax, cos(theta_circ), sin(theta_circ), 'k-', 'LineWidth', 1,'LineJoin', 'chamfer');
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
                        'Color', sty{1}, 'LineStyle', sty{2}, 'LineWidth', sty{3},'LineJoin', 'chamfer');
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

            % Initialize on first call or after reset
            if ~app.orth_initialized
                index_curve = str2double(app.CurveIndexDropDown.Value);
                chi_sigma   = app.orthChiSigma;
                to_music_f = applyRecallFilter(app, app.to_music, index_curve);
                app.orth_length_geodesic = guess_length_geodesics_from_to_music( ...
                    to_music_f, index_curve, chi_sigma);
                to_music_cdf = to_music_f;
                if ~strcmp(app.orthArcSubset, 'All arcs')
                    idx_c = find(to_music_cdf(:,2) == index_curve);
                    if strcmp(app.orthArcSubset, 'Even arcs only')
                        idx_c = idx_c(2:2:end);
                    else
                        idx_c = idx_c(1:2:end);
                    end
                    idx_other = find(to_music_cdf(:,2) ~= index_curve);
                    to_music_cdf = to_music_cdf([idx_other; idx_c], :);
                end
                [app.orth_x_vals, app.orth_f_vals] = compute_cumufun_from_to_music( ...
                    to_music_cdf, index_curve);
                app.orth_results = [];
                app.orth_percentages = [];
                app.orth_snapshots = {};
                app.orth_initialized = true;
                app.OrthTable.Data = [];
            end

            app.OrthStatusLabel.Text = 'Computing next element...';
            app.ComputeOrthButton.Enable = 'off';
            drawnow;

            try
                draw_flag   = app.orthDrawCDF;
                symmetric   = app.orthSymmetric;
                n_samples   = app.orthSamplePoints;

                % Save backup for drawing
                x_backup = app.orth_x_vals;
                f_backup = app.orth_f_vals;

                [min_length, x_new, f_new] = compute_next_orthospectrum_element( ...
                    app.orth_x_vals, app.orth_f_vals, app.orth_length_geodesic, ...
                    n_samples, false);  % never draw in external figure

                % Compute candidate CDF (needed for percentage, drawing, and symmetric mode)
                [x_cand, f_cand] = expected_cumufun_one_homotopy_class( ...
                    min_length, app.orth_length_geodesic, n_samples);

                % If symmetric: subtract 2x the candidate from backup instead
                if symmetric
                    f_cand_sub = 2 * f_cand;
                    % Align endpoints
                    x_vals_for_sub = app.orth_x_vals;
                    if x_cand(end) < x_vals_for_sub(end)
                        x_cand(end) = x_vals_for_sub(end);
                    else
                        x_vals_for_sub(end) = x_cand(end);
                    end
                    [x_new, f_new] = subtract_cumufuns(x_cand, f_cand_sub, x_vals_for_sub, app.orth_f_vals);
                    pct = f_cand(end) * 200;  % 2x probability
                else
                    pct = f_cand(end) * 100;
                end

                % Update state
                app.orth_x_vals = x_new;
                app.orth_f_vals = f_new;
                app.orth_results(end+1) = min_length;
                app.orth_percentages(end+1) = pct;

                % Save snapshot for this element (always, regardless of draw)
                snap = struct();
                snap.x_cand = x_cand; snap.x_cand(end) = 30;
                snap.x_backup = x_backup; snap.x_backup(end) = 30;
                snap.x_new = x_new; snap.x_new(end) = 30;
                if symmetric
                    snap.f_cand = f_cand_sub;
                else
                    snap.f_cand = f_cand;
                end
                snap.f_backup = f_backup;
                snap.f_new = f_new;
                snap.min_length = min_length;
                snap.pct = pct;
                app.orth_snapshots{end+1} = snap;

                % Draw on embedded CDF axes if requested
                if draw_flag
                    app.drawOrthSnapshot(length(app.orth_snapshots));
                end

                % Update table
                n = length(app.orth_results);
                app.OrthTable.Data = table( ...
                    (1:n)', app.orth_results(:), app.orth_percentages(:), ...
                    'VariableNames', {'Index', 'Length', 'Probability'});

                app.OrthStatusLabel.Text = sprintf( ...
                    'Element %d: %.6f (%.1f%%)', n, min_length, pct);

            catch ME
                app.OrthStatusLabel.Text = ['Error: ' ME.message];
            end

            app.ComputeOrthButton.Enable = 'on';
        end

        function drawOrthSnapshot(app, idx)
            % Draw the CDF snapshot for element idx on the embedded axes
            if idx < 1 || idx > length(app.orth_snapshots)
                return;
            end
            snap = app.orth_snapshots{idx};

            app.CenterTabGroup.SelectedTab = app.CDFTab;
            ax = app.CDFAxes;
            cla(ax);
            hold(ax, 'on');
            plot(ax, snap.x_cand, snap.f_cand, 'b-', 'LineWidth', 1.5, 'LineJoin', 'chamfer');
            plot(ax, snap.x_backup, snap.f_backup, 'k-', 'LineWidth', 1.5, 'LineJoin', 'chamfer');
            plot(ax, snap.x_new, snap.f_new, 'r-', 'LineWidth', 1.5, 'LineJoin', 'chamfer');
            hold(ax, 'off');
            legend(ax, 'Candidate CF', 'Previous residual', 'After subtraction', ...
                'Location', 'southeast');
            title(ax, sprintf('Element %d (min\\_length=%.4f, %.1f%%)', idx, snap.min_length, snap.pct));
            xlim(ax, [0 25]);
            ylim(ax, [-0.2 1]);
            grid(ax, 'on');
            drawnow;
        end

        function OrthTableCellSelected(app, event)
            % When user clicks a row in the orthospectrum table, show that snapshot
            if isempty(event.Indices)
                return;
            end
            row = event.Indices(1);
            if row >= 1 && row <= length(app.orth_snapshots)
                app.drawOrthSnapshot(row);
            end
        end

        function ResetOrthButtonPushed(app, ~)
            app.orth_initialized = false;
            app.orth_x_vals = [];
            app.orth_f_vals = [];
            app.orth_length_geodesic = [];
            app.orth_results = [];
            app.orth_percentages = [];
            app.orth_snapshots = {};
            app.OrthTable.Data = [];
            app.OrthStatusLabel.Text = 'Orthospectrum reset. Ready.';
        end

        function PlayButtonPushed(app, ~)
            if isempty(app.to_music)
                app.MusicStatusLabel.Text = 'No data. Run geodesic first.';
                return;
            end

            app.StopMusicRequested = false;
            app.PlayButton.Enable = 'off';
            app.StopMusicButton.Enable = 'on';
            speed = app.SpeedMultSpinner.Value;
            notes_frequency = [440.00, 554.37, 659.25];
            fs = 44100;

            % Precompute marimba signals for each curve
            app.MusicStatusLabel.Text = 'Precomputing sounds...';
            drawnow;
            signals = cell(1, length(notes_frequency));
            for k = 1:length(notes_frequency)
                signals{k} = play_note_marimba(notes_frequency, k);
            end

            app.MusicStatusLabel.Text = 'Playing...';
            drawnow;

            for i = 1:size(app.to_music, 1)
                if app.StopMusicRequested
                    break;
                end
                wait_time = app.to_music(i, 1) / speed;
                which_curve = round(app.to_music(i, 2));

                if which_curve >= 1 && which_curve <= length(signals)
                    sound(signals{which_curve}, fs);
                end
                pause(wait_time);
            end

            app.PlayButton.Enable = 'on';
            app.StopMusicButton.Enable = 'off';
            app.MusicStatusLabel.Text = 'Playback finished.';
        end

        function StopMusicButtonPushed(app, ~)
            app.StopMusicRequested = true;
            app.MusicStatusLabel.Text = 'Stopping...';
        end

        function InfoShortGeoButtonPushed(app, ~)
            msg = { ...
                'SHORT GEODESICS', '', ...
                'After running the geodesic computation, this panel', ...
                'draws arcs of the geodesic between consecutive curve', ...
                'crossings whose length is less than the given threshold.', '', ...
                'Max arc length L — only arcs shorter than this value', ...
                'are drawn.', '', ...
                'Number N — draw at most the first N such arcs found', ...
                '(in the order they appear along the geodesic).'};
            uialert(app.UIFigure, strjoin(msg, newline), 'Short Geodesics', 'Icon', 'info');
        end

        function ShortGeoStopButtonPushed(app, ~)
            app.ShortGeoStopRequested = true;
        end

        function ShortGeoRunButtonPushed(app, ~)
            if isempty(app.inter_crossing_arcs)
                uialert(app.UIFigure, ...
                    'No data available. Run geodesic computation first.', ...
                    'No Data', 'Icon', 'warning');
                return;
            end

            L_min        = app.drawArcMinLen;
            L_threshold  = app.drawArcMaxLen;
            N_target     = app.ShortGeoNSpinner.Value;
            pts          = app.visPointsPerGeo;
            ia_min       = app.drawArcInitAngMin;
            ia_max       = app.drawArcInitAngMax;
            fa_min       = app.drawArcFinalAngMin;
            fa_max       = app.drawArcFinalAngMax;

            % Draw hexagon backgrounds first
            DrawHexButtonPushed(app, []);
            app.CenterTabGroup.SelectedTab = app.HexTab;
            appAxes = {app.Ax1, app.Ax2, app.Ax3, app.Ax4};
            arc_colors = {[0 0.45 0.74], [0.85 0.33 0.10], [0.47 0.67 0.19], [0.49 0.18 0.56]};

            app.ShortGeoStopRequested = false;
            app.ShortGeoStopButton.Enable = 'on';
            app.ShortGeoRunButton.Enable = 'off';

            n_found = 0;
            for k = 1:size(app.inter_crossing_arcs, 1)
                if app.ShortGeoStopRequested, break; end

                row = app.inter_crossing_arcs(k, :);
                % cols: [px py vx vy to_avoid polytope length init_angle final_angle]
                arc_len       = row(7);
                arc_init_ang  = row(8);
                arc_final_ang = row(9);

                if arc_len < L_min || arc_len >= L_threshold
                    continue;
                end
                if arc_init_ang < ia_min || arc_init_ang > ia_max
                    continue;
                end
                if arc_final_ang < fa_min || arc_final_ang > fa_max
                    continue;
                end

                n_found = n_found + 1;
                col = arc_colors{mod(n_found - 1, numel(arc_colors)) + 1};

                ctx   = app.arc_geo_context;
                ptv_r = point_and_tg_vector([row(1); row(2)], [row(3); row(4)]);
                pi_r  = row(6);
                ta_r  = row(5);
                acc_r = 0;
                while acc_r < arc_len - 1e-12
                    if app.ShortGeoStopRequested, break; end
                    [ptv_next, side_r] = first_intersection_geodesic_fundamental_domain( ...
                        ptv_r, ctx.collection_of_collection_of_circles{pi_r}, ta_r);
                    dtp_r = distance_two_points(ptv_r.point, ptv_next.point);
                    acc_r = acc_r + dtp_r;

                    ax      = appAxes{pi_r};
                    seg_obj = segment(ptv_r.point, ptv_next.point);
                    [ctr, rad] = geodesic_circonference(seg_obj);
                    a1 = angleCW2D([1;0], seg_obj.startpoint - ctr, false);
                    a2 = angleCW2D([1;0], seg_obj.endpoint   - ctr, false);
                    if abs(a1 - a2) > pi
                        if a2 > a1, a2 = a2 - 2*pi; else, a1 = a1 - 2*pi; end
                    end
                    th = linspace(a1, a2, pts);
                    plot(ax, ctr(1) + rad*cos(th), ctr(2) + rad*sin(th), ...
                        '-', 'Color', col, 'LineWidth', 1.5, 'LineJoin', 'chamfer');
                    if app.ShortGeoSlowCheckBox.Value
                        drawnow;
                        pause(0.5);
                    end

                    % Advance to next polytope
                    [ptv_r, pi_r, ta_r] = apply_pairing( ...
                        ptv_next, pi_r, side_r, ctx.gluing, ctx.twisted_parameters, ctx.polytopes);
                end

                app.ShortGeoStatusLabel.Text = sprintf('Drew %d / %d', n_found, N_target);
                drawnow;

                if n_found >= N_target
                    break;
                end
            end

            app.ShortGeoStopButton.Enable = 'off';
            app.ShortGeoRunButton.Enable = 'on';

            if app.ShortGeoStopRequested
                app.ShortGeoStatusLabel.Text = sprintf('Stopped. Drew %d arc(s).', n_found);
            elseif n_found == 0
                app.ShortGeoStatusLabel.Text = 'No arcs found with these parameters.';
            else
                app.ShortGeoStatusLabel.Text = sprintf('Done. Drew %d arc(s).', n_found);
            end
        end

        function InfoDistButtonPushed(app, ~)
            msg = { ...
                'INTERSECTION DISTRIBUTION', '', ...
                'During the geodesic computation, every time the', ...
                'geodesic crosses curve 1, its position in the', ...
                'tangent bundle of curve 1 is recorded, together', ...
                'with the time elapsed before the next crossing', ...
                'of any active curve.', '', ...
                'Each point in the scatter plot corresponds to one', ...
                'such crossing. The X-axis shows the position along', ...
                'curve 1, the Y-axis shows the angle of the geodesic', ...
                'at that point, and the color encodes the travel time', ...
                'to the next intersection (colder = faster).', '', ...
                'The color scale is logarithmic.'};
            uialert(app.UIFigure, strjoin(msg, newline), 'Intersection Distribution', 'Icon', 'info');
        end

        function InitCondButtonPushed(app, ~)
            dlg = uifigure('Name', 'Initial Conditions', ...
                'Position', [500 420 360 160], 'Resize', 'off');

            uilabel(dlg, 'Text', 'Mode', 'Position', [10 108 50 22]);
            dd = uidropdown(dlg, ...
                'Items', {'Barycenter, random speed', 'Barycenter, random speed after 1000s', 'Barycenter, fixed angle'}, ...
                'Value', app.initCondMode, ...
                'Position', [65 108 280 22]);

            uilabel(dlg, 'Text', 'Angle (rad)', 'Position', [10 68 80 22]);
            sp_ang = uispinner(dlg, 'Position', [95 68 170 22], ...
                'Value', app.initCondAngle, ...
                'Limits', [0 2*pi], 'Step', 0.1, 'ValueDisplayFormat', '%.3f', ...
                'Enable', matlab.lang.OnOffSwitchState(strcmp(app.initCondMode, 'Barycenter, fixed angle')));
            dd.ValueChangedFcn = @(src,~) set(sp_ang, 'Enable', ...
                matlab.lang.OnOffSwitchState(strcmp(src.Value, 'Barycenter, fixed angle')));

            uibutton(dlg, 'push', 'Text', 'OK', ...
                'Position', [70 16 90 28], ...
                'ButtonPushedFcn', @(~,~) uiresume(dlg));
            uibutton(dlg, 'push', 'Text', 'Cancel', ...
                'Position', [200 16 90 28], ...
                'ButtonPushedFcn', @(~,~) close(dlg));

            uiwait(dlg);

            if isvalid(dlg)
                app.initCondMode  = dd.Value;
                app.initCondAngle = sp_ang.Value;
                close(dlg);
            end
        end

        function DrawArcFiltersButtonPushed(app, ~)
            dlg = uifigure('Name', 'Draw Arc Filters', ...
                'Position', [500 380 350 248], 'Resize', 'off');

            uilabel(dlg, 'Text', 'Arc length:', 'Position', [10 206 75 22]);
            sp_lmin = uispinner(dlg, 'Position', [90 206 90 22], ...
                'Value', app.drawArcMinLen, 'Limits', [0 Inf], ...
                'Step', 0.1, 'ValueDisplayFormat', '%.4f');
            uilabel(dlg, 'Text', 'to', 'Position', [184 206 18 22]);
            sp_lmax = uispinner(dlg, 'Position', [205 206 135 22], ...
                'Value', app.drawArcMaxLen, 'Limits', [0 Inf], ...
                'Step', 0.1, 'ValueDisplayFormat', '%.4f');

            uilabel(dlg, 'Text', 'Init. angle [0, pi]:', 'Position', [10 166 72 22]);
            sp_iamin = uispinner(dlg, 'Position', [90 166 90 22], ...
                'Value', app.drawArcInitAngMin, 'Limits', [-Inf Inf], ...
                'Step', 0.1, 'ValueDisplayFormat', '%.3f');
            uilabel(dlg, 'Text', 'to', 'Position', [184 166 18 22]);
            sp_iamax = uispinner(dlg, 'Position', [205 166 135 22], ...
                'Value', app.drawArcInitAngMax, 'Limits', [-Inf Inf], ...
                'Step', 0.1, 'ValueDisplayFormat', '%.3f');

            uilabel(dlg, 'Text', 'Final angle [0, pi]:', 'Position', [10 126 72 22]);
            sp_famin = uispinner(dlg, 'Position', [90 126 90 22], ...
                'Value', app.drawArcFinalAngMin, 'Limits', [-Inf Inf], ...
                'Step', 0.1, 'ValueDisplayFormat', '%.3f');
            uilabel(dlg, 'Text', 'to', 'Position', [184 126 18 22]);
            sp_famax = uispinner(dlg, 'Position', [205 126 135 22], ...
                'Value', app.drawArcFinalAngMax, 'Limits', [-Inf Inf], ...
                'Step', 0.1, 'ValueDisplayFormat', '%.3f');

            uibutton(dlg, 'push', 'Text', 'Only almost-perpendicular intersections', ...
                'Position', [10 82 330 28], ...
                'ButtonPushedFcn', @(~,~) setPerpendicularPreset( ...
                    sp_iamin, sp_iamax, sp_famin, sp_famax));

            uibutton(dlg, 'push', 'Text', 'OK', ...
                'Position', [70 20 90 28], ...
                'ButtonPushedFcn', @(~,~) uiresume(dlg));
            uibutton(dlg, 'push', 'Text', 'Cancel', ...
                'Position', [190 20 90 28], ...
                'ButtonPushedFcn', @(~,~) close(dlg));

            uiwait(dlg);

            if isvalid(dlg)
                app.drawArcMinLen      = sp_lmin.Value;
                app.drawArcMaxLen      = sp_lmax.Value;
                app.drawArcInitAngMin  = sp_iamin.Value;
                app.drawArcInitAngMax  = sp_iamax.Value;
                app.drawArcFinalAngMin = sp_famin.Value;
                app.drawArcFinalAngMax = sp_famax.Value;
                close(dlg);
            end

            function setPerpendicularPreset(sp_ia_min, sp_ia_max, sp_fa_min, sp_fa_max)
                sp_ia_min.Value = 1.54;
                sp_ia_max.Value = 1.6;
                sp_fa_min.Value = 1.54;
                sp_fa_max.Value = 1.6;
            end
        end

        function SaveArcFiltersButtonPushed(app, ~)
            dlg = uifigure('Name', 'Save Arc Filters', ...
                'Position', [500 350 350 288], 'Resize', 'off');

            uilabel(dlg, 'Text', 'Max arcs to save:', 'Position', [10 246 130 22]);
            sp_maxcount = uispinner(dlg, 'Position', [155 246 185 22], ...
                'Value', app.saveArcMaxCount, 'Limits', [1 1e7], ...
                'Step', 1000, 'ValueDisplayFormat', '%.0f');

            uilabel(dlg, 'Text', 'Arc length:', 'Position', [10 206 75 22]);
            sp_lmin = uispinner(dlg, 'Position', [90 206 90 22], ...
                'Value', app.saveArcMinLen, 'Limits', [0 Inf], ...
                'Step', 0.1, 'ValueDisplayFormat', '%.4f');
            uilabel(dlg, 'Text', 'to', 'Position', [184 206 18 22]);
            sp_lmax = uispinner(dlg, 'Position', [205 206 135 22], ...
                'Value', app.saveArcMaxLen, 'Limits', [0 Inf], ...
                'Step', 0.1, 'ValueDisplayFormat', '%.4f');

            uilabel(dlg, 'Text', 'Init. angle [0, pi]:', 'Position', [10 166 120 22]);
            sp_iamin = uispinner(dlg, 'Position', [90 166 90 22], ...
                'Value', app.saveArcInitAngMin, 'Limits', [-Inf Inf], ...
                'Step', 0.1, 'ValueDisplayFormat', '%.3f');
            uilabel(dlg, 'Text', 'to', 'Position', [184 166 18 22]);
            sp_iamax = uispinner(dlg, 'Position', [205 166 135 22], ...
                'Value', app.saveArcInitAngMax, 'Limits', [-Inf Inf], ...
                'Step', 0.1, 'ValueDisplayFormat', '%.3f');

            uilabel(dlg, 'Text', 'Final angle [0, pi]:', 'Position', [10 126 120 22]);
            sp_famin = uispinner(dlg, 'Position', [90 126 90 22], ...
                'Value', app.saveArcFinalAngMin, 'Limits', [-Inf Inf], ...
                'Step', 0.1, 'ValueDisplayFormat', '%.3f');
            uilabel(dlg, 'Text', 'to', 'Position', [184 126 18 22]);
            sp_famax = uispinner(dlg, 'Position', [205 126 135 22], ...
                'Value', app.saveArcFinalAngMax, 'Limits', [-Inf Inf], ...
                'Step', 0.1, 'ValueDisplayFormat', '%.3f');

            uibutton(dlg, 'push', 'Text', 'Only almost-perpendicular intersections', ...
                'Position', [10 82 330 28], ...
                'ButtonPushedFcn', @(~,~) setPerpendicularPreset( ...
                    sp_iamin, sp_iamax, sp_famin, sp_famax));

            uibutton(dlg, 'push', 'Text', 'OK', ...
                'Position', [70 20 90 28], ...
                'ButtonPushedFcn', @(~,~) uiresume(dlg));
            uibutton(dlg, 'push', 'Text', 'Cancel', ...
                'Position', [190 20 90 28], ...
                'ButtonPushedFcn', @(~,~) close(dlg));

            uiwait(dlg);

            if isvalid(dlg)
                app.saveArcMaxCount    = sp_maxcount.Value;
                app.saveArcMinLen      = sp_lmin.Value;
                app.saveArcMaxLen      = sp_lmax.Value;
                app.saveArcInitAngMin  = sp_iamin.Value;
                app.saveArcInitAngMax  = sp_iamax.Value;
                app.saveArcFinalAngMin = sp_famin.Value;
                app.saveArcFinalAngMax = sp_famax.Value;
                close(dlg);
            end

            function setPerpendicularPreset(sp_ia_min, sp_ia_max, sp_fa_min, sp_fa_max)
                sp_ia_min.Value = 1.54;
                sp_ia_max.Value = 1.6;
                sp_fa_min.Value = 1.54;
                sp_fa_max.Value = 1.6;
            end
        end

        function tm = applyRecallFilter(app, to_music, index_curve)
            % If "Recall other curves" is ON, return unchanged.
            % If OFF, remove rows for other curves and add their elapsed
            % time to the next crossing of index_curve.
            if app.RecallOtherCurvesCheckBox.Value
                tm = to_music;
                return;
            end
            tm = zeros(size(to_music, 1), 2);
            n = 0;
            pending = 0;
            for i = 1:size(to_music, 1)
                if to_music(i, 2) == index_curve
                    n = n + 1;
                    tm(n, :) = [to_music(i, 1) + pending, index_curve];
                    pending = 0;
                else
                    pending = pending + to_music(i, 1);
                end
            end
            tm = tm(1:n, :);
        end

        function GuessSepButtonPushed(app, ~)
            if isempty(app.to_music)
                app.OrthStatusLabel.Text = 'Run geodesic computation first.';
                return;
            end

            index_curve = str2double(app.CurveIndexDropDown.Value);
            to_music_f = applyRecallFilter(app, app.to_music, index_curve);
            idx_c = find(to_music_f(:,2) == index_curve);
            if length(idx_c) < 4
                app.OrthStatusLabel.Text = 'Not enough crossings to compare.';
                return;
            end

            idx_other = find(to_music_f(:,2) ~= index_curve);
            tm_even = to_music_f([idx_other; idx_c(2:2:end)], :);
            tm_odd  = to_music_f([idx_other; idx_c(1:2:end)], :);

            [x_even, f_even] = compute_cumufun_from_to_music(tm_even, index_curve);
            [x_odd,  f_odd ] = compute_cumufun_from_to_music(tm_odd,  index_curve);

            % Deduplicate knots (keep last CDF value at each x)
            [x_even, ia] = unique(x_even, 'last'); f_even = f_even(ia);
            [x_odd,  ia] = unique(x_odd,  'last'); f_odd  = f_odd(ia);

            % Evaluate both step-function CDFs on the union of their knots
            x_common = sort(union(x_even, x_odd));
            pad = max(x_even(end), x_odd(end)) + 1;
            f_ei = interp1([x_even; pad], [f_even; f_even(end)], x_common, 'previous', 0);
            f_oi = interp1([x_odd;  pad], [f_odd;  f_odd(end)],  x_common, 'previous', 0);

            dist = max(abs(f_ei - f_oi));

            threshold = 0.05;
            if dist < threshold
                guess = 'Nonseparating';
            else
                guess = 'Separating';
            end

            % Draw both CDFs on the CDF tab
            app.CenterTabGroup.SelectedTab = app.CDFTab;
            ax = app.CDFAxes;
            cla(ax); hold(ax, 'on');
            stairs(ax, x_even, f_even, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Even arcs');
            stairs(ax, x_odd,  f_odd,  'r-', 'LineWidth', 1.5, 'DisplayName', 'Odd arcs');
            hold(ax, 'off');
            legend(ax, 'Location', 'southeast');
            title(ax, sprintf('Even vs Odd — KS dist: %.4f → %s', dist, guess));
            xlim(ax, [0 25]);
            ylim(ax, [0 1.05]);
            drawnow;

            app.OrthStatusLabel.Text = sprintf('Guess: %s (KS distance: %.4f)', guess, dist);
        end

        function InfoGeodesicButtonPushed(app, ~)
            msg = { ...
                'GEODESIC INITIAL CONDITIONS', '', ...
                'Choose how the initial point and tangent vector', ...
                'of the geodesic are selected.', '', ...
                'Barycenter, random speed — start at the', ...
                'barycenter of hexagon 1 with a random unit', ...
                'tangent vector.', '', ...
                'Barycenter, random speed after 1000s — same as above, but', ...
                'the geodesic is first run silently for 1000', ...
                'hyperbolic length units before recording begins.', ...
                'This provides a "warm-up" to move away from the', ...
                'special starting geometry.', '', ...
                'Barycenter, fixed angle — start at the', ...
                'barycenter of hexagon 1 with the tangent vector', ...
                'pointing at the given angle (in radians from', ...
                'the horizontal axis).', '', ...
                'Max geodesic length — total hyperbolic arc', ...
                'length to trace before stopping.'};
            uialert(app.UIFigure, strjoin(msg, newline), 'Geodesic Initial Conditions', 'Icon', 'info');
        end

        function DrawDistButtonPushed(app, ~)
            if isempty(app.points_distribution)
                uialert(app.UIFigure, ...
                    'No data available. Run geodesic computation first.', ...
                    'No Data', 'Icon', 'warning');
                return;
            end

            D = app.points_distribution;
            D = D(1:end-1, :);   % drop last row (column 3 may still be 0)
            D = D(D(:,3) > 0, :);

            X = D(:,1);
            Y = D(:,2);
            Z = D(:,3);

            ax = app.DistAxes;
            cla(ax);
            scatter(ax, X, Y, 18, Z, 'filled');
            set(ax, 'ColorScale', 'log');
            colorbar(ax);
            grid(ax, 'on');
            title(ax, 'Intersection Distribution');
            xlabel(ax, 'Position on curve 1');
            ylabel(ax, 'Angle');
            ylim(ax, [-pi, pi]);
            app.CenterTabGroup.SelectedTab = app.DistTab;
            app.DistributionStatusLabel.Text = sprintf('%d points plotted.', size(D,1));
            drawnow;
        end

        function SaveWavButtonPushed(app, ~)
            if isempty(app.to_music)
                app.MusicStatusLabel.Text = 'No data. Run geodesic first.';
                return;
            end

            speed = app.SpeedMultSpinner.Value;
            notes_frequency = [440.00, 554.37, 659.25];
            fs = 44100;
            attack = 0.01;
            release = 0.02;

            app.MusicStatusLabel.Text = 'Building audio...';
            drawnow;

            max_duration = app.MaxSongDurSpinner.Value * 60;
            max_samples = max_duration * fs;
            y = [];
            for i = 1:size(app.to_music, 1)
                wait_time = app.to_music(i, 1) / speed;
                which_curve = round(app.to_music(i, 2));

                if which_curve < 1 || which_curve > 3
                    continue;
                end

                f = notes_frequency(which_curve);
                dur = wait_time;
                nSamples = max(1, round(dur * fs));
                t = (0:nSamples-1) / fs;

                % Marimba-like synthesis
                fund = 1.0 * sin(2*pi*f*t) .* exp(-5 * t);
                h4   = 0.4 * sin(2*pi*(f*4.01)*t) .* exp(-15 * t);
                h10  = 0.15 * sin(2*pi*(f*10)*t) .* exp(-50 * t);
                thud = 0.1 * rand(1, length(t)) .* exp(-100 * t);
                seg = (fund + h4 + h10 + thud);

                % Envelope
                a = min(attack, dur/4);
                r = min(release, dur/4);
                na = round(a * fs);
                nr = round(r * fs);
                env = ones(1, nSamples);
                if na > 0, env(1:na) = linspace(0, 1, na); end
                if nr > 0, env(end-nr+1:end) = linspace(1, 0, nr); end

                y = [y, seg .* env];

                if length(y) >= max_samples
                    y = y(1:max_samples);
                    app.MusicStatusLabel.Text = 'Building audio... (10 min limit reached)';
                    break;
                end
            end

            if isempty(y)
                app.MusicStatusLabel.Text = 'No audio generated.';
                return;
            end

            y = y / max(abs(y) + eps);

            [file, path] = uiputfile('*.wav', 'Save WAV file', 'hypermozart.wav');
            if isequal(file, 0)
                app.MusicStatusLabel.Text = 'Save cancelled.';
                return;
            end
            filepath = fullfile(path, file);
            audiowrite(filepath, y.', fs);
            app.MusicStatusLabel.Text = sprintf('Saved to %s', file);
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
            points_draw_geodesics = app.visPointsPerGeo;
            speed_drawing_geodesic = app.visDrawingSpeed;
            make_geodesics_grey_after = app.visGreyAfterN;
            delete_geodesics_after = app.visDeleteAfterN;

            notes_frequency   = [440.00, 554.37, 659.25];
            fs_audio = 44100;
            % Precompute marimba signals for playback during visualization
            geo_signals = cell(1, length(notes_frequency));
            for k = 1:length(notes_frequency)
                geo_signals{k} = play_note_marimba(notes_frequency, k);
            end

            if strcmp(app.GluingDropDown.Value, 'Separating S2')
                gluing = create_gluing_separating_S2();
            else
                gluing = create_gluing_nonseparating_S2();
            end

            if app.Curve1CheckBox.Value
                curve_combinations_1 = gluing.curve_combinations{1};
            else
                curve_combinations_1 = [0,0];
            end
            if app.Curve2CheckBox.Value
                curve_combinations_2 = gluing.curve_combinations{2};
            else
                curve_combinations_2 = [0,0];
            end
            if app.Curve3CheckBox.Value
                curve_combinations_3 = gluing.curve_combinations{3};
            else
                curve_combinations_3 = [0,0];
            end

            % --- Build polytopes ---
            curves_intersected = zeros(1, Max_len_geodesic);
            to_music_local = zeros(Max_len_geodesic, 2);

            polytopes = build_polytopes_from_gluing(gluing, lengths_curves);

            p_1 = barycenter_cell_of_points(polytopes{1});
            polytope_index = 1;

            init_cond = app.initCondMode;
            if strcmp(init_cond, 'Barycenter, fixed angle')
                a = app.initCondAngle;
            else
                a = rand(1)*2*pi;
            end
            tg_1 = 20*(2/(1-norm(p_1)^2))^(-2)*[sin(a);cos(a)];
            p0 = point_and_tg_vector(p_1, tg_1);

            % --- Build collection of circles ---
            collection_of_collection_of_circles = build_circles_from_polytopes(polytopes);

            % --- Store geometry context for arc reconstruction ---
            app.arc_geo_context = struct( ...
                'collection_of_collection_of_circles', {collection_of_collection_of_circles}, ...
                'gluing', gluing, ...
                'polytopes', {polytopes}, ...
                'twisted_parameters', twisted_parameters);

            % --- Visualization setup ---
            if visualize
                cla(app.Ax1); cla(app.Ax2); cla(app.Ax3); cla(app.Ax4);
                app.CenterTabGroup.SelectedTab = app.HexTab;
                appAxes = {app.Ax1, app.Ax2, app.Ax3, app.Ax4};
                Styles = curves_S2_styles();
                styleFunc = gluing.hex_style;
                % Draw hexagons on the embedded axes
                for pi_idx = 1:4
                    ax = appAxes{pi_idx};
                    hold(ax, 'on');
                    axis(ax, 'equal');
                    % Draw Poincare disk
                    theta_circ = linspace(0, 2*pi, 200);
                    plot(ax, cos(theta_circ), sin(theta_circ), 'k-', 'LineWidth', 1,'LineJoin', 'chamfer');
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
                            'Color', sty{1}, 'LineStyle', sty{2}, 'LineWidth', sty{3},'LineJoin', 'chamfer');
                    end
                    title(ax, sprintf('Polytope %d', pi_idx));
                    xlim(ax, [-1.1 1.1]);
                    ylim(ax, [-1.1 1.1]);
                end
                drawn_geodesics = {};
                drawnow;
            else
                % No visualization — don't switch tabs
            end

            % --- Main loop ---
            point_and_vec_init = p0;
            travelled_since_last_intersection = 0;
            travelled_distance = 0;
            to_avoid = length(polytopes{1}) + 1;
            index_curves = 1;
            first_cycle = true;
            current_percentage = 0;
            points_dist_local = zeros(Max_len_geodesic, 3);
            n_dist_local = 0;
            arc_initial_ptv       = [];
            arc_initial_to_avoid  = NaN;
            arc_initial_polytope  = NaN;
            current_arc_initial_angle = NaN;
            app.inter_crossing_arcs = zeros(app.saveArcMaxCount, 9);
            n_arcs = 0;

            if strcmp(init_cond, 'Barycenter, random speed after 1000s')
                warmup_target = 1000;
            else
                warmup_target = 0;
            end
            warmup_accumulated = 0;
            warmup_done = (warmup_target == 0);

            while ~warmup_done || travelled_distance < Max_len_geodesic

                % Check for stop request
                if app.StopRequested
                    throw(MException('HyperMozart:UserStop', 'Stopped by user.'));
                end

                % Track distribution for curve 1 crossings (only after warmup)
                if warmup_done && polytope_index == 1 && to_avoid == 1
                    l = distance_two_points(point_and_vec_init.point, polytopes{1}{1});
                    hv = point_and_vec_init.point - collection_of_collection_of_circles{1}{1}{1};
                    vca = [-hv(2), hv(1)];
                    n_dist_local = n_dist_local + 1;
                    points_dist_local(n_dist_local, :) = [l, angleCW2D(vca, point_and_vec_init.tg_vector), 0];
                end
                if warmup_done && polytope_index == 2 && to_avoid == 1
                    l = lengths_curves(1)/2 + distance_two_points(point_and_vec_init.point, polytopes{2}{2});
                    hv = point_and_vec_init.point - collection_of_collection_of_circles{2}{1}{1};
                    vca = [-hv(2), hv(1)];
                    n_dist_local = n_dist_local + 1;
                    points_dist_local(n_dist_local, :) = [l, angleCW2D(point_and_vec_init.tg_vector, vca) - pi, 0];
                end
                if warmup_done && polytope_index == 3 && to_avoid == 1
                    l = mod(twisted_parameters(1)/(2*pi)*lengths_curves(1) + distance_two_points(point_and_vec_init.point, polytopes{3}{1}), lengths_curves(1));
                    hv = point_and_vec_init.point - collection_of_collection_of_circles{3}{1}{1};
                    vca = [-hv(2), hv(1)];
                    n_dist_local = n_dist_local + 1;
                    points_dist_local(n_dist_local, :) = [l, -angleCW2D(vca, point_and_vec_init.tg_vector), 0];
                end
                if warmup_done && polytope_index == 4 && to_avoid == 1
                    l = mod(twisted_parameters(1)/(2*pi)*lengths_curves(1) + lengths_curves(1)/2 + distance_two_points(point_and_vec_init.point, polytopes{4}{2}), lengths_curves(1));
                    hv = point_and_vec_init.point - collection_of_collection_of_circles{4}{1}{1};
                    vca = [-hv(2), hv(1)];
                    n_dist_local = n_dist_local + 1;
                    points_dist_local(n_dist_local, :) = [l, -(angleCW2D(point_and_vec_init.tg_vector, vca) - pi), 0];
                end

                % Compute next intersection
                [point_and_vec_inters, side] = first_intersection_geodesic_fundamental_domain( ...
                    point_and_vec_init, collection_of_collection_of_circles{polytope_index}, to_avoid);

                % Visualization (skipped during warmup)
                if visualize && warmup_done
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
                    h = animatedline(ax, 'Color', 'r');
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

                % Record arc start state (after warmup only)
                if warmup_done
                    if isempty(arc_initial_ptv) && to_avoid <= length(collection_of_collection_of_circles{polytope_index})
                        hv_ia = point_and_vec_init.point - collection_of_collection_of_circles{polytope_index}{to_avoid}{1};
                        vca_ia = [-hv_ia(2), hv_ia(1)];
                        if polytope_index == 1 || polytope_index == 3
                            current_arc_initial_angle = mod(angleCW2D(vca_ia, point_and_vec_init.tg_vector), pi);
                        else
                            current_arc_initial_angle = mod(angleCW2D(point_and_vec_init.tg_vector, vca_ia) - pi, pi);
                        end
                        arc_initial_ptv      = point_and_vec_init;
                        arc_initial_to_avoid = to_avoid;
                        arc_initial_polytope  = polytope_index;
                    end
                end

                if ~warmup_done
                    warmup_accumulated = warmup_accumulated + dtp;
                    if warmup_accumulated >= warmup_target
                        warmup_done = true;
                        first_cycle = true;
                        travelled_since_last_intersection = 0;
                        n_dist_local = 0;
                        index_curves = 1;
                        arc_initial_ptv       = [];
                        arc_initial_to_avoid  = NaN;
                        arc_initial_polytope  = NaN;
                        current_arc_initial_angle = NaN;
                    end
                else
                    travelled_distance = travelled_distance + dtp;
                    travelled_since_last_intersection = travelled_since_last_intersection + dtp;
                end

                % Check curve intersections (skip during warmup)
                intersects_curve_1 = warmup_done && is_row([polytope_index, side], curve_combinations_1);
                intersects_curve_2 = warmup_done && is_row([polytope_index, side], curve_combinations_2);
                intersects_curve_3 = warmup_done && is_row([polytope_index, side], curve_combinations_3);

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
                                sound(geo_signals{which_curve}, fs_audio);
                            catch
                            end
                        end

                        to_music_local(index_curves, :) = [travelled_since_last_intersection, which_curve];
                        index_curves = index_curves + 1;

                        % Fill travel time for the last distribution point
                        if n_dist_local > 0 && points_dist_local(n_dist_local,3) == 0
                            points_dist_local(n_dist_local,3) = travelled_since_last_intersection;
                        end

                        % Compute final crossing angle
                        hv_fa = point_and_vec_inters.point - collection_of_collection_of_circles{polytope_index}{side}{1};
                        vca_fa = [-hv_fa(2), hv_fa(1)];
                        if polytope_index == 1 || polytope_index == 3
                            arc_final_angle = mod(angleCW2D(vca_fa, point_and_vec_inters.tg_vector), pi);
                        else
                            arc_final_angle = mod(angleCW2D(point_and_vec_inters.tg_vector, vca_fa) - pi, pi);
                        end

                        % Save arc record for short-geodesic panel (if within filters and cap)
                        if n_arcs < app.saveArcMaxCount && ...
                                ~isempty(arc_initial_ptv) && ...
                                travelled_since_last_intersection >= app.saveArcMinLen && ...
                                travelled_since_last_intersection <  app.saveArcMaxLen && ...
                                current_arc_initial_angle >= app.saveArcInitAngMin && ...
                                current_arc_initial_angle <= app.saveArcInitAngMax && ...
                                arc_final_angle >= app.saveArcFinalAngMin && ...
                                arc_final_angle <= app.saveArcFinalAngMax
                            n_arcs = n_arcs + 1;
                            app.inter_crossing_arcs(n_arcs, :) = [ ...
                                arc_initial_ptv.point(1), arc_initial_ptv.point(2), ...
                                arc_initial_ptv.tg_vector(1), arc_initial_ptv.tg_vector(2), ...
                                arc_initial_to_avoid, arc_initial_polytope, ...
                                travelled_since_last_intersection, ...
                                current_arc_initial_angle, arc_final_angle];
                        end
                    end
                    arc_initial_ptv       = [];
                    arc_initial_to_avoid  = NaN;
                    arc_initial_polytope  = NaN;
                    current_arc_initial_angle = NaN;
                    travelled_since_last_intersection = 0;
                    first_cycle = false;
                end

                % Compute pairing / next initial vector
                [point_and_vec_init, polytope_index, to_avoid] = apply_pairing( ...
                    point_and_vec_inters, polytope_index, side, gluing, twisted_parameters, polytopes);

                % Update progress
                if ~warmup_done
                    new_warmup_pct = floor(100 * warmup_accumulated / warmup_target);
                    if new_warmup_pct ~= current_percentage
                        current_percentage = new_warmup_pct;
                        app.ProgressGauge.Value = min(current_percentage, 100);
                        app.StatusLabel.Text = sprintf('Warm-up: %.0f / %.0f', warmup_accumulated, warmup_target);
                        drawnow limitrate;
                    end
                else
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
            end

            % --- Post-process to_music ---
            to_music_local = to_music_local(2:end, :);
            to_music_local = to_music_local(to_music_local(:,1) ~= 0, :);
            app.to_music = to_music_local;
            app.points_distribution = points_dist_local(1:n_dist_local, :);
            app.inter_crossing_arcs = app.inter_crossing_arcs(1:n_arcs, :);

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
            app.UIFigure.Position = [50 30 1728 972];
            app.UIFigure.Name = 'HyperMozart';
            app.UIFigure.Resize = 'on';

            % =============================================================
            %  LEFT COLUMN — Parameters Panel (x: 10..310)
            % =============================================================
            app.ParametersPanel = uipanel(app.UIFigure);
            app.ParametersPanel.Title = 'Surface Parameters';
            app.ParametersPanel.Position = [10 600 300 322];
            app.ParametersPanel.FontWeight = 'bold';

            % Info button — parameters panel documentation
            app.InfoParamsButton = uibutton(app.UIFigure, 'push');
            app.InfoParamsButton.Text = char(9432);
            app.InfoParamsButton.Position = [270 906 35 25];
            app.InfoParamsButton.FontSize = 14;
            app.InfoParamsButton.Tooltip = 'Help: Surface Parameters';
            app.InfoParamsButton.ButtonPushedFcn = createCallbackFcn(app, @InfoParamsButtonPushed, true);

            % --- Gluing selector ---
            ysurftype = 272;
            uilabel(app.ParametersPanel, 'Text', 'Surface type', ...
                'Position', [10 272 95 22], 'FontWeight', 'bold');
            app.GluingDropDown = uidropdown(app.ParametersPanel, ...
                'Items', {'Separating S2', 'Nonseparating S2'}, ...
                'Position', [115 ysurftype 165 22], ...
                'Value', 'Separating S2', ...
                'ValueChangedFcn', createCallbackFcn(app, @GluingDropDownChanged, true));

            % --- Curve lengths ---
            y = ysurftype-30;
            app.L1Label = uilabel(app.ParametersPanel, 'Text', 'L1 (curve 1 length)', ...
                'Position', [10 y 140 22]);
            app.L1Spinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 4, ...
                'Limits', [0.1 100], 'Step', 0.5, 'ValueDisplayFormat', '%.2f');
            app.CurveDotL1 = uilabel(app.ParametersPanel, 'Text', '', ...
                'Position', [282 y+7 10 8], 'BackgroundColor', [0 0 0]);

            y = y - 35;
            app.L2Label = uilabel(app.ParametersPanel, 'Text', 'L2 (curve 2 length)', ...
                'Position', [10 y 140 22]);
            app.L2Spinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 2, ...
                'Limits', [0.1 100], 'Step', 0.5, 'ValueDisplayFormat', '%.2f');
            app.CurveDotL2 = uilabel(app.ParametersPanel, 'Text', '', ...
                'Position', [282 y+7 10 8], 'BackgroundColor', [0 0 0]);

            y = y - 35;
            app.L3Label = uilabel(app.ParametersPanel, 'Text', 'L3 (curve 3 length)', ...
                'Position', [10 y 140 22]);
            app.L3Spinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 3.5, ...
                'Limits', [0.1 100], 'Step', 0.5, 'ValueDisplayFormat', '%.2f');
            app.CurveDotL3 = uilabel(app.ParametersPanel, 'Text', '', ...
                'Position', [282 y+7 10 8], 'BackgroundColor', [0 0 0]);

            % --- Draw hexagons preview button ---
            y = y - 32;
            app.DrawHexButton = uibutton(app.ParametersPanel, 'push');
            app.DrawHexButton.Text = 'Draw Hexagons';
            app.DrawHexButton.Position = [10 y 130 25];
            app.DrawHexButton.FontSize = 11;
            app.DrawHexButton.ButtonPushedFcn = createCallbackFcn(app, @DrawHexButtonPushed, true);

            app.Draw3DButton = uibutton(app.ParametersPanel, 'push');
            app.Draw3DButton.Text = 'Draw 3D Surface';
            app.Draw3DButton.Position = [150 y 130 25];
            app.Draw3DButton.FontSize = 11;
            app.Draw3DButton.ButtonPushedFcn = createCallbackFcn(app, @Draw3DButtonPushed, true);

            % --- Twist parameters ---
            y = y - 45;
            app.T1Label = uilabel(app.ParametersPanel, 'Text', 'T1 (twist param 1)', ...
                'Position', [10 y 140 22]);
            app.T1Spinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 1, ...
                'Limits', [0 2*pi], 'Step', 0.1, 'ValueDisplayFormat', '%.3f');
            app.CurveDotT1 = uilabel(app.ParametersPanel, 'Text', '', ...
                'Position', [282 y+7 10 8], 'BackgroundColor', [0 0 0]);

            y = y - 35;
            app.T2Label = uilabel(app.ParametersPanel, 'Text', 'T2 (twist param 2)', ...
                'Position', [10 y 140 22]);
            app.T2Spinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 4.5, ...
                'Limits', [0 2*pi], 'Step', 0.1, 'ValueDisplayFormat', '%.3f');
            app.CurveDotT2 = uilabel(app.ParametersPanel, 'Text', '', ...
                'Position', [282 y+7 10 8], 'BackgroundColor', [0 0 0]);

            y = y - 35;
            app.T3Label = uilabel(app.ParametersPanel, 'Text', 'T3 (twist param 3)', ...
                'Position', [10 y 140 22]);
            app.T3Spinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 2, ...
                'Limits', [0 2*pi], 'Step', 0.1, 'ValueDisplayFormat', '%.3f');
            app.CurveDotT3 = uilabel(app.ParametersPanel, 'Text', '', ...
                'Position', [282 y+7 10 8], 'BackgroundColor', [0 0 0]);



            % =============================================================
            %  LEFT COLUMN — Distribution Panel
            % =============================================================
            app.DistributionPanel = uipanel(app.UIFigure);
            app.DistributionPanel.Title = 'Intersection Distribution';
            app.DistributionPanel.Position = [1288 904 430 58];
            app.DistributionPanel.FontWeight = 'bold';

            app.DrawDistButton = uibutton(app.DistributionPanel, 'push');
            app.DrawDistButton.Text = 'Draw Distribution';
            app.DrawDistButton.Position = [10 8 140 26];
            app.DrawDistButton.ButtonPushedFcn = createCallbackFcn(app, @DrawDistButtonPushed, true);

            app.DistributionStatusLabel = uilabel(app.DistributionPanel);
            app.DistributionStatusLabel.Position = [158 10 130 18];
            app.DistributionStatusLabel.Text = '';
            app.DistributionStatusLabel.FontColor = [0.2 0.2 0.6];

            % =============================================================
            %  LEFT COLUMN — Geodesic Initial Conditions Panel
            % =============================================================
            app.GeodesicPanel = uipanel(app.UIFigure);
            app.GeodesicPanel.Title = 'Geodesic';
            app.GeodesicPanel.Position = [10 446 300 150];
            app.GeodesicPanel.FontWeight = 'bold';

            app.InfoGeodesicButton = uibutton(app.UIFigure, 'push');
            app.InfoGeodesicButton.Text = char(9432);
            app.InfoGeodesicButton.Position = [270 585 35 22];
            app.InfoGeodesicButton.FontSize = 14;
            app.InfoGeodesicButton.Tooltip = 'Help: Geodesic Initial Conditions';
            app.InfoGeodesicButton.ButtonPushedFcn = createCallbackFcn(app, @InfoGeodesicButtonPushed, true);

            app.MaxLenLabel = uilabel(app.GeodesicPanel, 'Text', 'Max geodesic length', ...
                'Position', [10 102 140 22]);
            app.MaxLenSpinner = uispinner(app.GeodesicPanel, ...
                'Position', [158 102 122 22], 'Value', 100000, ...
                'Limits', [100 1e8], 'Step', 10000, 'ValueDisplayFormat', '%.0f');

            app.InitCondButton = uibutton(app.GeodesicPanel, 'push');
            app.InitCondButton.Text = 'Initial conditions...';
            app.InitCondButton.Position = [10 62 160 28];
            app.InitCondButton.ButtonPushedFcn = createCallbackFcn(app, @InitCondButtonPushed, true);

            uilabel(app.GeodesicPanel, 'Text', 'Detect intersections with', ...
                'Position', [10 34 190 22]);
            app.CurveDotC1 = uilabel(app.GeodesicPanel, 'Text', '', ...
                'Position', [10 15 10 8], 'BackgroundColor', [0 0 0]);
            app.Curve1CheckBox = uicheckbox(app.GeodesicPanel, ...
                'Text', 'Curve 1', 'Position', [24 8 76 22], 'Value', true);
            app.CurveDotC2 = uilabel(app.GeodesicPanel, 'Text', '', ...
                'Position', [102 15 10 8], 'BackgroundColor', [0 0 0]);
            app.Curve2CheckBox = uicheckbox(app.GeodesicPanel, ...
                'Text', 'Curve 2', 'Position', [116 8 76 22], 'Value', true);
            app.CurveDotC3 = uilabel(app.GeodesicPanel, 'Text', '', ...
                'Position', [196 15 10 8], 'BackgroundColor', [0 0 0]);
            app.Curve3CheckBox = uicheckbox(app.GeodesicPanel, ...
                'Text', 'Curve 3', 'Position', [210 8 76 22], 'Value', true);

            % =============================================================
            %  LEFT COLUMN — Visualization Panel (created after GeodesicPanel so it renders on top)
            % =============================================================
            app.VisualizationPanel = uipanel(app.UIFigure);
            app.VisualizationPanel.Title = 'Run the geodesic';
            app.VisualizationPanel.Position = [10 9 300 210];
            app.VisualizationPanel.FontWeight = 'bold';

            app.VisualizeCheckBox = uicheckbox(app.VisualizationPanel, ...
                'Text', 'Visualize geodesics while running', ...
                'Position', [10 160 270 22], 'Value', false, ...
                'ValueChangedFcn', createCallbackFcn(app, @VisualizeCheckBoxChanged, true));

            app.VisDrawOptionsButton = uibutton(app.VisualizationPanel, 'push');
            app.VisDrawOptionsButton.Text = 'Drawing options...';
            app.VisDrawOptionsButton.Position = [10 120 130 28];
            app.VisDrawOptionsButton.ButtonPushedFcn = createCallbackFcn(app, @VisDrawOptionsButtonPushed, true);

            app.SaveArcFiltersButton = uibutton(app.VisualizationPanel, 'push');
            app.SaveArcFiltersButton.Text = 'Save arcs filters...';
            app.SaveArcFiltersButton.Position = [145 120 145 28];
            app.SaveArcFiltersButton.ButtonPushedFcn = createCallbackFcn(app, @SaveArcFiltersButtonPushed, true);

            app.RunButton = uibutton(app.VisualizationPanel, 'push');
            app.RunButton.Text = 'Run Geodesic Computation';
            app.RunButton.Position = [10 76 200 28];
            app.RunButton.FontWeight = 'bold';
            app.RunButton.BackgroundColor = [0.3 0.7 0.3];
            app.RunButton.FontColor = [1 1 1];
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);

            app.StopButton = uibutton(app.VisualizationPanel, 'push');
            app.StopButton.Text = 'Stop';
            app.StopButton.Position = [215 76 75 28];
            app.StopButton.FontWeight = 'bold';
            app.StopButton.BackgroundColor = [0.85 0.25 0.25];
            app.StopButton.FontColor = [1 1 1];
            app.StopButton.Enable = 'off';
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);

            app.ProgressGauge = uigauge(app.VisualizationPanel, 'linear');
            app.ProgressGauge.Position = [10 34 260 32];
            app.ProgressGauge.Limits = [0 100];
            app.ProgressGauge.Value = 0;

            app.StatusLabel = uilabel(app.VisualizationPanel);
            app.StatusLabel.Position = [10 8 260 18];
            app.StatusLabel.Text = 'Ready.';
            app.StatusLabel.FontColor = [0.2 0.2 0.6];

            app.InfoVisButton = uibutton(app.UIFigure, 'push');
            app.InfoVisButton.Text = char(9432);
            app.InfoVisButton.Position = [270 210 35 25];
            app.InfoVisButton.FontSize = 14;
            app.InfoVisButton.Tooltip = 'Help: Visualization';
            app.InfoVisButton.ButtonPushedFcn = createCallbackFcn(app, @InfoVisButtonPushed, true);

            % Info button for Distribution panel — created after VisualizationPanel so it renders on top
            app.InfoDistButton = uibutton(app.UIFigure, 'push');
            app.InfoDistButton.Text = char(9432);
            app.InfoDistButton.Position = [1683 940 35 22];
            app.InfoDistButton.FontSize = 14;
            app.InfoDistButton.Tooltip = 'Help: Intersection Distribution';
            app.InfoDistButton.ButtonPushedFcn = createCallbackFcn(app, @InfoDistButtonPushed, true);

            % =============================================================
            %  MIDDLE — Tab group with multiple views (x: 320..870)
            % =============================================================
            app.CenterTabGroup = uitabgroup(app.UIFigure);
            app.CenterTabGroup.Position = [320 11 958 950];

            % --- Hexagons tab ---
            app.HexTab = uitab(app.CenterTabGroup, 'Title', 'Hexagons');

            axW = 410; axH = 410;
            app.Ax1 = uiaxes(app.HexTab, 'Position', [15,  488, axW, axH]);
            app.Ax2 = uiaxes(app.HexTab, 'Position', [513, 488, axW, axH]);
            app.Ax3 = uiaxes(app.HexTab, 'Position', [15,  22,  axW, axH]);
            app.Ax4 = uiaxes(app.HexTab, 'Position', [513, 22,  axW, axH]);

            for ax = [app.Ax1, app.Ax2, app.Ax3, app.Ax4]
                ax.Box = 'on';
                axis(ax, 'equal');
                ax.XLim = [-1.1 1.1];
                ax.YLim = [-1.1 1.1];
            end

            % --- CDF Plots tab ---
            app.CDFTab = uitab(app.CenterTabGroup, 'Title', 'CDF Plots');

            app.CDFAxes = uiaxes(app.CDFTab, 'Position', [40 44 878 858]);
            title(app.CDFAxes, 'Orthospectrum CDF');
            xlabel(app.CDFAxes, 'Length');
            ylabel(app.CDFAxes, 'CDF');
            grid(app.CDFAxes, 'on');

            % --- 3D Surface tab ---
            app.SurfaceTab = uitab(app.CenterTabGroup, 'Title', '3D Surface');

            app.SurfaceAxes = uiaxes(app.SurfaceTab, 'Position', [20 22 918 873]);

            % --- Distribution tab ---
            app.DistTab = uitab(app.CenterTabGroup, 'Title', 'Distribution');

            app.DistAxes = uiaxes(app.DistTab, 'Position', [40 44 878 858]);
            title(app.DistAxes, 'Intersection Distribution');
            xlabel(app.DistAxes, 'Position on curve 1');
            ylabel(app.DistAxes, 'Angle');
            grid(app.DistAxes, 'on');

            % =============================================================
            %  RIGHT COLUMN — Remark + Music Panel
            % =============================================================
            app.RemarkLabel = uilabel(app.UIFigure);
            app.RemarkLabel.Position = [1288 714 430 28];
            app.RemarkLabel.Text = 'The two panels below only use the times the random geodesic has intersected the selected curves';
            app.RemarkLabel.WordWrap = 'on';
            app.RemarkLabel.FontAngle = 'italic';
            app.RemarkLabel.FontColor = [0.3 0.3 0.3];

            app.MusicPanel = uipanel(app.UIFigure);
            app.MusicPanel.Title = 'Music';
            app.MusicPanel.Position = [1288 524 430 184];
            app.MusicPanel.FontWeight = 'bold';

            app.InfoMusicButton = uibutton(app.UIFigure, 'push');
            app.InfoMusicButton.Text = char(9432);
            app.InfoMusicButton.Position = [1683 693 35 25];
            app.InfoMusicButton.FontSize = 14;
            app.InfoMusicButton.Tooltip = 'Help: Music';
            app.InfoMusicButton.ButtonPushedFcn = createCallbackFcn(app, @InfoMusicButtonPushed, true);

            ym = 137;
            app.SpeedMultLabel = uilabel(app.MusicPanel, 'Text', 'Speed multiplier', ...
                'Position', [10 ym 120 22]);
            app.SpeedMultSpinner = uispinner(app.MusicPanel, ...
                'Position', [140 ym 100 22], 'Value', 10, ...
                'Limits', [0.1 1000], 'Step', 1, 'ValueDisplayFormat', '%.1f');

            ym = ym - 35;
            app.MaxSongDurLabel = uilabel(app.MusicPanel, 'Text', 'Max song duration (min)', ...
                'Position', [10 ym 155 22]);
            app.MaxSongDurSpinner = uispinner(app.MusicPanel, ...
                'Position', [175 ym 80 22], 'Value', 1, ...
                'Limits', [1 10], 'Step', 1, 'ValueDisplayFormat', '%.0f');

            ym = ym - 40;
            app.PlayButton = uibutton(app.MusicPanel, 'push');
            app.PlayButton.Text = 'Play';
            app.PlayButton.Position = [10 ym 90 30];
            app.PlayButton.FontWeight = 'bold';
            app.PlayButton.BackgroundColor = [0.3 0.7 0.3];
            app.PlayButton.FontColor = [1 1 1];
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);

            app.StopMusicButton = uibutton(app.MusicPanel, 'push');
            app.StopMusicButton.Text = 'Stop';
            app.StopMusicButton.Position = [110 ym 70 30];
            app.StopMusicButton.FontWeight = 'bold';
            app.StopMusicButton.BackgroundColor = [0.85 0.25 0.25];
            app.StopMusicButton.FontColor = [1 1 1];
            app.StopMusicButton.Enable = 'off';
            app.StopMusicButton.ButtonPushedFcn = createCallbackFcn(app, @StopMusicButtonPushed, true);

            app.SaveWavButton = uibutton(app.MusicPanel, 'push');
            app.SaveWavButton.Text = 'Save WAV';
            app.SaveWavButton.Position = [190 ym 110 30];
            app.SaveWavButton.FontWeight = 'bold';
            app.SaveWavButton.BackgroundColor = [0.2 0.4 0.8];
            app.SaveWavButton.FontColor = [1 1 1];
            app.SaveWavButton.ButtonPushedFcn = createCallbackFcn(app, @SaveWavButtonPushed, true);

            ym = ym - 35;
            app.MusicStatusLabel = uilabel(app.MusicPanel);
            app.MusicStatusLabel.Position = [10 ym 410 22];
            app.MusicStatusLabel.Text = 'Run geodesic computation first.';
            app.MusicStatusLabel.FontColor = [0.2 0.2 0.6];

            % =============================================================
            %  LEFT COLUMN — Short Geodesic Arcs Panel (below Distribution)
            % =============================================================
            app.ShortGeoPanel = uipanel(app.UIFigure);
            app.ShortGeoPanel.Title = 'Short Geodesic Arcs';
            app.ShortGeoPanel.Position = [1288 748 430 150];
            app.ShortGeoPanel.FontWeight = 'bold';

            app.InfoShortGeoButton = uibutton(app.UIFigure, 'push');
            app.InfoShortGeoButton.Text = char(9432);
            app.InfoShortGeoButton.Position = [1683 886 35 22];
            app.InfoShortGeoButton.FontSize = 14;
            app.InfoShortGeoButton.Tooltip = 'Help: Short Geodesics';
            app.InfoShortGeoButton.ButtonPushedFcn = createCallbackFcn(app, @InfoShortGeoButtonPushed, true);

            app.ShortGeoNLabel = uilabel(app.ShortGeoPanel, 'Text', 'N', ...
                'Position', [10 96 22 22]);
            app.ShortGeoNSpinner = uispinner(app.ShortGeoPanel, ...
                'Position', [35 96 80 22], 'Value', 5, ...
                'Limits', [1 1000], 'Step', 1, 'ValueDisplayFormat', '%.0f');

            app.ShortGeoFiltersButton = uibutton(app.ShortGeoPanel, 'push');
            app.ShortGeoFiltersButton.Text = 'Filters...';
            app.ShortGeoFiltersButton.Position = [130 94 140 28];
            app.ShortGeoFiltersButton.ButtonPushedFcn = createCallbackFcn(app, @DrawArcFiltersButtonPushed, true);

            app.ShortGeoRunButton = uibutton(app.ShortGeoPanel, 'push');
            app.ShortGeoRunButton.Text = 'Find & Draw';
            app.ShortGeoRunButton.Position = [10 60 120 28];
            app.ShortGeoRunButton.FontWeight = 'bold';
            app.ShortGeoRunButton.BackgroundColor = [0.2 0.4 0.8];
            app.ShortGeoRunButton.FontColor = [1 1 1];
            app.ShortGeoRunButton.ButtonPushedFcn = createCallbackFcn(app, @ShortGeoRunButtonPushed, true);

            app.ShortGeoStopButton = uibutton(app.ShortGeoPanel, 'push');
            app.ShortGeoStopButton.Text = 'Stop';
            app.ShortGeoStopButton.Position = [140 60 70 28];
            app.ShortGeoStopButton.FontWeight = 'bold';
            app.ShortGeoStopButton.BackgroundColor = [0.85 0.25 0.25];
            app.ShortGeoStopButton.FontColor = [1 1 1];
            app.ShortGeoStopButton.Enable = 'off';
            app.ShortGeoStopButton.ButtonPushedFcn = createCallbackFcn(app, @ShortGeoStopButtonPushed, true);

            app.ShortGeoSlowCheckBox = uicheckbox(app.ShortGeoPanel, ...
                'Text', 'Draw slowly', 'Value', false, ...
                'Position', [10 32 110 22]);

            app.ShortGeoStatusLabel = uilabel(app.ShortGeoPanel);
            app.ShortGeoStatusLabel.Position = [10 8 390 22];
            app.ShortGeoStatusLabel.Text = 'Run geodesic computation first.';
            app.ShortGeoStatusLabel.FontColor = [0.2 0.2 0.6];

            % =============================================================
            %  RIGHT COLUMN — Orthospectrum Panel (x: 880..1290, bottom)
            % =============================================================
            app.OrthPanel = uipanel(app.UIFigure);
            app.OrthPanel.Title = 'Orthospectrum Computation';
            app.OrthPanel.Position = [1288 11 430 497];
            app.OrthPanel.FontWeight = 'bold';

            app.InfoOrthButton = uibutton(app.UIFigure, 'push');
            app.InfoOrthButton.Text = char(9432);
            app.InfoOrthButton.Position = [1683 493 35 25];
            app.InfoOrthButton.FontSize = 14;
            app.InfoOrthButton.Tooltip = 'Help: Orthospectrum';
            app.InfoOrthButton.ButtonPushedFcn = createCallbackFcn(app, @InfoOrthButtonPushed, true);

            y = 447;
            app.CurveIndexLabel = uilabel(app.OrthPanel, 'Text', 'Curve index', ...
                'Position', [10 y 120 22]);
            app.CurveIndexDropDown = uidropdown(app.OrthPanel, ...
                'Items', {'1','2','3'}, 'Value', '1', ...
                'Position', [140 y 80 22]);
            app.RecallOtherCurvesCheckBox = uicheckbox(app.OrthPanel, ...
                'Text', 'Recall other curves', 'Value', true, ...
                'Position', [230 y 170 22]);

            y = y - 40;
            app.OrthOptionsButton = uibutton(app.OrthPanel, 'push');
            app.OrthOptionsButton.Text = 'Options...';
            app.OrthOptionsButton.Position = [10 y 120 28];
            app.OrthOptionsButton.ButtonPushedFcn = createCallbackFcn(app, @OrthOptionsButtonPushed, true);

            app.GuessSepButton = uibutton(app.OrthPanel, 'push');
            app.GuessSepButton.Text = 'Guess sep / nonsep';
            app.GuessSepButton.Position = [135 y 265 28];
            app.GuessSepButton.ButtonPushedFcn = createCallbackFcn(app, @GuessSepButtonPushed, true);

            y = y - 45;
            app.ComputeOrthButton = uibutton(app.OrthPanel, 'push');
            app.ComputeOrthButton.Text = 'Estimate Next Element';
            app.ComputeOrthButton.Position = [10 y 180 35];
            app.ComputeOrthButton.FontWeight = 'bold';
            app.ComputeOrthButton.BackgroundColor = [0.2 0.4 0.8];
            app.ComputeOrthButton.FontColor = [1 1 1];
            app.ComputeOrthButton.Enable = 'off';
            app.ComputeOrthButton.ButtonPushedFcn = createCallbackFcn(app, @ComputeOrthButtonPushed, true);

            app.ResetOrthButton = uibutton(app.OrthPanel, 'push');
            app.ResetOrthButton.Text = 'Reset';
            app.ResetOrthButton.Position = [200 y 80 35];
            app.ResetOrthButton.FontWeight = 'bold';
            app.ResetOrthButton.BackgroundColor = [0.7 0.2 0.2];
            app.ResetOrthButton.FontColor = [1 1 1];
            app.ResetOrthButton.ButtonPushedFcn = createCallbackFcn(app, @ResetOrthButtonPushed, true);

            y = y - 30;
            app.OrthStatusLabel = uilabel(app.OrthPanel);
            app.OrthStatusLabel.Position = [10 y 410 22];
            app.OrthStatusLabel.Text = 'Run geodesic computation first.';
            app.OrthStatusLabel.FontColor = [0.2 0.2 0.6];

            y = y - 25;
            app.OrthTable = uitable(app.OrthPanel);
            app.OrthTable.Position = [10 10 410 y];
            app.OrthTable.ColumnName = {'Index', 'Length', 'Prob. %'};
            app.OrthTable.ColumnWidth = {50, 200, 100};
            app.OrthTable.CellSelectionCallback = createCallbackFcn(app, @OrthTableCellSelected, true);

            % --- Initialize curve color indicators ---
            updateCurveColors(app);

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