%% CSC 262 Project: Poisson Blending

% hello
% clearing workspace before running
close all; clear; clc;


%% Setting Up

% importing images and converting to double
 
load('/home/isekiyui/CSC262/project/mat/objects.mat')
load('/home/isekiyui/CSC262/project/mat/backgrounds.mat')

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

% discretized, simultaneous linear equation (7)

% first, taking the laplacian of the object image
laplace_kernel = [0 1 0; 1 -4 1; 0 1 0];

laplace_obj = zeros(size(object, 1), size(object, 2), 3);

laplace_obj(:, :, 1)= conv2(object(:, :, 1), laplace_kernel, 'same');
laplace_obj(:, :, 2)= conv2(object(:, :, 2), laplace_kernel, 'same');
laplace_obj(:, :, 3)= conv2(object(:, :, 3), laplace_kernel, 'same');

figure;
imshow(laplace_obj, []);
title('Laplacian of the Object Image');

% when guidance vector = laplace of g ( = laplace of f)
% getting partial derivatives with respect to x and y (probably wrong...)

gauss = gkern(2);
dgauss = gkern(2, 1);

dx_obj = zeros(size(object, 1), size(object, 2), 3);

dx_obj(:, :, 1)= conv2(gauss', dgauss, object(:, :, 1), 'same');
dx_obj(:, :, 2)= conv2(gauss', dgauss, object(:, :, 2), 'same');
dx_obj(:, :, 3)= conv2(gauss', dgauss, object(:, :, 3), 'same');

figure;
imshow(dx_obj, []);
title('Dx of the Object Image');

dy_obj = zeros(size(object, 1), size(object, 2), 3);

dy_obj(:, :, 1)= conv2(dgauss', gauss, object(:, :, 1), 'same');
dy_obj(:, :, 2)= conv2(dgauss', gauss, object(:, :, 2), 'same');
dy_obj(:, :, 3)= conv2(dgauss', gauss, object(:, :, 3), 'same');

figure;
imshow(dy_obj, []);
title('Dy of the Object Image');

% discrete laplacian operator * f = div v at p

% div v at p is div (gradient of g) at p
% f = a matrix with the values of f at each pixel p

