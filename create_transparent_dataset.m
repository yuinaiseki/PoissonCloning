
% Image locations for objects and backgrounds
base_path_obj = 'source_images/transparent/objects/';
base_path_bg = 'source_images/transparent/backgrounds/';

bg_names = ["old_paper", "raspberry_books", "ruled_paper"];
for i= 1:3
    bg = im2double(imread(strcat(base_path_bg, bg_names(i), ".png")));
    save(strcat("mat/transparent/backgrounds/", bg_names(i), ".mat"), 'bg');
end


% load all images and save into matrix
obj_names = ["bunny", "sibley", "wings", "zodiac"];
for i= 1:4
    [I,~,alpha] = imread(strcat(base_path_obj, obj_names(i), ".png"));
    I = im2double(I);
    alpha = im2double(alpha);

    background = ones(size(I));
    alpha_3 = repmat(alpha, [1 1 3]);

    % output = image * alpha + background * (1 - alpha)
    composite = I .* alpha_3 + background .* (1 - alpha_3);


    composite_nan = composite;
    composite_nan(composite(:,:,1) > 0.95) = NaN;



    logical_mask = true(size(composite_nan,1), size(composite_nan,2));
    logical_mask(isnan(composite_nan(:,:,1))) = false;
    % make it to logical matrix
    
    % The value of N matrix shows how many of adjacent pixels are objects.
    % So the value is between 0(no adjecency with object) to 4 (completely
    % inside the object).
    % convolution to get N matrix
    kernel = [0 1 0; 1 0 1; 0 1 0];
    N = conv2(logical_mask, kernel, 'same');

    save(strcat("mat/transparent/objects/", obj_names(i), ".mat"), 'I', 'alpha', 'composite', 'N', 'logical_mask', 'composite_nan');
end