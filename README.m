        %% CSC 262 Final Project

% This is a script to run the final project for CSC 262 with Yuina and Shuta.

%% Data Setup
% Run Setup.m to create matrix files under mat/ folder, which contains the image,
% logical mask, alpha data, neighbor matrix, etc. They are generated
% from the datasets under source/ folder.
% All codes below rely on these matrix files.
Setup;

%% Poisson Blending
% poissonblending.m is the test script which executes copy and paste method, 
% seamless cloning, and mixed gradient seamless cloning.
poissonblending;

% The output can be found in the testing folder as well as the matlab popup.
