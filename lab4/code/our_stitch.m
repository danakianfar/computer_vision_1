clear, clc, close all


im2= im2single(imread('./images/left.jpg'));
im1 = im2single(imread('./images/right.jpg'));

%im2= im2single(imread('./images/boat1.pgm'));
%im1 = im2single(imread('./images/boat2.pgm'));

if size(im1,3) > 1
   left = rgb2gray(im1);
   right = rgb2gray(im2);
else
   left = im1;
   right = im2;
end

% Detect interest points in each image and their descriptors
[F1, D1] = vl_sift(left);
[F2, D2] = vl_sift(right);

% Get the set of supposed matches between region descriptors in each image
M = vl_ubcmatch(D1, D2); 

% Execute RANSAC to get best match
p = 0.95; % confidence
[W, T]= ransac(F1, F2, M, p);

% Right-to-left
%t_image = transform_im(im1, W, T, neighbors, true, interp_fun);  

%%
[h, w,~] = size(im1);
[y, x] = meshgrid(1:h, 1:w);


y = reshape(y.', 1, []);
x = reshape(x.', 1, []);

xy_ = ceil([x;y]' * W' + repmat(T', [length(x), 1]));

%x = x';
%y = y';

% A hack to plot an image. Coordinates cannot be negative values
%min_xy_ = min(xy_);
%max_xy_ = max(xy_);

%[h, w, ~] = size(im2);
%min_xy = min([min_xy_; 1 1]);

%max_xy = max([max_xy_; w h]);
% Shift
%shift = 1 - min_xy

%w = max_xy(1) - min_xy(1) + 1;
%h = max_xy(2) - min_xy(2) + 1;

%%
% Shifting the first image

[row_num,col_num, n_channels] = size(im1);

Q = ceil(W * [ 1  1 col_num col_num; 1 row_num row_num 1] + T);
delta = 1 - min([min(Q'); 1 1]);
max_vals = max((Q + repmat(delta', [1,4]))');

w = max_vals(1);
h = max_vals(2);

xy_ = xy_ + repmat(delta, [length(xy_), 1]);
im3 = -1 * ones(h,w);

for i=1:length(xy_)
    im3(xy_(i, 2), xy_(i, 1)) = im1(y(i), x(i));
end

imshow(im3)

%%
%Nearest neighbor interpolation
for i=2:h-1
    for j=2:w-1
        if im3(i, j) == -1
            values = [im3(i-1,j-1:j+1) im3(i+1,j-1:j+1) im3(i, j-1) im3(i, j+1)];
            im3(i, j) = mean(values);
        end
    end
end

[im2_h, im2_w, ~] = size(im2);

im3(delta(2) + 1:delta(2) + im2_h,delta(1) + 1:delta(1)+ im2_w,:) = im2(:,:,1);
imshow(im3);