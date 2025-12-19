
function f = isometry_H2_two_points_poincare(p1, p2, q1, q2, varargin)
    z1_poinc = p1(1) + p1(2)*1i;
    z2_poinc = p2(1) + p2(2)*1i;
    w1_poinc = q1(1) + q1(2)*1i;
    w2_poinc = q2(1) + q2(2)*1i;

    z1 = 1i*(1+z1_poinc)/(1-z1_poinc);
    z2 = 1i*(1+z2_poinc)/(1-z2_poinc);
    w1 = 1i*(1+w1_poinc)/(1-w1_poinc);
    w2 = 1i*(1+w2_poinc)/(1-w2_poinc);

    L = isometry_H2_two_points_upper_half(z1, z2, w1, w2);

    LM = [L.a, L.b; L.c, L.d];

    poinc_M=[1, -1i; 1, 1i]*LM*[1i, 1i; -1, 1];

    f = hyp_isometry_2d(poinc_M, LM);
end
