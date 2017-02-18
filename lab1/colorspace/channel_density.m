function channel_density(channels, labels, plot_label)
figure;

for i=1:numel(channels)

    [f,xi] = ksdensity(channels{i}(:));
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