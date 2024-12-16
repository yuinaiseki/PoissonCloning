% Create folders for storing images and matrices

if not(exist('mat','dir'))
    mkdir('mat');
    mkdir('mat/colored');
    mkdir('mat/colored/backgrounds');
    mkdir('mat/colored/objects');
    mkdir('mat/transparent');
    mkdir('mat/transparent/backgrounds');
    mkdir('mat/transparent/objects');
end

% create .mat dataset
create_colored_dataset();
create_transparent_dataset();

