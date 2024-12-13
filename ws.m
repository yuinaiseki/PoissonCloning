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
A = bg(:,:,:,4);
B = obj(:,:,:,1);
B_log = obj_logical(:,:,1);
N = obj_N(:, :, 1);

reduction = 5;
A = A(1:reduction:end, 1:reduction:end, :);
B = B(1:reduction:end, 1:reduction:end, :);
B_log = B_log(1:reduction:end, 1:reduction:end, :);
N = N(1:reduction:end, 1:reduction:end);

img = poissonblending_f(A,B,N,B_log);

disp(size(img));

figure;
imshow(img(:,:,:,1));

