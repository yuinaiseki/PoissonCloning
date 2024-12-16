function [new_background, new_object] = ImagePaste(background, object, x, y)
% IMAGEPASTE Pastes an object image onto a background image at specified coordinates
%
%   [NEW_BACKGROUND, NEW_OBJECT] = IMAGEPASTE(BACKGROUND, OBJECT, X, Y) overlays 
%   an object image onto a background image at the specified position (X,Y).
%
%   Inputs:
%       BACKGROUND - MxNxC double array representing the background image
%                   where M and N are dimensions and C is number of color channels
%       OBJECT    - PxQxC double array representing the object image, where
%                   non-object regions are marked as NaN
%       X         - Vertical offset (row position) for pasting the object
%       Y         - Horizontal offset (column position) for pasting the object
%
%   Outputs:
%       NEW_BACKGROUND - MxNxC double array, background image with object 
%                       regions set to 0
%       NEW_OBJECT    - MxNxC double array, object image positioned at (X,Y) 
%                       with NaN regions set to 0
%
%   Notes:
%   - The function preserves the size of the background image
%   - object image should be equal to or smaller than background image
%   - X and Y specify the top-left corner position where object will be pasted
%   - Function will throw an error if object placement exceeds background boundaries
%   - Required: X+P ≤ M and Y+Q ≤ N where P,Q are object dimensions
%
%   Example:
%       bg = imread('background.jpg');
%       obj = imread('object.png');
%       [new_bg, new_obj] = ImagePaste(bg, obj, 100, 150);

    if x < 0 || y < 0
        error('X and Y must be positive');
    end

    % Validate that object placement won't exceed background boundaries
    if x + size(object, 1) > size(background, 1) || y + size(object, 2) > size(background, 2)
        error('Object image exceeds the boundaries of the background image');
    end

    %initialize base image
    new_object = nan(size(background));

    for i = 1:size(object,1)
        for j = 1:size(object,2)
            new_object(i+x,j+y,:) = object(i,j,:); %paste object to base with given offset
        end
    end

    %set object region of background to 0
    mask = ~isnan(new_object(:,:,1)); % Use first channel for mask
    for c = 1:size(background,3)
        background_channel = background(:,:,c);
        background_channel(mask) = 0;
        new_background(:,:,c) = background_channel;
    end

    %set non-object region of object to 0
    new_object(isnan(new_object)) = 0;

end

