%% Computer Vision 1 
% Lab 3: Edge Detection and Motion Tracking
% Authors: Dana Kianfar - Jose Gallego

%% Harris Corner Detector
% I = imread('../pingpong/0000.jpeg'); lab='pingpong' ;
I = imread('../person_toy/00000001.jpg'); lab='toy';

% Convert RGB data to instensity values
I = rgb2gray(im2double(I));

sigma = 1; % Gaussian kernel sigma. Higher sigma -> stronger blurring -> less detail, less edges
K = 5; % Gaussian kernel width. (sigma kept constant) higher width -> more values 

% Non-Maximal Supression and Threshold
N = 15; % neighborhood window size (converted to 2N+1)
threshold = 5e-6; % threshold for minimum R value

[ H, r, c, Ix, Iy] = harris(I, K, sigma, threshold, N);
corners = corner(I); % MATLAB default

figure, subplot(1,2,1), imshow(I); hold on; plot(r,c,'r.', 'MarkerSize', 5); hold off; title(compose('Corners n=%d, t=%.6f, s=%d, k=%d', 2*N+1, threshold, sigma, K), 'FontSize', 7);
subplot(1,2,2), imshow(I); hold on; plot(corners(:,1),corners(:,2),'r.', 'MarkerSize',5); hold off; title('MATLAB corners', 'FontSize', 7); print(char(compose('./figs/corner_%s', lab)),'-depsc');
figure, imshowpair(Ix,Iy, 'montage' );  print(char(compose('./figs/grad_corner_%s', lab)),'-depsc');