function [Trimmed_bg, B, B_log, X, Y] = preprocess(A, B, B_log)
% PREPROCESS Crops and prepares images for Poisson image blending
%   [TRIMMED_BG, B, B_LOG, X, Y] = PREPROCESS(A, B, B_LOG) processes input
%   images for Poisson blending by cropping them to the region of interest
%   and preparing the mask.
%
%   Inputs:
%       A           - Background image of type double where object will be pasted
%       B           - Object image of type double to be pasted
%       B_LOG       - Logical mask of type double indicating object region (1s inside object, 0s outside)
%
%   Outputs:
%       TRIMMED_BG - Cropped region of background image of type double matching object size
%       B          - Cropped object image of type double
%       B_LOG      - Processed mask with eroded edges of type double
%       X          - vertical offset (top left corner row index) of type double to paste object 
%       Y          - horizontal offset (top left corner column index) of type double to paste object
%
%   The function performs the following steps:
%       1. Finds the bounding box of the object using the mask
%       2. Crops both the object image and mask to this bounding box
%       3. Processes the mask by clearing borders and eroding edges
%       4. Crops the background image to match the object dimensions
%
%   CSC262 Final Project: Poisson Image Editing
%   Author: Shuta Shibue, Yuina Iseki

    [r, c] = find(B_log == 1);
    r_max = max(r);         % getting highest/lowest location of object image boundary
    r_min = min(r);
    c_max = max(c);
    c_min = min(c);

    max_h = r_max - r_min;  % getting height/width of object image boundary
    max_w = c_max - c_min;
    
    % setting top left corner to crop images, given offset inputs
    pos_x = r_min;
    pos_y = c_min;

    B = imcrop(B, [pos_y pos_x max_w max_h]);   % cropping the object image

    B_log = imcrop(B_log, [pos_y pos_x max_w max_h]); % cropping mask

    % boundary condition
    B_log(1, :) = 0;        % making outer border of mask to match background image
    B_log(end, :) = 0;
    B_log(:, 1) = 0;
    B_log(:, end) = 0;  
    se = strel('disk', 5);  % eroding mask 
    B_log = imerode(B_log, se);

    % cutting out background image
    Trimmed_bg = A(r_min:r_max, c_min:c_max, :);

    % initializing the position/index to the top left corner of the bounding box, to
    % initialize a position to place the object for pasting
    X = r_min ;
    Y = c_min;
end