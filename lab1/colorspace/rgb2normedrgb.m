function [output_image] = rgb2normedrgb(input_image)
% converts an RGB image into normalized rgb

input_image = double(input_image); % Converts to double for numerical stability

[R,G,B] = getColorChannels(input_image);

norm_factor = R + G + B; % intensity

normed_R = R ./ norm_factor;

normed_G = G ./ norm_factor;

normed_B = B ./ norm_factor;

output_image = cat(3, normed_R, normed_G, normed_B);

end

