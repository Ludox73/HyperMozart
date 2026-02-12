prova_identifier = 9;

if prova_identifier == 1

    rand_p1 = rand(2,1);
    rand_p2 = rand(2,1);
    rand_norm1 = rand(1);
    rand_norm2 = rand(1);
    rand_p1 = rand_p1/norm(rand_p1)*rand_norm1;
    rand_p2 = rand_p2/norm(rand_p2)*rand_norm2;

    L = segment(rand_p1, rand_p2);

    geodesic_circonference(L, 1);

end

if prova_identifier == 2

    seg1 = segment([0.1;0], [0; 0.1]);
    seg2 = segment([0.1;0], [0; 0.2]);

    geodesic_circonference(seg1, 1);
    hold on
    geodesic_circonference(seg2, 1);

    ang = angle(seg1, seg2)
end

if prova_identifier == 3

    
    ang=[];
    for a = 0.001:0.001:0.999
        seg1 = segment(a*[1;0], a*[cos(pi/4); -sin(pi/4)]);
        seg2 = segment(a*[1;0], a*[cos(pi/4); sin(pi/4)]);

        ang(end+1) = angle(seg1, seg2);
    end

    plot(ang)

    
    % Define the function to find the zero
    func = @(a) angle(segment(a*[1;0], a*[cos(pi/4); -sin(pi/4)]), ...
                      segment(a*[1;0], a*[cos(pi/4); sin(pi/4)])) - pi/4;

    % Use fzero to find the root of the function
    a_zero = fzero(func, 0.5); % Initial guess at 0.5

    % Display the result
    disp(['The zero of the function is at a = ', num2str(a_zero)]);
    
    a_zero-2^(-1/4)
end

if prova_identifier == 4

    a=2^(-1/4);
    p1 = a*[1;0];
    p2 = a*[cos(pi/4); -sin(pi/4)];

    q1=  a*[1;0];
    q2 = a*[cos(pi/4); sin(pi/4)];
    
    z1_poinc = p1(1) + p1(2)*1i;
    z2_poinc = p2(1) + p2(2)*1i;
    w1_poinc = q1(1) + q1(2)*1i;
    w2_poinc = q2(1) + q2(2)*1i;

    z1 = 1i*(1+z1_poinc)/(1-z1_poinc);
    z2 = 1i*(1+z2_poinc)/(1-z2_poinc);
    w1 = 1i*(1+w1_poinc)/(1-w1_poinc);
    w2 = 1i*(1+w2_poinc)/(1-w2_poinc);

    L = isometry_H2_two_points_upper_half(z1, z2, w1, w2)

end

if prova_identifier == 5

    a=2^(-1/4);
    p1 = a*[1;0];
    p2 = a*[cos(pi/4); -sin(pi/4)];

    q1=  a*[1;0];
    q2 = a*[cos(pi/4); sin(pi/4)];
    

    L5 = isometry_H2_two_points_poincare(p1, p2, q1, q2);

    L5.apply_poincare(p1)-q1

end



if prova_identifier == 6

    [vertices, all_sides] = rectangular_hexagon(1.2, 1.2, 1.2);
    
    collection_of_circles = cell(1,6);

    draw_hyp_plane;
    hold on

    for ind = 1:6
        if ind ~= 6
            ind2=ind+1;
        else
            ind2=1;
        end
        segment(vertices{ind}, vertices{ind2}).plot(1000, false)
        hold on
    end
    
end


if prova_identifier == 7
    
    p1 = point_and_vec_init.point;
    v1 = point_and_vec_init.tg_vector;


end

if prova_identifier == 8
    % reflection_through_geodesic = segment([0;0], [0.5;0]).mirroring_isometry.poincare_model
    % R = [-1 0; 0 1]
    % isoR = hyp_isometry_2d([], R)
    % iso_R.apply_upper_half_point_and_vector_orientation_reversing(np1, ntv1)
    % 
    z1_poinc = 0 + 0.2*1i;
    z2_poinc = 0 - 0.2*1i;

    z1 = 1i*(1+z1_poinc)/(1-z1_poinc)
    z2 = 1i*(1+z2_poinc)/(1-z2_poinc)
    % 
    % z1 = sqrt(2)/2 + sqrt(2)/2 * 1i;
    % z2 = -sqrt(2)/2 + sqrt(2)/2 * 1i;

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

    np1_poinc = -0 + 0*1i;
    ntv1_poinc = 1 + 0*1i

    np1 = 1i*(1+np1_poinc)/(1-np1_poinc);
    ntv1 = (1i + 1i)/((-np1_poinc + 1)^2) * ntv1_poinc
        

    iso_R = hyp_isometry_2d([], inv(M)*J*M);
    [np, ntv] = iso_R.apply_upper_half_point_and_vector_orientation_reversing(np1, ntv1)

    back_np = (np - 1i)/(np + 1i);
    back_ntv = (1i + 1i)/(1 * np + 1i)^2 * ntv

    new_point = [real(back_np); imag(back_np)];
    new_tg_vector = [real(back_ntv); imag(back_ntv)];
end

if prova_identifier == 9
f = first_intersection_geodesic_fundamental_domain(point_and_tg_vector([0.01; 0], [0.3; -1/2]), collection_of_collection_of_circles{2}, 7).point



figure
draw_hyp_plane
for ind = 1:6
    if ind ~= 6
        ind2=ind+1;
    else
        ind2=1;
    end
    segment(polytopes{3}{ind}, polytopes{3}{ind2}).plot(1000, false, 'b')
    
    hold on
end

for ind = 1:6
    if ind ~= 6
        ind2=ind+1;
    else
        ind2=1;
    end
    segment(polytopes{2}{ind}, polytopes{2}{ind2}).plot(1000, false, 'r')
    
    hold on
end

plot([0.01; f(1)], [0, f(2)]  )
end