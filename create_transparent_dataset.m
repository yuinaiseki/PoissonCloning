function create_transparent_dataset()
%CREATE_TRANSPARENT_DATASET Preprocesses transparent PNG images and saves as MAT files
%   This function processes transparent PNG images from source directories and saves
%   them as MAT files with various computed matrices for mixed gradient Poisson image editing.
%
%   The function performs the following:
%   1. Processes background images from 'source_images/transparent/backgrounds/'
%      - Saves as MAT files in 'mat/transparent/backgrounds/'
%      - Each file contains: bg (400x600x3 double)
%
%   2. Processes object images from 'source_images/transparent/objects/'
%      - Saves as MAT files in 'mat/transparent/objects/'
%      - Each file contains:
%        * I: Original image (400x600x3 double)
%        * alpha: Alpha channel (400x600 double)
%        * composite: Image with white background (400x600x3 double)
%        * N: Adjacency matrix (400x600 double)
%        * logical_mask: Object mask (400x600 logical)
%        * composite_nan: Image with NaN background (400x600x3 double)
%   CSC262 Final Project: Poisson Image Editing
%   Author: Shuta Shibue

    % Image locations for objects and backgrounds
    base_path_obj = 'source_images/transparent/objects/';
    base_path_bg = 'source_images/transparent/backgrounds/';

    % load background images and save into matrix
    % image path: source_images/transparent/backgrounds/background_name.png
    % destination path: mat/transparent/backgrounds/background_name.mat
    % format: bg, 400x600x3 double
    bg_names = ["old_paper", "raspberry_books", "ruled_paper"];
    for i= 1:3
        bg = im2double(imread(strcat(base_path_bg, bg_names(i), ".png")));
        save(strcat("mat/transparent/backgrounds/", bg_names(i), ".mat"), 'bg');
    end


    % load all images and save into matrix
    % image path: source_images/transparent/objects/object_name.png
    % destination path: mat/transparent/objects/object_name.mat
    % format: I, 400x600x3 double
    %         alpha, 400x600 double
    %         composite, 400x600x3 double
    %         N, 400x600 double
    %         logical_mask, 400x600 logical
    %         composite_nan, 400x600x3 double
    obj_names = ["bunny", "sibley", "wings", "zodiac"];
    for i= 1:4

        % load image and alpha
        [I,~,alpha] = imread(strcat(base_path_obj, obj_names(i), ".png"));
        I = im2double(I);
        alpha = im2double(alpha);

        % create background image with alpha channel
        background = ones(size(I));
        alpha_3 = repmat(alpha, [1 1 3]);

        % output = image * alpha + background * (1 - alpha)
        composite = I .* alpha_3 + background .* (1 - alpha_3);

        % set non-object part to NaN
        composite_nan = composite;
        composite_nan(composite(:,:,1) > 0.99) = NaN;

        % create logical mask
        logical_mask = true(size(composite_nan,1), size(composite_nan,2));
        logical_mask(isnan(composite_nan(:,:,1))) = false;
        
        % The value of N matrix shows how many of adjacent pixels are objects.
        % So the value is between 0(no adjecency with object) to 4 (completely
        % inside the object).
        % convolution to get N matrix
        kernel = [0 1 0; 1 0 1; 0 1 0];
        N = conv2(logical_mask, kernel, 'same');

        % save all variables
        save(strcat("mat/transparent/objects/", obj_names(i), ".mat"), 'I', 'alpha', 'composite', 'N', 'logical_mask', 'composite_nan');
    end
end
