%% Computer Vision 1 
% Lab 2: Filters
% Authors: Dana Kianfar - Jose Gallego

%% Harris Corner Detector
I = imread('../person_toy/00000001.jpg');

% Convert RGB data to instensity values
I = rgb2gray(im2double(I));

[ H, r, c, Ix, Iy] = harris(I, 3, 0.2, 0.00003, 5);

imshow(I);
hold on
plot(r,c,'r*');

%%

corners = corner(I);
figure
imshow(I);
hold on
plot(corners(:,1),corners(:,2),'r*');