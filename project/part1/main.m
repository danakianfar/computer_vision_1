%% Computer Vision 1 
%
% Project Part 1: Image Classfication
% Authors: Dana Kianfar - Jose Gallego
%
% Make sure you run VLFEAT setup beforehand.
% run('C:\Users\Dana\.src\vlfeat-0.9.20\toolbox\vl_setup')
% Also for LibLinear
% addpath('C:\Users\Dana\.src\liblinear-2.1\matlab\')
%% RESET - careful!
close all, clear all, clc

%% Set Parameters
num_img_samples = 0; % Number of images to sample for training. Use 0 to retrieve all.
K = [400, 800, 1600, 2000, 4000];
densities = {'dense', 'key'};
colorspaces = {'Gray', 'RGB', 'rgb', 'HSV', 'Opp'};

%% Perform Clustering
% Load features
S1_feats = load_data_from_folder('./data/training/clustering/', num_img_samples);

parfor k=1:length(K) % for each K
    for d=1:length(densities) % for each type of sampling (dense, keypoints)
        for c=1:length(colorspaces)  % for each colorspace
            X = get_features(S1_feats, densities{d}, c); % get features for d, c
            clustering_model = execute_clustering(X, K(k)); % do K-means
            fpath = char(compose('./data/clusters/K-%d_D-%s_c-%s.struct', ...
                K(k), densities{d}, colorspaces{c}));
            parsave(fpath, 'clustering_model'); % same to file
        end
    end
end

%% Perform Classification

% Load features
S2_feats = load_data_from_folder('./data/training/classification/', num_img_samples);

parfor k=1:length(K) % for each K
    for d=1:length(densities) % for each type of sampling (dense, keypoints)
        for c=1:length(colorspaces)  % for each colorspace
            X = get_features(S2_feats, densities{d}, c); % get features for d, c
            fpath = char(compose('./data/clusters/K-%d_D-%s_c-%s.struct', ...
                K(k), densities{d}, colorspaces{c}));
            clustering_model = load(fpath)
            
            bow = get_image_bow(X{c}, clustering_model);
            
            
            parsave(fpath, 'clustering_model'); % same to file
        end
    end
end
