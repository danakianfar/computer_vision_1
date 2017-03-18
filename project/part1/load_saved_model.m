function [model] = load_saved_model(fpath)
    tmp = load(fpath,'-mat');
    model = tmp.model;
end