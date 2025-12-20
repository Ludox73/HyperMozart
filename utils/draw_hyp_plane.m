function draw_hyp_plane(~)

theta = linspace(0, 2 * pi, 1000); % 100 points from 0 to 2*pi

% Draw the unit circumference
unit_radius = 1; % Radius of the unit circle
unit_center = [0;0]; % Center of the unit circle at the midpoint of the segment

% Generate points on the circumference of the unit circle
unit_x = unit_center(1) + unit_radius * cos(theta);
unit_y = unit_center(2) + unit_radius * sin(theta);

% Plot the unit circle
plot(unit_x, unit_y, 'g--'); % Plot the unit circumference in green dashed line

axis equal;
grid on;
end