function [vertices, all_sides] = rectangular_hexagon(l1, l3, l5)
    % Calculates the vertices of a right-angled hyperbolic hexagon
    % Given three alternating side lengths l1, l3, l5.
    
    % 1. Calculate missing side lengths using the Law of Cosines
    l2 = acosh((cosh(l1)*cosh(l3) + cosh(l5)) / (sinh(l1)*sinh(l3)));
    l4 = acosh((cosh(l3)*cosh(l5) + cosh(l1)) / (sinh(l3)*sinh(l5)));
    l6 = acosh((cosh(l5)*cosh(l1) + cosh(l3)) / (sinh(l5)*sinh(l1)));
    
    all_sides = [l1, l2, l3, l4, l5, l6];
    Matrix_sending_i_to_vertex_ind = cell(6,1);
    V = zeros(6, 1);
    
    V(1) = 1i;
    Matrix_sending_i_to_vertex_ind{1} = hyp_isometry_2d([],  eye(2));
    
    for inde=2:6
        M = hyp_isometry_2d([], [sqrt(2)/2, sqrt(2)/2; -sqrt(2)/2, sqrt(2)/2] * [exp(all_sides(inde-1)/2), 0; 0, exp(-all_sides(inde-1)/2)]);
        Matrix_sending_vertex_ind_to_i{inde} = hyp_isometry_2d([], inv([sqrt(2)/2, sqrt(2)/2; -sqrt(2)/2, sqrt(2)/2] * [exp(all_sides(inde-1)/2), 0; 0, exp(-all_sides(inde-1)/2)])  );
        V(inde) = M.apply_upper_half(1i);

        Matrix_sending_i_to_vertex_ind{inde} = hyp_isometry_2d([], inv([-exp(all_sides(inde-1)/2), 0; 0, -exp(-all_sides(inde-1)/2)]*[sqrt(2)/2, -sqrt(2)/2; sqrt(2)/2, sqrt(2)/2]) * Matrix_sending_i_to_vertex_ind{inde-1}.upper_half_model);
        V(inde) = Matrix_sending_i_to_vertex_ind{inde}.apply_upper_half(1i)
    end

    vertices = cell(6,1);
    for ind = 1:6
        complex_vec_poincare = (V(ind) - 1i) / ( V(ind)+ 1i)
        vertices{ind} = [real(complex_vec_poincare);imag(complex_vec_poincare)];
    end
end