%% Image Stitching
function Z = image_stitching(im2, im1)

    if size(im1,3) > 1
       left = rgb2gray(im1);
       right = rgb2gray(im2);
    else
       left = im1;
       right = im2;
    end

    % Detect interest points in each image and their descriptors
    [F1, D1] = vl_sift(left);
    [F2, D2] = vl_sift(right);

    % Get the set of supposed matches between region descriptors in each image
    M = vl_ubcmatch(D1, D2); 

    % Execute RANSAC to get best match
    p = 0.95; % confidence
    [W, T]= ransac(F1, F2, M, p);

    % Parameters
    neighbors = 1;
    nn_window = neighbors;
    med_filt = @(x) median(x);
    nn_filt = @(x) mean(x);
    interp_fun = med_filt; % selector variable

    % Find the delta vector by looking just at the original corners of right
    [row_num,col_num, n_channels] = size(im1);
    Q = ceil(W * [ 1  1 col_num col_num; 1 row_num row_num 1] + T);
    delta = 1 - min([min(Q'); 1 1]);
    max_vals = max((Q + repmat(delta', [1,4]))');

    % Find the corner locations of the transformed image
    corners = Q + repmat(delta', [1,4]);
    corners_2 = corners([2,1],[2 1 4 3]); % reorder for polygon matching;
    
    % Create grid of all points in "right" space
    [c_ids, r_ids] = meshgrid(1: size(im1, 1), 1:size(im1,2));
    
    % Number of pixels in image
    pix_num = size(im1,2) * size(im1, 1);
    
    % Initialize Z with -1s for finding outliers later
    Z = -1 * ones(max_vals(2), max_vals(1), n_channels);

    % Flatten vectors to create pairs of points in loop
    r_ids = reshape(r_ids.', 1, []);
    c_ids = reshape(c_ids.', 1, []);
    
    for pix_id=1:pix_num
        % Get each point in the grid and apply the transformation
        tformed = ceil([r_ids(pix_id);c_ids(pix_id)]' * W' + T') + delta;
        
        % Put the value of (x,y) into its transformed coordinates
        Z(tformed(2), tformed(1), :) = im1(c_ids(pix_id), r_ids(pix_id), :);
    end

    % Perform interpolation on the transformed image
    % Currently Z only has this inside
    [candidates_x, candidates_y] = ind2sub(size(Z), find(Z(:,:,1) < 0));
    Z = interpolate(Z, candidates_x, candidates_y, corners_2, interp_fun, nn_window, false);

    % Put the left image in place
    Z(delta(2) + 1:delta(2) + size(im2, 1),delta(1) + 1:delta(1)+ size(im2, 2),:) = im2;
end