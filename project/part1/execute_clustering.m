function res = execute_clustering(ft_matrix, method, K, show_plot)
%EXECUTE_CLUSTERING Runs clustering algorithm on matrix of features
%
%   RES = EXECUTE_CLUSTERING(FT_MATRIX, METHOD, K, SHOW_PLOT) finds K
%   clusters in data FT_MATRIX using METHOD.
%
% Inputs:
%   FT_MATRIX: matrix NxP of N examples of P-dimensional features
%   METHOD: possible to chosse from 'kmeans' and 'gmm'
%   K: number of clusters to use
%   SHOW_PLOT: boolean that determines whether to plot results
%
% Outputs:
%   RES: returns struct the corresponding cluster for each example in IDX
%   and the position of the CENTROIDS. For 'gmm' METHOD returns the
%   estimated GMM model for new data classification.

    % If not stated, do not show plot
    if nargin == 3
        show_plot = false;
    end
    
    % Apply normalization to the input data before clustering
    % Also store nomalization parameters for future data
    [ft_matrix, minv, rangev] = normalize_features(ft_matrix);
    
    % Switch depending on the selected method
    switch method
        case 'kmeans'
            
            % Run standard kmeans on data
            [idx, centroids]  = kmeans(ft_matrix,K);
            
            % Return results
            res = struct('name', 'kmeans', 'idx', idx, 'centroids', centroids, 'minv', minv, 'rangev', rangev);
        case 'gmm'
            
            % First fit the model
            GMM = fitgmdist(ft_matrix,K);
            
            % Find where each point corresponds
            idx = cluster(GMM,ft_matrix);
            
            % Extract location of centroids
            centroids = GMM.mu;
   
            % Return results
            res = struct('name', 'gmm', 'idx', idx, 'centroids', centroids, 'model', GMM, 'minv', minv, 'rangev', rangev, 'num_clusters', K);
        otherwise
            
            error('Error: Clustering method  %s not understood', method);
    end
    
    % If it is possible and desired to show plot, do it
    if show_plot
        if size(ft_matrix,2) == 2
            figure
            scatter(ft_matrix(:,1), ft_matrix(:,2), 2, res.idx)
            hold on
            scatter(res.centroids(:,1), res.centroids(:,2), 'r*')
            title('Clustering results')
        else
            disp('High dimensional data can not be displayed');
        end
    end
end


% Function to normalize features into [-1, 1]
function [res, minv, rangev] = normalize_features(ft_matrix)
    minv = min(ft_matrix);
    rangev = max(ft_matrix) - min(ft_matrix);
    res = -1 + 2.*(ft_matrix - minv)./ rangev;
end
