function [details, imout] = unsharp(image, sigma, kernel_size, k)
    image = im2double(image); % numerical stability
    kernel_size = 2*kernel_size + 1; % odd kernel width

    impulse = zeros([kernel_size kernel_size]);
    impulse(ceil(kernel_size/2), ceil(kernel_size/2)) = 1; % impulse
    
    h = impulse - fspecial('gaussian' , [kernel_size kernel_size], sigma); % high-pass = original image - low-pass gaussian smoothing
    details = k * imfilter(image, h, 'replicate', 'conv'); % Strengthen high-pass
    
    imout = details + image; % add back to image
    
    % Plotting
%     blur_h = fspecial('gaussian' , [kernel_size kernel_size], sigma);
%     figure; subplot(1,5,1); imshow(image), title('Original', 'FontSize', 15);
%     subplot(1,5,2); imshow(imfilter(image, blur_h,'replicate', 'conv')), title(compose('Low-pass n=%d s=%d', kernel_size, sigma),'FontSize', 15);
%     subplot(1,5,3); imshow(imfilter(image, impulse - blur_h,'replicate', 'conv')), title('High-pass','FontSize', 15);
%     subplot(1,5,4);  imshow(details), title(compose('Strengthen k=%d', k),'FontSize', 15);
%     subplot(1,5,5);  imshow(imout), title('Unsharpen','FontSize', 15);
    
end