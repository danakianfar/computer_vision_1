%% Computer Vision 1 
%
% Lab 4: Image Alignment and Stitching
% Authors: Dana Kianfar - Jose Gallego
%
%% Image Alignment

clear, clc, close all

left = im2single(imread('./images/boat1.pgm'));
right = im2single(imread('./images/boat2.pgm'));

% Detect interest points in each image and their descriptors
[F1, D1] = vl_sift(left);
[F2, D2] = vl_sift(right);

% Get the set of supposed matches between region descriptors in each image
M = vl_ubcmatch(D1, D2); 

% Randomly plot 50 matches
%[f1_selection, f2_selection] = plot_sample_matches( left, right, M, F1, F2, 50);
 
% Execute RANSAC to get best match
p = 0.95; % confidence
[W, T]= ransac(F1, F2, M, p);

% Plot results
%plot_ransac_results( left, right, f1_selection, f2_selection, W, T )

%%
neighbors = 4;
t_image = transform_image(left, W, T, neighbors, false);

subplot(1,2,1);
imshow(t_image);
subplot(1,2,2);
imshow(right);

%%

neighbors = 4;
t_image = transform_image(right, W, T, neighbors, true);

subplot(1,2,1);
imshow(t_image);
subplot(1,2,2);
imshow(left);
