function [new_background, new_object] = imagepaste(background,object)
% IMAGEPASTE takes two images, beckground and object, and put them together
% as one image. The size of resulting image is the same as background
% image, and object size is adjusted to the size of background.

% Background is double image and object is double image, with non-object
% region set to 1.


    for i = 1:size(object, 1)
        for j = 1:size(object, 2)
            if all(object(i, j, :) == 1)
                object(i, j, :) = NaN;
            else
                break;
            end
        end
    end

    for i = 1:size(object, 1)
        for j = size(object, 2):-1:1
            if all(object(i, j, :) == 1)
                object(i, j, :) = NaN;
            else
                break;
            end
        end
    end

    %set non-object region of object to 0
    object(isnan(object))=0;

    %add them together
    new_background = background;
    new_object = object;

end

