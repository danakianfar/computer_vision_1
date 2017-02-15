function [ image_stack, W, H ] = load_image( image_dir, image_ext )
%LOAD_IMAGE read from directory image_dir all files with extension image_ext
%   image_dir : path to the image directory, default 'Sphere'
%   image_ext : image extension with wildcard character, default '*.png'

if nargin == 0
    image_dir = 'Sphere';
    image_ext = '*.png';
end

files = dir(fullfile(image_dir, image_ext));
nfiles = length(files);

im = imread(fullfile(image_dir, files(1).name));
[w, h] = size(im);
image_stack = zeros(w, h, nfiles, 'uint8');
image_stack(:, :, 1) = im;

for i = 2 : nfiles
    image_stack(:, :, i) = imread(fullfile(image_dir, files(i).name));
end

W = size(image_stack, 1);
H = size(image_stack, 2);

end

