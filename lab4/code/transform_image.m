function [ Z ] = transform_image(X, W, T, neighbours, inverse)

    % Applies the affine transformation given by square matrix W and 
    % translation T to points in image X
    if inverse
        inverter = - ones(length(W)) + 2 * eye(length(W));
        W = W .* inverter;
    end
    
    [row_num,col_num] = size(X);
    
    z_bounds = floor(W * [ 1 row_num 1 row_num; 1 1 col_num col_num] + T);
    
    [min_vals, ~ ] = min(z_bounds');
    min_r = min_vals(1);
    min_c = min_vals(2);
    
    [max_vals, ~ ] = max(z_bounds');
    max_r = max_vals(1);
    max_c = max_vals(2);
    
    Z = zeros([max_r - min_r + 1, max_c - min_c + 1, 1]);
    
    for c=1:col_num
        for r=1:row_num
            tr_pos = floor(W * [r c]' + T) - [ min_r - 1; min_c - 1];
            Z(tr_pos(1), tr_pos(2)) = X(r,c);
        end
    end 
    
    
    %TODO: NN
    Z = medfilt2(Z, [floor(sqrt(neighbours)) floor(sqrt(neighbours))]);
end