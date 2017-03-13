%% Computer Vision 1 
%
% Lab 4: Image Alignment and Stitching
% Authors: Dana Kianfar - Jose Gallego
%
% Make sure you run VLFEAT setup beforehand.
% run('C:\Users\Dana\.src\vlfeat-0.9.20\toolbox\vl_setup')
%% Image Alignment

clear, clc, close all

im1 = imread('./images/boat1.pgm');
im2 = imread('./images/boat2.pgm');

% convert to single for SIFT
im1 = im2single(im1);
im2 = im2single(im2);

% convert to grayscale
if size(im1,3) > 1
   left = rgb2gray(im1);
   right = rgb2gray(im2);
else
   left = im1;
   right = im2;
end

[M, F1, D1, F2, D2] = siftmatch(im1, im2);

% Randomly plot 50 matches
[f1_selection, f2_selection] = plot_sample_matches(im1, im2, M, F1, F2, 50);
 
% Execute RANSAC to get best match
p = 0.95; % confidence
[W, T]= ransac(F1, F2, M, p);

% Plot results
plot_ransac_results( im1, im2, f1_selection, f2_selection, W, T )
autoArrangeFigures(); uistack(1);

%% Transform Image
% Parameters
nn_window = 1;
med_filt = @(x) median(x);
nn_filt = @(x) mean(x);
interp_fun = nn_filt; % selector variable

% % Left-to-right
% t_image = transform_image(left, W, neighbors, true, interp_fun);   
% figure, subplot(1,3,1), imshow(im1), title('Left Image');
% subplot(1,3,2), imshow(t_image), title('Left Image Transformed');
% subplot(1,3,3), imshow(im2), title('Right Image') ;
% %%
% Right-to-left
t_image = transform_image(right, W, nn_window, false, interp_fun);   
figure, subplot(1,3,1),imshow(im1), title('Left Image', 'FontSize', 16);
subplot(1,3,2),imshow(t_image), title('Right Image Transformed', 'FontSize', 16);
subplot(1,3,3), imshow(im2), title('Right Image', 'FontSize', 16) ;
autoArrangeFigures(); uistack(1);

%% Transform using MATLAB

tf = maketform('affine', [W ; T']);
t_image_m = imtransform(im2,tf, 'nearest');
figure, subplot(1,3,1),imshow(im1), title('Left Image');
subplot(1,3,2),imshow(t_image_m), title('Right Image Transform with MATLAB');
subplot(1,3,3), imshow(im2), title('Right Image') ;
autoArrangeFigures(); uistack(1);
% 
% W_inv = W .* (- ones(length(W)) + 2 * eye(length(W)));
% tf_inv = maketform('affine', [W_inv ; T']);
% t_image_m = imtransform(im1,tf_inv, 'nearest');
% figure, subplot(1,3,1),imshow(im1), title('Left Image');
% subplot(1,3,2),imshow(t_image_m), title('Left Image Transform with MATLAB');
% subplot(1,3,3), imshow(im2), title('Right Image') ;
% autoArrangeFigures(); uistack(1);

figure, subplot(1,2,1), imshow(t_image), title('Our transformation', 'FontSize', 16)
subplot(1,2,2),imshow(t_image_m), title('MATLAB imtransform and maketform', 'FontSize', 16)

%% Image Stitching

clear, clc, close all % better to reset

im2= im2single(imread('./images/left.jpg'));
im1 = im2single(imread('./images/right.jpg'));

%im2= im2single(imread('./images/boat1.pgm'));
%im1 = im2single(imread('./images/boat2.pgm'));

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
interp_fun = nn_filt; % selector variable


[y, x] = meshgrid(1: size(im1, 1), 1:size(im1,2));

y = reshape(y.', 1, []);
x = reshape(x.', 1, []);
xy_ = ceil([x;y]' * W' + repmat(T', [length(x), 1]));

[row_num,col_num, n_channels] = size(im1);
Q = ceil(W * [ 1  1 col_num col_num; 1 row_num row_num 1] + T);
delta = 1 - min([min(Q'); 1 1]);
max_vals = max((Q + repmat(delta', [1,4]))');

corners = Q + repmat(delta', [1,4]);

w = max_vals(1);
h = max_vals(2);

xy_ = xy_ + repmat(delta, [length(xy_), 1]);
im3 = -1 * ones(h,w, n_channels);

for i=1:length(xy_)
    im3(xy_(i, 2), xy_(i, 1), :) = im1(y(i), x(i), :);
end

Z = im3;

[candidates_x, candidates_y] = ind2sub(size(Z), find(Z(:,:,1) < 0));

corners_2 = corners(:,[2 1 4 3]); % reorder for polygon matching;

% perform interpolation
Z = interpolate(Z, candidates_x, candidates_y, corners_2, interp_fun, nn_window, false);

[h2, w2, ~] = size(im2);
Z(delta(2) + 1:delta(2) + h2,delta(1) + 1:delta(1)+ w2,:) = im2;
imshow(Z);