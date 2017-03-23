function[model] = load_saved_model_from_path(file_path)
    tmp = load(file_path,'-mat');
    model = tmp.model;
end