function [bow] = get_image_bow(descriptors, model)
%GET_IMAGE_BOW Returns a Bag-of-Words vector of the descriptors
% 
% BOW = GET_IMAGE_BOW(DESCRIPTORS, MODEL) returns a vector with C elements,
% where C is the number of centroids in the model. Each descriptor is
% matched to a centroid using find_closest_visual_word
% 
% Inputs:
%     DESCRIPTORS: An NxP matrix, consisting of N descriptors of
%     dimensionality P
%     MODEL: Pre-trained clustering model using execute_clustering
% 
% Outputs:
%     BOW: A vector of dimentionality P, where each entry is an integer
%     count of the matched centroids.
%See also:
% find_closest_visual_word

    words = find_closest_visual_word(descriptors, model);
    bow = histcounts(words, 1:length(model.centroids)+1, 'Normalization', 'probability');
    
end