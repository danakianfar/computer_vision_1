%% Computer Vision 1 
% Lab 2: Filters
% Authors: Dana Kianfar - Jose Gallego

%% Exercise 2.1
im1 = imread('../Images/image2.jpeg');

% Box filters
box_sizes = [1, 2, 3, 4];
n_box = length(box_sizes);
box_results = {n_box};
figure, subplot(1, n_box + 1, 1), imshow(im1), title('Original','FontSize', 10)

for i = 1:n_box
    box_results{i} = denoise(rgb2gray(im1), 'box', box_sizes(i));
    subplot(1, n_box + 1, i+1), imshow(box_results{i}), title(strcat('K=' , num2str(2*i+1)),'FontSize', 10)
    
end
% print('./figs/box', '-deps');

% Median filters
median_sizes = [1, 2, 3];
n_median = length(median_sizes);
median_results = {n_median};
figure, subplot(1, n_median + 1, 1), imshow(im1), title('Original','FontSize', 10)

for i = 1:n_median
    median_results{i} = denoise(rgb2gray(im1), 'median', median_sizes(i));
    subplot(1, n_median + 1, i+1), imshow(median_results{i}), title(strcat('K=' , num2str(2*i+1)),'FontSize', 10)
end
% print('./figs/median', '-deps');

%% Exercise 2.2

input = imread('../Images/input.png');
reference = imread('../Images/reference.png');
out = myHistMatching(input, reference);

%% Exercise 2.3

im1 = imread('../Images/image3.jpeg');
[w,h,c] = size(im1);
[Gx, Gy, grad_magnitude , grad_direction ] = compute_gradient( im1 );

figure, imshowpair(Gx, Gy, 'montage'), title('Gradient x-direction (left) and y-direction (right)', 'FontSize', 15); %, print('./figs/grad-xy', '-deps');
figure , imshowpair(grad_magnitude, grad_direction, 'montage') ,title('Gradient magnitude & Direction', 'FontSize', 15); %, print('./figs/grad-dir-mag', '-deps');

%% Exercise 2.4

im1 = imread('../Images/image4.jpeg');
K = [1,2,5,10];
sigma = [1,2,5,10,20];
kernel_size = [1,5,10,60] ;

for k =1:numel(K)
    for s = 1:numel(sigma)
        [details, imout] = unsharp(im1, sigma(s), kernel_size(s), K(k));
        figure('Position', [10,10, 900, 500]), subplot(1,3,1), imshow(im1), title('Original', 'FontSize', 12);
        subplot(1,3,2), imshow(details), title(sprintf('Details k=%d, s=%d, n=%d',K(k),sigma(s),kernel_size(s)), 'FontSize', 12);
        subplot(1,3,3), imshow(imout), title(sprintf('Result k=%d, s=%d, n=%d',K(k),sigma(s),kernel_size(s)), 'FontSize', 12);
%         print(sprintf('./figs/unsharpen_k=%d, s=%d, %n=%d',K(k),sigma(s),kernel_size(s)),'-deps');
    end
end

%% Exercise 2.5

im1 = rgb2gray(imread('../Images/image1.png'));
out1 = compute_LoG (im1, 'method1', 2, 0.5, 0.5);
out2 = compute_LoG (im1, 'method2', 2, 0.5, -1);
out3 = compute_LoG (im1, 'method3', 2, 1.2, 0.75);

figure, subplot(2,2,1), imshow(im1), title('Original');
subplot(2,2,2), imshow(out1, []), title('Method 1 - \sigma_1 = 0.5 - \alpha = 0.5');
subplot(2,2,3), imshow(out2, []), title('Method 2 - \sigma_1 = 0.5');
subplot(2,2,4), imshow(out3, []), title('Method 3 - \sigma_1 = 1.2 - \sigma_2 = 0.75');