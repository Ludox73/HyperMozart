function fundamental_domain = fundamental_domain_S2_Ludo_v2(param)
%FUNDAMENTAL_DOMAIN_S2_v2 We create a fundamental domain for S2 that is a
%octagon. We parametrize the octagon in a strange way:
% param is a real value in (-1, +1). When param == 0, we have the
% standard regular octahedron.
% While param -> -1, we push the vertices 2 and 4 close to the origin, and 
% we change accordingly the vertices 6 and 8 to keep 2*pi around the point.
% While param -> +1, we do the opposite.
fundamental_domain = cell(1,8);

if param == 0
    for ind = 0:7
        fundamental_domain{ind+1} = 2^(-1/4) * [cos(pi/4*ind); sin(pi/4*ind)];
    end
    return;
elseif param<0
    tf_vertices_euclidean_norm = (param+1)*2^(-1/4)
elseif param>0
    tf_vertices_euclidean_norm = 2^(-1/4) + param*(1-2^(-1/4))
end

v_1 = 2^(-1/4)*[1;0];
v_2 = tf_vertices_euclidean_norm*[cos(pi/4); sin(pi/4)];
v_3 = 2^(-1/4)*[0;1];
v_4 = tf_vertices_euclidean_norm*[-cos(pi/4); sin(pi/4)];
v_6 = @(a) a*[-cos(pi/4); -sin(pi/4)];
v_7 = 2^(-1/4)*[0;-1];
v_8 = @(a) a*[cos(pi/4); -sin(pi/4)];

angle_onefive = @(a) segment(v_1, v_8(a)).angle(segment(v_1, v_2));
angle_twofour = segment(v_2, v_1).angle(segment( v_2, v_3));
angle_three = segment(v_3, v_2).angle(segment(v_3, v_4));
angle_sixeight = @(a) segment(v_8(a), v_7).angle(segment( v_8(a), v_1));
angle_seven = @(a) segment(v_7, v_6(a)).angle(segment( v_7, v_8(a)));

to_nullify = @(ss) 2*pi- ( ...
    2*angle_onefive(ss) + ...
    2*angle_twofour + ...
    angle_three + ...
    2*angle_sixeight(ss)+ ...
    angle_seven(ss))   ;

se_vertices_euclidean_norm = fzero(to_nullify, [0.001,0.999]);

assert(se_vertices_euclidean_norm<1);


for ind = 0:2:6
    fundamental_domain{ind+1} = 2^(-1/4) * [cos(pi/4*ind); sin(pi/4*ind)];
end

for ind = 1:2:3
    fundamental_domain{ind+1} = tf_vertices_euclidean_norm * [cos(pi/4*ind); sin(pi/4*ind)];
end

for ind = 5:2:7
    fundamental_domain{ind+1} = se_vertices_euclidean_norm * [cos(pi/4*ind); sin(pi/4*ind)];
end

end