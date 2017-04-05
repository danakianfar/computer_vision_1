function save_images_to_files(paths, labels, is_training_set)
    
    % Lever defines if the point will be used for classifier training or
    % for vocabulary construction
%     lever = 0;
    training_path = './data/training';
    testing_path = './data/testing';
    dataset = {'classification','clustering'};
    
    parfor i=1:length(paths)
        if mod(i,200) == 0
           disp(compose('%d/%d images processed.', i, length(paths))) 
        end
        
       image = struct;
       image.path = paths{i};

       % Assign label
       for l=1:length(labels)
            if strfind(image.path, labels{l}) > 1
                image.label = l; 
                image.label_name = labels{l}; 
                break;
            end
       end
        
       % Generate SIFT descriptor
       im_data = imread(image.path);
       
       if size(im_data, 3) == 1 % if an grayscale image, just replicate channel
          im_data = repmat(im_data,1,1,3);
       end
       
       
       [dense_desc, key_desc] = extract_descriptors(im_data);
       image.dense = dense_desc;
       image.key = key_desc;
       
       image.hog = vl_hog(im2single(im_data), 35);

       % Save
       if is_training_set
           lever = mod(i,2);
           fpath = char(compose('%s/%s/%s_%d.struct', training_path, dataset{lever+1}, image.label_name, i));
       else
           fpath = char(compose('%s/%s_%d.struct', testing_path, image.label_name, i));
       end
       
       parsave(fpath, image)
    end
end