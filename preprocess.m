function [Trimmed_bg, B, B_log] = preprocess(A, B, B_log)

    [r, c] = find(B_log == 1);
    r_max = max(r);         % getting highest/lowest location of object image boundary
    r_min = min(r);
    c_max = max(c);
    c_min = min(c);

    max_h = r_max - r_min;  % getting height/width of object image boundary
    max_w = c_max - c_min;

    B = imcrop(B, [c_min r_min max_w max_h]);   % cropping the object image

    % figure;
    % imshow(B);
    % title('cropped object image B');
    %imwrite(B, 'testing/cropped-B-obj.jpg')     % saving cropped object image

    B_log = imcrop(B_log, [c_min r_min max_w max_h]);

    % boundary condition
    B_log(1, :) = 0;        % making outer border of mask to match background image
    B_log(end, :) = 0;
    B_log(:, 1) = 0;
    B_log(:, end) = 0;  
    se = strel('disk', 5);  % eroding mask
    B_log = imerode(B_log, se);

    % figure;
    % imshow(B_log);
    % title('the mask, OBJ_MASK');
    %imwrite(B_log, 'testing/cropped-B-mask.jpg')     % saving cropped object image mask (logical matrix)

    % cutting out background image
    Trimmed_bg = A(r_min:r_max, c_min:c_max, :);
end