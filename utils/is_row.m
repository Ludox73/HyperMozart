function answer = is_row(row,matrix)
%IS_ROW checks if row is a row of matrix

answer=false;
for ind = 1:size(matrix,1)
    if all(row == matrix(ind,:))
        answer = true;
        break
    end
end


end