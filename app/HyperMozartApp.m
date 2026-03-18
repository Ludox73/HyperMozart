classdef HyperMozartApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure

        % --- Left panel: Parameters ---
        ParametersPanel              matlab.ui.container.Panel
        GluingDropDown               matlab.ui.control.DropDown
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
        SamplePointsLabel            matlab.ui.control.Label
        SamplePointsSpinner          matlab.ui.control.Spinner
        DrawOrthCheckBox             matlab.ui.control.CheckBox
        SymmetricCheckBox            matlab.ui.control.CheckBox
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
    end

    % Internal state
    properties (Access = private)
        to_music                     % Result matrix from geodesic computation
        points_distribution          % Nx3 matrix [position, angle, travel_time] for distribution plot
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
        marimba_signals              % Precomputed marimba signals for each curve
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
                'Max geodesic length — total hyperbolic arc', ...
                'length of the geodesic to trace before stopping.', '', ...
                'Draw Hexagons — preview the four right-angled', ...
                'hexagons (fundamental domains) in the Poincaré disk.', '', ...
                'Draw 3D Surface — render a 3D model of the', ...
                'genus-2 surface with the curves highlighted.'};
            uialert(app.UIFigure, strjoin(msg, newline), 'Surface Parameters', 'Icon', 'info');
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
                'removed entirely to keep the display clean.'};
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
                'Assume symmetric loops (2×) — assumes every', ...
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
                gluing_preview = create_gluing_standard_S2();
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
                chi_sigma   = app.ChiSigmaSpinner.Value;
                app.orth_length_geodesic = guess_length_geodesics_from_to_music( ...
                    app.to_music, index_curve, chi_sigma);
                [app.orth_x_vals, app.orth_f_vals] = compute_cumufun_from_to_music( ...
                    app.to_music, index_curve);
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
                draw_flag   = app.DrawOrthCheckBox.Value;
                symmetric   = app.SymmetricCheckBox.Value;
                n_samples   = app.SamplePointsSpinner.Value;

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
            points_draw_geodesics = app.PointsDrawSpinner.Value;
            speed_drawing_geodesic = app.SpeedDrawSpinner.Value;
            make_geodesics_grey_after = app.GreyAfterSpinner.Value;
            delete_geodesics_after = app.DeleteAfterSpinner.Value;

            notes_frequency   = [440.00, 554.37, 659.25];
            fs_audio = 44100;
            % Precompute marimba signals for playback during visualization
            geo_signals = cell(1, length(notes_frequency));
            for k = 1:length(notes_frequency)
                geo_signals{k} = play_note_marimba(notes_frequency, k);
            end

            if strcmp(app.GluingDropDown.Value, 'Separating S2')
                gluing = create_gluing_standard_S2();
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
            points_dist_local = [];

            while travelled_distance < Max_len_geodesic

                % Check for stop request
                if app.StopRequested
                    throw(MException('HyperMozart:UserStop', 'Stopped by user.'));
                end

                % Track distribution for curve 1 crossings
                if polytope_index == 1 && to_avoid == 1
                    l = distance_two_points(point_and_vec_init.point, polytopes{1}{1});
                    hv = point_and_vec_init.point - collection_of_collection_of_circles{1}{1}{1};
                    vca = [-hv(2), hv(1)];
                    points_dist_local(end+1, :) = [l, angleCW2D(vca, point_and_vec_init.tg_vector), 0];
                end
                if polytope_index == 2 && to_avoid == 1
                    l = lengths_curves(1)/2 + distance_two_points(point_and_vec_init.point, polytopes{2}{2});
                    hv = point_and_vec_init.point - collection_of_collection_of_circles{2}{1}{1};
                    vca = [-hv(2), hv(1)];
                    points_dist_local(end+1, :) = [l, angleCW2D(point_and_vec_init.tg_vector, vca) - pi, 0];
                end
                if polytope_index == 3 && to_avoid == 1
                    l = mod(twisted_parameters(1)/(2*pi)*lengths_curves(1) + distance_two_points(point_and_vec_init.point, polytopes{3}{1}), lengths_curves(1));
                    hv = point_and_vec_init.point - collection_of_collection_of_circles{3}{1}{1};
                    vca = [-hv(2), hv(1)];
                    points_dist_local(end+1, :) = [l, -angleCW2D(vca, point_and_vec_init.tg_vector), 0];
                end
                if polytope_index == 4 && to_avoid == 1
                    l = mod(twisted_parameters(1)/(2*pi)*lengths_curves(1) + lengths_curves(1)/2 + distance_two_points(point_and_vec_init.point, polytopes{4}{2}), lengths_curves(1));
                    hv = point_and_vec_init.point - collection_of_collection_of_circles{4}{1}{1};
                    vca = [-hv(2), hv(1)];
                    points_dist_local(end+1, :) = [l, -(angleCW2D(point_and_vec_init.tg_vector, vca) - pi), 0];
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
                travelled_distance = travelled_distance + dtp;
                travelled_since_last_intersection = travelled_since_last_intersection + dtp;

                % Check curve intersections
                intersects_curve_1 = is_row([polytope_index, side], curve_combinations_1);
                intersects_curve_2 = is_row([polytope_index, side], curve_combinations_2);
                intersects_curve_3 = is_row([polytope_index, side], curve_combinations_3);

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
                        if ~isempty(points_dist_local) && points_dist_local(end,3) == 0
                            points_dist_local(end,3) = travelled_since_last_intersection;
                        end
                    end
                    travelled_since_last_intersection = 0;
                    first_cycle = false;
                end

                % Compute pairing / next initial vector
                [out_fund_dom_index, out_side_index, isometry] = pairing_from_gluing( ...
                    gluing, polytope_index, side, twisted_parameters, point_and_vec_inters.point, polytopes);

                [new_point1, new_tg_vector1] = isometry.apply_poincare_point_and_vector( ...
                    point_and_vec_inters.point, point_and_vec_inters.tg_vector);

                if is_row([polytope_index, out_fund_dom_index], gluing.noncoherent_pairs)
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
            app.points_distribution = points_dist_local;

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
            app.ParametersPanel.Position = [10 335 300 555];
            app.ParametersPanel.FontWeight = 'bold';

            % Info button — parameters panel documentation
            app.InfoParamsButton = uibutton(app.UIFigure, 'push');
            app.InfoParamsButton.Text = char(9432);
            app.InfoParamsButton.Position = [270 880 35 25];
            app.InfoParamsButton.FontSize = 14;
            app.InfoParamsButton.Tooltip = 'Help: Surface Parameters';
            app.InfoParamsButton.ButtonPushedFcn = createCallbackFcn(app, @InfoParamsButtonPushed, true);

            % --- Gluing selector ---
            uilabel(app.ParametersPanel, 'Text', 'Surface type', ...
                'Position', [10 492 95 22], 'FontWeight', 'bold');
            app.GluingDropDown = uidropdown(app.ParametersPanel, ...
                'Items', {'Separating S2', 'Nonseparating S2'}, ...
                'Position', [115 492 165 22], ...
                'Value', 'Separating S2');

            % --- Curve lengths ---
            y = 460;
            app.L1Label = uilabel(app.ParametersPanel, 'Text', 'L1 (curve 1 length)', ...
                'Position', [10 y 140 22]);
            app.L1Spinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 4, ...
                'Limits', [0.1 100], 'Step', 0.5, 'ValueDisplayFormat', '%.2f');

            y = y - 35;
            app.L2Label = uilabel(app.ParametersPanel, 'Text', 'L2 (curve 2 length)', ...
                'Position', [10 y 140 22]);
            app.L2Spinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 2, ...
                'Limits', [0.1 100], 'Step', 0.5, 'ValueDisplayFormat', '%.2f');

            y = y - 35;
            app.L3Label = uilabel(app.ParametersPanel, 'Text', 'L3 (curve 3 length)', ...
                'Position', [10 y 140 22]);
            app.L3Spinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 3.5, ...
                'Limits', [0.1 100], 'Step', 0.5, 'ValueDisplayFormat', '%.2f');

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
                'Limits', [0 2*pi-0.001], 'Step', 0.1, 'ValueDisplayFormat', '%.3f');

            y = y - 35;
            app.T2Label = uilabel(app.ParametersPanel, 'Text', 'T2 (twist param 2)', ...
                'Position', [10 y 140 22]);
            app.T2Spinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 4.5, ...
                'Limits', [0 2*pi-0.001], 'Step', 0.1, 'ValueDisplayFormat', '%.3f');

            y = y - 35;
            app.T3Label = uilabel(app.ParametersPanel, 'Text', 'T3 (twist param 3)', ...
                'Position', [10 y 140 22]);
            app.T3Spinner = uispinner(app.ParametersPanel, ...
                'Position', [160 y 120 22], 'Value', 2, ...
                'Limits', [0 2*pi-0.001], 'Step', 0.1, 'ValueDisplayFormat', '%.3f');

            % --- Active curves ---
            y = y - 40;
            app.Curve1CheckBox = uicheckbox(app.ParametersPanel, ...
                'Text', 'Curve 1', 'Position', [10 y 80 22], 'Value', true);
            app.Curve2CheckBox = uicheckbox(app.ParametersPanel, ...
                'Text', 'Curve 2', 'Position', [100 y 80 22], 'Value', true);
            app.Curve3CheckBox = uicheckbox(app.ParametersPanel, ...
                'Text', 'Curve 3', 'Position', [190 y 80 22], 'Value', true);

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

            app.InfoVisButton = uibutton(app.UIFigure, 'push');
            app.InfoVisButton.Text = char(9432);
            app.InfoVisButton.Position = [270 350 35 25];
            app.InfoVisButton.FontSize = 14;
            app.InfoVisButton.Tooltip = 'Help: Visualization';
            app.InfoVisButton.ButtonPushedFcn = createCallbackFcn(app, @InfoVisButtonPushed, true);

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
            app.RunButton.Position = [10 62 200 28];
            app.RunButton.FontWeight = 'bold';
            app.RunButton.BackgroundColor = [0.3 0.7 0.3];
            app.RunButton.FontColor = [1 1 1];
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);

            app.StopButton = uibutton(app.UIFigure, 'push');
            app.StopButton.Text = 'Stop';
            app.StopButton.Position = [220 62 90 28];
            app.StopButton.FontWeight = 'bold';
            app.StopButton.BackgroundColor = [0.85 0.25 0.25];
            app.StopButton.FontColor = [1 1 1];
            app.StopButton.Enable = 'off';
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);

            app.ProgressGauge = uigauge(app.UIFigure, 'linear');
            app.ProgressGauge.Position = [10 28 300 32];
            app.ProgressGauge.Limits = [0 100];
            app.ProgressGauge.Value = 0;

            app.StatusLabel = uilabel(app.UIFigure);
            app.StatusLabel.Position = [10 8 300 18];
            app.StatusLabel.Text = 'Ready.';
            app.StatusLabel.FontColor = [0.2 0.2 0.6];

            % =============================================================
            %  LEFT COLUMN — Distribution Panel
            % =============================================================
            app.DistributionPanel = uipanel(app.UIFigure);
            app.DistributionPanel.Title = 'Intersection Distribution';
            app.DistributionPanel.Position = [10 94 300 53];
            app.DistributionPanel.FontWeight = 'bold';

            app.InfoDistButton = uibutton(app.UIFigure, 'push');
            app.InfoDistButton.Text = char(9432);
            app.InfoDistButton.Position = [270 138 35 22];
            app.InfoDistButton.FontSize = 14;
            app.InfoDistButton.Tooltip = 'Help: Intersection Distribution';
            app.InfoDistButton.ButtonPushedFcn = createCallbackFcn(app, @InfoDistButtonPushed, true);

            app.DrawDistButton = uibutton(app.DistributionPanel, 'push');
            app.DrawDistButton.Text = 'Draw Distribution';
            app.DrawDistButton.Position = [10 8 140 26];
            app.DrawDistButton.ButtonPushedFcn = createCallbackFcn(app, @DrawDistButtonPushed, true);

            app.DistributionStatusLabel = uilabel(app.DistributionPanel);
            app.DistributionStatusLabel.Position = [158 10 130 18];
            app.DistributionStatusLabel.Text = '';
            app.DistributionStatusLabel.FontColor = [0.2 0.2 0.6];

            % =============================================================
            %  MIDDLE — Tab group with multiple views (x: 320..870)
            % =============================================================
            app.CenterTabGroup = uitabgroup(app.UIFigure);
            app.CenterTabGroup.Position = [320 10 550 880];

            % --- Hexagons tab ---
            app.HexTab = uitab(app.CenterTabGroup, 'Title', 'Hexagons');

            axW = 240; axH = 380;
            app.Ax1 = uiaxes(app.HexTab, 'Position', [15,  440, axW, axH]);
            app.Ax2 = uiaxes(app.HexTab, 'Position', [280, 440, axW, axH]);
            app.Ax3 = uiaxes(app.HexTab, 'Position', [15,  20,  axW, axH]);
            app.Ax4 = uiaxes(app.HexTab, 'Position', [280, 20,  axW, axH]);

            for ax = [app.Ax1, app.Ax2, app.Ax3, app.Ax4]
                ax.Box = 'on';
                axis(ax, 'equal');
                ax.XLim = [-1.1 1.1];
                ax.YLim = [-1.1 1.1];
            end

            % --- CDF Plots tab ---
            app.CDFTab = uitab(app.CenterTabGroup, 'Title', 'CDF Plots');

            app.CDFAxes = uiaxes(app.CDFTab, 'Position', [40 40 480 780]);
            title(app.CDFAxes, 'Orthospectrum CDF');
            xlabel(app.CDFAxes, 'Length');
            ylabel(app.CDFAxes, 'CDF');
            grid(app.CDFAxes, 'on');

            % --- 3D Surface tab ---
            app.SurfaceTab = uitab(app.CenterTabGroup, 'Title', '3D Surface');

            app.SurfaceAxes = uiaxes(app.SurfaceTab, 'Position', [20 20 510 810]);

            % --- Distribution tab ---
            app.DistTab = uitab(app.CenterTabGroup, 'Title', 'Distribution');

            app.DistAxes = uiaxes(app.DistTab, 'Position', [40 40 480 780]);
            title(app.DistAxes, 'Intersection Distribution');
            xlabel(app.DistAxes, 'Position on curve 1');
            ylabel(app.DistAxes, 'Angle');
            grid(app.DistAxes, 'on');

            % =============================================================
            %  RIGHT COLUMN — Music Panel (x: 880..1290, top)
            % =============================================================
            app.MusicPanel = uipanel(app.UIFigure);
            app.MusicPanel.Title = 'Music';
            app.MusicPanel.Position = [880 625 410 265];
            app.MusicPanel.FontWeight = 'bold';

            app.InfoMusicButton = uibutton(app.UIFigure, 'push');
            app.InfoMusicButton.Text = char(9432);
            app.InfoMusicButton.Position = [1255 880 35 25];
            app.InfoMusicButton.FontSize = 14;
            app.InfoMusicButton.Tooltip = 'Help: Music';
            app.InfoMusicButton.ButtonPushedFcn = createCallbackFcn(app, @InfoMusicButtonPushed, true);

            ym = 215;
            app.SpeedMultLabel = uilabel(app.MusicPanel, 'Text', 'Speed multiplier', ...
                'Position', [10 ym 120 22]);
            app.SpeedMultSpinner = uispinner(app.MusicPanel, ...
                'Position', [140 ym 100 22], 'Value', 10, ...
                'Limits', [0.1 1000], 'Step', 1, 'ValueDisplayFormat', '%.1f');

            ym = ym - 35;
            app.MaxSongDurLabel = uilabel(app.MusicPanel, 'Text', 'Max song duration (min)', ...
                'Position', [10 ym 155 22]);
            app.MaxSongDurSpinner = uispinner(app.MusicPanel, ...
                'Position', [175 ym 80 22], 'Value', 10, ...
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
            app.MusicStatusLabel.Position = [10 ym 380 22];
            app.MusicStatusLabel.Text = 'Run geodesic computation first.';
            app.MusicStatusLabel.FontColor = [0.2 0.2 0.6];

            % =============================================================
            %  RIGHT COLUMN — Orthospectrum Panel (x: 880..1290, bottom)
            % =============================================================
            app.OrthPanel = uipanel(app.UIFigure);
            app.OrthPanel.Title = 'Orthospectrum Computation';
            app.OrthPanel.Position = [880 10 410 640];
            app.OrthPanel.FontWeight = 'bold';

            app.InfoOrthButton = uibutton(app.UIFigure, 'push');
            app.InfoOrthButton.Text = char(9432);
            app.InfoOrthButton.Position = [1255 640 35 25];
            app.InfoOrthButton.FontSize = 14;
            app.InfoOrthButton.Tooltip = 'Help: Orthospectrum';
            app.InfoOrthButton.ButtonPushedFcn = createCallbackFcn(app, @InfoOrthButtonPushed, true);

            y = 500;
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
            app.SamplePointsLabel = uilabel(app.OrthPanel, 'Text', 'Sample points (subtraction)', ...
                'Position', [10 y 170 22]);
            app.SamplePointsSpinner = uispinner(app.OrthPanel, ...
                'Position', [190 y 80 22], 'Value', 100000, ...
                'Limits', [1000 5000000], 'Step', 50000, 'ValueDisplayFormat', '%.0f');

            y = y - 35;
            app.DrawOrthCheckBox = uicheckbox(app.OrthPanel, ...
                'Text', 'Draw intermediate CDF plots', ...
                'Position', [10 y 250 22], 'Value', true);

            y = y - 30;
            app.SymmetricCheckBox = uicheckbox(app.OrthPanel, ...
                'Text', 'Assume symmetric loops (2x)', ...
                'Position', [10 y 250 22], 'Value', false);

            y = y - 40;
            app.ComputeOrthButton = uibutton(app.OrthPanel, 'push');
            app.ComputeOrthButton.Text = 'Compute Next Element';
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
            app.OrthStatusLabel.Position = [10 y 380 22];
            app.OrthStatusLabel.Text = 'Run geodesic computation first.';
            app.OrthStatusLabel.FontColor = [0.2 0.2 0.6];

            y = y - 25;
            app.OrthTable = uitable(app.OrthPanel);
            app.OrthTable.Position = [10 10 380 y];
            app.OrthTable.ColumnName = {'Index', 'Length', 'Prob. %'};
            app.OrthTable.ColumnWidth = {50, 200, 100};
            app.OrthTable.CellSelectionCallback = createCallbackFcn(app, @OrthTableCellSelected, true);

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