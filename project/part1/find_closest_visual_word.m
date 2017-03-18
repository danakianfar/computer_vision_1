function new_idx = find_closest_visual_word(points, model, show_plot)
%FIND_CLOSEST_VISUAL_WORD Find closest visual words.
%
%   IDX = FIND_CLOSEST_VISUAL_WORD(POINTS, MODEL, SHOW_PLOT) returns the
%   cluster numbers for the examples in POINTS given a pretrained
%   clustering MODEL.
%
% Inputs:
%   POINTS: matrix NxP of N P-dimensional examples for which the best
%   cluster will be found
%   MODEL: pretrained clustering model trained using execute_clustering
%   SHOW_PLOT: boolean that determines whether to plot results
%
% Outputs:
%   IDX: Returns the corresponding cluster number for each example in
%   points
%
%See also:
% execute_clustering
   
    % If not stated, do not show plot
    if nargin == 2
        show_plot = false;
    end
    
    % Switch depending on the provided model type
    switch model.name
        case 'kmeans'
            new_idx = knnsearch(model.centroids, points);
        case 'gmm'
            new_idx = cluster(model.model,points);
        otherwise
            error('Error: Clustering method  %s not understood', method);
    end
    
    points = apply_normalization(points, model.minv, model.rangev);
    
    % If it is possible and desired to show plot, do it
    if show_plot
        if size(points,2) == 2
            figure
            scatter(points(:,1), points(:,2), 2, new_idx)
            hold on
            scatter(model.centroids(:,1), model.centroids(:,2), 'r*')
            title('New data clustering')
        else
            disp('High dimensional data can not be displayed');
        end
    end
end


% Function to apply [-1, 1] normalization
function res = apply_normalization(ft_matrix, minv, rangev)
    res = -1 + 2.*(ft_matrix - minv)./ rangev;
end
