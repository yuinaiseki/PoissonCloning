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

% Setting up Matrix A
    % new object image to paste:    H
    % original object image:        B
    % background image:             A

% initializing H
A = bg(:,:,:,4);
B = obj(:,:,:,1);
H = zeros(size(B));

%     figure;
%     imshow(A);
    
    
% lhs of the equation: spatial gradient at H(x, y)

% creating a logical matrix to determine boundary of object image
N = obj_N(:, :, 1);
Boundary = N;
Boundary(N == 4) = 0;
Boundary(Boundary ~= 0) = 1;

    % figure;
    % imshow(Boundary);

% setting boundary of H to be background image for matrix A
Boundary_A = zeros(size(A));
Boundary_A(:,:,1) = Boundary;
Boundary_A(:,:,2) = Boundary;
Boundary_A(:,:,3) = Boundary;

Boundary_A(Boundary_A==1) = A(Boundary_A==1)

%     figure;
%     imshow(Boundary_A);

% creating a logical matrix to determine interior of object image
N = obj_N(:, :, 1);
Interior = N;
Interior(N == 4) = 1;

%     figure;
%     imshow(Interior);
    
% setting interior of H to gradient of object image for matrix A
laplace_kernel = [0 1 0; 1 0 1; 0 1 0];
H_gradient = conv2(im2gray(H), laplace_kernel, 'same');

Interior = Interior .* H_gradient;

% lhs of equation complete
H_gradient = N .* H - Interior - Boundary_A;

     figure;
     imshow(H_gradient, []);

% rhs of equation: gradient of B at (x, y), which should match with our
% gradient at H(x, y)
laplace_kernel = [0 1 0; 1 -4 1; 0 1 0];
B_gradient = conv2(im2gray(B), laplace_kernel, 'same');
    % figure;
    % imshow(B_gradient);


    