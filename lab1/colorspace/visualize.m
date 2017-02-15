function visualize(varargin)
% Displays a set of images. The format should be 
% visualize(im_1, ..., im_n, {'label_1', ..., 'label_n'})

if nargin <= 3
    row_num = 1;
    col_num = nargin-1;
else
    row_num = 2;
    col_num = ceil((nargin-1)/2);
end

for i = 1:nargin-1
    subplot(row_num, col_num, i);
    imshow(varargin{i});
    title(varargin{end}(i))
end

