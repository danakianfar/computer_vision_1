function G = gauss(sigma, kernel_size)
    xvec = (0:kernel_size-1) - floor(kernel_size/2);
    denom = 1/(sigma*sqrt(2*pi));
    G = denom * exp(- (xvec.^2)/(2*sigma^2)) ;
end