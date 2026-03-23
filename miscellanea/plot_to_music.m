% AI generated
 
A = to_music(1:100, :);

y = A(:,2);
L = A(:,1);

% Compute start and end x for each segment
x_start = cumsum([0; L(1:end-1)]);
x_end   = x_start + L;

% Plot
figure; hold on; box on;

% Draw each segment as a horizontal line
for i = 1:numel(y)
    plot([x_start(i), x_end(i)], [y(i), y(i)], 'LineWidth', 3);
end

% Optional styling
xlabel('x (cumulative length)');
ylabel('height (y)');
title('Horizontal segments at given heights with specified lengths');
ylim([min(y)-0.5, max(y)+0.5]);
xlim([0, x_end(end)]);
grid on;

