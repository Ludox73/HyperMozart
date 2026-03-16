t=true;
f=false;

% NEED TO THINK HOW TO VISUALIZE
visualize = f;
points_draw_geodesics = 10;
speed_drawing_geodesic = 2;
make_geodesics_grey_after = 2;
delete_geodesics_after = Inf;
% This flah is used to create new figures and visualize geodesics that last
% less than the specified amount.
visualize_less_than = f;
visualize_only_first_amount = 1;
amount_less_than = 0.7594;
visualize_only_one_side = "east"; %Choose "east", "west" or "both"

notes_frequency = [440.00, 554.37, 659.25]; % A, C#, E
how_long_note_played =0.1;



lengths_curves = [5, 3, 3]; % Insert values
twisted_parameters = [0, pi/2, pi/2]; % Insert values in [0, 2pi)
Max_len_geodesic = 100000;

combination_curve_count_intersections1 = [1, 1; 2, 1; 3, 1; 4, 1] ;
% combination_curve_count_intersections2 = [1, 3; 1, 5; 2, 3; 2, 5] ;
% combination_curve_count_intersections3 = [3, 3; 3, 5; 4, 3; 4, 5] ;
combination_curve_count_intersections2 = [0, 0] ;
combination_curve_count_intersections3 = [0, 0] ;


pause_time = 0;

combination_noncoherent_orientation = [1, 2; 1, 4; 2, 1; 2, 3; 3, 2; 3, 4; 4, 1; 4, 3] ;


curves_intersected = zeros(1, Max_len_geodesic);
to_music = zeros(Max_len_geodesic, 2);

polytopes = {};

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

p0=point_and_tg_vector(p_1,tg_1);

collection_of_collection_of_circles = cell(length(polytopes));

points_to_understand_distribution = [];

for index_collection_of_collection = 1:length(polytopes)
    num_sides = size(polytopes{1},1);
    collection_of_circles = cell(1,num_sides);
    
    for ind = 1:num_sides
        if ind == num_sides
            ind2=1;
        else
            ind2=ind+1;
        end
        seg = segment(polytopes{index_collection_of_collection}{ind}, polytopes{index_collection_of_collection}{ind2});
        [center, radius] = geodesic_circonference(seg);
        collection_of_circles{ind} = {center, radius};
    end
    collection_of_collection_of_circles{index_collection_of_collection} = collection_of_circles;
end


point_and_vec_init = p0;
travelled_since_last_intersection = 0;
travelled_distance=0;
to_avoid = length(polytopes{1}) + 1;
index_curves = 1;

if visualize == true
    fig1 = figure;
    Styles=curves_S2_styles();
    draw_hexagons(Styles, polytopes, points_draw_geodesics, @(x,y) get_hexagon_style_separating(x,y));
    drawn_geodesics = {};
end

if visualize_less_than == true
    points_for_drawing = {};
end

first_cycle= true;
number_visualized = 0;

current_percentage = 0;

while travelled_distance<Max_len_geodesic
    % Start the cicle with:
    % - point_and_vec_init
    % - polytope_index
    % - to_avoid which is the side to avoid when computing the intersection
    


    %This is to get a distribution of intersections
    if polytope_index == 1 && to_avoid ==1
        l = distance_two_points(point_and_vec_init.point, polytopes{1}{1});


        help_vector = (point_and_vec_init.point - collection_of_collection_of_circles{1}{1}{1});
        vector_to_compute_angle = [-help_vector(2), help_vector(1)];
        angle = angleCW2D(vector_to_compute_angle, point_and_vec_init.tg_vector);

        % angle = mod(atan2(point_and_vec_init.tg_vector(2),point_and_vec_init.tg_vector(1)), 2*pi);

        points_to_understand_distribution = [points_to_understand_distribution; l, angle, 0];
    end
    if polytope_index == 2 && to_avoid ==1
        l =  lengths_curves(1)/2+ distance_two_points(point_and_vec_init.point,polytopes{2}{2});
        
        help_vector = (point_and_vec_init.point - collection_of_collection_of_circles{1}{1}{1});
        vector_to_compute_angle = [-help_vector(2), help_vector(1)];
        angle = angleCW2D(point_and_vec_init.tg_vector, vector_to_compute_angle) - pi;

        % angle = mod(atan2(point_and_vec_init.tg_vector(2),point_and_vec_init.tg_vector(1)), 2*pi);

        points_to_understand_distribution = [points_to_understand_distribution; l, angle, 0];
    end

    % Here we compute the new intersection
    [point_and_vec_inters, side] = first_intersection_geodesic_fundamental_domain(point_and_vec_init, collection_of_collection_of_circles{polytope_index}, to_avoid);
    
    if visualize == true
        subplot(2,2,polytope_index)
        hold on
        % plot(point_and_vec_init.point(1), point_and_vec_init.point(2), 'o')
        drawn_geodesics{end+1} = segment(point_and_vec_init.point, point_and_vec_inters.point).plot_real_time(points_draw_geodesics, false, {'r', '-',  1}, speed_drawing_geodesic);
        if length(drawn_geodesics)>make_geodesics_grey_after
            drawn_geodesics{end-make_geodesics_grey_after}.Color = [0.9, 0.9, 0.9];
        end
        if length(drawn_geodesics)>delete_geodesics_after
            delete(drawn_geodesics{end-delete_geodesics_after});
        end
    end

    % Here we add the data if necessary
    dtp = distance_two_points(point_and_vec_init.point,point_and_vec_inters.point);
    travelled_distance = travelled_distance + dtp;
    print_travelled_distance(travelled_distance, Max_len_geodesic)

    travelled_since_last_intersection = travelled_since_last_intersection + dtp;
    % to_music(index_curves-1, :) = [to_avoid, dtp];
    % index_curves=index_curves+1;
    
    % if visualize
    %     seg = segment(new_point, point_and_vec_inters.point);
    %     seg.plot(points_for_geodesics, false, Colors{side})
    %     hold on
    % end

    if visualize_less_than == true
        if travelled_since_last_intersection < amount_less_than
            points_for_drawing{end+1} = {point_and_vec_init.point, polytope_index};
            points_for_drawing{end+1} = {point_and_vec_inters.point, polytope_index};
        end
    end
    
    
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
                play_note_marimba(notes_frequency, which_curve, how_long_note_played)
            end
             
            to_music(index_curves, :) = [travelled_since_last_intersection, which_curve];
            index_curves = index_curves + 1;

            if ~isempty(points_to_understand_distribution)
                if points_to_understand_distribution(end, 3) == 0
                    points_to_understand_distribution(end, 3) = travelled_since_last_intersection;
                end
            end
            
            flag_correct_side = false;
            if strcmp(visualize_only_one_side, "east")
                if (polytope_index == 1 || polytope_index == 2)
                    flag_correct_side = true;
                end
            elseif strcmp(visualize_only_one_side, "west")
                if (polytope_index == 3 || polytope_index == 4)
                    flag_correct_side = true;
                end
            elseif strcmp(visualize_only_one_side, "both")
                flag_correct_side = true;
            else
                throw(MException("variable_value:unexpected", "Unexpected value for variable visualize_only_one_side. Supported strings are east, west, and both."))
            end
            
            if visualize_less_than ==true && flag_correct_side
                if travelled_since_last_intersection < amount_less_than
                    figure
                    draw_hexagons(Styles, polytopes, points_draw_geodesics, @(x,y) get_hexagon_style_separating(x,y));
                    
                    for ind = 1:2:length(points_for_drawing)
                        subplot(2,2, points_for_drawing{ind}{2})
                        seg = segment(points_for_drawing{ind}{1}, points_for_drawing{ind+1}{1});
                        seg.plot(points_draw_geodesics, false)
                    end
        
                    
                    if visualize
                        fig1;
                    end
    
                    number_visualized = number_visualized + 1;
                    if visualize_only_first_amount == number_visualized
                        throw(MException("Break:Standard_break_of_script","First shorter geodesic found. We are interrupting the script."))
                    end
                end
            end
        end
        
        travelled_since_last_intersection = 0;
        points_for_drawing = {};
        first_cycle = false;
    end



    % Here we compute the new initial vector
    [out_fund_dom_index, out_side_index, isometry] = pairing_hexagon_standard_S2(polytope_index, side, t1, t2, t3, point_and_vec_inters.point, polytopes);

    [new_point1,new_tg_vector1] = isometry.apply_poincare_point_and_vector(point_and_vec_inters.point,point_and_vec_inters.tg_vector);
    
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

        x1 = real(z1);
        y1 = imag(z1);
        x2 = real(z2);
        y2 = imag(z2);
        c = (x1^2 + y1^2 - x2^2 - y2^2) / (2*(x1-x2));

        r=sqrt((x1-c)^2 + y1^2);

        alpha = c-r;
        beta = c+r;

        M = [ 1 -alpha; 1 -beta];
        J = [-1 0; 0 1];
    
        np1_poinc = new_point1(1) + new_point1(2)*1i;
        ntv1_poinc = new_tg_vector1(1) + new_tg_vector1(2)*1i;

        np1 = 1i*(1+np1_poinc)/(1-np1_poinc);
        ntv1 = 2i/(-np1_poinc + 1)^2 * ntv1_poinc;
        
        aus_M = M\J*M;
        iso_R = hyp_isometry_2d([], aus_M);
        [np, ntv] = iso_R.apply_upper_half_point_and_vector_orientation_reversing(np1, ntv1);
        
        back_np = (np - 1i)/(np + 1i);
        back_ntv = (2i)/(1 * np + 1i)^2 * ntv;

        new_point = [real(back_np); imag(back_np)];
        new_tg_vector = [real(back_ntv); imag(back_ntv)];
        
        if norm(new_point1 - new_point)>1e-4
            warning("It looks that the mirroring is moving points on the segment. There may be an error here.")
            value = norm(new_point1 - new_point)
        end
        
        % We use new_point1 since it should not have been changed.
        point_and_vec_init = point_and_tg_vector(new_point1,new_tg_vector);
    else
        point_and_vec_init = point_and_tg_vector(new_point1,new_tg_vector1);
    end
    
    
    polytope_index = out_fund_dom_index;
    to_avoid = out_side_index;

    % if visualize
    %     new_point_and_tg.plot()
    %     hold on
    % end

    if visualize
        drawnow
        pause(pause_time)
    end

    if floor(100*travelled_distance/Max_len_geodesic) ~= current_percentage
        fprintf('%d%% completed\n', floor(travelled_distance / Max_len_geodesic * 100))
        current_percentage = floor(100*travelled_distance/Max_len_geodesic);
    end
    
end


to_music =  to_music(2:end, :);
to_music = to_music(to_music(1:end,1) ~= 0, :);
 
% This worked before. Now we do not save the side anymore.
% min_east_side = min( min(to_music(to_music(:,1) == 1, 2)), min(to_music(to_music(:,1) == 2, 2)))
% min_west_side = min( min(to_music(to_music(:,1) == 3, 2)), min(to_music(to_music(:,1) == 4, 2)))
% for ind = 1:8
%     sum(curves_intersected == ind)
% end