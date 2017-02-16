function [ albedo, normal, p, q ] = compute_surface_gradient( stack_images, scriptV )
%COMPUTE_SURFACE_GRADIENT compute the gradient of the surface
%   stack_image : the images of the desired surface stacked up on the 3rd
%   dimension
%   scriptV : matrix V (in the algorithm) of source and camera information
%   albedo : the surface albedo
%   normal : the surface normal
%   p : measured value of df / dx
%   q : measured value of df / dy

stack_images = double(stack_images);

W = size(stack_images, 1);
H = size(stack_images, 2);
n_images = size(stack_images, 3);

% create arrays for 
%   albedo, normal (3 components)
%   p measured value of df/dx, and
%   q measured value of df/dy
albedo = zeros(W, H, 1);
normal = zeros(W, H, 3);
p = zeros(W, H);
q = zeros(W, H);

% TODO: Your code goes here
% for each point in the image array
%   stack image values into a vector i
%   construct the diagonal matrix scriptI
%   solve scriptI * scriptV * g = scriptI * i to obtain g for this point
%   albedo at this point is |g|
%   normal at this point is g / |g|
%   p at this point is N1 / N3
%   q at this point is N2 / N3


for w = 1:W
    for h = 1:H
        i = reshape(stack_images(w,h,:),n_images,1);
        scriptI = diag(i);
        g = pinv(scriptI * scriptV) * (scriptI * i);
        albedo(w,h) = norm(g);
        normal(w,h,:) = g / albedo(w,h);
        p(w,h) = -normal(w,h,1) / normal(w,h,3);
        q(w,h) = -normal(w,h,2) / normal(w,h,3);
    end
end



end

