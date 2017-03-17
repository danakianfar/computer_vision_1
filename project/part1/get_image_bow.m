function [bow] = get_image_bow(descriptors, centroids, model)

    words = find_closest_visual_word(descriptors, model, false);
    bow = 1:length()

end