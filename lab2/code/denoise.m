function imout = denoise(image, kernel_type, kernel_size)
    
    kernel_size = 2 * kernel_size + 1;
    
    % Add padding to get same size
    pad = floor(kernel_size/2);
    img = padarray(double(image), [pad pad] , 'replicate', 'both');
    
    imout = zeros(size(img));
    
    if strcmp(kernel_type,'median')
        f = @(x) median(x(:));
    elseif strcmp(kernel_type,'box') 
        f = @(x) mean(x(:));
    end
    
    % Apply filter on channels
    for i=1:size(image,3)
        x = squeeze(img(:,:,i));
        imout(:,:,i) = nlfilter(x , [kernel_size kernel_size], f);
    end
    
    % remove padding
    imout = imout(pad+1:end-pad,pad+1:end-pad,:);
    
end