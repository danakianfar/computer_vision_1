function [M, F1, D1, F2, D2] = siftmatch (left, right)

    % Detect interest points in each image and their descriptors
    [F1, D1] = vl_sift(left);
    [F2, D2] = vl_sift(right);

    % Get the set of supposed matches between region descriptors in each image
    M = vl_ubcmatch(D1, D2); 