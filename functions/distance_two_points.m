function dist = distance_two_points(p1,p2)

delta = 2*(norm(p1-p2))^2 / ((1-norm(p1)^2)*(1-norm(p2)^2));

dist = acosh(1+delta);
end