function imOut = myHistMatching(input, reference)
    imOut = hist_matching(input, reference);
    
    figure;
    subplot(2,3,1), imshow(input), title('Input');
    subplot(2,3,2), imshow(reference), title('Reference');
    subplot(2,3,3), imshow(imOut), title('Transformed');
    subplot(2,3,4), histogram(input,256), title('Input Histogram');
    subplot(2,3,5), histogram(reference,256), title('Reference Histogram');
    subplot(2,3,6), histogram(imOut,256), title('Transformed Histogram');
end

function out = hist_matching(im1, im2)
M = zeros(256,1,'uint8'); % Mapping for each bin in CDF. No need for converting to double here

% Get histograms
hist1 = imhist(im1);
hist2 = imhist(im2);

% Compute CDFs
cdf1 = cumsum(hist1) / numel(im1); 
cdf2 = cumsum(hist2) / numel(im2);

% Compute mapping for each bin
for i = 1 : 256
    [~,ind] = min(abs(cdf1(i) - cdf2)); % find the bin with the smallest intensity difference
    M(i) = ind-1; % decrement range [1,256] to match uint8 [0,255]
end

%// Now apply the mapping to get first image to make
%// the image look like the distribution of the second image
out = M(double(im1)+1); % increment to get recover RGB trips
end

