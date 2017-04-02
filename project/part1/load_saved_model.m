function [model] = load_saved_model(type, num_centroids, density, colorspace, classifier, class)
    
    switch type 
        case 'clustering'
            fpath = './data/clusters';
        case 'classification'
            fpath = './data/classifiers';
    end 

    if nargin < 5
        fpath = char(compose('%s/K-%d_D-%s_c-%s.struct', fpath, num_centroids, density, colorspace));   
    else
        fpath = char(compose('%s/bin-%d_K-%d_D-%s_c-%s_%s.struct', fpath, class, num_centroids, density, colorspace, classifier));   
    end
    
    model = load_saved_model_from_path(fpath);
end