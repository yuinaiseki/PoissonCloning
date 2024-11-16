

base_path_obj = '/home/isekiyui/CSC262/project/objects/';
base_path_bg = '/home/isekiyui/CSC262/project/backgrounds/';

obj = zeros(400, 600, 3, 4);
bg =  zeros(400, 600, 3, 7);

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