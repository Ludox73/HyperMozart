%% test_geodesics_from_barycenter.m
% For every angle theta = 0:0.1:2*pi, start a geodesic at the barycenter
% of polytope 1 and follow it until it crosses 2 walls. Draw each geodesic
% in its own color on the standard 4-hexagon figure.

%% Parameters — edit these as needed
lengths_curves    = [5, 3, 3];
twisted_parameters = [0, 6.28, 0];
points_draw = 200;

%% Build polytopes
polytopes = cell(1,4);
polytopes{1} = rectangular_hexagon_centered(lengths_curves(1)/2, lengths_curves(2)/2, lengths_curves(2)/2);
polytopes{2} = rectangular_hexagon_centered(lengths_curves(1)/2, lengths_curves(2)/2, lengths_curves(2)/2);
polytopes{3} = rectangular_hexagon_centered(lengths_curves(1)/2, lengths_curves(3)/2, lengths_curves(3)/2);
polytopes{4} = rectangular_hexagon_centered(lengths_curves(1)/2, lengths_curves(3)/2, lengths_curves(3)/2);

t1 = twisted_parameters(1);
t2 = twisted_parameters(2);
t3 = twisted_parameters(3);

combination_noncoherent_orientation = [1,2; 1,4; 2,1; 2,3; 3,2; 3,4; 4,1; 4,3];

%% Build collection of circles for all polytopes
collection_of_collection_of_circles = cell(4, 1);
for idx_coll = 1:4
    num_sides = size(polytopes{1}, 1);
    coll = cell(1, num_sides);
    for ind = 1:num_sides
        ind2 = mod(ind, num_sides) + 1;
        seg = segment(polytopes{idx_coll}{ind}, polytopes{idx_coll}{ind2});
        [center, radius] = geodesic_circonference(seg);
        coll{ind} = {center, radius};
    end
    collection_of_collection_of_circles{idx_coll} = coll;
end

%% Draw the 4 hexagons
Styles = curves_S2_styles();
styleFunc = @(x,y) get_hexagon_style_separating(x,y);

fig = figure('Color', 'w', 'Name', 'Geodesic Fan Test', 'NumberTitle', 'off', ...
    'Position', [50 50 1000 800]);

ax_arr = gobjects(1,4);
for pi_idx = 1:4
    ax_arr(pi_idx) = subplot(2, 2, pi_idx);
    hold on; axis equal;
    % Poincare disk
    theta_circ = linspace(0, 2*pi, 200);
    plot(cos(theta_circ), sin(theta_circ), 'k-', 'LineWidth', 1);
    % Hexagon edges
    for s_idx = 1:6
        s2 = mod(s_idx, 6) + 1;
        seg_d = segment(polytopes{pi_idx}{s_idx}, polytopes{pi_idx}{s2});
        [cc, rr] = geodesic_circonference(seg_d);
        aa1 = angleCW2D([1;0], seg_d.startpoint - cc, false);
        aa2 = angleCW2D([1;0], seg_d.endpoint - cc, false);
        if abs(aa1-aa2) > pi
            if aa2 > aa1, aa2 = aa2-2*pi; else, aa1 = aa1-2*pi; end
        end
        tth = linspace(aa1, aa2, points_draw);
        sty = Styles{styleFunc(pi_idx, s_idx)};
        plot(cc(1)+rr*cos(tth), cc(2)+rr*sin(tth), ...
            'Color', sty{1}, 'LineStyle', sty{2}, 'LineWidth', sty{3});
    end
    title(sprintf('Polytope %d', pi_idx));
    xlim([-1.1 1.1]); ylim([-1.1 1.1]);
end

%% Generate colors for each geodesic
theta_values = 1:0.1:2;
n_geodesics = length(theta_values);
colors = hsv(n_geodesics);  % distinct color per geodesic

%% Barycenter of polytope 1
p_1 = barycenter_cell_of_points(polytopes{1});

%% Trace each geodesic for 2 wall crossings
num_walls_to_cross = 2;

for g_idx = 1:n_geodesics
    theta = theta_values(g_idx);
    col = colors(g_idx, :);
    
    % Initial tangent vector at the barycenter
    tg_1 = 20 * (2/(1-norm(p_1)^2))^(-2) * [cos(theta); sin(theta)];
    
    point_and_vec_init = point_and_tg_vector(p_1, tg_1);
    polytope_index = 1;
    to_avoid = 7;  % no side to avoid at start
    
    for wall = 1:num_walls_to_cross
        % Find next wall intersection
        [point_and_vec_inters, side] = first_intersection_geodesic_fundamental_domain( ...
            point_and_vec_init, collection_of_collection_of_circles{polytope_index}, to_avoid);
        
        % Draw the arc on the correct subplot
        seg_vis = segment(point_and_vec_init.point, point_and_vec_inters.point);
        [ctr, rad] = geodesic_circonference(seg_vis);
        a1 = angleCW2D([1;0], seg_vis.startpoint - ctr, false);
        a2 = angleCW2D([1;0], seg_vis.endpoint - ctr, false);
        if abs(a1-a2) > pi
            if a2 > a1, a2 = a2-2*pi; else, a1 = a1-2*pi; end
        end
        tth = linspace(a1, a2, points_draw);
        
        subplot(2, 2, polytope_index);
        plot(ctr(1)+rad*cos(tth), ctr(2)+rad*sin(tth), '-', 'Color', col, 'LineWidth', 1.2);
        
        % Compute pairing to continue into the next polytope
        [out_fund_dom_index, out_side_index, isometry] = pairing_hexagon_standard_S2( ...
            polytope_index, side, t1, t2, t3, point_and_vec_inters.point, polytopes);
        
        [new_point1, new_tg_vector1] = isometry.apply_poincare_point_and_vector( ...
            point_and_vec_inters.point, point_and_vec_inters.tg_vector);
        
        % Handle non-coherent orientation
        if is_row([polytope_index, out_fund_dom_index], combination_noncoherent_orientation)
            if out_side_index == 6
                index2 = 1;
            else
                index2 = out_side_index + 1;
            end
            pp1 = polytopes{out_fund_dom_index}{out_side_index};
            pp2 = polytopes{out_fund_dom_index}{index2};
            
            z1_poinc = pp1(1) + pp1(2)*1i;
            z2_poinc = pp2(1) + pp2(2)*1i;
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
            
            new_tg_vector = [real(back_ntv); imag(back_ntv)];
            
            point_and_vec_init = point_and_tg_vector(new_point1, new_tg_vector);
        else
            point_and_vec_init = point_and_tg_vector(new_point1, new_tg_vector1);
        end
        
        polytope_index = out_fund_dom_index;
        to_avoid = out_side_index;
    end
end

sgtitle(sprintf('Geodesic fan from barycenter of Polytope 1 — %d geodesics, %d twist', ...
    n_geodesics, twisted_parameters(2)));

drawnow;
