prova_identifier = 16;

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

if prova_identifier == 10
fs = 44100;              % Frequenza di campionamento (Hz)
t = 0:1/fs:0.1;            % Durata di 0.1 secondo
f = 440;                 % Frequenza della nota (La4)
nota = sin(2*pi*f*t);    % Generazione dell'onda sinusoidale

sound(nota, fs);         % Riproduzione audio
end

if prova_identifier == 11

s=0.1;
y = -0.15;
theta = 0.5;

draw_hyp_plane
hold on

pv = point_and_tg_vector([0;y],[cos(theta); sin(theta)]);
[center, radius] = pv.geodesic_circonference_tg_vec
hold on

sv = point_and_tg_vector([tanh(2*s);0],[0; 1]);
[center2, radius2] = sv.geodesic_circonference_tg_vec

s = find_intersection_circles(center, radius, center2, radius2)

if isempty(s)
    d = Inf
elseif ~isempty(s)
    found = false;
    for h = 1:size(s,2)
        point = s(:,h);
        if norm(point)<1
            found = 1
            break
        end
    end
    if ~found
        throw(MException("unexpected", "There is an intersection but not in the plane. This is strange."))
    end
    d = distance_two_points([0;y], point)
end

hold off
end

if prova_identifier == 12

% 1. Define the parameters
N = 1000000; % Number of samples
s = min_east_side;
length_geodesic_actual = lengths_curves(1)
length_geodesic_guessed = length(to_music)/Max_len_geodesic * 2 * pi * pi
length_geodesic = length_geodesic_guessed;
function_fixed_s = @(y,theta) dist_function(y, theta, s);
width_x = 4*length_geodesic;



% 2. Generate random variables (e.g., Uniform distributions)
x = -width_x/2 + width_x * rand(N, 1);
theta = -pi/2 + pi * rand(N, 1);

% 3. Evaluate your function f(x, theta)
vals1 = zeros(1,N);
for ind = 1:N
    vals1(ind) = function_fixed_s(x(ind), theta(ind));
    if mod(ind, 100000)==0
        ind
    end
end

finitevals = vals1(isfinite(vals1));
AL = width_x * pi;
AB = length(finitevals)/N * AL;
num_inf_to_add = round(((length_geodesic*pi)/AB)*length(finitevals))-length(finitevals);
vals = [finitevals, Inf*ones(1,num_inf_to_add)];



% 4. Compute and Plot the Empirical CDF

figure
[f_vals, x_eval] = ecdf(vals);
% f_vals = f_vals * ( width_x / length_geodesic );

plot(x_eval, f_vals);
xlabel('y'); ylabel('P(f(x, \theta) \leq y)');
title('Empirical Cumulative Distribution Function');
grid on;

xlim([0,10])
ylim([0,1])

end

if prova_identifier ==13

% Define your function, for example:
f = @(y,theta) dist_function(y, theta, s); 

width_x = 20;


% Define grid
y = linspace(-width_x/2, width_x/2, 1000);
theta = linspace(-pi/2+0.01, pi/2-0.01, 1000);
[Y, THETA] = meshgrid(y, theta);

% Evaluate function


Z = NaN(length(theta), length(y));  % preallocate

% Evaluate function point by point
for i = 1:length(theta)
    for j = 1:length(y)
        val = f(y(j), theta(i));
        if isfinite(val)
            Z(i,j) = val;
        end
    end
    i
end

% Plot
figure;
surf(Y, THETA, Z);   % 3D surface
shading interp         % smooth color shading
colorbar               % show color scale
xlabel('y');
ylabel('\theta');
zlabel('f(y, \theta)');
title('Function plot avoiding infinities');
end


if prova_identifier ==14

f1 = f_vals;
x1 = x_eval;
f2 = fasd;
x2 = xasd;

% 1. Clean the data for both ECDFs
idx1 = isfinite(x1) & isfinite(f1);
x1_clean = x1(idx1);
f1_clean = f1(idx1);

idx2 = isfinite(x2) & isfinite(f2);
x2_clean = x2(idx2);
f2_clean = f2(idx2);

% 1. Remove duplicates from both ECDFs
% 'last' ensures we keep the highest CDF value for that specific X point
[x1_u, idx1] = unique(x1_clean, 'last');
f1_u = f1_clean(idx1);

[x2_u, idx2] = unique(x2_clean, 'last');
f2_u = f2_clean(idx2);

% 2. Define the common x-grid
x_common = unique([x1_u(:); x2_u(:)]);

% 3. Interpolate using the unique sets
f1_interp = interp1(x1_u, f1_u, x_common, 'previous', 0);
f2_interp = interp1(x2_u, f2_u, x_common, 'previous', 0);

figure
% 4. Subtract
f_diff = f2_interp - f1_interp;
fasd = f_diff;
xasd = x_common;
stairs(x_common, f_diff);
end

if prova_identifier == 15

F = fasd;
x = xasd;

% 2. Compute raw derivative (Method 1)
dF = diff(F);
dx = diff(x);
deriv_raw = dF ./ dx;

% 3. Smooth the derivative
% Adjust 'windowSize' to control smoothness (e.g., 5 to 20)
windowSize = 1000; 
deriv_smooth = movmean(deriv_raw, windowSize);

% 4. Plot
plot(x(1:end-1), deriv_smooth);
title('Smoothed Empirical Derivative');
end

if prova_identifier == 16

X = points_to_understand_distribution(1:end-1,1);
Y = points_to_understand_distribution(1:end-1,2);
Z = points_to_understand_distribution(1:end-1,3);

figure;
set(gca, 'ColorScale', 'log')
scatter(X, Y, [], Z, 'filled'); % 'filled' makes the points solid
set(gca, 'ColorScale', 'log')
grid on;
title('Data Point Distribution');
xlabel('X-axis');
ylabel('Y-axis');
end