function [trainset, testset] = get_svm_data(data, net)

    trainset.labels = [];
    trainset.features = [];

    testset.labels = [];
    testset.features = [];
    for i = 1:size(data.images.data, 4)

        res = vl_simplenn(net, data.images.data(:, :,:, i));
        feat = res(end-3).x; feat = squeeze(feat);

        if(data.images.set(i) == 1)
            trainset.features = [trainset.features feat];
            trainset.labels   = [trainset.labels;  data.images.labels(i)];
        else
            testset.features = [testset.features feat];
            testset.labels   = [testset.labels;  data.images.labels(i)];
        end

    end

    trainset.labels = double(trainset.labels);
    trainset.features = sparse(double(trainset.features'));

    testset.labels = double(testset.labels);
    testset.features = sparse(double(testset.features'));

end