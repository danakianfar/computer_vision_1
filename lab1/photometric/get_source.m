function [ scriptV ] = get_source(scale_factor)
%GET_SOURCE compute illumination source property 
%   scale_factor : arbitrary 

if nargin == 0
    scale_factor = 1;
end

% TODO: define arbitrary direction to V

scriptV = [ 0, 0, 1;
            1, -1, 1;
           -1, -1, 1;
            1, 1, 1;
           -1, 1, 1];

% TODO: normalize V into scriptV
scriptV = bsxfun(@rdivide, scriptV, sqrt(sum(scriptV .* scriptV, 2)));

% scale up to scale factor before return
scriptV = scale_factor * scriptV;

end

