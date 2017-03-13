function sti( im1, im2)
    
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
    med_filt = @(x) median(x);
    nn_filt = @(x) mean(x);
    interp_fun = nn_filt; % selector variable

    % Right-to-left
    [t_image, delta] = transform_im(im2, W, T, neighbors, false, interp_fun);   
    
    delta
    
    delta = round(delta + T);
    
    [h1,w1,n_channels] = size(im1);
    orig_size = [h1 + delta(2); w1 + delta(1)];
    
    [h2,w2,~] = size(t_image);
    
    Z= zeros(max([orig_size(1), h2]), max([orig_size(2), w2]), n_channels); 
    
    
    Z(1:h2, 1:w2, :) = t_image;
    Z(1+delta(2) : orig_size(1), 1+delta(1) : orig_size(2), :) = im1;

    imshow(Z);
    
    figure
    
    imshowpair(t_image,im1)
%     % Create array of corner positions for both images
%     [h,w,n_channels] = size(im1);
%     x_bounds = [ 1 1 h h; 1 w 1 w];
%     w_bounds = [x_bounds, z_bounds  - round([T(2) ; T(1) ])];
% 
%     %- min(z_bounds(1,:))
%     % - min(z_bounds(2,:))
% 
%     % Correct for the minimum value to not have negative indices
%     [min_vals, ~ ] = min(w_bounds');
%     min_r = min_vals(1);
%     min_c = min_vals(2);
%     q_bounds = w_bounds - [min_r; min_c] + 1;
% 
%     % Create big black image of the apropriate size
%     Z = zeros([max(q_bounds(1,:)), max(q_bounds(2,:)), n_channels]);
% 
%     % Merge both transformed and left image
%     Z(min(q_bounds(1,5:8)): max(q_bounds(1,5:8)), min(q_bounds(2,5:8)) : max(q_bounds(2,5:8)), :) = t_image;
%     Z(min(q_bounds(1,1:4)) : max(q_bounds(1,1:4)), min(q_bounds(2,1:4)) : max(q_bounds(2,1:4)), :) = im1;

    
end