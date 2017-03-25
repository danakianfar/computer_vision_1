%% Run this script to pre-process images and save to disk
function data_preprocessing()
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

    disp('Pre-processing training data');
    save_images_to_files(training_paths, labels, true);
    
    disp('Pre-processing testing data');
    save_images_to_files(testing_paths, labels, false);
end