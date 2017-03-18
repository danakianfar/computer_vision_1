function [data, targets] = get_bows_with_labels(cell_of_structs, clustering_model)

    N = length(cell_of_structs);
    P = size(clustering_model.centroids,1);
    data = zeros();

    for i=1:length()
       image = cell_of_structs{i}; 
       bow = get_image_bow(image, clustering_model)
    end
end