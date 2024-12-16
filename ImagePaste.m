function [new_background, new_object, object_logical] = ImagePaste(background,object)
% IMAGEPASTE takes two images, beckground and object, and put them together
% as one image. The size of resulting image is the same as background
% image, and object size is adjusted to the size of background.

% Background is double image and object is double image, with non-object
% region set to 1.

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

