function [ Z , z_bounds] = transform_image(X, W, neighbours, inverse, interp_fun)

    % Applies the affine transformation given by square matrix W and 
    % translation T to points in image X
    if inverse
        inverter = - ones(length(W)) + 2 * eye(length(W));
        W = W .* inverter;
    end
    
    [row_num,col_num, n_channels] = size(X);
    
    % Obtain corners of transformed image
    z_bounds = floor(W * [ 1  1 row_num row_num; 1 col_num col_num 1] );
 
    [min_vals, ~ ] = min(z_bounds');
    min_r = min_vals(1);
    min_c = min_vals(2);
    
    [max_vals, ~ ] = max(z_bounds');
    max_r = max_vals(1);
    max_c = max_vals(2);
    
    % initialize to -1, so we can track unassigned pixels for interpolation
    z_size= [max_r - min_r + 1, max_c - min_c + 1];
    Z = -1 * ones([z_size, n_channels]);
    
    % assign values
    for c=1:col_num
        for r=1:row_num
            tr_pos = floor(W * [r c]') - [ min_r - 1; min_c - 1];
            Z(tr_pos(1), tr_pos(2), :) = X(r,c, :);
        end
    end 
    
    % interpolation window size (generally 1)
    nn_window = neighbours;
    
    % pick candidates for NN interpolation (previously assigned as -1)
    [candidates_x, candidates_y] = ind2sub(z_size, find(Z(:,:,1) < 0));
    
    % find corners of image
    corners = [(z_bounds(1,:) - min_r +1); (z_bounds(2,:) - min_c +1)];

    % perform interpolation
    Z = interpolate(Z, candidates_x, candidates_y, corners, interp_fun, nn_window, true);
end