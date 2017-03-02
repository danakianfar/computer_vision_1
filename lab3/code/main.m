%% Computer Vision 1 
% Lab 3: Edge Detection and Motion Tracking
% Authors: Dana Kianfar - Jose Gallego

%% Harris Corner Detector
I = imread('../person_toy/00000001.jpg');

% Convert RGB data to instensity values
I = rgb2gray(im2double(I));

sigma = 1; % Gaussian kernel sigma
K = 5; % Gaussian kernel width

% Non-Maximal Supression and Threshold
N = 1; % neighborhood window size (converted to 2N+1)
threshold = 5e-6; % threshold for minimum R value

[ H, r, c, Ix, Iy] = harris(I, K, sigma, threshold, N);

figure, subplot(2,2,1:2), imshowpair(I, I, 'montage'); hold on; plot(r,c,'r*'); hold off; title(compose('Corners (left) and Original (right), n=%d, t=%.6f, s=%d, k=%d', 2*N+1, threshold, sigma, K), 'FontSize', 15);
subplot(2,2,3:4), imshowpair(Ix,Iy, 'montage' ); title('Gradient-x (left) and Gradient-y (right)', 'FontSize', 15);

%%

corners = corner(I);
figure
imshow(I);
hold on
plot(corners(:,1),corners(:,2),'r*');