function [x_out, f_out] = subtract_cumufuns(x1, f1, x2, f2)
%SUBTRACT_CUMUFUNS 
    
    % 1. Clean the data for both ECDFs
    idx1 = isfinite(x1) & isfinite(f1);
    x1_clean = x1(idx1);
    f1_clean = f1(idx1);
    
    idx2 = isfinite(x2) & isfinite(f2);
    x2_clean = x2(idx2);
    f2_clean = f2(idx2);
    
    % 1. Remove duplicates from both ECDFs
    % 'last' ensures we keep the highest CDF value for that specific X point
    [x1_u, idx1] = unique(x1_clean, 'last');
    f1_u = f1_clean(idx1);
    
    [x2_u, idx2] = unique(x2_clean, 'last');
    f2_u = f2_clean(idx2);
    
    % 2. Define the common x-grid
    x_common = unique([x1_u(:); x2_u(:)]);
    
    % 3. Interpolate using the unique sets
    f1_interp = interp1(x1_u, f1_u, x_common, 'previous', 0);
    f2_interp = interp1(x2_u, f2_u, x_common, 'previous', 0);
    
    % 4. Subtract
    f_diff = f2_interp - f1_interp;
    f_out = f_diff;
    x_out = x_common;
    
end