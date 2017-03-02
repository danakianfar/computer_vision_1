function [u, v] = opticalflow(image1, image2, X, Y, n, K, sigma)
    % Convert images to double and grayscale
    I1 = rgb2gray(im2double(image1));
    I2 = rgb2gray(im2double(image2));
    [size_x, size_y] = size(I1);
    
    % Initialize u and v vectors
    u = zeros(size(X));
    v = zeros(size(X));
    
    % Smooth and get gradients
    G = fspecial('gaussian',[K K]);
    [Gx,Gy] = gradient(G, sigma);

    % Calculates the derivatives of the smoothed image
    Ix = imfilter(I1, Gx, 'replicate', 'same',  'conv');
    Iy = imfilter(I1, Gy, 'replicate', 'same', 'conv');
    It = I1 - I2; % assume time gap is 1
    
    % To center a block upon an interest point, create a mask of indices
    % corresponding to the 
    %blocks = cell(1, numel(X));
    %mask = reshape(1:numel(I1), size(I1));
    
    % For each interest point, create a region mask
    for i_x=1:length(X)
        x = X(i_x); % x-cor of interest point
        y = Y(i_x); % y-cor of interest point
%         m  = zeros(n,n); % block around interest point (zero-padded if necessary)
        
        % Identify size of non-zero region (if the interest point is at the corners of the image)
        t_x = min(floor(n/2), x-1); % num of non-zero elems top of interest point
        b_x = min(floor(n/2), size_x - x); % num of non-zero elems bottom of interest point
        r_y = min(floor(n/2), size_y - y); % num of non-zero elems right of interest point
        l_y = min(floor(n/2), y -1);% num of non-zero elems left of interest point
        
        idx = [x - t_x : x + b_x, y - l_y : y + r_y];
        
%         m() = {mask(x-t_x:x+b_x, y-l_y:y+r_y)}; % assign non-zero regions
%         blocks(i_x) = {m};
%         idx = cell2mat(blocks(i));
        
        A = [reshape(Ix(idx),[],1) reshape(Iy(idx),[],1)];
        b = reshape(It(idx),[],1);
        uv = pinv(A'*A) * A'*b;
        
        u(i_x) = uv(1);
        v(i_x) = uv(2); 
    end 
end