function [u, v, X, Y] = opticalflow(image1, image2, n, K, sigma, X, Y)
    
    window_width = floor(n/2);

    if nargin < 7
        tmp_x=[window_width:n:size(image1,1)];
        tmp_y=[window_width:n:size(image1,2)];
        X = repmat(tmp_x, 1, numel(tmp_y));
        Y = kron(tmp_y, ones(1,numel(tmp_x)));
    end
    
    % Convert images to double and grayscale
    if size(image1,3) > 1
        I1 = rgb2gray(im2double(image1));
        I2 = rgb2gray(im2double(image2));
    else
        I1 = im2double(image1);
        I2 = im2double(image2);
    end
    
    % pad array and shift interest points
    I1 = padarray(I1, [n n]);
    I2 = padarray(I2, [n n]);
    X = X+n;
    Y = Y+n;
    
    % Initialize u and v vectors
    u = zeros(size(X));
    v = zeros(size(X));
    
    % Smooth and get gradients
    G = fspecial('gaussian',[K K], sigma);
    [Gx,Gy] = gradient(G);

    % Calculates the derivatives of the smoothed image
    Ix = imfilter(I1, Gx, 'replicate', 'same',  'conv');
    Iy = imfilter(I1, Gy, 'replicate', 'same', 'conv');
    It = I1 - I2; % assume time gap is 1
    
    % For each interest point, create a region mask
    for i_x=1:length(X)
        
        x = X(i_x); % x-cor of interest point
        y = Y(i_x); % y-cor of interest point
        
        % neighborhood around interest point
        x_ind = repmat([x - window_width : x + window_width], 1, n);
        y_ind = kron([y - window_width: y + window_width], ones(1,n));
        
        idx = sub2ind(size(I1), x_ind, y_ind);
        
        A = [reshape(Ix(floor(idx)),[],1) reshape(Iy(floor(idx)),[],1)];
        b = reshape(It(floor(idx)),[],1);
        uv = pinv(A'*A) * A'*b;
        
        u(i_x) = uv(1);
        v(i_x) = uv(2); 
    end 
    
    X = X-n;
    Y = Y-n;
end