function imOut = myHistMatching(input, reference)
    imOut = hist_matching(input, reference);
    
    figure;
    subplot(2,3,1), imshow(input), title('Input', 'FontSize', 15);
    subplot(2,3,2), imshow(reference), title('Reference', 'FontSize', 15);
    subplot(2,3,3), imshow(imOut, []), title('Transformed', 'FontSize', 15);
    subplot(2,3,4), histogram(input,256), xlim([0,256]), title('Input Histogram', 'FontSize', 15);
    subplot(2,3,5), histogram(reference,256), xlim([0,256]), title('Reference Histogram', 'FontSize', 15);
    subplot(2,3,6), histogram(imOut,256), xlim([0,256]), title('Transformed Histogram', 'FontSize', 15);
end

function out = hist_matching(im1, im2)
    % Compute CDF of both images
    cdf1 = cumsum(imhist(im1)) / numel(im1); 
    cdf2 = cumsum(imhist(im2)) / numel(im2);

    % compute differences between each item in cdf of image, and the entire cdf
    % of the reference image. Produces a matrix of differences
    differences = abs(bsxfun(@minus, kron(cdf1, ones(1,numel(cdf1))) , cdf2'));

    % Find minimum difference between cdfs.
    % Indices i are a mapping from image cdf to reference cdf
    [~,i] = min(differences');
    
    % Map CDFs
    out = zeros(size(im1));
    for map_idx=1:256
        out(im1 == map_idx-1) = i(map_idx)-1;  % correction done to convert [1 256] interval of indixes to [0 255] RGB values
    end
end

