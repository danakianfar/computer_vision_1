function [ Z, z_bounds] = transform_image2(X, W, T, neighbours, inverse)

    % Applies the affine transformation given by square matrix W and 
    % translation T to points in image X
    if inverse
        inverter = - ones(length(W)) + 2 * eye(length(W));
        W = W .* inverter;
    end
    
    [row_num,col_num, n_channels] = size(X);
    
    z_bounds = floor(W * [ 1 row_num 1 row_num; 1 1 col_num col_num]);
    
    [min_vals, ~ ] = min(z_bounds');
    min_r = min_vals(1);
    min_c = min_vals(2);
    
    [max_vals, ~ ] = max(z_bounds');
    max_r = max_vals(1);
    max_c = max_vals(2);
    
    Z = -1 * ones([max_r - min_r + 1, max_c - min_c + 1, n_channels]);
    
    for c=1:col_num
        for r=1:row_num
            tr_pos = floor(W * [r c]') - [ min_r - 1; min_c - 1];
            Z(tr_pos(1), tr_pos(2), :) = X(r,c, :);
        end
    end 
    
    nn_window = 1;
    
%    for i=2:size(Z,1)-1
%        for j=2:size(Z,2)-1
%            if Z(i,j) == -1 % if unfilled values
%                 if inpolygon(i,j, z_bounds(1,:), z_bounds(2,:)) %inside the image
%                     Z(i,j) = mean(mean(Z(i-nn_window:i+nn_window, j-nn_window:j+nn_window)));
%                 else % the boundaries
%                     Z(i,j) = 0;
%                 end
%            end
%        end
%    end    

end
