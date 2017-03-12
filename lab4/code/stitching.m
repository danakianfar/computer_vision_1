function Z = stitching( im1, im2)

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

% Randomly plot 50 matches
% [f1_selection, f2_selection] = plot_sample_matches(left, right, M, F1, F2, 50);
 
% Execute RANSAC to get best match
p = 0.95; % confidence
[W, T]= ransac(F1, F2, M, p);

neighbors = 4;
[t_image, z_bounds] = transform_image2(im2, W, T, neighbors, false);

[min_vals, ~ ] = min(z_bounds');
min_r = min_vals(1);
min_c = min_vals(2);

[max_vals, ~ ] = max(z_bounds');
max_r = max_vals(1);
max_c = max_vals(2);

[h,w,n_channels] = size(im1);

x_bounds = [ 1 1 h h; 1 w 1 w];
w_bounds = [x_bounds, z_bounds - round([T(2) - min(z_bounds(1,:) ); T(1) - min(z_bounds(2,:) )])];
q_bounds = w_bounds - [min_r; min_c] + 1;

Z = zeros([min(q_bounds(1,:)), min(q_bounds(2,:)), n_channels]);
Z(q_bounds(1,7) : q_bounds(1,6), q_bounds(2,5) : q_bounds(2,8), :) = t_image;
Z(q_bounds(1,1) : q_bounds(1,3), q_bounds(2,1) : q_bounds(2,2), :) = im1;

end

