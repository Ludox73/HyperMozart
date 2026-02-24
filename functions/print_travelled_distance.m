function print_travelled_distance(travelled_distance, Max_len_geodesic)
%DRAW_HEXAGONS Draws the hexagons

if floor(100*(travelled_distance-1)/Max_len_geodesic) < floor(100*(travelled_distance-1)/Max_len_geodesic)
    fprintf('%d %% completed\n', floor(100*(travelled_distance)/Max_len_geodesic));
end
end