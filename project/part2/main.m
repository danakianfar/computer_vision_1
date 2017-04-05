%% Computer Vision 1 
%
% Project Part 2: Convolutional Neural Networks
% Authors: Dana Kianfar - Jose Gallego
%
% Make sure you run VLFEAT setup and LibLinear beforehand.

%% Windows Ubuntu

run('C:\Users\Dana\.src\vlfeat-0.9.20\toolbox\vl_setup')
addpath('C:\Users\Dana\.src\liblinear-2.1\matlab\')
addpath('C:\Users\Dana\.src\matconvnet-1.0-beta23\matlab')
run('C:\Users\Dana\.src\matconvnet-1.0-beta23\matlab\vl_setupnn')
% vl_compilenn('enableGpu', true, 'cudaRoot', 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v8.0', 'cudaMethod', 'nvcc', 'enableCudnn', true, 'cudnnRoot', 'local/cudnn-rc4') ;

%% Setup Ubuntu

run('../../../../vlfeat/toolbox/vl_setup')
run('../../../../matconvnet/matlab/vl_setupnn')
addpath('../../../../matconvnet/matlab')
addpath('../../../../liblinear-2.1/matlab/')


%% Fine-tune CNN

% The imdb-caltech.mat file has been removed from the submission folder due
% to its size. It should be created again after runing finetune_cnn();

[net, info, expdir] = finetune_cnn();

%% Hyper Parameter Tuning

clear, clc
expdir = 'data/cnn_assignment-lenet';

res_cell = {};
ix = 1;

for bs = 50:50:100
    for ep = 40:40:120
        nets.fine_tuned = load(fullfile(expdir, strcat('b',num2str(bs),'_e', num2str(ep),'.mat'))); 
        nets.fine_tuned = nets.fine_tuned.net;
        nets.pre_trained = load(fullfile('data', 'pre_trained_model.mat')); 
        nets.pre_trained = nets.pre_trained.net; 
        data = load(fullfile(expdir, 'imdb-caltech.mat'));
        res_cell{ix} = train_svm(nets, data);
        ix = ix+1;
    end
end

clc

ix = 1;
for bs = 50:50:100
    for ep = 40:40:120
        disp('CNN: fine_tuned_accuracy   SVM: pre_trained_accuracy:  Fine_tuned_accuracy:')
        disp(strcat('b',num2str(bs),'_e', num2str(ep)))
        res_cell{ix}
        ix = ix+1;
    end
end

%% TSNE

clear, clc
expdir = 'data/cnn_assignment-lenet';

% Load networks
nets.fine_tuned = load(fullfile(expdir, 'b100_e80.mat')); 
nets.fine_tuned = nets.fine_tuned.net;
nets.pre_trained = load(fullfile('data', 'pre_trained_model.mat')); 
nets.pre_trained = nets.pre_trained.net; 
nets.pre_trained.layers{end}.type = 'softmax';
nets.fine_tuned.layers{end}.type = 'softmax';

% Load data
data = load(fullfile(expdir, 'imdb-caltech.mat'));

% Extract features
[svm.pre_trained.trainset, svm.pre_trained.testset] = get_svm_data(data, nets.pre_trained);
[svm.fine_tuned.trainset,  svm.fine_tuned.testset] = get_svm_data(data, nets.fine_tuned);

addpath('tsne')

% Run TSNE
figure1 = figure('Color',[1 1 1]);
tsne_pre = tsne(vertcat(svm.pre_trained.trainset.features,svm.pre_trained.testset.features),  vertcat(svm.pre_trained.trainset.labels, svm.pre_trained.testset.labels));
savefig('results/tsne_pre.fig')
figure2 = figure('Color',[1 1 1]);
tsne_fine = tsne(vertcat(svm.fine_tuned.trainset.features,svm.fine_tuned.testset.features),  vertcat(svm.fine_tuned.trainset.labels, svm.fine_tuned.testset.labels));
savefig('results/tsne_fine.fig')


%% Data Augmentation

expdir = 'data/cnn_assignment-lenet';
nets.fine_tuned = load(fullfile(expdir, 'b100_e80.mat')); 
nets.fine_tuned = nets.fine_tuned.net;
nets.pre_trained = load(fullfile('data', 'pre_trained_model.mat')); 
nets.pre_trained = nets.pre_trained.net; 
data = load(fullfile(expdir, 'imdb-caltech.mat'));
train_svm(nets, data);

%% Freezing Early Layers

expdir = 'data/cnn_assignment-lenet';
nets.fine_tuned = load(fullfile(expdir, 'frozen.mat')); 
nets.fine_tuned = nets.fine_tuned.net;
nets.pre_trained = load(fullfile('data', 'pre_trained_model.mat')); 
nets.pre_trained = nets.pre_trained.net; 
data = load(fullfile(expdir, 'imdb-caltech.mat'));
train_svm(nets, data);

%% Dropout

expdir = 'data/cnn_assignment-lenet';
nets.fine_tuned = load(fullfile(expdir, 'dropout.mat')); 
nets.fine_tuned = nets.fine_tuned.net;
nets.pre_trained = load(fullfile('data', 'pre_trained_model.mat')); 
nets.pre_trained = nets.pre_trained.net; 
data = load(fullfile(expdir, 'imdb-caltech.mat'));
train_svm(nets, data);

%% Filter Visualization
% The explanation on how to show this was found on the Matconvnet docs.

% Fine-tuned
expdir = 'data/cnn_assignment-lenet';
net = load(fullfile(expdir, 'b100_e80.mat')); 

figure1 = figure('Color',[1 1 1]) ; clf ; colormap gray ;
vl_imarraysc(squeeze(net.net.layers{1}.weights{1}),'spacing',2)
axis equal ;
title('Fine-Tuned - Filters in the first layer') ;

% Alex-Net
% We remove this file from the submission folder due to its size
net = load(fullfile('data', 'imagenet-matconvnet-alex.mat'));

sigure2 = figure('Color',[1 1 1]) ; clf ; colormap gray ;
vl_imarraysc(squeeze(net.params(1).value),'spacing',2)
axis equal ;
title('AlexNet - Filters in the first layer') ;