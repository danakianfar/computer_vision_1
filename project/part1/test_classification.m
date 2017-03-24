function test_classification()
    
    num_img_samples = 0; % Number of images to sample for training. Use 0 to retrieve all.
    classifiers = {'liblinear'};
    K = [2000]; %[400, 800, 1600, 2000]; %, 4000];
    densities = {'key'};%{'dense', 'key'};
    colorspaces = {'Gray', 'RGB', 'rgb', 'HSV', 'Opp'};

    % Load features
    tic
    S2_feats = load_data_from_folder('./data/training/classification/', num_img_samples);
    toc
    binary_class = true;

    for k=1:length(K) % for each K
        for d=1:length(densities) % for each type of sampling (dense, keypoints)
            for c=1:length(colorspaces)  % for each colorspace
                
                if c < 3
                    continue
                end
                
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
end