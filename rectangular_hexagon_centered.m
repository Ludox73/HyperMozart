function [vertices, all_sides] = rectangular_hexagon_centered(l1, l3, l5)
    % THERE IS A BUG WHEN USED WITH TWISTED PARAMETERS.
    % I know, it makes no sense.

    % Calculates the vertices of a right-angled hyperbolic hexagon
    % Given three alternating side lengths l1, l3, l5.
    
    % throw(MException("function:bugged", "This function has shown unexpected behaviour. Do not use it."))
    % 1. Calculate missing side lengths using the Law of Cosines
    l2 = acosh((cosh(l1)*cosh(l3) + cosh(l5)) / (sinh(l1)*sinh(l3)));
    l4 = acosh((cosh(l3)*cosh(l5) + cosh(l1)) / (sinh(l3)*sinh(l5)));
    l6 = acosh((cosh(l5)*cosh(l1) + cosh(l3)) / (sinh(l5)*sinh(l1)));
    
    all_sides = [l1, l2, l3, l4, l5, l6];
    Matrix_sending_vertex_ind_to_i = cell(6,1);
    V = zeros(6, 1);
    
    V(1) = 1i;
    Matrix_sending_vertex_ind_to_i{1} = eye(2);
    
    for inde=2:6
        M = [sqrt(2)/2, sqrt(2)/2; -sqrt(2)/2, sqrt(2)/2] * [exp(all_sides(inde-1)/2), 0; 0, exp(-all_sides(inde-1)/2)];
        Matrix_sending_vertex_ind_to_i{inde} =  inv([sqrt(2)/2, sqrt(2)/2; -sqrt(2)/2, sqrt(2)/2] * [exp(all_sides(inde-1)/2), 0; 0, exp(-all_sides(inde-1)/2)]) * Matrix_sending_vertex_ind_to_i{inde-1} ;
        V(inde) = apply_upp_half_matrix(inv(Matrix_sending_vertex_ind_to_i{inde-1})*M, 1i);

    end

    vertices = cell(6,1);
    complex_vec_poincare = cell(6,1);
    for ind = 1:6

        % This is done to correct a problem given by two vertices being on the same
        % vertical line.
        aus = apply_upp_half_matrix([1.25, 0.5; 0, 1/1.25], V(ind));


        complex_vec_poincare{ind} = (aus - 1i) / (aus+ 1i);
        vertices{ind} = [real(complex_vec_poincare{ind});imag(complex_vec_poincare{ind})];
    end
    
    %We here move the barycenter to the origin for better visualization
    bary = barycenter_cell_of_points(vertices);
    bary_complex = bary(1) + 1i*bary(2);
    
    for ind = 1:6
        z = complex_vec_poincare{ind};
        aus2 = ((z - bary_complex)/(-z*conj(bary_complex) + 1));
        vertices{ind} = [real(aus2); imag(aus2)];
    end

end