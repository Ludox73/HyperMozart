function guessed_length = guess_length_geodesics_from_to_music(to_music, index_curve, chi_sigma)
%GUESS_LENGTH_GEODESICS_FROM_TO_MUSIC It takes the file to_music as created
%by the routine, the euler characteristic of the surface and the index of
%the curve we are willing to guess the length of, and returns the guessed
%length.

total_time = sum(to_music(:,1));

num_intersections = sum(to_music(:,2) == index_curve);

guessed_length = - 1/total_time * num_intersections * pi^2 * chi_sigma;

end