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

% Randomly sample 50 matches
num_matches = 50;
rand_sample = randi(length(M),[num_matches, 1]);
f1_selection = F1(:,M(1,rand_sample));
f2_selection = F2(:,M(2,rand_sample)) + [size(left,2);0;0;0];

figure, imshow([left right]); hold on
vl_plotframe(f1_selection); % left image
vl_plotframe(f2_selection); % right image

% Plot random subset of all matching points
plot([f1_selection(1,:) ; f2_selection(1,:)], [f1_selection(2,:) ; f2_selection(2,:)], 'y-')

p = 0.95; % confidence

% Do RANSAC to get best match
[W, T]= ransac(F1, F2, M, p);

figure, imshow([left right]); hold on
vl_plotframe(f1_selection); % left image
vl_plotframe(f2_selection); % right image

ransac_keyspoints = W * f1_selection(1:2,:)  + T + [size(left,2);0];
plot([f1_selection(1,:) ; ransac_keyspoints(1,:)], [f1_selection(2,:) ; ransac_keyspoints(2,:)], 'y-')


