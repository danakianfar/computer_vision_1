%% Computer Vision 1 
%
% Lab 4: Image Alignment and Stitching
% Authors: Dana Kianfar - Jose Gallego
%
%% Note
% Make sure you run VLFEAT setup beforehand
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

% Plot a sample of 50 matches
%plot_sample_matches( left, right, M, F1, F2, 500)

[W, T] = ransac(F1,F2,M,0.9999);