%% Computer Vision 1 
%
% Project Part 1: Image Classfication
% Authors: Dana Kianfar - Jose Gallego
%
% Make sure you run VLFEAT setup beforehand.
% run('C:\Users\Dana\.src\vlfeat-0.9.20\toolbox\vl_setup')
%% RESET
close all, clear all, clc

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

% Training images
training.images = cell(length(training_paths), 1);
for i=1:length(training_paths)
   image = struct;
   image.path = training_paths{i};
   image.img = imread(image.path);
   
   % assign label
   for l=1:length(labels)
        if strfind(image.path, labels{l}) > 1
            image.label = l; 
            image.label_name = labels{l};
            break;
        end
   end
   
   % generate SIFT descriptor
   if size(image.img,3) > 1
       tmp = rgb2gray(image.img);
   else
      tmp = image.img; 
   end
   sift = vl_sift(im2single(tmp));
   image.sift = sift(3:4,:);
end

% Test images
testing.images = cell(length(testing_paths), 1); 
for i=1:length(testing_paths)
   image = struct;
   image.path = testing_paths{i};
   image.img = imread(image.path);
   
   % assign label
   for l=1:length(labels)
        if strfind(image.path, labels{l}) > 1
            image.label = l; 
            image.label_name = labels{l}; break;
        end
   end
   
   % generate SIFT descriptor
   if size(image.img,3) > 1
       tmp = rgb2gray(image.img);
   else
      tmp = image.img; 
   end
   sift = vl_sift(im2single(tmp));
   image.sift = sift(3:4,:);
end

