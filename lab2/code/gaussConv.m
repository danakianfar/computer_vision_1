function imOut = gaussConv(image, sigma_x, sigma_y, kernel_size)
     imOut = conv2(gauss(sigma_x, kernel_size), gauss(sigma_y, kernel_size), double(image));
end