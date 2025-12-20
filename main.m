visualize = true;
if visualize
    figure 
end
a = rand(1)*2*pi;
p_1 = 0.1*[sin(a);cos(a)];

a = rand(1)*2*pi;
tg_1 = (2/0.99)^2*[sin(a);cos(a)];

p0=point_and_tg_vector(p_1,tg_1);

fundamental_domain = cell(1,8);
for ind = 0:7
    fundamental_domain{ind+1} = 2^(-1/4) * [cos(pi/4*ind); sin(pi/4*ind)];
end

collection_of_circles = cell(1,8);

for ind = 1:8
    if ind == 8
        ind2=1;
    else
        ind2=ind+1;
    end
    seg = segment(fundamental_domain{ind}, fundamental_domain{ind2});
    [center, radius] = geodesic_circonference(seg);
    collection_of_circles{ind} = {center, radius};
end

%Set up the transformations
isometries_pairing_sides = cell(1,8);

pairings = [
1,2,4,3;
2,3,5,4;
3,4,2,1;
4,5,3,2;
5,6,8,7;
6,7,1,8;
7,8,6,5;
8,1,7,6
];
for ind = 1:8
    isometries_pairing_sides{ind} = isometry_H2_two_points_poincare(fundamental_domain{pairings(ind,1)}, fundamental_domain{pairings(ind,2)}, fundamental_domain{pairings(ind,3)}, fundamental_domain{pairings(ind,4)});
end

mapping_of_sides = [
    1 3;
    2 4;
    3 1;
    4 2;
    5 7;
    6 8;
    7 5;
    8 6];

if visualize
    draw_hyp_plane;
    hold on
    % p0.plot()
    for ind = 1:8
        plot_circle(collection_of_circles{ind}{1}, collection_of_circles{ind}{2})
    end
end

if visualize
    [clol, rlol] =  geodesic_circonference_tg_vec(p0);
    % plot_circle(clol, rlol)
    hold on
end

[point_and_vec_inters, side] = first_intersection_geodesic_fundamental_domain(p0,collection_of_circles);
to_avoid = mapping_of_sides(side,2);
if visualize
    seg = segment(p0.point, point_and_vec_inters.point);
    seg.plot()
    hold on
end
travelled_distance = distance_two_points(p0.point,point_and_vec_inters.point);

while travelled_distance<1000
    
        
    isometry_to_use = isometries_pairing_sides{side};
    [new_point,new_tg_vector] = isometry_to_use.apply_poincare_point_and_vector(point_and_vec_inters.point,point_and_vec_inters.tg_vector);
    
    new_point_and_tg = point_and_tg_vector(new_point,new_tg_vector);
    
    % if visualize
    %     new_point_and_tg.plot()
    %     hold on
    % end

    [point_and_vec_inters, side] = first_intersection_geodesic_fundamental_domain(new_point_and_tg,collection_of_circles, to_avoid);
    to_avoid = mapping_of_sides(side,2);
    if visualize
        seg = segment(new_point, point_and_vec_inters.point);
        seg.plot(10)
        hold on
    end
    
    travelled_distance = travelled_distance + distance_two_points(new_point_and_tg.point,point_and_vec_inters.point)



end