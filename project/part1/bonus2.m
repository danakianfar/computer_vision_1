function bonus2() %% Set Parameters
num_img_samples = 400; % Number of images to sample for training. Use 0 to retrieve all.
K = [400];
densities = {'dense'};
colorspaces = {'Gray', 'RGB', 'HSV', 'Opp','rgb'};

% Perform Clustering
% Load features
S1_feats = load_data_from_folder('./data/training/clustering/', num_img_samples);

for d=1:length(densities) % for each type of sampling (dense, keypoints)
    for k=1:length(K) % for each K
        for c=1:length(colorspaces)  % for each colorspace
            X = get_features(S1_feats, densities{d}, c); % get features for d, c
            disp(compose('K-means with K=%d, density=%s, colorspace=%s',K(k),densities{d}, colorspaces{c}))
            tic
            clustering_model = execute_clustering(double(X), 'gmm',K(k)); % do K-means
            toc 
            fpath = char(compose('./data/clusters/K-%d_D-%s_c-%s.struct', ...
                K(k), densities{d}, colorspaces{c}));
            parsave(fpath, clustering_model); % same to file
        end
    end
end

return
% Clear workspace
clear S1_feats

%% Perform Classification

num_img_samples = 0; % Number of images to sample for training. Use 0 to retrieve all.
classifiers = {'liblinear', 'libsvm-poly', 'libsvm-rbf'}; % We use fitcsvm, not libsvm
K = [400, 800, 1600, 2000, 4000];
densities = {'dense', 'key'};
colorspaces = {'Gray', 'RGB', 'HSV', 'Opp','rgb'};


% Load features
tic
S2_feats = load_data_from_folder('./data/training/classification/', num_img_samples);
toc
binary_class = true;

for d=1:length(densities) % for each type of sampling (dense, keypoints)    
    for k=1:length(K) % for each K
        for c=1:length(colorspaces)  % for each colorspace
            for cl=1:length(classifiers)
                
                % load clustering model
                clustering_model = load_saved_model('clustering', K(k), densities{d}, colorspaces{c});

                % load data
                tic
                [bow_features, labels] = get_bows_with_labels(S2_feats, clustering_model, densities{d}, c);

                if binary_class
                    for obj_class = 1:4
                        disp(compose('Binary clustering class=%d with K=%d, density=%s, colorspace=%s',obj_class, K(k),densities{d}, colorspaces{c}))
                        class_labels = double(labels == obj_class);

                        % Train classifier
                        classification_model = execute_classification(bow_features, class_labels, classifiers{cl});

                        fpath_save = char(compose('./data/classifiers/bin-%d_K-%d_D-%s_c-%s_%s.struct', ...
                            obj_class, K(k), densities{d}, colorspaces{c}, classifiers{cl}));
                        parsave(fpath_save, classification_model); % same to file
                    end
                    toc
                else
                    disp(compose('Multi-class clustering with K=%d, density=%s, colorspace=%s',K(k),densities{d}, colorspaces{c}))
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

%% Clear workspace
clear S2_feats

%% Run test evaluation
num_img_samples = 0; % Number of images to sample for training. Use 0 to retrieve all.
classifiers = {'liblinear', 'libsvm-poly', 'libsvm-rbf'};
labels = {'airplane', 'car', 'face', 'motorbike'};
K = [400, 800, 1600, 2000, 4000];
densities = {'dense', 'key'};
colorspaces = {'Gray', 'RGB', 'HSV', 'Opp','rgb'};

num_experiments = length(classifiers) * length(K) * length(densities) * length(colorspaces);
model_params = {'Colorspace', 'K', 'Density', 'Classifier', 'Airplane', 'Car', 'Face', 'Bike' , 'mAP'};
results = cell(1, length(model_params));
results(1,:) = model_params;


% Load test images 
testing_imgs = load_data_from_folder('./data/testing/', num_img_samples);
image_paths = cell2mat(testing_imgs);
image_paths = {image_paths.path};

for k=1:length(K) % for each K
    for d=1:length(densities) % for each type of sampling (dense, keypoints)
        for c=1:length(colorspaces)  % for each colorspace

            % load clustering & classification models
            clustering_model = load_saved_model('clustering', K(k), densities{d}, colorspaces{c});

            % load data
            [bow_features, labels] = get_bows_with_labels(testing_imgs, clustering_model, densities{d}, c);

            for cl=1:length(classifiers)
                
                sorted_images = cell(length(testing_imgs),4); % sorted images for each class
               
                map = zeros(1,4);
                
                for class_model = 1:4
                    
                    classification_model = load_saved_model('classification', K(k), densities{d}, colorspaces{c}, classifiers{cl}, class_model);

                    class_labels = double(labels == class_model);
                    
                    % Predict labels
                    if cl == 1 % if liblinear
                        [predicted_label, accuracy,  scores] = predict(class_labels, sparse(bow_features), classification_model);

                        if classification_model.Label(1) == 0 % Ensure labels are correctly assigned
                           scores = -scores; 
                        end
                    else % fitcsvm
                        [~, scores] = classification_model.predict(bow_features);
                        scores = scores(:,2);
                    end
                    % Evaluate predictions
                    [map_val, sort_idx] = scores2map(scores, class_labels, 1);
                    
                    map(class_model) = map_val;
                    sorted_images(:,class_model) = image_paths(sort_idx);
                end
                
                results(end+1,:) = {colorspaces{c}, K(k), densities{d}, classifiers{cl}, map(1), map(2), map(3), map(4), mean(map)};
                
                disp(compose('mAP of K=%d, d=%s, c=%s, cl=%s: airplanes:%.3f, cars:%.3f, faces:%.3f, motorbikes:%.3f', K(k), densities{d}, colorspaces{c}, classifiers{cl}, map(1), map(2), map(3), map(4)));
              
                % export to html
                export_to_html(colorspaces{c}, K(k), densities{d}, classifiers{cl}, mean(map), map(1), map(2), map(3), map(4), sorted_images);
            end
        end
    end
end

end