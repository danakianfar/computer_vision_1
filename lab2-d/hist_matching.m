function hist_matching(im1, im2)
M = zeros(256,1,'uint8'); % Mapping for each bin in CDF. No need for converting to double here

% Get histograms
hist1 = imhist(im1);
hist2 = imhist(im2);

% Compute CDFs
cdf1 = cumsum(hist1) / numel(im1); 
cdf2 = cumsum(hist2) / numel(im2);

% Compute mapping for each bin
for i = 1 : 256
    [~,ind] = min(abs(cdf1(idx) - cdf2)); % find the bin with the smallest intensity difference
    M(idx) = ind-1; % decrement range [1,256] to match uint8 [0,255]
end

%// Now apply the mapping to get first image to make
%// the image look like the distribution of the second image
out = M(double(im1)+1); % increment to get recover RGB trips

figure;
subplot(2,3,1), imshow(im1), title('Input');
subplot(2,3,2), imshow(im2), title('Reference');
subplot(2,3,3), imshow(out), title('Matched');
subplot(2,3,4), histogram(im1,256), title('Input Histogram');
subplot(2,3,5), histogram(im2,256), title('Reference Histogram');
subplot(2,3,6), histogram(out,256), title('Post-Matching Histogram');
end
