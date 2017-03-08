% Performs non-maximal supression. Returns a binary array with maxima
% within specified window sizes. Zero-padding is applied to X but corner
% values are zeroed.
function [maxima] = nonmaxsupp(X, N)
    
    N = 2*N + 1;
    h = ones(N);
    % Center of filter is 0 as we are replacing that value
    h(ceil((N*N)/2)) = 0; 

    % Non-overlapping zero-padded windows
    bin_max = ordfilt2(X, (N ^ 2) - 1, h); % create a matrix with all 2nd largest vals
    maxima = (X > bin_max) ; % threshold to find maximum, result is binary

    % Corners are unreliable as they are padded
    pad_edges = floor(N/2);
    maxima(1 : pad_edges , :) = 0; % top rows
    maxima(end - pad_edges : end , :) = 0; % bottom rows
    maxima( : , 1 : pad_edges) = 0; % left-most columns
    maxima( : , end - pad_edges : end) = 0; % right-most columns

end 