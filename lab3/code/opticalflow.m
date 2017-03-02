function [u, v] = opticalflow(image1, image2, X, Y, n, K, sigma)

    window_width = floor(n/2);
    
    % Convert images to double and grayscale
    I1 = rgb2gray(im2double(image1));
    I2 = rgb2gray(im2double(image2));
    
    % pad array and shift interest points
    I1 = padarray(I1, [n n]);
    I2 = padarray(I2, [n n]);
    X = X+n;
    Y = Y+n;
    
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
        
        % neighborhood around interest point
        x_ind = repmat([x - window_width : x + window_width], 1, n);
        y_ind = kron([y - window_width: y + window_width], ones(1,n));
        
        idx = sub2ind(size(I1), x_ind, y_ind);
        
        A = [reshape(Ix(idx),[],1) reshape(Iy(idx),[],1)];
        b = reshape(It(idx),[],1);
        uv = pinv(A'*A) * A'*b;
        
        u(i_x) = uv(1);
        v(i_x) = uv(2); 
    end 
end