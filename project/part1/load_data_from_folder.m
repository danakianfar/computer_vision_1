function [data] = load_data_from_folder (folder_path, num_samples)
    
    files = dir(folder_path);
    files = {files.name};
    files = files{3:end};
    
    data = cell(1,length(files));
    
    if nargin > 1 && num_samples > 0
        files =  randsample(files, num_samples);
    end
    
    for f=1:length(files)
        data{f} = load(files{f});
    end

end