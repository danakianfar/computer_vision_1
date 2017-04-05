function bonus()
    
        % Run test evaluation
    num_img_samples = 0; % Number of images to sample for training. Use 0 to retrieve all.
    classifiers = {'knn'};
    labels = {'airplane', 'car', 'face', 'motorbike'};
    K = [400];
    densities = {'dense'};
    colorspaces = {'Gray', 'RGB', 'HSV', 'Opp','rgb'};
    KNN_K = [1,5,10,20];
    
    
    num_experiments = length(classifiers) * length(K) * length(densities) * length(colorspaces);
    model_params = {'Colorspace', 'K', 'Density', 'Classifier', 'Airplane AP', 'Car AP', 'Face AP', 'Motorbike AP', 'mAP' };
    results = cell(1, length(model_params));
    results(1,:) = model_params;


    % Load test images 
    testing_imgs = load_data_from_folder('./data/testing/', num_img_samples);
    S2_feats = load_data_from_folder('./data/training/classification/', num_img_samples);
    image_paths = cell2mat(testing_imgs);
    image_paths = {image_paths.path};

    for knn_idx = 1:length(KNN_K)
        for k=1:length(K) % for each K
            for d=1:length(densities) % for each type of sampling (dense, keypoints)
                for c=1:length(colorspaces)  % for each colorspace
                    if (c == 1) % actually only grayscale                     

                        % load clustering model 
                        clustering_model = load_saved_model('clustering', K(k), densities{d}, colorspaces{c});

                        % load data
                        [bow_features_train, labels_train] = get_bows_with_labels(S2_feats, clustering_model, densities{d}, c);
                        [bow_features_test, labels_test] = get_bows_with_labels(testing_imgs, clustering_model, densities{d}, c);

                        for cl=1:length(classifiers) % each classifier

                            sorted_images = cell(length(testing_imgs),4); % sorted images for each class

                            map = zeros(1,4);

                            for class_model = 1:4

                                class_positions = (labels_test == class_model);
                                [~, sort_test_idx] = sort(-class_positions);
                                bow_features_test = bow_features_test(sort_test_idx,:); % reorder to that relevant test images are on top

                                % KNN with cosine similarity
    %                             similarity = bow_features_test*bow_features_train'; % testing-to-training similarity matrix
    % 
    %                             [scores, i] = max(similarity, [], 2);
                                [i, ~] = knnsearch(bow_features_train, bow_features_test, 'K', KNN_K(knn_idx));
                                
                                if size(i,2) > 1
                                    tmp = labels_train(i);
                                    predicted_labels = mode(tmp,2);
                                else
                                    predicted_labels = labels_train(i);  
                                end
                                   
                                predicted_labels = double(predicted_labels == class_model);

                                map(class_model) = mean_avg_precision(predicted_labels);
%                                 sorted_images(:,class_model) = image_paths(sort_idx);
                            end

                            results(end+1,:) = {colorspaces{c}, K(k), densities{d}, classifiers{cl}, map(1), map(2), map(3), map(4), mean(map)};

                            disp(compose('mAP of K=%d, d=%s, c=%s, cl=%s: airplanes:%.3f, cars:%.3f, faces:%.3f, motorbikes:%.3f, mAP:%.3f', K(k), densities{d}, colorspaces{c}, compose('%s-%d', classifiers{cl}, KNN_K(knn_idx)), map(1), map(2), map(3), map(4), mean(map)));
                        end
                    end
                end
            end
        end
    end
end

