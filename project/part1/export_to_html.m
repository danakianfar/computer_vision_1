function export_to_html ( colorspace, K, sampling, svm_kernel, map, airplane_map, car_map, face_map, motorbike_map, sorted_results)

    template = fileread('Template_Result.html');
    
    if strcmp(colorspace, 'RGB')
        colorspace = 'regular-RGB';
    end
        
    result = strrep(template, '%SIFT_STEP%', '10');
    result = strrep(result, '%SIFT_BLOCK%', '3');
    result = strrep(result, '%SIFT_METHOD%', colorspace);
    result = strrep(result, '%SAMPLING_METHOD%', sampling);
    result = strrep(result, '%VOCAB_SIZE%', int2str(K));
    result = strrep(result, '%VOCAB_FRAC%', '400/2000');
    result = strrep(result, '%SVM_POS%', '250');
    result = strrep(result, '%SVM_NEG%', '750');
    result = strrep(result, '%SVM_KERNEL%', svm_kernel);
    result = strrep(result, '%MAP%', compose('%.3f', map));
    result = strrep(result, '%AIRPLANE_MAP%', compose('%.3f', airplane_map));
    result = strrep(result, '%FACE_MAP%', compose('%.3f', face_map));
    result = strrep(result, '%MOTORBIKE_MAP%', compose('%.3f', motorbike_map));
    result = strrep(result, '%CAR_MAP%', compose('%.3f', car_map));
    
    x = '<tr><td><img src="%A%" /></td><td><img src="%C%" /></td><td><img src="%F%" /></td><td><img src="%M%" /></td></tr>\n';
    y = '';
    for i=1:length(sorted_results)
        tmp = strrep(x, '%A%', sorted_results(i,1));
        tmp = strrep(tmp, '%C%', sorted_results(i,2));
        tmp = strrep(tmp, '%F%', sorted_results(i,3));
        tmp = strrep(tmp, '%M%', sorted_results(i,4));
        y = strcat(y,tmp);
    end
    
    result = strrep(result, '%RESULTS%', y{1});
    
    result = strrep(result, '../', '');
    
    fid = fopen(char(compose('../color-%s_K-%d_sampling-%s_svm-%s.html', colorspace, K, sampling, svm_kernel)), 'wt');
    fprintf(fid, result);
    fclose(fid);
    
end