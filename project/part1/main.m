%% Computer Vision 1 
%
% Project Part 1: Image Classfication
% Authors: Dana Kianfar - Jose Gallego
%
% Make sure you run VLFEAT setup beforehand.
% run('C:\Users\Dana\.src\vlfeat-0.9.20\toolbox\vl_setup')
%% RESET
close all, clear all, clc

% Params
num_img_samples = 0; % Number of images to sample for training. Use 0 to retrieve all.
K = [400, 800, 1600, 2000, 4000];
densities = {'dense', 'key'};
colorspace = {'Gray', 'RGB', 'rgb', 'HSV', 'Opp'};

%% Extract Features 


%% Perform Clustering
% Load features

S1_feats = load_data_from_folder('./data/training/clustering', num_img_samples);



%% Perform Classification

% Load features
S2_feats = load_data_from_folder('./data/training/classification', num_img_samples);
