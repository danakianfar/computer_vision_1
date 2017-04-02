net = load(fullfile('data', 'imagenet-vgg-verydeep-16.mat'));
net = vl_simplenn_tidy(net) ;

%%

% Obtain and preprocess an image.
im = imread('../Caltech4/ImageData/faces_train/img010.jpg') ;
im = imread('peppers.png') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;

% Run the CNN.
res = vl_simplenn(net, im_) ;

% Show the classification result.
scores = squeeze(gather(res(end).x)) ;
[bestScore, best] = max(scores) ;
figure(1) ; clf ; imagesc(im) ;
title(sprintf('%s (%d), score %.3f',...
   net.meta.classes.description{best}, best, bestScore)) ;


%%

clc
expdir = 'data/cnn_assignment-lenet';



nets.fine_tuned = load(fullfile(expdir, 'b100_e80.mat')); 
nets.fine_tuned = nets.fine_tuned.net;

net = load(fullfile('data', 'imagenet-matconvnet-alex.mat'));
net = vl_simplenn_tidy(net) ;
nets.pre_trained = net ;

data = load(fullfile(expdir, 'imdb-caltech.mat'));
train_svm(nets, data);