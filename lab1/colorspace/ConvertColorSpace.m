function [new_image] = ConvertColorSpace(input_image, colorspace)
% convert image into double precision for conversions
input_image = im2double(input_image);

if strcmp(colorspace, 'opponent')
    new_image = rgb2opponent(input_image); % fill in this function
    labels = {'O1', 'O2', 'O3'};
elseif strcmp(colorspace, 'rgb')  
    new_image = rgb2normedrgb(input_image); % fill in this function
    labels = {'Normalized R', 'Normalized G', 'Normalized B'};
elseif strcmp(colorspace, 'hsv')   
    % use the built-in function
    new_image = rgb2hsv(input_image);
    labels = {'H', 'S', 'V'};
elseif strcmp(colorspace, 'ycbcr')
    % use the built-in function
    new_image = rgb2ycbcr(input_image);
    labels = {'Y', 'Cb', 'Cr'};
elseif strcmp(colorspace, 'gray')
    [out_light, out_avg, out_lum, out_matlab] = rgb2grays(input_image); % fill in this function
    new_image = {out_light, out_avg, out_lum, out_matlab};
    else
% if user inputs an unknow colorspace just notify and do not plot anything
    fprintf('Error: Unknown colorspace type [%s]...\n',colorspace);
    new_image = input_image;
    return;
end

if strcmp(colorspace, 'gray')
    visualize(out_light, out_avg, out_lum, out_matlab, input_image, ...
        {'lightness', 'average', 'luminosity', 'matlab', 'original'},colorspace);
    channel_density(new_image, {'lightness', 'average', 'luminosity', 'matlab'},'gray_kernels');
else
    visualize(new_image(:,:,1), new_image(:,:,2), new_image(:,:,3), input_image, [labels {'Original'}], colorspace);
    colorspace_scatterplot(new_image, input_image, labels, colorspace)
end

end