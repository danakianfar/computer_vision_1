function test_classification()
    
    % Run test evaluation
    num_img_samples = 0; % Number of images to sample for training. Use 0 to retrieve all.
    classifiers = {'liblinear'};
    label_names= {'airplane', 'car', 'face', 'motorbike'};
    K = [400, 800];
    densities = {'dense'};
    colorspaces = {'Gray', 'RGB', 'HSV', 'Opp','rgb'};

    num_experiments = length(classifiers) * length(K) * length(densities) * length(colorspaces);
    model_params = {'Colorspace', 'K', 'Density', 'Classifier', 'Airplane', 'Car', 'Face', 'Bike' , 'mAP'};
    results = cell(1, length(model_params));
    results(1,:) = model_params;

    % Load test images 
    testing_imgs = load_data_from_folder('./data/testing/', num_img_samples);
    image_paths = cell2mat(testing_imgs);
    image_paths = {image_paths.path};
    
    figure;

    for k=1:length(K) % for each K
        for d=1:length(densities) % for each type of sampling (dense, keypoints)
            for c=1:length(colorspaces)  % for each colorspace
                
                if (c == 3 && k==2)|| (c == 1 && k==1) % top two models

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
                                [predicted_labels, accuracy,  scores] = predict(class_labels, sparse(bow_features), classification_model);

                                if classification_model.Label(1) == 0 % Ensure labels are correctly assigned
                                   scores = -scores; 
                                end
                            else % fitcsvm
                                [predicted_labels, scores] = classification_model.predict(bow_features);
                                scores = scores(:,2);
                            end
                            % Evaluate predictions
                            [map_val, sort_idx] = scores2map(scores, class_labels, 1);

                            map(class_model) = map_val;
                            sorted_images(:,class_model) = image_paths(sort_idx);
                            
                            subplot(1,4,class_model);
                            [X,Y, ~, AUC] = perfcurve(class_labels,scores,1); 
                            
                            disp(compose('K=%d, d=%s, c=%s, cl=%s, AUC:%.3f',K(k), densities{d}, colorspaces{c}, classifiers{cl}, AUC))
                            
                            plot(X,Y);
                            title('ROC Curve', 'FontSize', 14)
                            xlabel('False positive rate', 'FontSize', 14)
                            ylabel('True positive rate', 'FontSize', 14)
                            legend(compose('K=%d, d=%s, c=%s, cl=%s:',K(k), densities{d}, colorspaces{c}, classifiers{cl}))
                            hold on;
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
end