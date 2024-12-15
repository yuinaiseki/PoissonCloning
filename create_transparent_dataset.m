
% Image locations for objects and backgrounds
base_path_obj = 'transparent_source/objects/';
base_path_bg = 'transparent_source/backgrounds/';

% set up matrix - 4 images for objects and 3 images for backgrounds
obj = zeros(400, 600, 3, 4);
alpha = zeros(400, 600, 4);
bg =  zeros(400, 600, 3, 3);

% load all images and save into matrix
obj_names = ["bunny", "sibley", "wings", "zodiac"];
for i= 1:4
    [inpict,~,alpha] = imread(strcat(base_path_obj, obj_names(i), ".png"));
    obj(:,:,:,i) = im2double(inpict);
    alpha(:,:,i) = im2double(alpha);
end


bg_names = ["old_paper", "raspberry_books", "ruled_paper"];
for i= 1:3
    bg(:,:,:,i) = im2double(imread(strcat(base_path_bg, bg_names(i), ".png")));
end

% use montage to show all image in the dataset
figure;
montage(bg, 'Size', [2 2]);
figure;
montage(obj, 'Size', [2 2]);
figure;
montage(alpha, 'Size', [2 2]);


% Set non-object part to NaN. For each pixels from left, turn the pixels to 0
% until we find a pixel such that not(all(r,g,b>0.95)).
obj_logical = zeros(400, 600, 4);
obj_N = zeros(400, 600, 4);
for img = 1:4
    object = obj(:,:,:,img);
    for i = 1:size(object, 1)
        for j = 1:size(object, 2)
            if all(object(i, j, :) > 0.95)
                object(i, j, :) = NaN;
            else
                break;
            end
        end
    end

    % do it from the right side of image too. Note that this is not the
    % perfect trimming algorithm, but we can remove most of white
    % backgrounds while keeping white elements in the actual object.
    for i = 1:size(object, 1)
        for j = size(object, 2):-1:1
            if all(object(i, j, :) > 0.95)
                object(i, j, :) = NaN;
            else
                break;
            end
        end
    end

    obj(:,:,:,img) = object;
    logical_mask = true(size(object,1), size(object,2));
    logical_mask(isnan(object(:,:,1))) = false;
    % make it to logical matrix
    obj_logical(:,:,img) = logical_mask;

    % The value of N matrix shows how many of adjacent pixels are objects.
    % So the value is between 0(no adjecency with object) to 4 (completely
    % inside the object).
    % convolution to get N matrix
    kernel = [0 1 0; 1 0 1; 0 1 0];
    N = conv2(obj_logical(:,:,img), kernel, 'same');
    obj_N(:,:,img) = N;
end

% saving matrices as files
save('mat/transparent/objects.mat', 'obj');
save('mat/transparent/backgrounds.mat', 'bg');
save('mat/transparent/objects_logical.mat', 'obj_logical');
save('mat/transparent/objects_N.mat', 'obj_N');
save('mat/transparent/alpha.mat', 'alpha');
