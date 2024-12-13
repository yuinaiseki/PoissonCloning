%% CSC 262 Project: Poisson Blending

% clearing workspace before running
close all; clear; clc;


%% Setting Up

% importing images and converting to double
 
load('mat/objects.mat')
load('mat/backgrounds.mat')

% a matrix of number of neighboring pixels in object image (N<=4 for boundary pixel)
load('mat/objects_N.mat')
load('mat/objects_logical.mat')

copy_paste = zeros(400, 600, 3, 28);

for i= 1:4
    for j = 1:7
        background = bg(:,:,:,i);
        object = obj(:,:,:,j);

        [new_background, new_object] = imagepaste(background, object);
        copy_paste(:,:,:,i*7+j) = new_background + new_object;
    end
end

 montage(copy_paste);

%% Poisson equation

A = bg(:,:,:,4);
B = obj(:,:,:,1);
B_log = obj_logical(:,:,1);
H = zeros(size(B));
N = obj_N(:, :, 2);

B_mask = zeros(size(B));
B_mask(:, :, 1) = B_log;
B_mask(:, :, 2) = B_log;
B_mask(:, :, 3) = B_log;

B_mask = rgb2gray(B_mask);

[r, c] = find(B_mask == 1);
r_max = max(r);
r_min = min(r);
c_max = max(c);
c_min = min(c);

max_h = r_max - r_min;
max_w = c_max - c_min;

B = imcrop(B, [c_min r_min max_w max_h]);

figure;
imshow(B);

B_mask = imcrop(B_mask, [c_min r_min max_w max_h]);

B_mask(1, :) = 0;
B_mask(end, :) = 0;
B_mask(:, 1) = 0;
B_mask(:, end) = 0;
se = strel('disk', 5);
B_mask = imerode(B_mask, se);

figure;
imshow(B_mask);
title('the mask, OBJ_MASK')

% cutting out background image
TRG(:,:,1) = A(r_min:r_max, c_min:c_max, 1);
TRG(:,:,2) = A(r_min:r_max, c_min:c_max, 2);
TRG(:,:,3) = A(r_min:r_max, c_min:c_max, 3);

figure;
imshow(TRG);
title('background image, IMG_BG')

figure;
imshow(B);
title('original object image, IMG_OBJ');

im_out = PoissonSolver(TRG,B,B_mask,0,0);

% pasting new object image
A(r_min:r_max,c_min:c_max,1) = im_out(:,:,1);
A(r_min:r_max,c_min:c_max, 2) = im_out(:,:,2);
A(r_min:r_max,c_min:c_max, 3) = im_out(:,:,3);

figure;
imshow(im_out, []);
title('final object image');

figure;
imshow(A, []);
title('final image');
