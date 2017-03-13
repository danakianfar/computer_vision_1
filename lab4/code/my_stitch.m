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

% Parameters
neighbors = 1;
nn_window = neighbors;
med_filt = @(x) median(x);
nn_filt = @(x) mean(x);
interp_fun = nn_filt; % selector variable

%%
[y, x] = meshgrid(1: size(im1, 1), 1:size(im1,2));

y = reshape(y.', 1, []);
x = reshape(x.', 1, []);
xy_ = ceil([x;y]' * W' + repmat(T', [length(x), 1]));

[row_num,col_num, n_channels] = size(im1);
Q = ceil(W * [ 1  1 col_num col_num; 1 row_num row_num 1] + T);
delta = 1 - min([min(Q'); 1 1]);
max_vals = max((Q + repmat(delta', [1,4]))');

corners = Q + repmat(delta', [1,4]);

w = max_vals(1);
h = max_vals(2);

xy_ = xy_ + repmat(delta, [length(xy_), 1]);
im3 = -1 * ones(h,w, n_channels);

for i=1:length(xy_)
    im3(xy_(i, 2), xy_(i, 1), :) = im1(y(i), x(i), :);
end

Z = im3;

% %Nearest neighbor interpolation
% for chan=1:n_channels
%     for i=2:h-1
%         for j=2:w-1
%             if im3(i, j, chan) == -1
%                 values = [im3(i-1,j-1:j+1, chan) im3(i+1,j-1:j+1, chan) im3(i, j-1, chan) im3(i, j+1, chan)];
%                 im3(i, j, chan) = mean(values);
%             end
%         end
%     end
% end


%%
% replace assigned variables by interpolation, or zero if outside image

[candidates_x, candidates_y] = ind2sub([h,w], find(Z(:,:,1) == -1));

min_j = min(find(max(Z(:,:,1) > 0)));

% replace assigned variables by interpolation, or zero if outside image
for c=1:n_channels
    disp(c)
    for i=numel(candidates_x):-1:1
        x = candidates_x(i); y = candidates_y(i);
        
        if y >= min_j
            window = Z(max(1,x-nn_window):min(size(Z,1),x+nn_window), ...
                max(1,y-nn_window):min(size(Z,2),y+nn_window), c);
            window = window(:);
            window = window(window >= 0);
            Z(x,y,c) = interp_fun(window);
        end
    end
end

imshow(Z)
%%


for chan=1:n_channels
    disp(chan)
    for i= 2:h-1
        for j= min_j:w-1
            if Z(i, j, chan) == -1
                window = Z(max(1,x-nn_window):min(size(Z,1),x+nn_window), ...
                    max(1,y-nn_window):min(size(Z,2),y+nn_window), chan);
                window = window(:);
                window = window(window >= 0);
                Z(x,y,chan) = interp_fun(window);
            end
        end
    end
end

imshow(Z)
%%

[h2, w2, ~] = size(im2);
im3(delta(2) + 1:delta(2) + h2,delta(1) + 1:delta(1)+ w2,:) = im2;
imshow(im3);