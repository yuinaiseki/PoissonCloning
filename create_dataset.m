

base_path_obj = 'objects/';
base_path_bg = 'backgrounds/';

obj = zeros(400, 600, 3, 7);
bg =  zeros(400, 600, 3, 4);

obj_names = ["raft", "dog", "cowboy", "bird", "deer", "monkey", "person"];
for i= 1:7
    obj(:,:,:,i) = im2double(imread(strcat(base_path_obj, obj_names(i), ".jpg")));
end


bg_names = ["fall_road", "grass", "mountains", "ocean"];
for i= 1:4
    bg(:,:,:,i) = im2double(imread(strcat(base_path_bg, bg_names(i), ".jpg")));
end

figure;
montage(bg, 'Size', [2 2]);
figure;
s=montage(obj, 'Size', [3 3]);

obj_logical = zeros(400, 600, 7);
obj_N = zeros(400, 600, 7);
for img = 1:7
    object = obj(:,:,:,img);
    for i = 1:size(object, 1)
        for j = 1:size(object, 2)
            if all(object(i, j, :) > 0.95)
                object(i, j, :) = NaN;
            else
                break;
            end
        end
    end

    for i = 1:size(object, 1)
        for j = size(object, 2):-1:1
            if all(object(i, j, :) > 0.95)
                object(i, j, :) = NaN;
            else
                break;
            end
        end
    end

    obj(:,:,:,img) = object;
    obj_logical(:,img) = true(size(object,1), size(object,2));

    % convolution to get N matrix
    kernel = [0 1 0; 1 0 1; 0 1 0];
    N = conv2(obj_logical(:,img), kernel, 'same');
    obj_N(:,img) = N;
end

save('mat/objects.mat', 'obj');
save('mat/backgrounds.mat', 'bg');
save('mat/objects_logical.mat', 'obj_logical');
save('mat/objects_N.mat', 'obj_N');
