function [ H, r, c, Ix, Iy, R] = harris(I, K, sigma, threshold_constant, N, alpha)

    if nargin <= 5
       alpha = 0.06; 
    end
    
% Sobel kernel
%     G = fspecial('sobel');
%     [Ix, Iy] = imgradientxy(I, 'sobel');

    % Creates a gaussian filter G and its x and y derivatives
    G = fspecial('gaussian',[K K]);
    [Gx,Gy] = gradient(G, sigma);

    % Calculates the derivatives of the smoothed image
    Ix = imfilter(I, Gx, 'replicate', 'same',  'conv');
    Iy = imfilter(I, Gy, 'replicate', 'same', 'conv');
    
    % Calculates the components of the Q matrix
    A = imfilter(Ix .* Ix , G, 'replicate','same',  'conv');
    B = imfilter(Ix .* Iy , G, 'replicate','same',  'conv');
    C = imfilter(Iy .* Iy , G, 'replicate','same',  'conv');
    
    % Calculates 'cornerness'
    H = (A .* C) - (B .^ 2) - alpha * ((A + C) .^ 2);
    
    % Threshold heuristic: take mean of cornerness map and threshold by a
    % scaled coefficient
    R = abs(mean(mean(H))) * threshold_constant;
    
    % Threshold values
    H = H .* double(H > R); 
    
    % Apply non maximal supression to non-overlapping neighborhoods
    H = nonmaxsupp(H, N);
    
    [c, r] = find(H);
    
end