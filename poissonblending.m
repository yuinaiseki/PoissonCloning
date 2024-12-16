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

% ------------ testing/saving images for: 1. object gradient -------------

    % Test a) raft + ocean

% loading image data from data set
raft = load('mat/colored/objects/raft.mat');

raft_img = raft.obj;                 % original raft image
raft_mask = raft.logical_mask;       % binary mask for raft image

ocean = load('mat/colored/backgrounds/ocean.mat');
ocean_img = ocean.bg;                % original ocean image

% preprocessing data for poisson editing
[ocean_proc, raft_proc, raft_mask_proc, x, y] = preprocess(ocean_img, raft_img, raft_mask);

% calling PoissonSolver function to adjust object image
raft_poisson = PoissonSolver(ocean_proc,raft_proc,raft_mask_proc, 0,0);

% pasting new object image
[ocean_bg, raft_poisson_obj] = ImagePaste(ocean_img, raft_poisson, x, y);
final_raft = ocean_bg + raft_poisson_obj;

figure;
imshow(final_raft, []);
title('1. color / obj gradient - a) raft');
imwrite(final_raft, 'testing/final-raft.jpg');          % saving final image

imwrite(raft_poisson, 'testing/raft_poisson.jpg');      % saving more images for paper
imwrite(raft_mask_proc, 'testing/raft_mask_proc.jpg');  
imwrite(raft_proc, 'testing/raft_proc.jpg');            
imwrite(ocean_proc, 'testing/ocean_proc.jpg');          

    % end of Test a)  

    % Test b) deer + grass 

% loading image data from data set
deer = load('mat/colored/objects/deer.mat');

deer_img = deer.obj;                 % original deer image
deer_mask = deer.logical_mask;       % binary mask for deer image

grass = load('mat/colored/backgrounds/grass.mat');
grass_img = grass.bg;                % original grass image

% preprocessing data for poisson editing
[grass_proc, deer_proc, deer_mask_proc, x, y] = preprocess(grass_img, deer_img, deer_mask);

% calling PoissonSolver function to adjust object image
deer_poisson = PoissonSolver(grass_proc,deer_proc,deer_mask_proc, 0,0);

% pasting new object image
[grass_bg, deer_poisson_obj] = ImagePaste(grass_img, deer_poisson, x, y);
final_deer = grass_bg + deer_poisson_obj;

figure;
imshow(final_deer, []);
title('1. color / obj gradient - b) deer');
imwrite(final_deer, 'testing/final-deer.jpg');          % saving final image

imwrite(deer_poisson, 'testing/deer_poisson.jpg');      % saving more images for paper
imwrite(deer_mask_proc, 'testing/deer_mask_proc.jpg');  
imwrite(deer_proc, 'testing/deer_proc.jpg');            
imwrite(grass_proc, 'testing/grass_proc.jpg');    

    % end of Test b).1

%% Poisson Image Editing with Mixed Gradients (Milestone 4)

% ------------- testing/saving images for: 2. mixed gradient --------------
% loading image data from data set

bunny = load('mat/transparent/objects/bunny.mat');

bunny_img = bunny.composite;           % original bunny image
bunny_mask = bunny.logical_mask;       % logical mask for bunny image

paper = load('mat/transparent/backgrounds/old_paper.mat');
paper_img = paper.bg;                % original ocean image

% preprocessing data for poisson editing
[paper_proc, bunny_proc, bunny_mask_proc, x, y] = preprocess(paper_img, bunny_img, bunny_mask);

% calling PoissonSolver function to adjust object image
bunny_poisson = PoissonSolver(paper_proc,bunny_proc,bunny_mask_proc, 1,0);

% pasting new object image
[paper_bg, bunny_poisson_obj] = ImagePaste(paper_img, bunny_poisson, x, y);
final_bunny = paper_bg + bunny_poisson_obj;

figure;
imshow(final_bunny, []);
title('3. color / mixed gradient - bunny');
imwrite(final_bunny, 'testing/final_bunny.jpg');          % saving final image

imwrite(bunny_poisson, 'testing/bunny_poisson.jpg');      % saving more images for paper
imwrite(bunny_mask_proc, 'testing/bunny_mask_proc.jpg');  
imwrite(bunny_proc, 'testing/bunny_proc.jpg');            
imwrite(paper_proc, 'testing/paper_proc.jpg');  


% --- comparing results with just the object gradient ---

% calling PoissonSolver function to adjust object image
bunny_poisson_ng = PoissonSolver(paper_proc,bunny_proc,bunny_mask_proc, 0, 0);

% pasting new object image
[paper_bg, bunny_poisson_obj_ng] = ImagePaste(paper_img, bunny_poisson_ng, x, y);
final_bunny_ng = paper_bg + bunny_poisson_obj_ng;
imwrite(final_bunny, 'testing/final_bunny_ng.jpg');          % saving final image

figure;
imshow(final_bunny_ng, []);
title('3. color / object gradient - bunny');
