function [ Z ] = transform_image(X, W, T, neighbours, inverse, interp_fun)

    % Applies the affine transformation given by square matrix W and 
    % translation T to points in image X
    if inverse
        inverter = - ones(length(W)) + 2 * eye(length(W));
        W = W .* inverter;
    end
    
    [row_num,col_num, n_channels] = size(X);
    
    % Obtain corners of transformed image
    z_bounds = floor(W * [ 1  1 row_num row_num; 1 col_num col_num 1] + T);

    [min_vals, ~ ] = min(z_bounds');
    min_r = min_vals(1);
    min_c = min_vals(2);
    
    [max_vals, ~ ] = max(z_bounds');
    max_r = max_vals(1);
    max_c = max_vals(2);
    
    % initialize to -1, so we can track unassigned pixels for interpolation
    Z = -1 * ones([max_r - min_r + 1, max_c - min_c + 1, n_channels]);
    
    % assign values
    for c=1:col_num
        for r=1:row_num
            tr_pos = floor(W * [r c]' + T) - [ min_r - 1; min_c - 1];
            Z(tr_pos(1), tr_pos(2), :) = X(r,c, :);
        end
    end 
    
    nn_window = neighbours;
    % pick candidates for NN interpolation
    [candidates_x, candidates_y] = ind2sub(size(Z), find(Z < 0));
    
    corners = [(z_bounds(1,:) - min_r +1); (z_bounds(2,:) - min_c +1)];


    % filter candidates for those inside the boundary
    [interp_candidates] = inpoly([candidates_x, candidates_y], corners');
    
    % replace assigned variables by interpolation, or zero if outside image
    for i=1:numel(interp_candidates)
        x = candidates_x(i); y = candidates_y(i);
        
        if interp_candidates(i)
            window = Z(max(1,x-nn_window):min(size(Z,1),x+nn_window), ...
                max(1,y-nn_window):min(size(Z,2),y+nn_window));
            window = window(:);
            window = window(window >= 0);
            Z(x,y) = interp_fun(window);
        else
            Z(x,y) = 0;
        end
    end
end