function fundamental_domain = fundamental_domain_S2_Ludo_v3(param1, param2, param3)
%FUNDAMENTAL_DOMAIN_S2_v3 : this does not compute a correct fundamental
%domain. Avoid using this.

assert(false)

fundamental_domain = cell(1,8);

if param1 == 0
    tf_vertices_euclidean_norm_1 = 2^(-1/4);
elseif param1<0
    tf_vertices_euclidean_norm_1 = (param1+1)*2^(-1/4);
elseif param1>0
    tf_vertices_euclidean_norm_1 = 2^(-1/4) + param1*(1-2^(-1/4));
end

if param2 == 0
    tf_vertices_euclidean_norm_2 = 2^(-1/4);
elseif param2<0
    tf_vertices_euclidean_norm_2 = (param2+1)*2^(-1/4);
elseif param2>0
    tf_vertices_euclidean_norm_2 = 2^(-1/4) + param2*(1-2^(-1/4));
end

if param3 == 0
    tf_vertices_euclidean_norm_3 = 2^(-1/4);
elseif param3<0
    tf_vertices_euclidean_norm_3 = (param3+1)*2^(-1/4);
elseif param3>0
    tf_vertices_euclidean_norm_3 = 2^(-1/4) + param3*(1-2^(-1/4));
end




v_1 = tf_vertices_euclidean_norm_1*[1;0];
v_2 = @(a) a*[cos(pi/4); sin(pi/4)];
v_3 = tf_vertices_euclidean_norm_2*[0;1];
v_4 = @(a) a*[-cos(pi/4); sin(pi/4)];
v_5 = tf_vertices_euclidean_norm_1*[-1;0];
v_6 = @(a) a*[-cos(pi/4); -sin(pi/4)];
v_7 = tf_vertices_euclidean_norm_3*[0;-1];
v_8 = @(a) a*[cos(pi/4); -sin(pi/4)];

angle_uponefive = @(a) segment(v_1, [0.1;0.00000000000001]).angle(segment(v_1, v_2(a))); %I SHOULD CHANGE 0.0000000000000000001
angle_twofour = @(a) segment(v_2(a), v_1).angle(segment( v_2(a), v_3));
angle_three = @(a) segment(v_3, v_2(a)).angle(segment(v_3, v_4(a)));
angle_downonefive = @(a) segment(v_1, v_8(a)).angle(segment(v_1, [0.1;0.00000000000001])); %I SHOULD CHANGE 0.0000000000000000001
angle_sixeight = @(a) segment(v_8(a), v_7).angle(segment( v_8(a), v_1));
angle_seven = @(a) segment(v_7, v_6(a)).angle(segment( v_7, v_8(a)));

to_nullify_up = @(ss) pi- ( ...
    2*angle_uponefive(ss) + ...
    2*angle_twofour(ss) + ...
    angle_three(ss));

to_nullify_down = @(ss) pi- ( ...
    2*angle_downonefive(ss)+ ...
    2*angle_sixeight(ss) + ...
    angle_seven(ss));

se_vertices_euclidean_norm_up = fzero(to_nullify_up, [0.0001,0.9999]);
se_vertices_euclidean_norm_down = fzero(to_nullify_down, [0.0001,0.9999]);


assert(se_vertices_euclidean_norm_up<1);
assert(se_vertices_euclidean_norm_down<1);


fundamental_domain{1} = tf_vertices_euclidean_norm_1*[1;0];
fundamental_domain{2} = se_vertices_euclidean_norm_up*[cos(pi/4); sin(pi/4)];
fundamental_domain{3} = tf_vertices_euclidean_norm_2*[0;1];
fundamental_domain{4} = se_vertices_euclidean_norm_up*[-cos(pi/4); sin(pi/4)];
fundamental_domain{5} = tf_vertices_euclidean_norm_1*[-1;0];
fundamental_domain{6} = se_vertices_euclidean_norm_down*[-cos(pi/4); -sin(pi/4)];
fundamental_domain{7} = tf_vertices_euclidean_norm_3*[0;-1];
fundamental_domain{8} = se_vertices_euclidean_norm_down*[cos(pi/4); -sin(pi/4)];

end