t=true
f=false

% NEED TO THINK HOW TO VISUALIZE
visualize = f;
points_draw_geodesics = 1000;
% This flah is used to create new figures and visualize geodesics that last
% less than the specified amount.
visualize_less_than = f;
visualize_only_first = f;
amount_less_than = 3.04;


lengths_curves = [2, 2, 3]; % Insert values
twisted_parameters = [1, 1, 1]; % Insert values in [0, 2pi)
Max_len_geodesic = 50000;

combination_curve_count_intersections = [1, 1; 2, 1; 3, 1; 4, 1] ;
combination_noncoherent_orientation = [1, 2; 1, 4; 2, 1; 2, 3; 3, 2; 3, 4; 4, 1; 4, 3] ;


curves_intersected = zeros(1, Max_len_geodesic);
to_music= zeros(Max_len_geodesic, 2);

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

p_1 = barycenter_cell_of_points(polytopes{1});
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


point_and_vec_init = p0;
travelled_since_last_intersection = 0;
travelled_distance=0;
to_avoid = length(polytopes{1}) + 1;
index_curves = 1;

if visualize == true
    fig1 = figure;

    draw_hexagons({'b','r', 'b', 'r', 'r', 'r'}, polytopes, 1000);
end

if visualize_less_than == true
    points_for_drawing = {};
end

while travelled_distance<Max_len_geodesic
    % Start the cicle with:
    % - point_and_vec_init
    % - polytope_index
    % - to_avoid which is the side to avoid when computing the intersection


    % Here we compute the new intersection

    [point_and_vec_inters, side] = first_intersection_geodesic_fundamental_domain(point_and_vec_init, collection_of_collection_of_circles{polytope_index}, to_avoid);
    
    if visualize == true
        subplot(2,2,polytope_index)
        hold on
        plot(point_and_vec_init.point(1), point_and_vec_init.point(2), 'o')
        segment(point_and_vec_init.point, point_and_vec_inters.point).plot(1000, false, 'g')
    end

    % Here we add the data if necessary
    dtp = distance_two_points(point_and_vec_init.point,point_and_vec_inters.point);
    travelled_distance = travelled_distance + dtp
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
    
    
    
    if ismember([polytope_index, side], combination_curve_count_intersections, 'rows') 
        to_music(index_curves, :) = [polytope_index, travelled_since_last_intersection];
        index_curves = index_curves + 1;
        
        if visualize_less_than
            if travelled_since_last_intersection < amount_less_than
                figure;
                draw_hexagons({'b','r', 'b', 'r', 'r', 'r'}, polytopes, points_draw_geodesics);
                
                for ind = 1:2:length(points_for_drawing)
                    subplot(2,2, points_for_drawing{ind}{2})
                    seg = segment(points_for_drawing{ind}{1}, points_for_drawing{ind+1}{1});
                    seg.plot(points_draw_geodesics, false, 'y')
                end
    
                
                if visualize
                    fig1;
                end
                if visualize_only_first
                    throw(MException("Break:Standard_break_of_script","First shorter geodesic found. We are interrupting the script."))
                end
            end
            points_for_drawing = {};
        end

        travelled_since_last_intersection = 0;
    end



    % Here we compute the new initial vector
    [out_fund_dom_index, out_side_index, isometry] = pairing_hexagon_standard_S2(polytope_index, side, t1, t2, t3, point_and_vec_inters.point, polytopes);

    [new_point1,new_tg_vector1] = isometry.apply_poincare_point_and_vector(point_and_vec_inters.point,point_and_vec_inters.tg_vector);
    
    if ismember([polytope_index, out_fund_dom_index], combination_noncoherent_orientation, 'rows')
        if out_side_index == 6
            index2 = 1;
        else
            index2 = out_side_index + 1;
        end
        z1_poinc = polytopes{polytope_index}{out_side_index}(1) + polytopes{polytope_index}{out_side_index}(2)*1i;
        z2_poinc = polytopes{polytope_index}{index2}(1) + polytopes{polytope_index}{index2}(2)*1i;
    
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
        ntv1 = (1i + 1i)/(-np1_poinc + 1)^2 * ntv1_poinc;
            

        iso_R = hyp_isometry_2d([], inv(M)*J*M);
        [np, ntv] = iso_R.apply_upper_half_point_and_vector_orientation_reversing(np1, ntv1);

        back_np = (np - 1i)/(np + 1i);
        back_ntv = (1i + 1i)/(1 * np + 1i)^2 * ntv;

        new_point = [real(back_np); imag(back_np)];
        new_tg_vector = [real(back_ntv); imag(back_ntv)];


        % reflection_through_geodesic = segment(polytopes{polytope_index}{out_side_index}, polytopes{polytope_index}{index2}).mirroring_isometry
        % 
        % [new_point,new_tg_vector] = reflection_through_geodesic.apply_poincare_point_and_vector_orientation_reversing(new_point1,new_tg_vector1);
        point_and_vec_init = point_and_tg_vector(new_point,new_tg_vector);
    else
        point_and_vec_init = point_and_tg_vector(new_point1,new_tg_vector1);
    end
    
    
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