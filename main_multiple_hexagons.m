% NEED TO THINK HOW TO VISUALIZE
% visualize = true;
% if visualize
%     figure
%     points_for_geodesics=10;
% end

lengths_curves = [2, 2, 3]; % Insert values
twisted_parameters = [1, 1, 1]; % Insert values in [0, 2pi)
Max_len_geodesic = 1000;

combination_curve_count_intersections = [1, 1; 2, 1; 3, 1; 4, 1] ;



curves_intersected = zeros(1, Max_len_geodesic);
to_music= zeros(Max_len_geodesic, 2);
index_curves = 1;

polytopes = {};

polytopes{1} = rectangular_hexagon(lengths_curves(1)/2, lengths_curves(2)/2, lengths_curves(2)/2);
polytopes{2} = rectangular_hexagon(lengths_curves(1)/2, lengths_curves(2)/2, lengths_curves(2)/2);
polytopes{3} = rectangular_hexagon(lengths_curves(1)/2, lengths_curves(3)/2, lengths_curves(3)/2);
polytopes{4} = rectangular_hexagon(lengths_curves(1)/2, lengths_curves(3)/2, lengths_curves(3)/2);


t1 = twisted_parameters(1);
t2 = twisted_parameters(2);
t3 = twisted_parameters(3);

% if strcmp(type_domain, "standard")
%     fundamental_domain = cell(1,8); %#ok<UNRCH>
%     for ind = 0:7
%         fundamental_domain{ind+1} = 2^(-1/4) * [cos(pi/4*ind); sin(pi/4*ind)];
%     end
% elseif strcmp(type_domain, "v1")
%     fundamental_domain = fundamental_domain_S2_Ludo(parameter_fundamental_domain); %#ok<UNRCH>
% elseif strcmp(type_domain, "v2")
%     fundamental_domain = fundamental_domain_S2_Ludo_v2(parameter_fundamental_domain);
% end

p_1 =barycenter_cell_of_points(polytopes{1});
polytope_index = 1;

a = rand(1)*2*pi;
tg_1 = (2/(1-norm(p_1)^2))^(-2)*[sin(a);cos(a)];

p0=point_and_tg_vector(p_1,tg_1);

collection_of_collection_of_circles = cell(length(polytopes));

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


% if visualize
%     draw_hyp_plane;
%     hold on
%     % p0.plot()
%     % for ind = 1:8
%     %     plot_circle(collection_of_circles{ind}{1}, collection_of_circles{ind}{2})
%     % end
% 
%     Colors = {'b','r', 'b', 'r', 'y', 'g', 'y', 'g'};
% 
%     for ind = 1:8
%         if ind ~= 8
%             ind2=ind+1;
%         else
%             ind2=1;
%         end
%         segment(fundamental_domain{ind}, fundamental_domain{ind2}).plot(1000, false, Colors{ind})
%         hold on
%     end
% 
% end

% if visualize
%     [clol, rlol] =  geodesic_circonference_tg_vec(p0);
%     % plot_circle(clol, rlol)
%     hold on
% end

[point_and_vec_inters, side] = first_intersection_geodesic_fundamental_domain(p0,collection_of_collection_of_circles{polytope_index});
[out_fund_dom_index, out_side_index, isometry] = pairing_hexagon_standard_S2(polytope_index, side, t1, t2, t3, point_and_vec_inters.point, polytopes);

% segment(p0, point_and_vec_inters).plot

travelled_distance = distance_two_points(p0.point,point_and_vec_inters.point);

[new_point,new_tg_vector]  = isometry.apply_poincare_point_and_vector(point_and_vec_inters.point,point_and_vec_inters.tg_vector);
point_and_vec_init = point_and_tg_vector(new_point,new_tg_vector);
polytope_index = out_fund_dom_index;
% to_music(index_curves, :) = [side, travelled_distance];
index_curves=index_curves+1;
to_avoid = out_side_index;
% if visualize
%     seg = segment(p0.point, point_and_vec_inters.point);
%     seg.plot()
%     hold on
% end
travelled_since_last_intersection = 0;

while travelled_distance<Max_len_geodesic
    % Start the cicle with:
    % - point_and_vec_init
    % - polytope_index
    % - to_avoid which is the side to avoid when computing the intersection


    % Here we compute the new intersection

    draw_hyp_plane;
    hold on
    polytope_index
    point_and_vec_init.tg_vector
    plot(point_and_vec_init.point(1), point_and_vec_init.point(2), 'o')
    hold on
    Colors = {'b','r', 'b', 'r', 'r', 'r', 'y', 'g'};
    for ind = 1:6
    if ind ~= 6
        ind2=ind+1;
    else
        ind2=1;
    end
    segment(polytopes{polytope_index}{ind}, polytopes{polytope_index}{ind2}).plot(1000, false, Colors{ind})
    
    hold on
    end



    [point_and_vec_inters, side] = first_intersection_geodesic_fundamental_domain(point_and_vec_init, collection_of_collection_of_circles{polytope_index}, to_avoid)
    

    segment(point_and_vec_init.point, point_and_vec_inters.point).plot(1000, false, 'g')


    % Here we add the data if necessary
    dtp = distance_two_points(point_and_vec_init.point,point_and_vec_inters.point);
    travelled_distance = travelled_distance + dtp;
    travelled_since_last_intersection = travelled_since_last_intersection + dtp;
    % to_music(index_curves-1, :) = [to_avoid, dtp];
    % index_curves=index_curves+1;
    
    % if visualize
    %     seg = segment(new_point, point_and_vec_inters.point);
    %     seg.plot(points_for_geodesics, false, Colors{side})
    %     hold on
    % end
    
    
    if ismember([polytope_index, side], combination_curve_count_intersections, 'rows') 
        to_music(index_curves-1, :) = [polytope_index, travelled_since_last_intersection];
        index_curves = index_curves + 1;
        travelled_since_last_intersection = 0;
    end



    % Here we compute the new initial vector
    [out_fund_dom_index, out_side_index, isometry] = pairing_hexagon_standard_S2(polytope_index, side, t1, t2, t3, point_and_vec_inters.point, polytopes);

    [new_point,new_tg_vector] = isometry.apply_poincare_point_and_vector(point_and_vec_inters.point,point_and_vec_inters.tg_vector);
    
    
    point_and_vec_init = point_and_tg_vector(new_point,new_tg_vector);
    polytope_index = out_fund_dom_index;
    to_avoid = out_side_index;

    % if visualize
    %     new_point_and_tg.plot()
    %     hold on
    % end

    
    
    
    
end

% for ind = 1:8
%     sum(curves_intersected == ind)
% end