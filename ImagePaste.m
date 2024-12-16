function [new_background, new_object, object_logical] = ImagePaste(background, object)
% IMAGEPASTE Combines a background image with an object image
%   [NEW_BACKGROUND, NEW_OBJECT, OBJECT_LOGICAL] = IMAGEPASTE(BACKGROUND, OBJECT)
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
%       OBJECT_LOGICAL - Logical mask indicating object regions (true where
%                       object exists, false in NaN regions)
%
%   The function preserves the size of the background image. The object image
%   should be pre-scaled to match the desired size in the background.
%

    object_logical = true(size(object));
    %set non-object region of object to 0
    object_logical(isnan(object))=false;

    %set non-background region of background to 0
    background(object_logical)=0;
    
    object(isnan(object)) = 0;
    %add them together
    new_background = background;
    new_object = object;

end

