function [ dense_desc, key_desc ] = extract_descriptors(im)
%EXTRACT_DESCRIPTORS Extracts dense and keypoints SIFT descriptors
%
%   [D, K] = EXTRACT_DESCRIPTORS(I) extracts dense D and keypoint K SIFT
%   descriptors for an image I in color spaces: grayscale, RGB, rgb, HSV
%   and opponent.
%
% Inputs:
%   I: RGB image tensor
%
% Outputs:
%   D: dense SIFT descriptors calculated every 10 pixels
%   K: SIFT descriptors at the keypoints detected using grayscale image

    % SIFT needs image to be single precision
    im = im2single(im);
    
    % Convert image to different color spaces
    im_cspaces = { rgb2gray(im), im, rgb2hsv(im), rgb2opp(im), rgb2norm(im)};
    
    % Execute keypoint SIFT on grayscale image
    % F (frames) is the location of the keypoints
    [F, ~] = vl_sift(im_cspaces{1});
    
    % Store the results of the descriptors for the image in the format:
    % --Dense--  {grayscale, RGB, HSV, opp, rgb}
    % -Keypoint- {grayscale, RGB, HSV, opp, rgb}
    
    % Execute SIFT
    dense_desc = apply_sift(im_cspaces, 'dense');
    key_desc = apply_sift(im_cspaces, 'keypoints', F);
    
end


% Function for applying dense SIFT on cell of several color spaces
function res = apply_sift(im_cell, method, F)
    
    % Number of color spaces used
    cspaces = size(im_cell,2);
    
    % Allocate size of result
    res = cell(1,cspaces);
    
    % For each color space find features
    for c = 1:cspaces
       
        % How many channels does this color space have?
        channel = size(im_cell{c},3);
        
        % Init empty array
        aux = [];
        
        % Concatenate descriptors on all channels
        for i = 1:channel
            
            % Check selected method
            if strcmp(method, 'keypoints')
                % If no frames provided for keypoints, detect frames per
                % channel
                if nargin < 3
                    [~,desc] = vl_sift(im_cell{c}(:,:,channel));
                else
                    [~,desc] = vl_sift(im_cell{c}(:,:,channel), 'frames',F);
                end
            elseif strcmp(method, 'dense')
                [~,desc] = vl_dsift(im_cell{c}(:,:,channel), 'step', 10);
            else
                error('Error: SIFT method  %s not understood', method);
            end
            
            % Concatenate descriptors
            aux = cat(1,aux,desc);
            
            if isempty(aux)
               disp('Empty!!') 
            end
        end
        
        % Save results
        res{1,c} = aux';
    end
end

% Functions for converting to different color spaces
function res = rgb2opp(im)
    
    [R, G, B] = divide_channels(im);

    % Convert to opponent space
    O1 = (R - G) ./ sqrt(2);
    O2 = (R + G - (2 * B)) ./ sqrt(6);
    O3 = (R + G + B) ./ sqrt(3);
    
    res = cat(3, O1, O2, O3);
end

function res = rgb2norm(im)

    [R, G, B] = divide_channels(im);
    
    % Intensity per pixel
    I = R + G + B;
    
    % Convert to normalized RGB
    r = R; %./ I;
    g = G; %./ I;
    b = B; %./ I;
    
    res = cat(3, r, g, b);
end

function [R, G, B] = divide_channels(im)

    % Divide image into channels
    R  = im(:,:,1);
    G  = im(:,:,2);
    B  = im(:,:,3);
end