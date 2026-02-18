function [out_fund_dom_index, out_side_index, isometry] = pairing_hexagon_standard_S2(in_fund_domain_index, in_side_index, t1, t2, t3, intersection_point, polytopes)
%PAIRING_STANDARD This object contains the information of the gluing.
% Given:
% - The index of the fundamental domain
% - The index of the side
% - The twisted parameters
% - The point of intersection
% - The polytopes
% Returns:
% - The index of the following fundamental domain
% - The index of the following side
% - The isometry that must be used to continue the geodesic

% We start with the gluings that create the pair of pants, the easiest ones.
if all([in_fund_domain_index, in_side_index] == [1, 6])
    out_fund_dom_index = 2;
    out_side_index = 6;
    isometry = isometry_H2_two_points_poincare(polytopes{1}{6}, polytopes{1}{1}, polytopes{2}{6}, polytopes{2}{1});
elseif all([in_fund_domain_index, in_side_index] == [1, 4])
    out_fund_dom_index = 2;
    out_side_index = 4;
    isometry = isometry_H2_two_points_poincare(polytopes{1}{4}, polytopes{1}{5}, polytopes{2}{4}, polytopes{2}{5});

elseif all([in_fund_domain_index, in_side_index] == [1, 2])
    out_fund_dom_index = 2;
    out_side_index = 2;
    isometry = isometry_H2_two_points_poincare(polytopes{1}{2}, polytopes{1}{3}, polytopes{2}{2}, polytopes{2}{3});

elseif all([in_fund_domain_index, in_side_index] == [2, 6])
    out_fund_dom_index = 1;
    out_side_index = 6;
    isometry = isometry_H2_two_points_poincare(polytopes{2}{6}, polytopes{2}{1}, polytopes{1}{6}, polytopes{1}{1});

elseif all([in_fund_domain_index, in_side_index] == [2, 4])
    out_fund_dom_index = 1;
    out_side_index = 4;
    isometry = isometry_H2_two_points_poincare(polytopes{2}{4}, polytopes{2}{5}, polytopes{1}{4}, polytopes{1}{5});

elseif all([in_fund_domain_index, in_side_index] == [2, 2])
    out_fund_dom_index = 1;
    out_side_index = 2;
    isometry = isometry_H2_two_points_poincare(polytopes{2}{2}, polytopes{2}{3}, polytopes{1}{2}, polytopes{1}{3});

elseif all([in_fund_domain_index, in_side_index] == [3, 6])
    out_fund_dom_index = 4;
    out_side_index = 6;
    isometry = isometry_H2_two_points_poincare(polytopes{3}{6}, polytopes{3}{1}, polytopes{4}{6}, polytopes{4}{1});
elseif all([in_fund_domain_index, in_side_index] == [3, 4])
    out_fund_dom_index = 4;
    out_side_index = 4;
    isometry = isometry_H2_two_points_poincare(polytopes{3}{4}, polytopes{3}{5}, polytopes{4}{4}, polytopes{4}{5});

elseif all([in_fund_domain_index, in_side_index] == [3, 2])
    out_fund_dom_index = 4;
    out_side_index = 2;
    isometry = isometry_H2_two_points_poincare(polytopes{3}{2}, polytopes{3}{3}, polytopes{4}{2}, polytopes{4}{3});


elseif all([in_fund_domain_index, in_side_index] == [4, 6])
    out_fund_dom_index = 3;
    out_side_index = 6;
    isometry = isometry_H2_two_points_poincare(polytopes{4}{6}, polytopes{4}{1}, polytopes{3}{6}, polytopes{3}{1});
elseif all([in_fund_domain_index, in_side_index] == [4, 4])
    out_fund_dom_index = 3;
    out_side_index = 4;
    isometry = isometry_H2_two_points_poincare(polytopes{4}{4}, polytopes{4}{5}, polytopes{3}{4}, polytopes{3}{5});

elseif all([in_fund_domain_index, in_side_index] == [4, 2])
    out_fund_dom_index = 3;
    out_side_index = 2;
    isometry = isometry_H2_two_points_poincare(polytopes{4}{2}, polytopes{4}{3}, polytopes{3}{2}, polytopes{3}{3});




% We now move to the more complicated ones. 1st hexagon

elseif all([in_fund_domain_index, in_side_index] == [1, 1])
    [isometry, overshoot] = compute_isometry_with_twisted_parameter(intersection_point, polytopes{1}{1}, polytopes{1}{2}, polytopes{3}{2}, polytopes{3}{1}, polytopes{4}{1}, polytopes{4}{2}, t1);
    if overshoot == 0 ||  overshoot == 2
        out_fund_dom_index = 3;
        out_side_index = 1;
    elseif overshoot == 1 
        out_fund_dom_index = 4;
        out_side_index = 1; 
    end

elseif all([in_fund_domain_index, in_side_index] == [1, 3])
    [isometry, overshoot] = compute_isometry_with_twisted_parameter(intersection_point, polytopes{1}{3}, polytopes{1}{4}, polytopes{1}{6}, polytopes{1}{5}, polytopes{2}{5}, polytopes{2}{6}, t2);
    if overshoot == 0 ||  overshoot == 2
        out_fund_dom_index = 1;
        out_side_index = 5;
    elseif overshoot == 1 
        out_fund_dom_index = 2;
        out_side_index = 5; 
    end

elseif all([in_fund_domain_index, in_side_index] == [1, 5])
    [isometry, overshoot] = compute_isometry_with_twisted_parameter(intersection_point, polytopes{1}{5}, polytopes{1}{6}, polytopes{1}{4}, polytopes{1}{3}, polytopes{2}{3}, polytopes{2}{4}, t2);
    if overshoot == 0 ||  overshoot == 2
        out_fund_dom_index = 1;
        out_side_index = 3;
    elseif overshoot == 1 
        out_fund_dom_index = 2;
        out_side_index = 3; 
    end


% 2nd hexagon
elseif all([in_fund_domain_index, in_side_index] == [2, 1])
    [isometry, overshoot] = compute_isometry_with_twisted_parameter(intersection_point, polytopes{2}{1}, polytopes{2}{2}, polytopes{4}{2}, polytopes{4}{1}, polytopes{3}{1}, polytopes{3}{2}, t1);
    if overshoot == 0 ||  overshoot == 2
        out_fund_dom_index = 4;
        out_side_index = 1;
    elseif overshoot == 1 
        out_fund_dom_index = 3;
        out_side_index = 1; 
    end

elseif all([in_fund_domain_index, in_side_index] == [2, 3])
    [isometry, overshoot] = compute_isometry_with_twisted_parameter(intersection_point, polytopes{2}{3}, polytopes{2}{4}, polytopes{2}{6}, polytopes{2}{5}, polytopes{1}{5}, polytopes{1}{6}, t2);
    if overshoot == 0 ||  overshoot == 2
        out_fund_dom_index = 2;
        out_side_index = 5;
    elseif overshoot == 1 
        out_fund_dom_index = 1;
        out_side_index = 5; 
    end

elseif all([in_fund_domain_index, in_side_index] == [2, 5])
    [isometry, overshoot] = compute_isometry_with_twisted_parameter(intersection_point, polytopes{2}{5}, polytopes{2}{6}, polytopes{2}{4}, polytopes{2}{3}, polytopes{1}{3}, polytopes{1}{4}, t2);
    if overshoot == 0 ||  overshoot == 2
        out_fund_dom_index = 2;
        out_side_index = 3;
    elseif overshoot == 1 
        out_fund_dom_index = 1;
        out_side_index = 3; 
    end



% 3rd hexagon

elseif all([in_fund_domain_index, in_side_index] == [3, 1])
    [isometry, overshoot] = compute_isometry_with_twisted_parameter(intersection_point, polytopes{3}{1}, polytopes{3}{2}, polytopes{1}{2}, polytopes{1}{1}, polytopes{2}{1}, polytopes{2}{2}, t1);
    if overshoot == 0 ||  overshoot == 2
        out_fund_dom_index = 1;
        out_side_index = 1;
    elseif overshoot == 1 
        out_fund_dom_index = 2;
        out_side_index = 1; 
    end

elseif all([in_fund_domain_index, in_side_index] == [3, 3])
    [isometry, overshoot] = compute_isometry_with_twisted_parameter(intersection_point, polytopes{3}{3}, polytopes{3}{4}, polytopes{3}{6}, polytopes{3}{5}, polytopes{4}{5}, polytopes{4}{6}, t3);
    if overshoot == 0 ||  overshoot == 2
        out_fund_dom_index = 3;
        out_side_index = 5;
    elseif overshoot == 1 
        out_fund_dom_index = 4;
        out_side_index = 5; 
    end

elseif all([in_fund_domain_index, in_side_index] == [3, 5])
    [isometry, overshoot] = compute_isometry_with_twisted_parameter(intersection_point, polytopes{3}{5}, polytopes{3}{6}, polytopes{3}{4}, polytopes{3}{3}, polytopes{4}{3}, polytopes{4}{4}, t3);
    if overshoot == 0 ||  overshoot == 2
        out_fund_dom_index = 3;
        out_side_index = 3;
    elseif overshoot == 1 
        out_fund_dom_index = 4;
        out_side_index = 3; 
    end


% 4th hexagon

elseif all([in_fund_domain_index, in_side_index] == [4, 1])
    [isometry, overshoot] = compute_isometry_with_twisted_parameter(intersection_point, polytopes{4}{1}, polytopes{4}{2}, polytopes{2}{2}, polytopes{2}{1}, polytopes{1}{1}, polytopes{1}{2}, t1);
    if overshoot == 0 ||  overshoot == 2
        out_fund_dom_index = 2;
        out_side_index = 1;
    elseif overshoot == 1 
        out_fund_dom_index = 1;
        out_side_index = 1; 
    end

elseif all([in_fund_domain_index, in_side_index] == [4, 3])

    [isometry, overshoot] = compute_isometry_with_twisted_parameter(intersection_point, polytopes{4}{3}, polytopes{4}{4}, polytopes{4}{6}, polytopes{4}{5}, polytopes{3}{5}, polytopes{3}{6}, t3);
    
    if overshoot == 0 ||  overshoot == 2
        out_fund_dom_index = 4;
        out_side_index = 5;
    elseif overshoot == 1 
        out_fund_dom_index = 3;
        out_side_index = 5; 
    end

elseif all([in_fund_domain_index, in_side_index] == [4, 5])
    [isometry, overshoot] = compute_isometry_with_twisted_parameter(intersection_point, polytopes{4}{5}, polytopes{4}{6}, polytopes{4}{4}, polytopes{4}{3}, polytopes{3}{3}, polytopes{3}{4}, t3);
    if overshoot == 0 ||  overshoot == 2
        out_fund_dom_index = 4;
        out_side_index = 3;
    elseif overshoot == 1 
        out_fund_dom_index = 3;
        out_side_index = 3; 
    end


end
end