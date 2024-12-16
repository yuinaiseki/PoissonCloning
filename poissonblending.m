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
%   Author: Yuina Iseki

% clearing workspace before running
close all; clear; clc;

%% Setting Up Dataset

% importing images and matrices from pre-made dataset

% if the data hasn't been set up yet, run:
% run('Setup.m')

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

% loading data from data set
raft = load('mat/colored/objects/raft.mat');

raft_img = raft.obj;                 % original raft image
raft_mask = raft.logical_mask;       % binary mask for raft image
raft_n = raft.N;                     % matrix of neighbors in raft image

ocean = load('mat/colored/backgrounds/ocean.mat');
ocean_img = ocean.bg;                % original ocean image

[ocean_proc, raft_proc, raft_mask_proc, x, y] = preprocess(ocean_img, raft_img, raft_mask);

% calling PoissonSolver function to adjust object image
raft_poisson = PoissonSolver(ocean_proc,raft_proc,raft_mask_cropped, 0,0);

% pasting new object image
[raft_bg, raft_poisson] = ImagePaste(ocean_img, raft_poisson, x, y);
img_final = raft_bg + raft_poisson;

figure;
imshow(img_final, []);
title('1. color / obj gradient - raft');
% imwrite(A, 'testing/final-img.jpg')     % saving final image

%{
% ------ testing/saving images for: 2. grayscale / object gradient -------

% -------- testing/saving images for: 3. color / mixed gradient ---------

bunny = load('mat/transparent/objects/bunny.mat');

bunny_I = bunny.I;                  % original bunny image
bunny_obj = bunny.composite;        % composite bunny image
bunny_alpha = bunny.alpha;                % alpha mask
B_log = bunny.logical_mask;         % logical mask of bunny
bunny_N = bunny.N;                  % loads N matrix of bunny
bunny_composite_nan = bunny.composite_nan;
B = bunny_obj;

% calling PoissonSolver function to adjust object image
img_final = PoissonSolver(TRG1,B,B_log,1,0);

% pasting new object image

%}

%% Versatile and automatic Poisson Image Editing! (Milestone 4)


%% Saving images from test runs

% figure;
% imshow(TRG);
% title('background image, IMG_BG')
%imwrite(TRG, 'testing/cropped-A-bg.jpg')     % saving cropped background

% figure;
% imshow(B);
% title('cropped object image B');
%imwrite(B, 'testing/cropped-B-obj.jpg')     % saving cropped object image

% figure;
% imshow(B_log);
% title('the mask, OBJ_MASK');
%imwrite(B_log, 'testing/cropped-B-mask.jpg')     % saving cropped object image mask (logical matrix)

% figure;
% imshow(img_final, []);
% title('final object image');
%imwrite(img_final, 'testing/final-B-obj.jpg')     % saving final object image
