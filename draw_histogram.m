provenience_to_music = "hexagons";
which_part = "east";
parameters_for_title = strcat(string(mat2str(lengths_curves)), string(mat2str(twisted_parameters)));

if strcmp(provenience_to_music, "hexagons")
    to_music_helper = to_music;
    for index = 1:size(to_music_helper, 1)
        if to_music_helper(index, 1) == 2
            to_music_helper(index, 1) = 1;
        elseif to_music_helper(index, 1) == 3 || to_music_helper(index, 1) == 4
            to_music_helper(index, 1) = 2;
        end
    end
else
    to_music_helper = to_music;
end

if strcmp(which_part, "east")
    index_to_find = 1;
elseif strcmp(which_part, "west")
    index_to_find = 2;
else
    throw(MException('which_part:notCorrectValue', "Which part is not settled correctly"))
end

values_1 = to_music_helper(to_music_helper(:,1) == index_to_find, 2);

values_2 = to_music(:,1);

figure 
[fasd, xasd] = ecdf(values_2);
plot(xasd, fasd, 'o-')

xlabel('Value')
ylabel('Empirical CDF')
titolo = strcat(provenience_to_music, " ", which_part, " ", parameters_for_title);
title(titolo)
xlim([0 10])
ylim([0,1])
grid on
% savefig(strcat("figs/autosaved/",titolo))
