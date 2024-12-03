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

reduction = 4;
A = A(1:reduction:end, 1:reduction:end, :);
B = B(1:reduction:end, 1:reduction:end, :);
B_log = B_log(1:reduction:end, 1:reduction:end, :);
N = N(1:reduction:end, 1:reduction:end);

img = poissonblending_f(A,B,N,B_log);

figure;
imshow(img, []);
title("poisson");

[bg, obj, objlog] = imagepaste(A,B);
figure;
imshow(bg+obj, []);
title("copypaste");
