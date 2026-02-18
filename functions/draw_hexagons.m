function draw_hexagons(Colors, polytopes, number_points_drawing)
%DRAW_HEXAGONS Draws the hexagons

num_hexagons = length(polytopes);
if num_hexagons == 4
    for polytope_index_plot = 1:4
            subplot(2,2,polytope_index_plot);
            draw_hyp_plane;
            hold on
            for ind = 1:6
                if ind ~= 6
                    ind2=ind+1;
                else
                    ind2=1;
                end
                segment(polytopes{polytope_index_plot}{ind}, polytopes{polytope_index_plot}{ind2}).plot(number_points_drawing, false, Colors{ind})
                
                hold on
            end
    end
else
    raise(MException("Unsupported number of hexagons for drawing."))
end
end