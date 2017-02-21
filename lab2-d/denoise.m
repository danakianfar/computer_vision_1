function imout = denoise (image , kernel_type , kernel_size, boundary_padding)
    img = im2double(image);
    
    pad = floor(kernel_size/2);
    img = padarray(img, [pad pad] , boundary_padding, 'both');
    
    imout = zeros(size(img));
    
    if strcmp(kernel_type,'median')
        f = @(x) median(x(:));
    elseif strcmp(kernel_type,'box') 
        f = @(x) mean(x(:));
    end
    
    for i=1:size(image,3)
        x = squeeze(img(:,:,i));
        % imout(:,:,i) = colfilt(x , [kernel_size kernel_size], 'sliding', f);
        imout(:,:,i) = nlfilter(x , [kernel_size kernel_size], f);
    end
    
    % remove padding
    imout = imout(pad+1:end-pad,pad+1:end-pad,:);
    
end