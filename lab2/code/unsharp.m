function [details, imout] = unsharp(image, sigma, kernel_size, k)
    image = im2double(image);
    kernel_size = 2*kernel_size + 1;

    impulse = zeros([kernel_size kernel_size]);
    impulse(ceil(kernel_size/2), ceil(kernel_size/2)) = 1;

    h = impulse - fspecial('gaussian' , [kernel_size kernel_size], sigma);
    details = k * imfilter(image, h, 'replicate', 'conv');
    imout = details + image;
end