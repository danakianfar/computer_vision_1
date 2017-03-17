%% Computer Vision 1 
% Lab 3: Corner Detection, Optical Flow and Tracking
% Authors: Dana Kianfar - Jose Gallego

%% Harris Corner Detector
clear, clc, 

I1 = imread('../pingpong/0000.jpeg'); lab='pingpong' ;
% I1 = imread('../person_toy/00000001.jpg'); lab='toy';

% Convert RGB data to instensity values
I = rgb2gray(im2double(I1));

% Gradient and smoothing
sigma = 1; % Gaussian kernel sigma. Higher sigma -> stronger blurring -> less detail, less edges
K = 9; % Gaussian kernel width. (sigma kept constant) higher width -> more values 

alpha = 0.06; % Cornerness map constant generally 0.04 (more corners) or 0.06 (less corners)

% Non-Maximal Supression and Threshold
N = 5; % neighborhood window size (converted to 2N+1)
threshold_constant = 1.5; % threshold scaling constant

[ H, r, c, Ix, Iy, threshold] = harris(I, K, sigma, threshold_constant, N, alpha);

corners = corner(I); % MATLAB default

figure, subplot(1,2,1), imshow(I1); hold on; plot(r,c,'ro', 'MarkerSize', 5); hold off; title(compose('Corners n=%d, t=%.3E, s=%d, k=%d, alpha=%.E', 2*N+1, threshold, sigma, K, alpha), 'FontSize', 7);
subplot(1,2,2), imshow(I1); hold on; plot(corners(:,1),corners(:,2),'ro', 'MarkerSize',5); hold off; title('MATLAB corners', 'FontSize', 7); print(char(compose('./figs/corner_%s', lab)),'-depsc');
figure, imshowpair(Ix,Iy, 'montage');  print(char(compose('./figs/grad_corner_%s', lab)),'-depsc');
autoArrangeFigures(); uistack(1);

%% Lucas Kanade
clear, clc, close all

% Load images
I1 = imread('../sphere1.ppm');
I2 = imread('../sphere2.ppm');

%I1 = imread('../synth1.pgm');
%I2 = imread('../synth2.pgm');

% Set up parameters
n = 5; % Size of non-overlapping regions.
K = 9; % Gaussian kernel width.
sigma = 1; % Gaussian kernel sigma

% Execute optical flow on evenly spread points at the image with non
% overlapping regions
[U, V, X, Y] = opticalflow(I1, I2, n, K, sigma);

% Display the found velocity vectors in a video like manner
figure
for i=1:10
    imshow(I1);
    hold on
    scatter(X,Y,'.r')%, 'MarkerFaceAlpha',.35,'MarkerEdgeAlpha',.35)
    quiver(Y, X, U, V, 'w')
    getframe;
    pause(0.1)
    imshow(I2)
    scatter(X,Y,'.r')%, 'MarkerFaceAlpha',.35,'MarkerEdgeAlpha',.35)
    getframe;
end

%% Tracking
clear, clc, close all

disp('** Dont resize the video! Please wait until the .avi file is generated to look at the video in a larger window size **')
% Make sure to remove the previous avi to avoid frame size error

% Set up director name and extension
% folder = '../pingpong/'; sigma = 1; 
folder = '../person_toy/'; sigma = 2; 
ext = 'jp';

% Parameters for Optical Flow
K = 9; 
harris_N = 5; 
threshold_constant = 1.5; 
flow_N = 25;

of_constant = 1; % scaling constant for flow vectors

% File to store the video
vfname = '../videos/person_toy.avi';

% Execute optical flow on features
applyflow(folder, ext, vfname, flow_N, K, sigma, threshold_constant, harris_N, of_constant);

% Show generated video
viewvideo(vfname);