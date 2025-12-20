function plot_circle(center, radius)

theta = linspace(0, 2*pi, 1000);
x = center(1) + radius * cos(theta);
y = center(2) + radius * sin(theta);

% Plot the arc
plot(x, y);
axis equal;

end
