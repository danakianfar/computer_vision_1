function test_classification()
    
    %% Perform Classification

num_img_samples = 0; % Number of images to sample for training. Use 0 to retrieve all.
classifiers = {'liblinear', 'libsvm-poly', 'libsvm-rbf'};
K = [400];
densities = {'dense', 'key'};
colorspaces = {'Gray', 'RGB'};

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

%%

% Clear workspace
clear S2_feats

%% Run test evaluation
num_img_samples = 0; % Number of images to sample for training. Use 0 to retrieve all.
labels = {'airplane', 'car', 'face', 'motorbike'};


num_experiments = length(classifiers) * length(K) * length(densities) * length(colorspaces);
model_params = {'Colorspace', 'K', 'Density', 'Classifier', 'Airplane mAP', 'Car mAP', 'Face mAP', 'Motorbike mAP' };
results = cell(1, length(model_params));
results(1,:) = model_params;


% Load test images 
testing_imgs = load_data_from_folder('./data/testing/', num_img_samples);

for k=1:length(K) % for each K
    for d=1:length(densities) % for each type of sampling (dense, keypoints)
        for c=1:length(colorspaces)  % for each colorspace
            for cl=1:length(classifiers)
                
                % load clustering & classification models
                clustering_model = load_saved_model('clustering', K(k), densities{d}, colorspaces{c});
                
                % load data
                [bow_features, labels] = get_bows_with_labels(testing_imgs, clustering_model, densities{d}, c);
                
                map = zeros(1,4);
                
                for class_model = 1:4
                    
                    classification_model = load_saved_model('classification', K(k), densities{d}, colorspaces{c}, classifiers{cl}, class_model);

                    class_labels = double(labels == class_model);
                    
                    % Predict labels
                    if cl == 1 % if liblinear
                        [predicted_label, accuracy, scores] = predict(class_labels, sparse(bow_features), classification_model);
                    else
                        [predicted_label, scores] = classification_model.predict(bow_features);
                    end
                    % Evaluate predictions
                    map(class_model) = scores2map(scores(:,1), class_labels, 1);
                end
                
                results(end+1,:) = {colorspaces{c}, K(k), densities{d}, classifiers{cl}, map(1), map(2), map(3), map(4)};
                
                disp(compose('mAP of K=%d, d=%s, c=%s, cl=%s: airplanes:%.3f, cars:%.3f, faces:%.3f, motorbikes:%.3f', K(k), densities{d}, colorspaces{c}, classifiers{cl}, map(1), map(2), map(3), map(4)));
              
                % Save mat
%                 fpath_save = char(compose('./data/classifiers/K-%d_D-%s_c-%s_%s.struct', ...
%                     K(k), densities{d}, colorspaces{c}, classifiers{cl}));
%                 parsave(fpath_save, classification_model); % same to file
            end
        end
    end
end

end