%% Computer Vision 1 
%
% Project Part 1: Image Classfication
% Authors: Dana Kianfar - Jose Gallego
%
% Make sure you run VLFEAT setup beforehand.
run('C:\Users\Dana\.src\vlfeat-0.9.20\toolbox\vl_setup')
% Also for LibLinear
addpath('C:\Users\Dana\.src\liblinear-2.1\matlab\')
addpath('C:\Users\Dana\.src\matconvnet-1.0-beta23\matlab')
run('C:\Users\Dana\.src\matconvnet-1.0-beta23\matlab\vl_setupnn')
% vl_compilenn('enableGpu', true, 'cudaRoot', 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v8.0', 'cudaMethod', 'nvcc', 'enableCudnn', true, 'cudnnRoot', 'local/cudnn-rc4') ;

%% Setup Ubuntu

run('../../../../vlfeat/toolbox/vl_setup')
run('../../../../matconvnet/matlab/vl_setupnn')
addpath('../../../../matconvnet/matlab')
addpath('../../../../liblinear-2.1/matlab/')


%% RESET - careful!
close all, clear, clc

%% Pre-process data (will overwrite, this takes time!)
tic, data_preprocessing(), toc;

%% Set Parameters
num_img_samples = 400; % Number of images to sample for training. Use 0 to retrieve all.
K = [400, 800, 1600, 2000]; %, 4000];
densities = {'dense', 'key'};
colorspaces = {'Gray', 'RGB', 'rgb', 'HSV', 'Opp'};

%% Perform Clustering
% Load features
S1_feats = load_data_from_folder('./data/training/clustering/', num_img_samples);

for k=1:length(K) % for each K
    for d=1:length(densities) % for each type of sampling (dense, keypoints)
        for c=1:length(colorspaces)  % for each colorspace
            X = get_features(S1_feats, densities{d}, c); % get features for d, c
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

% Clear workspace
clear S1_feats

%% Perform Classification

num_img_samples = 0; % Number of images to sample for training. Use 0 to retrieve all.
classifiers = {'liblinear'};

% Load features
S2_feats = load_data_from_folder('./data/training/classification/', num_img_samples);
binary_class = false;

for k=1:length(K) % for each K
    for d=1:length(densities) % for each type of sampling (dense, keypoints)
        for c=1:length(colorspaces)  % for each colorspace
            for cl=1:length(classifiers)
                
                % load clustering model
                        clustering_model = load_saved_model('clustering', K(k), densities{d}, colorspaces{c});

                        disp(compose('Clustering with K=%d, density=%s, colorspace=%s',K(k),densities{d}, colorspaces{c}))

                        % load data
                        tic
                        [bow_features, labels] = get_bows_with_labels(S2_feats, clustering_model, densities{d}, c);

                        
                if binary_class
                    for obj_class = 1:4
                    
                        labels = double(labels == obj_class);

                        % Train classifier
                        classification_model = execute_classification(bow_features, labels, classifiers{cl});

                        fpath_save = char(compose('./data/classifiers/bin-%d_K-%d_D-%s_c-%s_%s.struct', ...
                            obj_class, K(k), densities{d}, colorspaces{c}, classifiers{cl}));
                        parsave(fpath_save, classification_model); % same to file
                    end
                    toc
                else
                    
                        % Train classifier
                        classification_model = execute_classification(bow_features, labels, classifiers{cl});
                        toc

                        fpath_save = char(compose('./data/classifiers/K-%d_D-%s_c-%s_%s.struct', ...
                                    K(k), densities{d}, colorspaces{c}, classifiers{cl}));
                        parsave(fpath_save, classification_model); % same to file
                end
            end
        end
    end
end

%%

% Clear workspace
clear S2_feats

%% Run test evaluation
num_img_samples = 0; % Number of images to sample for training. Use 0 to retrieve all.
classifiers = {'liblinear'};
labels = {'airplane', 'car', 'face', 'motorbike'};
    
% Load test images 
testing_imgs = load_data_from_folder('./data/testing/', num_img_samples);

for k=1:length(K) % for each K
    for d=1:length(densities) % for each type of sampling (dense, keypoints)
        for c=1:length(colorspaces)  % for each colorspace
            for cl=1:length(classifiers)
                
                % load clustering & classification models
                clustering_model = load_saved_model('clustering', K(k), densities{d}, colorspaces{c});
                classification_model = load_saved_model('classification', K(k), densities{d}, colorspaces{c}, classifiers{cl});
                
                % load data
                [bow_features, labels] = get_bows_with_labels(testing_imgs, clustering_model, densities{d}, c);
                                
                % Predict labels
                [predicted_label, accuracy, scores] = predict(labels, sparse(bow_features), classification_model);
                
                % Evaluate predictions
                map1 = scores2map(scores(:,1), labels, 1);
                map2 = scores2map(scores(:,2), labels, 2);
                map3 = scores2map(scores(:,3), labels, 3);
                map4 = scores2map(scores(:,4), labels, 4);
                
                disp(compose('mAP of K=%d, d=%s, c=%s: airplanes:%.3f, cars:%.3f, faces:%.3f, motorbikes:%.3f', K(k), densities{d}, colorspaces{c}, map1, map2, map3, map4));
                
                % Save mat
%                 fpath_save = char(compose('./data/classifiers/K-%d_D-%s_c-%s_%s.struct', ...
%                     K(k), densities{d}, colorspaces{c}, classifiers{cl}));
%                 parsave(fpath_save, classification_model); % same to file
            end
        end
    end
end

