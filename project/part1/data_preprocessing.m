%% Run this script to pre-process images and save to disk
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

save_images_to_files(training_paths, true);
save_images_to_files(testing_paths, false);

function save_images_to_files(paths, labels, is_training_set)
    lever = 0;
    training_path = './data/training';
    testing_path = './data/testing';
    dataset = {'classification','clustering'};
    
    for i=1:length(paths)
       image = struct;
       image.path = paths{i};
    %    image.img = imread(image.path);

       % assign label
       for l=1:length(labels)
            if strfind(image.path, labels{l}) > 1
                image.label = l; 
                image.label_name = labels{l}; 
                break;
            end
       end

       % generate SIFT descriptor
       % JOSE LOOK HERE
       
       % Save
       if is_training_set
           fpath = compose('%s/%s/%s_%d.struct', training_path, dataset{lever+1}, image.label, i);
           lever = abs(lever-1);
       else
           fpath = compose('%s/%s_%d,struct', testing_path, image.label, i);
       end
       
       save(fpath, image, '-v6')
    end
end

