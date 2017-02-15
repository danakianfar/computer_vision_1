function visualize(varargin)
for i = 1:nargin-1
    subplot(2, ceil((nargin-1)/2),i);
    imshow(varargin{i});
    title(varargin{end}(i))
end

