function [model] = execute_classification(bow_features, targets, classifier)
%execute_classification Run a linear SVM classifier.
%
%   MODEL = EXECUTE_CLASSIFICATION(BOW_FEATURES, TARGETS, CLASSIFIER)
%   returns a classifier trained on the input data.
%
% Inputs:
%   BOW_FEATURES: An NxP matrix, where N is the number of images and P is
%   the dimensionality of each BoW feature (number of visual words).
%   TARGETS: Nx1 vector of labels for each image 
%   CLASSIFIER: Classification method, can be one of 'liblinear' or ..
%
% Outputs:
%   model: trained classifier
%
%See also:
% get_bow_with_labels

    switch(classifier)
        case 'liblinear'
            C = train(targets, sparse(bow_features) ,'-C -s 0');
            model = train(targets, sparse(bow_features) , sprintf('-c %f -s 0', C(1)));
        case 'libsvm-poly'
            model = fitcsvm(bow_features, targets, 'KernelFunction', 'polynomial');
        case 'libsvm-rbf'
            model = fitcsvm(bow_features, targets, 'KernelFunction', 'rbf');
    end
end