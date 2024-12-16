function create_colored_dataset()
% CREATE_COLORED_DATASET Preprocesses and saves colored images for Poisson blending
%   This function processes source images and creates necessary data files for 
%   Poisson image blending experiments. It handles both background and object images for data used in poisson blending.
%
%   The function performs the following operations:
%   1. Loads and processes background images, saving them as .mat files
%   2. Loads object images and creates:
%      - Object matrix with white background removed (set to NaN)
%      - Logical mask indicating object pixels
%      - Adjacency matrix N showing number of neighboring object pixels
%
%   Input images should be in:
%   - Background images: source_images/colored/backgrounds/
%   - Object images: source_images/colored/objects/
%
%   Output .mat files are saved to:
%   - Background: mat/colored/backgrounds/
%   - Objects: mat/colored/objects/
%
%   Each object .mat file contains:
%   - obj: 400x600x3 double, image with non-object pixels as NaN
%   - logical_mask: 400x600 logical, true for object pixels
%   - N: 400x600 double, adjacency count matrix
%
%   Each background .mat file contains:
%   - bg: 400x600x3 double, background image
%   CSC262 Final Project: Poisson Image Editing
%   Author: Shuta Shibue

    % Image locations for objects and backgrounds
    base_path_obj = 'source_images/colored/objects/';
    base_path_bg = 'source_images/colored/backgrounds/';

    % load background images and save into matrix
    % image path: source_images/colored/backgrounds/background_name.jpg
    % destination path: mat/colored/backgrounds/background_name.mat
    % format: bg, 400x600x3 double
    bg_names = ["fall_road", "grass", "mountains", "ocean"];
    for i= 1:4
        bg = im2double(imread(strcat(base_path_bg, bg_names(i), ".jpg")));
        save(strcat("mat/colored/backgrounds/", bg_names(i), ".mat"), 'bg');
    end


    obj_names = ["raft", "dog", "cowboy", "bird", "deer", "monkey", "person"];
    % load background images and save into matrix
    % path: source_images/colored/objects/object_name.jpg
    % format:   obj, 400x600x3 double
    %           logical_mask, 400x600 logical
    %           N, 400x600 double
    for img_i = 1:7
        obj = im2double(imread(strcat(base_path_obj, obj_names(img_i), ".jpg")));


        % Set non-object part to NaN. For each pixels from left, turn the pixels to 0
        % until we find a pixel such that not(all(r,g,b>0.95)).
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

        % make it to logical matrix with true for object and false for non-object
        logical_mask = true(size(obj,1), size(obj,2));
        logical_mask(isnan(obj(:,:,1))) = false;

        % The value of N matrix shows how many of adjacent pixels are objects.
        % So the value is between 0(no adjecency with object) to 4 (completely
        % inside the object).
        % convolution to get N matrix
        kernel = [0 1 0; 1 0 1; 0 1 0];
        N = conv2(logical_mask, kernel, 'same');

        % save the object, N, and logical_mask
        save(strcat("mat/colored/objects/", obj_names(img_i), ".mat"), 'obj', 'N', 'logical_mask');
    end
end
