%% CSC 262 Project: Poisson Blending
%
%   This script tests functions and datasets for Poisson Image Editing.
% 
%   We first load the dataset, and then start by copy-and-paste of object
%   images on background images. Then, we test the PoissonSolver.m function
%   for Poisson Image Editing of images using color vs. grayscale images,
%   and using object gradient vs. mixed gradients.
%
%   CSC262 Final Project: Poisson Image Editing
%   Author: Yuina Iseki, Shuta Shibue

% clearing workspace before running
close all; clear; clc;

%% Setting Up Dataset

% importing images and matrices from pre-made dataset

% ------- data set for partially transparent object image blending -------

% obj_tp:
%   4-D array of object images, transparent
%       1: NYC stamp
%       2: bunny
%       3: dragonflies
%       4: fish zodiac
load('mat/transparent/objects.mat')             % loads obj_tp
obj_tp = obj;

% bg_tp:
%   4-D array of background images, for blending transparent object images
%       1: paper
%       2: fancy paper with raspberries
%       3: lined paper
load('mat/transparent/backgrounds.mat')         % loads bg_tp
bg_tp = bg;

% obj_N_tp: 
%   a matrix of number of neighboring pixels(N <= 4) within object image
%   boundary (i.e. neighbor matrix of object image)
load('mat/transparent/objects_N.mat')           % loads obj_N_tp
obj_N_tp = obj_N;

% obj_logical_tp:
%   a matrix of object image that dictates whether the corresponding pixel 
%   is within object image boundary (i.e. logical matrix of object image)
load('mat/transparent/objects_logical.mat')     % loads obj_logical_tp
obj_logical_tp = obj_logical;

% ---------- data set for colored solid object images blending ----------

% obj:
%   4-D array of object images, colored
%       1: raft
%       2: dog
%       3: cowboy
%       4: bird
%       5: deer
%       6: monkey
%       7: camera cam
load('mat/colored/objects.mat')             % loads obj

% bg:
%   4-D array of background images, colored
%       1: fall road
%       2: hill
%       3: mountain
%       4: ocean
load('mat/colored/backgrounds.mat')         % loads bg

% obj_N: 
%   a matrix of number of neighboring pixels(N <= 4) within object image
%   boundary (i.e. neighbor matrix of object image)
load('mat/colored/objects_N.mat')           % loads obj_N

% obj_logical:
%   a matrix of object image that dictates whether the corresponding pixel 
%   is within object image boundary (i.e. logical matrix of object image)
load('mat/colored/objects_logical.mat')     % loads obj_logical


%% Simple Copy-and-Paste (Milestone 1)

% This part of the project aims for a simple copy-and paste of images,
% without any blending technique.

% initializing copy-and-paste demo
copy_paste = zeros(400, 600, 3, 28);

% number of background images
num_bg = size(bg, 4);

% number of object images
num_obj = size(obj, 4);

% looping through each background / object image combination to demonstrate
% copy-and-paste result
for i= 1:num_bg
    for j = 1:num_obj

        % using imagepaste function to paste object image to background
        % image
        [new_background, new_object] = ImagePaste(bg(:,:,:,i), obj(:,:,:,j));
        
        % saving result 
        copy_paste(:,:,:,i*7+j) = new_background + new_object;
    end
end

% showing all combination of copy-and-paste results in montage 
montage(copy_paste);


%% Poisson Image Editing (Milestone 2-3)

% This part tests the PoissonSolver.m function on various images to compare
% its results on colored vs. grayscale images and different guidance
% vectors.

% TO-DO: test for
%       color images
%       grayscale images
%       object gradient (seamless cloning)
%       mixed gradient
%   test for all combinations of color and guidance vector

% -------- testing/saving images for: 1. color / object gradient ---------

% setting up data for PoissonSolver
%   *later on in milestone 4, these processes have been made into a
%   function for easier + more versatile image blending

% saving relevant copy-paste version of image for comparison
% raft_cp_ind = 29;
% imwrite(copy_paste(:,:,:,raft_cp_ind), 'testing/copy-paste.jpg')

A = bg(:,:,:,2);                % background image
B = obj(:,:,:,5);               % object image
B_log = obj_logical(:,:,5);     % logical matrix of raft 
N = obj_N(:, :, 2);             % neighbor matrix of raft

% cropping the B_log matrix
[r, c] = find(B_log == 1);
r_max = max(r);         % getting highest/lowest location of object image boundary
r_min = min(r);
c_max = max(c);
c_min = min(c);

max_h = r_max - r_min;  % getting height/width of object image boundary
max_w = c_max - c_min;

B = imcrop(B, [c_min r_min max_w max_h]);   % cropping the object image

% figure;
% imshow(B);
% title('cropped object image B');
%imwrite(B, 'testing/cropped-B-obj.jpg')     % saving cropped object image

B_log = imcrop(B_log, [c_min r_min max_w max_h]);

% boundary condition
B_log(1, :) = 0;        % making outer border of mask to match background image
B_log(end, :) = 0;
B_log(:, 1) = 0;
B_log(:, end) = 0;  
se = strel('disk', 5);  % eroding mask
B_log = imerode(B_log, se);

% figure;
% imshow(B_log);
% title('the mask, OBJ_MASK');
%imwrite(B_log, 'testing/cropped-B-mask.jpg')     % saving cropped object image mask (logical matrix)

% cutting out background image
TRG(:,:,1) = A(r_min:r_max, c_min:c_max, 1);
TRG(:,:,2) = A(r_min:r_max, c_min:c_max, 2);
TRG(:,:,3) = A(r_min:r_max, c_min:c_max, 3);

% figure;
% imshow(TRG);
% title('background image, IMG_BG')
%imwrite(TRG, 'testing/cropped-A-bg.jpg')     % saving cropped background

% calling PoissonSolver function to adjust object image
img_final = PoissonSolver(TRG,B,B_log,0,0);

% pasting new object image
A(r_min:r_max,c_min:c_max,1) = img_final(:,:,1);
A(r_min:r_max,c_min:c_max, 2) = img_final(:,:,2);
A(r_min:r_max,c_min:c_max, 3) = img_final(:,:,3);

% figure;
% imshow(img_final, []);
% title('final object image');
%imwrite(img_final, 'testing/final-B-obj.jpg')     % saving final object image

figure;
imshow(A, []);
title('final image');
%imwrite(A, 'testing/final-img.jpg')     % saving final image

% ------ testing/saving images for: 2. grayscale / object gradient -------

% -------- testing/saving images for: 3. color / mixed gradient ---------

% setting up data for PoissonSolver
%   *later on in milestone 4, these processes have been made into a
%   function for easier + more versatile image blending

% saving relevant copy-paste version of image for comparison
% raft_cp_ind = 29;
% imwrite(copy_paste(:,:,:,raft_cp_ind), 'testing/copy-paste.jpg')

A = bg(:,:,:,2);                % background image
B = obj(:,:,:,5);               % object image
B_log = obj_logical(:,:,5);     % logical matrix of raft 
N = obj_N(:, :, 2);             % neighbor matrix of raft

% cropping the B_log matrix
[r, c] = find(B_log == 1);
r_max = max(r);         % getting highest/lowest location of object image boundary
r_min = min(r);
c_max = max(c);
c_min = min(c);

max_h = r_max - r_min;  % getting height/width of object image boundary
max_w = c_max - c_min;

B = imcrop(B, [c_min r_min max_w max_h]);   % cropping the object image

% figure;
% imshow(B);
% title('cropped object image B');
%imwrite(B, 'testing/cropped-B-obj.jpg')     % saving cropped object image

B_log = imcrop(B_log, [c_min r_min max_w max_h]);

% boundary condition
B_log(1, :) = 0;        % making outer border of mask to match background image
B_log(end, :) = 0;
B_log(:, 1) = 0;
B_log(:, end) = 0;  
se = strel('disk', 5);  % eroding mask
B_log = imerode(B_log, se);

% figure;
% imshow(B_log);
% title('the mask, OBJ_MASK');
%imwrite(B_log, 'testing/cropped-B-mask.jpg')     % saving cropped object image mask (logical matrix)

% cutting out background image
TRG(:,:,1) = A(r_min:r_max, c_min:c_max, 1);
TRG(:,:,2) = A(r_min:r_max, c_min:c_max, 2);
TRG(:,:,3) = A(r_min:r_max, c_min:c_max, 3);

% figure;
% imshow(TRG);
% title('background image, IMG_BG')
%imwrite(TRG, 'testing/cropped-A-bg.jpg')     % saving cropped background

% calling PoissonSolver function to adjust object image
img_final = PoissonSolver(TRG,B,B_log,0,0);

% pasting new object image
A(r_min:r_max,c_min:c_max,1) = img_final(:,:,1);
A(r_min:r_max,c_min:c_max, 2) = img_final(:,:,2);
A(r_min:r_max,c_min:c_max, 3) = img_final(:,:,3);

% figure;
% imshow(img_final, []);
% title('final object image');
%imwrite(img_final, 'testing/final-B-obj.jpg')     % saving final object image

figure;
imshow(A, []);
title('final image');
%imwrite(A, 'testing/final-img.jpg')     % saving final image


%% Versatile and automatic Poisson Image Editing! (Milestone 4)


