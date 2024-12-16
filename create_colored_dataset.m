
% Image locations for objects and backgrounds
base_path_obj = 'source_images/colored/objects/';
base_path_bg = 'source_images/colored/backgrounds/';

% load background images and save into matrix
bg_names = ["fall_road", "grass", "mountains", "ocean"];
for i= 1:4
    bg = im2double(imread(strcat(base_path_bg, bg_names(i), ".jpg")));
    save(strcat("mat/colored/backgrounds/", bg_names(i), ".mat"), 'bg');
end


obj_names = ["raft", "dog", "cowboy", "bird", "deer", "monkey", "person"];
% Set non-object part to NaN. For each pixels from left, turn the pixels to 0
% until we find a pixel such that not(all(r,g,b>0.95)).
for img_i = 1:7
    obj = im2double(imread(strcat(base_path_obj, obj_names(img_i), ".jpg")));
    for i = 1:size(obj, 1)
        for j = 1:size(obj, 2)
            if all(obj(i, j, :) > 0.95)
                obj(i, j, :) = NaN;
            else
                break;
            end
        end
    end

    % do it from the right side of image too. Note that this is not the
    % perfect trimming algorithm, but we can remove most of white
    % backgrounds while keeping white elements in the actual object.
    for i = 1:size(obj, 1)
        for j = size(obj, 2):-1:1
            if all(obj(i, j, :) > 0.95)
                obj(i, j, :) = NaN;
            else
                break;
            end
        end
    end

    logical_mask = true(size(obj,1), size(obj,2));
    logical_mask(isnan(obj(:,:,1))) = false;
    % make it to logical matrix

    % The value of N matrix shows how many of adjacent pixels are objects.
    % So the value is between 0(no adjecency with object) to 4 (completely
    % inside the object).
    % convolution to get N matrix
    kernel = [0 1 0; 1 0 1; 0 1 0];
    N = conv2(logical_mask, kernel, 'same');
    save(strcat("mat/colored/objects/", obj_names(img_i), ".mat"), 'obj', 'N', 'logical_mask');
end