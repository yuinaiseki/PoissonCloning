function img_obj_final = PoissonSolver(img_bg,img_obj, obj_mask, grad, clr)
%%
% POISSONSOLVER returns a poisson-adjusted object image according to input
% object and background images and chosen type of guidance vector.
% 
%   IMG_OBJ_FINAL = POISSONSOLVER(IMG_OBJ, IMG_BG, OBJ_MASK, GRAD, CLR)
%   where IMG_OBJ and IMG_BG are double images of an object and background
%   to integrate. OBJ_MASK is a logical matrix of the object image that
%   dictates whether the corresponding pixel in IMG_OBJ is within the
%   object image boundary(1), or not (0). The pixel is only adjusted if
%   it's within the object image boundary. GRAD is a double to indicate
%   whether the guidance vector should only be the object gradient (0) or
%   mixed gradients of object and background (1). CLR is a double to
%   indicate whether images are color(0) or grayscale(1). Finally,
%   IMG_OBJ_FINAL is a uint8 image of the object after it has been adjusted
%   after poisson image editing, based on the given gradient setting and
%   object mask. Moreover, the function is written on the assumption that
%   img_obj, img_bg, and obj_mask are of the same size.
% 
%
%   GRAD: determines type of guidance vector for poisson-adjusted object image  
%       0: seamless cloning (only object image gradient)
%       1: mixed gradients of object and background image gradients. Works
%       better for partially transparent images / images with holes
%
%   CLR: 
%       0: both object and background images are color images
%       1: both object and background images are grayscale
%
%   CSC262 Final Project: Poisson Image Editing
%   Author: Yuina Iseki
%%

% -------------------------- set up of variables --------------------------

% making sure IMG_OBJ, IMG_BG, OBJ_MASK have same size
if size(img_obj, 1) ~= size(img_bg, 1) || size(img_obj, 2) ~= size(img_bg, 2) ||...
   size(img_obj, 3) ~= size(img_bg, 3) || size(img_obj, 1) ~= size(obj_mask, 1) ||...
   size(img_obj, 2) ~= size(obj_mask, 2)
    error('IMG_OBJ, IMG_BG, OBJ_MASK must be of the same size.')
end

% making sure OBJ_MASK is a logical matrix
obj_mask = mat2gray(obj_mask);

% making sure IMG_OBJ, IMG_BG are double
img_obj = im2double(img_obj);
img_bg = im2double(img_bg);

% initialize IMG_OBJ_FINAL to be IMG_BG
img_obj_final = img_bg;

% Laplacian kernel
laplace_kernel = [0 1 0; 1 -4 1; 0 1 0];

% if color image, initialize clr_channels to 3, otherwise 1
if clr == 0
    clr_channels = 3;
else
    clr_channels = 1;
    
    % convert to grayscale if grayscale blending
    if size(img_bg,3)>1
        img_bg=rgb2gray(img_bg);
    end
    if size(img_obj,3)>1
        img_obj=rgb2gray(img_obj);
    end
end

% number of pixels to adjust in img_obj (which is where obj_mask is 1)
num_pix = size(find(obj_mask == 1), 1);

% mapping to-adjust pixels to a pixel index
pix_indices = zeros(size(obj_mask));
pix_ind = 1;
for row = 1:size(pix_indices, 1)
    for col = 1:size(pix_indices, 2)
   
        % checking if it's a pixel within object image boundary
        if obj_mask(row, col) == 1 
            % set pixel index
            pix_indices(row, col) = pix_ind;
            % increment pixel index
            pix_ind = pix_ind + 1;
        end
    end
end


%%
% ----------------------- solving Poisson equation -----------------------
% 
%   Ax = B, where
%   
%   A: a sparse matrix consisting a system of linear equations to adjust
%   each pixel in IMG_OBJ according to the chosen guidance vector 
%   B: the guidance vector x: a vector of all poisson-adjusted pixels in
%   IMG_OBJ_FINAL
%
%   We are solving for x.

% the maximum number of coefficients in a row of matrix A is 5
max_num_coeff = 5;

% ---------- creating matrix A and vector B of Poisson equation ---------- 

for c=1:clr_channels % loop through each color channel
    
    % initializing vector B
    B = zeros(num_pix, 1);

    % initializing matrix A (using spalloc to save memory)
    A = spalloc(num_pix, num_pix, num_pix*max_num_coeff);

    % ----- creating guidance vector B -----
    
    if grad == 0 % seamless cloning (just object image gradient)
        
        % fprintf('Object Gradient...');
        
        % Perez et al. Eq(9)
        % use gradient from object image
        B_lap = conv2(img_obj(:,:,c), laplace_kernel, 'same');
        
    else 
        % fprintf('Mixed Gradient...');
        
        % Perez et al. Eq(12)
        % use gradient from background or object, whichever is bigger
        sobel_x = [-1 1];
        sobel_y = [-1; 1];
        
        % getting 1st derivative of bg image
        bg_grad_x = conv2(img_bg(:,:,c), sobel_x, 'same');
        bg_grad_y = conv2(img_bg(:,:,c), sobel_y, 'same');
        bg_mag = sqrt(bg_grad_x.^2 + bg_grad_y.^2);
        
        
        % getting 1st derivative of obj image
        obj_grad_x = conv2(img_obj(:,:,c), sobel_x, 'same');
        obj_grad_y = conv2(img_obj(:,:,c), sobel_y, 'same');
        obj_mag = sqrt(obj_grad_x.^2 + obj_grad_y.^2);
        
        % initialize final gradient to be object gradient
        final_grad_x = obj_grad_x(:);
        final_grad_y = obj_grad_y(:);
        
        % make into 1D vectors
        bg_mag = bg_mag(:);
        obj_mag = obj_mag(:);
        
        % if the background graidient is bigger than the object gradient at
        % a certain pixel, choose the background pixel
        final_grad_x(abs(bg_mag)>abs(obj_mag)) = bg_grad_x(bg_mag>obj_mag);
        final_grad_y(abs(bg_mag)>abs(obj_mag)) = bg_grad_y(bg_mag>obj_mag);
        
        % reshape 1D vector back into 2D
        final_grad_x = reshape(final_grad_x, size(obj_grad_x, 1), size(obj_grad_x, 2));
        final_grad_y = reshape(final_grad_y, size(obj_grad_y, 1), size(obj_grad_y, 2));
        
        % take second derivative i.e. laplacian of 
        B_lap_x = conv2(final_grad_x, sobel_x, 'same');
        B_lap_y = conv2(final_grad_y, sobel_y, 'same');
        B_lap = B_lap_x + B_lap_y;
        
    end
    
    % index all to-adjust pixels in OBJ_IMG
    pix_ind = 1;
    
    % ----- creating matrix A -----
    
    for row = 1:size(pix_indices, 1)
        for col = 1:size(pix_indices, 2)
            
            % checking if it is a pixel that should be adjusted
            if obj_mask(row, col) == 1
                
                % diagonal in matrix A is the number of neighbors the
                % corresponding pixel has (4 or less)
                A(pix_ind, pix_ind) = 4; 
                
                % examine each neighbor pixel
                % left
                % check if the neighbor is unchanging (a boundary pixel)
                if obj_mask(row-1, col) == 0
                    % if a boundary pixel, get gradient from the background
                    % image
                    B(pix_ind) = img_bg(row-1, col, c);
                else
                    A(pix_ind, pix_indices(row-1,col)) = -1;
                end
                
                % right
                if obj_mask(row+1, col) == 0
                    B(pix_ind) = B(pix_ind) + img_bg(row+1, col, c);
                else
                    A(pix_ind, pix_indices(row+1,col)) = -1;
                end
                
                % up
                if obj_mask(row, col+1) == 0
                    B(pix_ind) = B(pix_ind) + img_bg(row, col+1, c);
                else
                    A(pix_ind, pix_indices(row,col+1)) = -1;
                end
                
                % down
                if obj_mask(row, col-1) == 0
                    B(pix_ind) = B(pix_ind) + img_bg(row, col-1, c);
                else
                    A(pix_ind, pix_indices(row,col-1)) = -1;
                end
                
                B(pix_ind) = B(pix_ind) - B_lap(row, col);
                
                % increment pix_counter
                pix_ind = pix_ind + 1;
            end
        end
    end
    
    % solve for x
    x = A\B;

    % reshape x and store in img_obj_final
    for i=1:length(x)
        [row,col]=find(pix_indices==i);
         img_obj_final(row, col, c) = x(i);
    end
    
    % clear variables for next color channel
    clear A B x B_lap
    
end

% img_obj_final = uint8(img_obj_final);
end

