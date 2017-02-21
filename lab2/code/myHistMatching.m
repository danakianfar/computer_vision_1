function imOut = myHistMatching(input, reference)
    imOut = imhistmatch(input, reference);
    
    figure
    subplot(2,1,1)
    imshow(input)
    title('Input Image')
    subplot(2,1,2)
    histogram(input)
    title('Input Histogram')
    
    
    figure
    subplot(2,1,1)
    imshow(reference)
    title('Reference Image')
    subplot(2,1,2)
    histogram(reference)
    title('Reference Histogram')
    
    
    figure
    subplot(2,1,1)
    imshow(imOut)
    title('output Image')
    subplot(2,1,2)
    histogram(imOut)
    title('Output Histogram')
end