% Setup.m
%
% This script initializes the project environment by:
% 1. Creating necessary folder structure for storing processed image data:
%    - mat/colored/backgrounds: Background images for colored dataset
%    - mat/colored/objects: Object images for colored dataset
%    - mat/transparent/backgrounds: Background images for transparent dataset
%    - mat/transparent/objects: Object images for transparent dataset
%    - testing: Output directory for result images
% 2. Calling functions to create .mat datasets:
%    - create_colored_dataset(): Processes and saves colored image matrices
%    - create_transparent_dataset(): Processes and saves transparent image matrices

% Create folders for storing images and matrices

if not(exist('mat','dir'))
    mkdir('mat'); % all processed image data will be stored here
    mkdir('mat/colored');
    mkdir('mat/colored/backgrounds');
    mkdir('mat/colored/objects');
    mkdir('mat/transparent');
    mkdir('mat/transparent/backgrounds');
    mkdir('mat/transparent/objects');
end

if not(exist('testing','dir'))
    mkdir('testing'); % store output images here
end

% create .mat dataset
create_colored_dataset();
create_transparent_dataset();

