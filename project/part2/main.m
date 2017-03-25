%% Computer Vision 1 
%
% Project Part 2: Convolutional Neural Networks
% Authors: Dana Kianfar - Jose Gallego
%
% Make sure you run VLFEAT setup beforehand.
run('C:\Users\Dana\.src\vlfeat-0.9.20\toolbox\vl_setup')
% Also for LibLinear
addpath('C:\Users\Dana\.src\liblinear-2.1\matlab\')
addpath('C:\Users\Dana\.src\matconvnet-1.0-beta23\matlab')
run('C:\Users\Dana\.src\matconvnet-1.0-beta23\matlab\vl_setupnn')
% vl_compilenn('enableGpu', true, 'cudaRoot', 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v8.0', 'cudaMethod', 'nvcc', 'enableCudnn', true, 'cudnnRoot', 'local/cudnn-rc4') ;
%% fine-tune cnn

[net, info, expdir] = finetune_cnn();

%% extract features and train svm


nets.fine_tuned = load(fullfile(expdir, 'net-epoch-34.mat')); nets.fine_tuned = nets.fine_tuned.net;
nets.pre_trained = load(fullfile('data', 'pre_trained_model.mat')); nets.pre_trained = nets.pre_trained.net; 
data = load(fullfile(expdir, 'imdb-caltech.mat'));


%%
train_svm(nets, data);


%%
%net = load(fullfile('data', 'imagenet-vgg-verydeep-16.mat'));

net = load(fullfile('data', 'imagenet-matconvnet-alex.mat'));

%%

% obtain and preprocess an image
im = imread('../Caltech4/ImageData/faces_train/img011.jpg') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;

% run the CNN
res = vl_simplenn(net, im_) ;

% show the classification result
scores = squeeze(gather(res(end).x)) ;
[bestScore, best] = max(scores) ;

figure(1) ; clf ; imagesc(im) ;
title(sprintf('%s (%d), score %.3f',...
  net.meta.classes.description{best}, best, bestScore)) ;