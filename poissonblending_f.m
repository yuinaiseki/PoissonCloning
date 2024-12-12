function [final_imgs] = poissonblending_f(A,B,N,B_log)
%POISSONBLENDING_F Summary of this function goes here
%   Detailed explanation goes here

    laplace_kernel = [0 1 0; 1 -4 1; 0 1 0];

    % Setting up Matrix A
    % new object image to paste:    H
    % original object image:        B
    % background image:             A
    B_log_vec = B_log(:); % to vector
    H = zeros(size(B));
    
    % matA_D will be the number of neighbors at pixel x_i, so
    matA_D = diag(N(:));

    num_pix = size(B_log_vec, 1);

    % matA_L and matA_L (which we will combine to mat_T here)
    % for pixel i, all values in row i in the matrix are 0, unless it is a
    % neighboring pixel of i, which will be -1

    matA_T = zeros(num_pix, num_pix);
    % matA_T(1:num_pix, 1:num_pix) = -1;

    img_width = size(B, 1);

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
                matA_T(i, top) = -1 * B_log_vec(top, 1);
                % matA_T(i, top) = i;
            end
            if bottom < num_pix && 0 < bottom
                matA_T(i, bottom) = -1 * B_log_vec(bottom, 1);
                % matA_T(i, bottom) = i;
            end
            if left < num_pix && 0 < left
                matA_T(i, left) = -1 * B_log_vec(left, 1);
                %matA_T(i, left) = i;
            end
            if right < num_pix && 0 < right
                matA_T(i, right) = -1 * B_log_vec(right, 1);
                %matA_T(i, right) = i;
            end
    end

    % solve for X
    matA = matA_D + matA_T;
    
    
    B_gradient = zeros(size(B));
    for c=1:3 % Each color channel
        % Take data of specific color channel
        B_color = B(:,:,c);

        gradient = conv2(B_color, laplace_kernel, 'same');
        gradient(isnan(gradient)) = 0;
        B_gradient(:,:,c) = gradient;
    end
    
    [final_img, ~, ~] = imagepaste(A,B);

    error = 1;
    threshold_error = 0.00001;
    weight = 1;
    max_iterations = 1;
    final_imgs = zeros(size(B, 1), size(B, 2), 3, max_iterations);
    iterations = 0;

    while error > threshold_error && (max_iterations > iterations)
        error = 0;
        for c=1:3 % Each color channel
            % Take data of specific color channel
            gradient = B_gradient(:,:,c);
            %epsilon = 0.00001;
            %maxit = 10;
            %H(:, :, c) = reshape(Jacobi(matA, gradient(:), epsilon, maxit, zeros(size(gradient(:)))) , [size(B,1), size(B,2)]);
            H(:, :, c) = reshape(matA \ gradient(:), [size(B,1), size(B,2)]);
            x = H(:, :, c);
            Ax = matA * x(:);
            error_vec = gradient(:) - Ax;
            sqerror = error_vec .^2;
            error = error + sum(sqerror(:));
            H(:, :, c) = H(:, :, c) + weight*reshape(error_vec, [size(B,1), size(B,2)]);
        end
        H(isnan(H)) = 0;
        final_img = final_img + H;
        iterations = iterations + 1;
        final_imgs(:,:,:,iterations) = H;
    end
    
end

