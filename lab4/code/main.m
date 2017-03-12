%% Computer Vision 1 
%
% Lab 4: Image Alignment and Stitching
% Authors: Dana Kianfar - Jose Gallego
%
%% Image Alignment

clear, clc, close all

im1= im2single(imread('./images/left.jpg'));
im2 = im2single(imread('./images/right.jpg'));

%im1 = im2single(imread('./images/boat1.pgm'));
%im2 = im2single(imread('./images/boat2.pgm'));

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

% Plot results
% plot_ransac_results( left, right, f1_selection, f2_selection, W, T )

%%
neighbors = 4;
t_image = transform_image(im1, W, T, neighbors, true);

figure, subplot(1,3,1), imshow(im1), title('Left Image');
subplot(1,3,2), imshow(t_image), title('Left Image Transformed');
subplot(1,3,3), imshow(im2), title('Right Image') ;

%%

neighbors = 4;
t_image = transform_image(im2, W, T, neighbors, false);

figure, subplot(1,3,1),imshow(im1), title('Left Image');
subplot(1,3,2),imshow(t_image), title('Right Image Transformed');
subplot(1,3,3), imshow(im2), title('Right Image') ;


%% Image Stitching

clear, clc, close all

im1= im2single(imread('./images/left.jpg'));
im2 = im2single(imread('./images/right.jpg'));

stitched = stitching(im1, im2);
imshow(stitched);