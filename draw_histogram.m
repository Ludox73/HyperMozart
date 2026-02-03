figure

values_1 = to_music(to_music(:,1) == 2, 2);

[f, x] = ecdf(values_1);
plot(x, f, 'o-')

xlabel('Value')
ylabel('Empirical CDF')
title('std_from_south')
xlim([0 40])
grid on
