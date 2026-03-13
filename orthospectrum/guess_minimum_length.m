function min_length = guess_minimum_length(x_vals, f_vals, tol1, tol2)
%GUESS_MINIMUM_LENGTH x_vals and f_vals represent the cumulative
%distribution function from which we are trying to get the lenght of the
%shortest orthogonal geodesics.
arguments
    x_vals 
    f_vals 
    tol1 = 0.0040;
    tol2 = 0.1;
end
all_greater_tol1 = true;

for f_ind = 1:length(f_vals)
    f = f_vals(f_ind);
    if f<tol1
        all_greater_tol1 = false;
    end

    if f>tol2
        if all_greater_tol1
            min_length = x_vals(1);
            break
        else
            guessed_min_length_index = f_ind;
            while f_vals(guessed_min_length_index)>tol1
                guessed_min_length_index = guessed_min_length_index -1;
            end
            min_length = x_vals(guessed_min_length_index);
            break
        end
    end
end

end