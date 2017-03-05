%% Computer Vision 1 
% Lab 3: Corner Detection and Motion Tracking
% Authors: Dana Kianfar - Jose Gallego

%% Harris Corner Detector
clear, clc, 

% I = imread('../pingpong/0000.jpeg'); lab='pingpong' ;
I = imread('../person_toy/00000001.jpg'); lab='toy';

% Convert RGB data to instensity values
I = rgb2gray(im2double(I));

% Gradient and smoothing
sigma = 2; % Gaussian kernel sigma. Higher sigma -> stronger blurring -> less detail, less edges
K = 9; % Gaussian kernel width. (sigma kept constant) higher width -> more values 

alpha = 0.04; % Cornerness map constant generally 0.04 (more corners) or 0.06 (less corners)

% Non-Maximal Supression and Threshold
N = 5; % neighborhood window size (converted to 2N+1)
threshold_constant = 1.5; % threshold scaling constant

[ H, r, c, Ix, Iy, threshold] = harris(I, K, sigma, threshold_constant, N, alpha);

corners = corner(I); % MATLAB default

figure, subplot(1,2,1), imshow(I); hold on; plot(r,c,'ro', 'MarkerSize', 5); hold off; title(compose('Corners n=%d, t=%.6f, s=%d, k=%d', 2*N+1, threshold, sigma, K), 'FontSize', 7);
subplot(1,2,2), imshow(I); hold on; plot(corners(:,1),corners(:,2),'ro', 'MarkerSize',5); hold off; title('MATLAB corners', 'FontSize', 7); print(char(compose('./figs/corner_%s', lab)),'-depsc');
figure, imshowpair(Ix,Iy, 'montage' );  print(char(compose('./figs/grad_corner_%s', lab)),'-depsc');
autoArrangeFigures(); uistack(1);
%% Lucas Kanade
clear, clc, close all

% Load images
%I1 = imread('../sphere1.ppm');
%I2 = imread('../sphere2.ppm');

I1 = imread('../synth1.pgm');
I2 = imread('../synth2.pgm');

% Set up parameters
n = 15;
K = 10;
sigma = 1.5;

% Execute optical flow on evenly spread points at the image with non
% overlapping regions
[U, V, X, Y] = opticalflow(I1, I2, n, K, sigma);

% Display the found velocity vectors in a video like manner
figure
for i=1:50
    imshow(I1);
    hold on
    scatter(X,Y,'.r', 'MarkerFaceAlpha',.35,'MarkerEdgeAlpha',.35)
    quiver(Y, X, U, V, 'b')
    getframe;
    pause(0.1)
    imshow(I2)
    scatter(X,Y,'.r', 'MarkerFaceAlpha',.35,'MarkerEdgeAlpha',.35)
    getframe;
end

%% Tracking
clear, clc, close all

% Set up director name and extension
folder = '../person_toy/';
ext = 'jp';

% Parameters for Optical Flow
sigma = 1.2; 
K = 9; 
harris_N = 15; 
threshold_constant = 1.2; 
flow_N = 25;

% File to store the video
vfname = './v1.avi';

% Execute optical flow on features
applyflow(folder, ext, vfname, flow_N, K, sigma, threshold_constant, harris_N);

% Show generated video
viewvideo(vfname);