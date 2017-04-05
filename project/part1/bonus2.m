num_img_samples = 0; % Number of images to sample for training. Use 0 to retrieve all.
K = [50];

% Perform Clustering
% Load features
S1_feats = load_data_from_folder('./data/training/clustering/', num_img_samples);
X = get_hog_feats(S1_feats);
[centroids, idx] = vl_kmeans(X', K, 'MaxNumIterations', 800 , 'Algorithm', 'elkan', 'Verbose') ;
clustering_model = struct('name', 'kmeans', 'idx', idx, 'centroids', centroids, 'num_clusters', K); % 'minv', minv, 'rangev', rangev,);

% Classification
S2_feats = load_data_from_folder('./data/training/classification/', 0);

N = length(S2_feats);
P = clustering_model.num_clusters;
bow_features = zeros(N,P);
labels = zeros(N,1);

% Get BoW features
for i=1:N % for each image struct
   img = S2_feats{i}; 

   im = imread(img.path);
    hog = vl_hog(im2single(im), 8);

    [m,n,o] = size(hog);
    feats = double(reshape(hog, m*n, o)); % get colorspace

   [~, words] = min(vl_alldist(feats', centroids)) ;
   bow_features(i,:) = histcounts(words, 1:length(centroids)+1, 'Normalization', 'probability');

   labels(i) = img.label; % save target (1-4)
end

% Train classifier
classification_model = execute_classification(bow_features, labels, 'liblinear');


% Test 
testing_imgs = load_data_from_folder('./data/testing/', 0);

N = length(testing_imgs);
P = clustering_model.num_clusters;
bow_features_test = zeros(N,P);
labels_test = zeros(N,1);

% Get BoW
for i=1:N % for each image struct
   img = testing_imgs{i}; 

   im = imread(img.path);
    hog = vl_hog(im2single(im), 8);

    [m,n,o] = size(hog);
    feats = double(reshape(hog, m*n, o)); % get colorspace

   [~, words] = min(vl_alldist(feats', centroids)) ;
   bow_features_test(i,:) = histcounts(words, 1:length(centroids)+1, 'Normalization', 'probability');

   labels_test(i) = img.label; % save target (1-4)
end


map = zeros(1,4);

for class_model = 1:4

    class_labels = double(labels_test == class_model);

    [predicted_label, accuracy,  scores] = predict(class_labels, sparse(bow_features_test), classification_model);

    if classification_model.Label(1) == 0 % Ensure labels are correctly assigned
       scores = -scores; 
    end
    
    % Evaluate predictions
    [map_val, sort_idx] = scores2map(scores, class_labels, 1);

    map(class_model) = map_val;
end
disp(map)