function visualize(varargin)
% Displays a set of images. The format should be 
% visualize(im_1, ..., im_n, {'label_1', ..., 'label_n'})

if nargin <= 3
    row_num = 1;
    col_num = nargin-2;
else
    row_num = 2;
    col_num = ceil((nargin-2)/2);
end

figure('Position', [10, 10, 1000, 800])
for i = 1:nargin-2
    subplot(row_num, col_num, i);
    imshow(varargin{i});
    title(varargin{end-1}(i), 'FontSize', 18);
end

fig = gcf;
%fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
set(gcf, 'PaperSize', [fig_pos(3) fig_pos(4)]);
fig.PaperSize = [fig_pos(3) fig_pos(4)];

lab = strcat('./figs/',varargin{end},'_subplots');
print(lab,'-dpng');