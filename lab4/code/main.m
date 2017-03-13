%% Computer Vision 1 
%
% Lab 4: Image Alignment and Stitching
% Authors: Dana Kianfar - Jose Gallego
%
% Make sure you run VLFEAT setup beforehand.
% run('C:\Users\Dana\.src\vlfeat-0.9.20\toolbox\vl_setup')
%
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

%% Transform Image and compare with MATLAB

% Parameters
nn_window = 1;
med_filt = @(x) median(x);
nn_filt = @(x) mean(x);
interp_fun = nn_filt; % selector variable

%% Left-to-right

t_image = transform_image(left, W, nn_window, true, interp_fun);   
figure, subplot(1,3,1), imshow(im1), title('Left Image');
subplot(1,3,2), imshow(t_image), title('Left Image Transformed');
subplot(1,3,3), imshow(im2), title('Right Image') ;

W_inv = W .* (- ones(length(W)) + 2 * eye(length(W)));
tf_inv = maketform('affine', [W_inv ; T']);
t_image_m = imtransform(im1,tf_inv, 'nearest');

% Compare with MATLAB
figure, subplot(1,2,1), imshow(t_image), title('Our transformation', 'FontSize', 16)
subplot(1,2,2),imshow(t_image_m), title('MATLAB imtransform and maketform', 'FontSize', 16)
autoArrangeFigures(); uistack(1);

%% Right-to-left

t_image = transform_image(right, W, nn_window, false, interp_fun);   
figure, subplot(1,3,1),imshow(im1), title('Left Image', 'FontSize', 16);
subplot(1,3,2),imshow(t_image), title('Right Image Transformed', 'FontSize', 16);
subplot(1,3,3), imshow(im2), title('Right Image', 'FontSize', 16) ;
autoArrangeFigures(); uistack(1);

tf = maketform('affine', [W ; T']);
t_image_m = imtransform(im2,tf, 'nearest');

% Compare with MATLAB
figure, subplot(1,2,1), imshow(t_image), title('Our transformation', 'FontSize', 16)
subplot(1,2,2),imshow(t_image_m), title('MATLAB imtransform and maketform', 'FontSize', 16)
autoArrangeFigures(); uistack(1);

%% Image Stitching

clear, clc, close all 

im1 = im2single(imread('./images/left.jpg'));
im2 = im2single(imread('./images/right.jpg'));

stitched = image_stitching(im1, im2);

imshow(stitched)
