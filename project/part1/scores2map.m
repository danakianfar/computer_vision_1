function [ map, I ] = scores2map( scores, labels, target_class)
%SCORES2MAP Calculates MAP given the scores of the images from a particular
%binary classifier
%
% Inputs:
%   SCORES: Classification score of each image
%   LABELS: True label of each image
%   CLASSIFIER: Target category for which the binary classifier was trained
%
% Outputs:
%   MAP: Mean average precision of the classification task

    % Join scores and labels and sort them on ascending negatives (=
    % descending) scores
    A = [ -scores labels];
    [sorted_A, I]= sortrows(A, 1);
     
    % Get the sorted labels and check if they are the relevant label
    ranking = (sorted_A(:,2) == target_class);
    
    % Calculate MAP on ranking
    map = mean_avg_precision(ranking);

end

