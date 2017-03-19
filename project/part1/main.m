%% Computer Vision 1 
%
% Project Part 1: Image Classfication
% Authors: Dana Kianfar - Jose Gallego
%
% Make sure you run VLFEAT setup beforehand.
run('C:\Users\Dana\.src\vlfeat-0.9.20\toolbox\vl_setup')
% Also for LibLinear
addpath('C:\Users\Dana\.src\liblinear-2.1\matlab\')
vl_compilenn('enableGpu', true, 'cudaRoot', 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v8.0', 'cudaMethod', 'nvcc', 'enableCudnn', true, 'cudnnRoot', 'local/cudnn-rc4') ;
%% RESET - careful!
close all, clear, clc

%% Pre-process data (will overwrite, this takes time!)
tic
data_preprocessing();
toc
%% Set Parameters
num_img_samples = 400; % Number of images to sample for training. Use 0 to retrieve all.
K = [400, 800, 1600, 2000]; %, 4000];
% densities = {'dense', 'key'};
densities = {'key'};
colorspaces = {'Gray', 'RGB', 'rgb', 'HSV', 'Opp'};

%% Perform Clustering
% Load features
S1_feats = load_data_from_folder('./data/training/clustering/', num_img_samples);

for k=1:length(K) % for each K
    for d=1:length(densities) % for each type of sampling (dense, keypoints)
        for c=1:length(colorspaces)  % for each colorspace
            X = double(get_features(S1_feats, densities{d}, c)); % get features for d, c
            disp(compose('K-means with K=%d, density=%s, colorspace=%s',K(k),densities{d}, colorspaces{c}))
            tic
            clustering_model = execute_clustering(X, 'kmeans',K(k)); % do K-means
            toc 
            fpath = char(compose('./data/clusters/K-%d_D-%s_c-%s.struct', ...
                K(k), densities{d}, colorspaces{c}));
            parsave(fpath, clustering_model); % same to file
        end
    end
end

%% Clear workspace
clear S1_feats

%% Perform Classification

classifiers = {'liblinear'};

% Load features
S2_feats = load_data_from_folder('./data/training/classification/', num_img_samples);

parfor k=1:length(K) % for each K
    for d=1:length(densities) % for each type of sampling (dense, keypoints)
        for c=1:length(colorspaces)  % for each colorspace
            for cl=1:length(classifiers)
                % load clustering model
                fpath = char(compose('./data/clusters/K-%d_D-%s_c-%s.struct', ...
                    K(k), densities{d}, colorspaces{c}));
                clustering_model = load_saved_model(fpath);

                % load data
                [bow_features, labels] = get_bows_with_labels(S2_feats, clustering_model, densities{d}, c);

                % Train classifier
                classification_model = execute_classification(bow_features, labels, classifiers{cl});
                
                fpath_save = char(compose('./data/classifiers/K-%d_D-%s_c-%s_%s.struct', ...
                    K(k), densities{d}, colorspaces{c}, classifiers{cl}));
                parsave(fpath_save, classification_model); % same to file
            end
        end
    end
end

%% Clear workspace
clear S2_feats