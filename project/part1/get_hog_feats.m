function [features] = get_hog_feats(cell_of_structs)
% Gets HOG features from stored images

    N=0;
    features = zeros(1,31);
    j=1;
    for i=1:length(cell_of_structs)
        img = cell_of_structs{i};
        
        im = imread(img.path);
        hog = vl_hog(im2single(im), 8);
        
        [m,n,o] = size(hog);
        feats = reshape(hog, m*n, o); % get colorspace
        
        features(j:j+size(feats,1)-1,:) = feats;
        j = j+ size(feats,2); % update pointer
    end

end