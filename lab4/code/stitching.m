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

% Execute RANSAC to get best match
p = 0.95; % confidence
[W, T]= ransac(F1, F2, M, p);

neighbors = 1;
nn_filt = @(x) mean(x);
[t_image, z_bounds] = transform_image(im2, W, neighbors, false, nn_filt);

[h,w,n_channels] = size(im1);

x_bounds = [ 1 1 h h; 1 w 1 w];
w_bounds = [x_bounds, z_bounds  - round([T(2) - min(z_bounds(1,:)); T(1) - min(z_bounds(2,:))])];

[min_vals, ~ ] = min(w_bounds');
min_r = min_vals(1);
min_c = min_vals(2);

[max_vals, ~ ] = max(w_bounds');
max_r = max_vals(1);
max_c = max_vals(2);

q_bounds = w_bounds - [min_r; min_c] + 1;

Z = zeros([min(q_bounds(1,:)), min(q_bounds(2,:)), n_channels]);
Z(min(q_bounds(1,5:8)): max(q_bounds(1,5:8)), min(q_bounds(2,5:8)) : max(q_bounds(2,5:8)), :) = t_image;
Z(min(q_bounds(1,1:4)) : max(q_bounds(1,1:4)), min(q_bounds(2,1:4)) : max(q_bounds(2,1:4)), :) = im1;

end

