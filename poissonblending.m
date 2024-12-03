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
A = bg(:,:,:,3);
B = obj(:,:,:,2);
B_log = obj_logical(:,:,2);
H = zeros(size(B));

     figure;
     imshow(B);
     title('object image');
    
    
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
     title('LHS...?');

% rhs of equation: gradient of B at (x, y), which should match with our
% gradient at H(x, y)

laplace_kernel = [0 1 0; 1 -4 1; 0 1 0];


%% from here...

A = A(1:5:end, 1:5:end, :);
B = B(1:5:end, 1:5:end, :);
B_log = B_log(1:5:end, 1:5:end, :);
B_log = B_log(:);
H = rand(size(B));
N = N(1:5:end, 1:5:end);
final_img = A;

% initializing target gradient B_gradient for Ax = b
B_gradient = zeros(size(B));

% 3 color channels
B_gradient(:, :, 1) = conv2(B(:, :, 1), laplace_kernel, 'same');
B_gradient(:, :, 2) = conv2(B(:, :, 2), laplace_kernel, 'same');
B_gradient(:, :, 3) = conv2(B(:, :, 3), laplace_kernel, 'same');

    figure;
    imshow(B_gradient, []);
    title('B gradient');
    
    error1 = 0;
    error2 = 0;
    error3 = 0;

% Poisson solver?


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
    %% from here...
    num_pix = size(B, 1) * size(B, 2);
    
    % matA_L and matA_L (which we will combine to mat_T here)
    % for pixel i, all values in row i in the matrix are 0, unless it is a
    % neighboring pixel of i, which will be -1
    
    matA_T = zeros(num_pix, num_pix);
    %matA_T(1:num_pix, 1:num_pix) = -1;
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
            %matA_T(i, top) = i;
        end
        if bottom < num_pix && 0 < bottom
            matA_T(i, bottom) = -1 * B_log(bottom, 1);
            %matA_T(i, bottom) = i;
        end
        if left < num_pix && 0 < left
            matA_T(i, left) = -1 * B_log(left, 1);
            %matA_T(i, left) = i;
        end
        if right < num_pix && 0 < right
            matA_T(i, right) = -1 * B_log(right, 1);
            %matA_T(i, right) = i;
        end
    end
    
    matA = matA_D + matA_T;
    
    % solve for X
    matA = matA_D + matA_T;
    
    b_1 = B_gradient(:, :, 1);
    b_1 = b_1(:);
    b_1(isnan(b_1)) = 0;
    H(:, :, 1) = reshape(b_1(:) \ matA, [80 120]);
    
    b_2 = B_gradient(:, :, 2);
    b_2 = b_2(:);
    b_2(isnan(b_2)) = 0;
    H(:, :, 2) = reshape(b_2(:) \ matA, [80 120]);
    
    b_3 = B_gradient(:, :, 3);
    b_3 = b_3(:);
    b_3(isnan(b_3)) = 0;
    H(:, :, 3) = reshape(b_3(:) \ matA, [80 120]);
    
    % Jacobi method
    %{
x0 = zeros(size(num_pix));
epsilon = 1e-16;
maxit = 100;

b_r = B_gradient(:, :, 1);
b_r = b_r(:);

b_g = B_gradient(:, :, 2);
b_g = b_g(:);
    
b_b = B_gradient(:, :, 3);
b_b = b_b(:);

x1 = Jacobi(matA, b_r, epsilon, maxit, x0);
x2 = Jacobi(matA, b_g, epsilon, maxit, x0);
x3 = Jacobi(matA, b_b, epsilon, maxit, x0);

    %}
    
    % final_img = A;
    % figure;
    % imshow(final_img);
    
    final_log = reshape(B_log, [80 120]);
    final_log = repmat(final_log, 1, 1, 3);
    final_img(final_log == 1) = 0;
    
    % figure;
    % imshow(final_img);
    % title('prepared bkg image');
    
    
% gradient descent

% initial x values
    x1 = H(:, :, 1);
    x2 = H(:, :, 2);
    x3 = H(:, :, 3);
    
    total_error = 1;
    threshold_error = 0.00001;
    weight = 0.1;
    max_iterations = 15;
    
    iterations = 0;
while total_error > threshold_error && (max_iterations > iterations)
    
    Ax1 = matA * x1(:);
    Ax2 = matA * x2(:);
    Ax3 = matA * x3(:);
    
    error1 = b_1 - Ax1;
    error2 = b_2 - Ax2;
    error3 = b_3 - Ax3;
    
    total_error = error1'*error1 + error2'*error2 + error3'*error3;
    
    H(:, :, 1) = H(:, :, 1) + weight*reshape(error1, [80 120]);
    H(:, :, 2) = H(:, :, 2) + weight*reshape(error2, [80 120]);
    H(:, :, 3) = H(:, :, 3) + weight*reshape(error3, [80 120]);
    
    x1 = H(:, :, 1);
    x2 = H(:, :, 2);
    x3 = H(:, :, 3);
    
    figure;
    imshow(H, []);
    title('adjusted object image');
    
    H(isnan(H)) = 0;
    
    final_img(:,:,1) = final_img(:,:,1) + H(:,:,1);
    final_img(:,:,2) = final_img(:,:,2) + H(:,:,2);
    final_img(:,:,3) = final_img(:,:,3) + H(:,:,3);
    
    figure;
    imshow(final_img, []);
    title('final edited image');
    
    iterations = iterations + 1;

end
