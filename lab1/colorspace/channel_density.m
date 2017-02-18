% Plots the empirical distribution of image intensities in a set of
% channels
function channel_density(channels, labels, plot_label)
% Input format should be (vector_1, vector_2, ..., vector_n, {'label_1', 'label_2', ..., 'label_n'}, 'plot_title')

figure;

for i=1:numel(channels)

    [f,xi] = ksdensity(channels{i}(:)); % Kernel density estimate
    plot(xi,f);
    hold on;

end

hold off;
legend(labels, 'FontSize', 18);
xlabel('Image Intensity', 'FontSize', 18);
ylabel('Frequency', 'FontSize', 18);
axis([0,1,-inf,inf]);

print(strcat('./figs/',plot_label),'-dpng');
end