%% Exc 2.1 - Gaussian vs. box
I = imread('images/image2.jpeg');
box_filt_size = [3,5,7,9];
median_filt_size = [3,5,7];
padding = {'replicate'};
BOX = numel(box_filt_size);
MED = numel(median_filt_size);
PAD = numel(padding );


% Box filters
close all;
figure; 
for p=1:PAD
    for b=1:BOX
        subplot(PAD, BOX,BOX*(p-1)+b);
        imout = denoise(I, 'box', box_filt_size(b), char(padding(p)));
        imshow(imout);
        title(compose('Box Filter %dx%d - %s Padding', box_filt_size(b), box_filt_size(b), char(padding(p))));
    end
end
clear b;
print('box-filters', '-dpdf');
%%

figure; 
for m=1:MED
    for p=1:PAD
        subplot(MED, BOX,BOX*(p-1)+m);
        imout = denoise(I, 'median', median_filt_size(m), char(padding(p)));
        imshow(imout);
        title(compose('Median Filter %dx%d - %s Padding', median_filt_size(m), median_filt_size(m), char(padding(p))));
    end
end

print('median-filters', '-dpdf');