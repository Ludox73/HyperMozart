function styleIdx = get_hexagon_style_nonseparating(val1, val2)
    % Style lookup for the nonseparating_S2 gluing.
    % Rows = hexagon index (1-4), columns = side index (1-6).
    %
    % Style library (curves_S2_styles):
    %   1: Red Solid        2: Green Solid      3: Blue Solid
    %   4: Magenta Dashed   5: Cyan Dashed       6: Orange Dashed
    %   7: Purple Solid     8: Dark Grey Dashed  9: Brown Solid
    %
    % Side 1 (all):      Brown solid     (9)
    % Side 2 hex 1,2:    Blue solid      (3)
    % Side 2 hex 3,4:    Orange dashed   (6)
    % Side 3 (all):      Dark grey dash  (8)
    % Side 4 hex 1,2:    Red solid       (1)
    % Side 4 hex 3,4:    Magenta dashed  (4)
    % Side 5 (all):      Purple solid    (7)
    % Side 6 hex 1,2:    Green solid     (2)
    % Side 6 hex 3,4:    Cyan dashed     (5)

    lookup = [
        9, 3, 8, 1, 7, 2;  % hex 1
        9, 3, 8, 1, 7, 2;  % hex 2
        9, 6, 8, 4, 7, 5;  % hex 3
        9, 6, 8, 4, 7, 5   % hex 4
    ];

    if val1 >= 1 && val1 <= size(lookup, 1) && ...
       val2 >= 1 && val2 <= size(lookup, 2)
        styleIdx = lookup(val1, val2);
    else
        error('Out of intervals: val1(1-4), val2(1-6).');
    end
end
