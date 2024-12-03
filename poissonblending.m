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
B_log = obj_logical(:,:,1);
H = zeros(size(B));

     figure;
     imshow(B);
    
    
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

Boundary_A(Boundary_A==1) = A(Boundary_A==1);

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

% lhs of equation complete ?
H_gradient = N .* H - Interior - Boundary_A;

     figure;
     imshow(H_gradient, []);

% rhs of equation: gradient of B at (x, y), which should match with our
% gradient at H(x, y)

laplace_kernel = [0 1 0; 1 -4 1; 0 1 0];


%% from here...

A = A(1:5:end, 1:5:end, :);
B = B(1:5:end, 1:5:end, :);
B_log = B_log(1:5:end, 1:5:end, :);
B_log = B_log(:);
H = zeros(size(B));
N = N(1:5:end, 1:5:end);

% initializing target gradient B_gradient for Ax = b
B_gradient = zeros(size(B));

% 3 color channels
B_gradient(:, :, 1) = conv2(B(:, :, 1), laplace_kernel, 'same');
B_gradient(:, :, 2) = conv2(B(:, :, 1), laplace_kernel, 'same');
B_gradient(:, :, 3) = conv2(B(:, :, 1), laplace_kernel, 'same');

    figure;
    imshow(B_gradient);


% Poisson solver?

for i = 1:5

% Making matrix A, matA, using the Jacobi Method

% matA can be decomposed into a diagonal component, matA_D
% and two triangular parts: the lower triangular part, matA_L
% and the upper triangular part, matA_U
% ** matA_L and matA_U will actually be the negative version of the real
% matA_L and matA_U matrices, because we need to subtract these values to
% calculate the gradient
% using these matrices and B_gradient, the target gradient, we can
% approximate X

% matA_D will be the number of neighbors at pixel x_i, so
matA_D = diag(N(:));

num_pix = size(B, 1) * size(B, 2);

% matA_L and matA_L (which we will combine to mat_T here)
% for pixel i, all values in row i in the matrix are 0, unless it is a
% neighboring pixel of i, which will be -1
matA_T = zeros(num_pix, num_pix);
max_num_neighbor = 4;

img_width = size(B, 1);
img_height = size(B, 2);

% for each pixel in the image
for i = 1:num_pix
    
        % by data set up, we assume that edge of the image is always 0,
        % therefore irrelevant whether it's actually neighbor or not
        top = i - img_width;
        bottom = i + img_width;
        left = i - 1;
        right = i + 1;
        
        if top < num_pix && 0 < top
            % make coefficient at [row i, col *ind of neighbor pixel*] to -1
            % if there is no neighbor, B_1d(1, top) will be 0 so the
            % coefficient will be 0
            matA_T(i, top) = -1 * B_log(top, 1);
        end
        if bottom < num_pix && 0 < bottom
            matA_T(i, bottom) = -1 * B_log(bottom, 1);
        end
        if left < num_pix && 0 < left
            matA_T(i, left) = -1 * B_log(left, 1);
        end
        if right < num_pix && 0 < right
            matA_T(i, right) = -1 * B_log(right, 1);
        end
end

% solve for X
%{
matA = matA_D + matA_T;

b_r = B_gradient(:, :, 1);
b_r = b_r(:);
H(:, :, 1) = reshape(matA / b_r(:)', [80 120]);

b_g = B_gradient(:, :, 2);
b_g = b_g(:);
H(:, :, 2) = reshape(matA / b_g(:)', [80 120]);
    
b_b = B_gradient(:, :, 3);
b_b = b_b(:);
H(:, :, 3) = reshape(matA / b_b(:)', [80 120]);
%}



final_img = A;
figure;
imshow(final_img);

final_log = reshape(B_log, [80 120]);
final_log = repmat(final_log, 1, 1, 3);
final_img(final_log == 1) = 0;
H(isnan(H)) = 0;
final_img = final_img + H;

figure;
imshow(final_img, []);

end
