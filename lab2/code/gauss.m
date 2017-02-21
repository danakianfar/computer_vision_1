function G = gauss(sigma, kernel_size)
%% Computes a 1D gaussian filter of size kernel_size x 1
    k = floor(kernel_size/2);
    G = linspace(-k,k,kernel_size);
    G = 1/(sigma * sqrt(2*pi)) * exp(- G.^2 / (2*sigma^2));
end