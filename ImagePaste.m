function [new_background, new_object] = ImagePaste(background, object, x, y)
% IMAGEPASTE Combines a background image with an object image
%   [NEW_BACKGROUND, NEW_OBJECT] = IMAGEPASTE(BACKGROUND, OBJECT)
%   combines two images by overlaying the object on the background.
%
%   Inputs:
%       BACKGROUND - Double image to be used as background
%       OBJECT    - Double image to be overlaid, with non-object
%                   regions marked as NaN
%
%   Outputs:
%       NEW_BACKGROUND - Background image with object regions set to 0
%       NEW_OBJECT    - Object image with NaN regions set to 0
%
%   The function preserves the size of the background image. The object image
%   should be pre-scaled to match the desired size in the background.
%

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

