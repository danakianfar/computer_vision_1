function [out_light, out_avg, out_lum, out_matlab] = rgb2grays(input_image)
% converts an RGB into grayscale by using 4 different methods
input_image = double(input_image)/255; % Converts to double for numerical stability

[R,G,B] = getColorChannels(input_image);

% lightness method
out_light = 0.5 * (min(input_image, [], 3) + max(input_image, [], 3)); 

% average method
out_avg = sum(input_image, 3)/3;

% luminosity method
out_lum = 0.21 * R + 0.72 * G + 0.07*B;

% built-in MATLAB function 
out_matlab = rgb2gray(input_image);

end

