function imOut = denoise ( image , kernel_type , kernel_size )
    if strcmp(kernel_type,'box')
        imOut = imboxfilt(image,[2 * kernel_size + 1, 2 * kernel_size + 1]);
    elseif strcmp(kernel_type,'median')
        imOut = medfilt2(image, [2 * kernel_size + 1, 2 * kernel_size + 1]);
    end
end