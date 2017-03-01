function [ H, r, c, Ix, Iy] = harris(I, K, R, N)
    
    % Creates a gaussian filter G and its x and y derivatives
    G = fspecial('gaussian',[K K]);
    [Gx,Gy] = gradient(G);

    % Calculates the derivatives of the smoothed image
    Ix = imfilter(I, Gx, 'replicate', 'same',  'conv');
    Iy = imfilter(I, Gy, 'replicate', 'same', 'conv');
    
    % Calculates the components of the Q matrix
    A = imfilter(Ix .* Ix , G, 'replicate','same',  'conv');
    B = imfilter(Ix .* Iy , G, 'replicate','same',  'conv');
    C = imfilter(Iy .* Iy , G, 'replicate','same',  'conv');
    
    % Calculates 'cornerness'
    H = (A .* C) - (B .^ 2) - 0.04 * (A + C) .^ 2;
    
    % Apply threshold and non maximal supression
    H = nonmaxsupp(H, N, R);
    
    %H = H .* (H>R);
    
    [c, r] = find(H);
    
end

function [maxima] = nonmaxsupp(X, N, R)

    h = ones(N);
    % Center of filter is 0 as we are replacing that value
    h(ceil((N*N)/2)) = 0; 

    bin_max = ordfilt2(X, (N ^ 2) - 1, h);
    maxima = (X > bin_max) & (X > R);

    % Corners are unreliable as they are padded
    maxima(1:N,1:N) = 0;
    maxima(end - N:end, 1:N) = 0;
    maxima(1:N,end - N:end) = 0;
    maxima(end - N:end,end - N:end) = 0;

end 