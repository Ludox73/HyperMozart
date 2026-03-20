t=true;
f=false;

% NEED TO THINK HOW TO VISUALIZE
visualize = t;
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



lengths_curves = [5, 1.5, 3]; % Insert values
twisted_parameters = [2.4, 1.2, 5.4]; % Insert values in [0, 2pi)
Max_len_geodesic = 100;

pause_time = 0;

gluing = create_gluing_nonseparating_S2();


curves_intersected = zeros(1, Max_len_geodesic);
to_music = zeros(Max_len_geodesic, 2);

polytopes = build_polytopes_from_gluing(gluing, lengths_curves);

p_1 = barycenter_cell_of_points(polytopes{1});
polytope_index = 1;

a = rand(1)*2*pi;
tg_1 = 20*(2/(1-norm(p_1)^2))^(-2)*[sin(a);cos(a)];

p0=point_and_tg_vector(p_1,tg_1);

collection_of_collection_of_circles = build_circles_from_polytopes(polytopes);

points_to_understand_distribution = [];


point_and_vec_init = p0;
travelled_since_last_intersection = 0;
travelled_distance=0;
to_avoid = length(polytopes{1}) + 1;
index_curves = 1;

if visualize == true
    fig1 = figure;
    Styles=curves_S2_styles();
    draw_hexagons(Styles, polytopes, points_draw_geodesics, @(x,y) gluing.hex_style(x,y));
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
    if to_avoid == 1
        if polytope_index == 1 || polytope_index == 3
            l = distance_two_points(point_and_vec_init.point, polytopes{polytope_index}{1});
        else
            l =  lengths_curves(1)/2+ distance_two_points(point_and_vec_init.point,polytopes{polytope_index}{2});
        end
        help_vector = (point_and_vec_init.point - collection_of_collection_of_circles{polytope_index}{1}{1});
        vector_to_compute_angle = [-help_vector(2), help_vector(1)];
        if polytope_index == 1 || polytope_index == 3
            angle = angleCW2D(vector_to_compute_angle, point_and_vec_init.tg_vector);
        else
            angle = angleCW2D(point_and_vec_init.tg_vector, vector_to_compute_angle) - pi;
        end
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
    
    
    intersects_curve_1 = is_row([polytope_index, side], gluing.curve_combinations{1});
    intersects_curve_2 = is_row([polytope_index, side], gluing.curve_combinations{2});
    intersects_curve_3 = is_row([polytope_index, side], gluing.curve_combinations{3});

    if intersects_curve_1 || intersects_curve_2 || intersects_curve_3
        if intersects_curve_1
                which_curve = 1;
            elseif intersects_curve_2
                which_curve = 2;
            elseif intersects_curve_3
                which_curve = 3;
        end
        if visualize
            s = play_note_marimba(notes_frequency, which_curve);
            sound(s, 44100);
        end
        if ~first_cycle
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
                    draw_hexagons(Styles, polytopes, points_draw_geodesics, @(x,y) gluing.hex_style(x,y));
                    
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
    [point_and_vec_init, polytope_index, to_avoid] = apply_pairing( ...
        point_and_vec_inters, polytope_index, side, gluing, twisted_parameters, polytopes);

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