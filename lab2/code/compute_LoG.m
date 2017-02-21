function imOut = compute_LoG ( image , LOG_type, kernel_size, sigma1, sigma2)
    
    image = im2double(image);
    kernel_size = 2 * kernel_size + 1;
    
    if strcmp(LOG_type,'method1')
        H = fspecial('gaussian', [kernel_size kernel_size], sigma1);
        filtered = imfilter(image, H, 'replicate', 'conv');
        L = fspecial('laplacian');
        imOut = imfilter(filtered, L, 'replicate', 'conv');
    elseif strcmp(LOG_type,'method2') 
       H = fspecial('log');
       imOut = imfilter(image, H, 'replicate', 'conv');
    elseif strcmp(LOG_type,'method3') 
       H1 = fspecial('gaussian', [kernel_size kernel_size], sigma1);
       H2 = fspecial('gaussian', [kernel_size kernel_size], sigma2);
       imOut = 50*imfilter(image, H1 - H2, 'replicate', 'conv');
    end
end