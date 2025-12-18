prova_identifier = 1;

if prova_identifier == 1

    rand_p1 = rand(2,1);
    rand_p2 = rand(2,1);
    rand_norm1 = rand(1);
    rand_norm2 = rand(1);
    rand_p1 = rand_p1/norm(rand_p1)*rand_norm1;
    rand_p2 = rand_p2/norm(rand_p2)*rand_norm2;

    L = segment(rand_p1, rand_p2);

    geodesic_circonference(L, 1);

end
