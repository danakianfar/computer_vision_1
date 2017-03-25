function [net, info, expdir] = finetune_cnn(varargin)

    %% Define options
    % run(fullfile(fileparts(mfilename('fullpath')), ...
    %   '..', '..', '..', 'matlab', 'vl_setupnn.m')) ;

    opts.modelType = 'lenet' ;
    [opts, varargin] = vl_argparse(opts, varargin) ;

    opts.expDir = fullfile('data', ...
      sprintf('cnn_assignment-%s', opts.modelType)) ;
    [opts, varargin] = vl_argparse(opts, varargin) ;

    opts.dataDir = './data/' ;
    opts.imdbPath = fullfile(opts.expDir, 'imdb-caltech.mat');
    opts.whitenData = true ;
    opts.contrastNormalization = true ;
    opts.networkType = 'simplenn' ;
    opts.train = struct() ;
    opts = vl_argparse(opts, varargin) ;
    if ~isfield(opts.train, 'gpus')
        opts.train.gpus = []; 
    end

    %opts.train.gpus = [1];  
    %opts.cudnn = true ;
    opts.nesterovUpdate = true ;
    
%     opts.errorFunction = 'multiclass';

    % Update model
    net = update_model();

    % Get Caltech data
    if exist(opts.imdbPath, 'file')
      imdb = load(opts.imdbPath) ;
    else
      imdb = getCaltechIMDB() ;
      mkdir(opts.expDir) ;
      save(opts.imdbPath, '-struct', 'imdb') ;
    end

    %%
    net.meta.classes.name = imdb.meta.classes(:)' ;

    % -------------------------------------------------------------------------
    %                                                                     Train
    % -------------------------------------------------------------------------

    trainfn = @cnn_train ;
    [net, info] = trainfn(net, imdb, getBatch(opts), ...
      'expDir', opts.expDir, ...
      net.meta.trainOpts, ...
      opts.train, ...
      'val', find(imdb.images.set == 2)) ;

    expdir = opts.expDir;
end
% -------------------------------------------------------------------------
function fn = getBatch(opts)
% -------------------------------------------------------------------------
    switch lower(opts.networkType)
      case 'simplenn'
        fn = @(x,y) getSimpleNNBatch(x,y) ;
      case 'dagnn'
        bopts = struct('numGpus', numel(opts.train.gpus)) ;
        fn = @(x,y) getDagNNBatch(bopts,x,y) ;
    end
end

function [images, labels] = getSimpleNNBatch(imdb, batch)
% -------------------------------------------------------------------------
    images = imdb.images.data(:,:,:,batch) ;
    labels = imdb.images.labels(1,batch) ;
    
    H = fspecial('gaussian');
    
    % Flip in left/right direction
    if rand < 0.3
        images=fliplr(images);
    % Apply random rotation
    elseif rand < 0.5        
        images = imrotate(images ,(0.5-rand)*30);
    elseif rand < 0.7
        images = imfilter(images,H,'replicate', 'same');
    end
    
end

% -------------------------------------------------------------------------
function imdb = getCaltechIMDB()
    % -------------------------------------------------------------------------
    % Preapre the imdb structure, returns image data with mean image subtracted
    classes = {'airplanes', 'cars', 'faces', 'motorbikes'};

    % Utility variables
    prefix = '../Caltech4/ImageData/';
    suffix = '.jpg';
    airplane_train_paths = read_file_lines('../Caltech4/ImageSets/airplanes_train.txt',prefix, suffix);
    airplane_test_paths = read_file_lines('../Caltech4/ImageSets/airplanes_test.txt',prefix, suffix);
    motorbike_train_paths = read_file_lines('../Caltech4/ImageSets/motorbikes_train.txt',prefix, suffix);
    motorbike_test_paths = read_file_lines('../Caltech4/ImageSets/motorbikes_test.txt',prefix, suffix);
    face_train_paths = read_file_lines('../Caltech4/ImageSets/faces_train.txt',prefix, suffix);
    face_test_paths = read_file_lines('../Caltech4/ImageSets/faces_test.txt',prefix, suffix);
    cars_train_paths = read_file_lines('../Caltech4/ImageSets/cars_train.txt',prefix, suffix);
    cars_test_paths = read_file_lines('../Caltech4/ImageSets/cars_test.txt',prefix, suffix);

    % label values correspond to position in array
    labels = {'airplane', 'car', 'face', 'motorbike'};

    % Aggregate paths
    training_paths = [airplane_train_paths; cars_train_paths; face_train_paths; motorbike_train_paths];
    testing_paths = [airplane_test_paths; cars_test_paths; face_test_paths; motorbike_test_paths ];

    % Initialize structs
    imdb = struct;
    imdb.images = struct;
    imdb.meta = struct;

    % Allocate memory
    imdb.images.data = zeros(32,32,3,length(training_paths) + length(testing_paths));
    imdb.images.labels = zeros(1,length(training_paths) + length(testing_paths));
    imdb.images.set = zeros(1,length(training_paths) + length(testing_paths));

    tr_img = vl_imreadjpeg(training_paths, 'Resize', [32, 32]);

    for i=1:length(training_paths)

        im_data = tr_img{i};

        if size(im_data, 3) == 1 % if an grayscale image, just replicate channel
          im_data = repmat(im_data,1,1,3);
        end

       % Store image data
       imdb.images.data(:,:,:,i) = im_data; 

        % Assign label
        for l=1:length(labels)
            if strfind(training_paths{i}, labels{l}) > 1
                imdb.images.labels(i) = l; 
                break;
            end
        end

        % 1 for training
        imdb.images.set(i) = 1;    
    end

    tst_img = vl_imreadjpeg(testing_paths, 'Resize', [32, 32]);

    for i=1:length(testing_paths)

        im_data = tst_img{i};

        if size(im_data, 3) == 1 % if an grayscale image, just replicate channel
          im_data = repmat(im_data,1,1,3);
        end

       % Store image data
       imdb.images.data(:,:,:,i + length(training_paths)) = im_data; 

        % Assign label
        for l=1:length(labels)
            if strfind(testing_paths{i}, labels{l}) > 1
                imdb.images.labels(i + length(training_paths)) = l; 
                break;
            end
        end

        % 2 for testing
        imdb.images.set(i + length(training_paths)) = 2;    
    end

    % subtract mean
    dataMean = mean(imdb.images.data(:, :, :, imdb.images.set == 1), 4);
    data = bsxfun(@minus, imdb.images.data, dataMean);

    imdb.images.data = data;
    imdb.meta.sets = {'train', 'val'} ;
    imdb.meta.classes = classes;

    perm = randperm(numel(imdb.images.labels));
    imdb.images.data = single(imdb.images.data(:,:,:, perm)/255);
    imdb.images.labels = single(floor(imdb.images.labels(perm)));
    imdb.images.set = single(imdb.images.set(perm));
end
