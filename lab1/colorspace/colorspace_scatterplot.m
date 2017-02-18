function colorspace_scatterplot(colorspace, reference_img, axes_labels, plot_label)
    % Get 3 different channels
    A = colorspace(:,:,1);
    B = colorspace(:,:,2);
    C = colorspace(:,:,3);

    colors = double(reshape(reference_img,[],size(reference_img,3),1)); % normalized reshaped image

    %#projection on the X-Z plane
    f = figure('Position', [100, 100, 1500, 500]);
    axesHandles = findobj(get(f,'Children'), 'flat','Type','axes');
    % Set the axis property to square
    axis(axesHandles,'square')
    subplot(1,3,1)
    scatter3(A(:), B(:), C(:), 10, colors, 'filled');
    xlabel(axes_labels(1), 'FontSize', 18)
    ylabel(axes_labels(2), 'FontSize', 18)
    zlabel(axes_labels(3), 'FontSize', 18)
    view([0,0])
    %print(char(string(plot_label)+'_XZ'),'-dpng')

    %#projection on the Y-Z plane
    subplot(1,3,2)
    scatter3(A(:), B(:), C(:), 10, colors, 'filled');
    xlabel(axes_labels(1), 'FontSize', 18)
    ylabel(axes_labels(2), 'FontSize', 18)
    zlabel(axes_labels(3), 'FontSize', 18)
    view([90,0])
    %print(char(string(plot_label)+'_YZ'),'-dpng')

    %#projection on the X-Y plane
    subplot(1,3,3)
    scatter3(A(:), B(:), C(:), 10, colors, 'filled');
    xlabel(axes_labels(1), 'FontSize', 18)
    ylabel(axes_labels(2), 'FontSize', 18)
    zlabel(axes_labels(3), 'FontSize', 18)
    view([0,90])
    
    print(strcat('./figs/',plot_label,'_scatter'),'-dpng');

end