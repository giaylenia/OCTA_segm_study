%**************************************************************************
%  author: Ylenia Giarratano
%  e-mail: ylenia.giarratano@ed.ac.uk 
%  date: November 2019
%  Overview: Apply Frangi Filter to the OCTA images
%                     
%**************************************************************************
%
% INPUT: 
%   - images folder: training/test
%   
% PROCESS:
%   - Apply Frangi filter to OCTA images
%
% OUTPUT:
%   - folder with images enhanced: training/test
%   
% 
% NOTES: 
% To set suitable parameters of the Frangi Filter, run hyperpar_opts.m
% 
% REQUIREMENTS:
% this script requires the Hessian based Frangi Vesselness filter available
% here:https://uk.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter
% Order files https://uk.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort
% -------------------------------------------------------------------------

%% Setup & Clear memory
clear       % clear workspace
clc         % Clear Command Window
close all   % close all windows 

%% Add Matlab paths required to run the code
addpath('frangi_filter_version2a/');

% Image paths
orig_images_path = '../images/original/test';
ground_truth_path = '../images/masks/test';

% Read files
orig_images = dir(fullfile(orig_images_path,  '*.tif'));
seg_images = dir(fullfile(ground_truth_path,  '*.png'));

% create space to allocate images
orig_paths = cell(length(orig_images), 1);
seg_paths = cell(length(orig_images), 1);
NAMES = cell(length(orig_images), 1);

% initialize your variables
for i= 1:length(orig_paths)
NAMES{i} = orig_images(i).name;
orig_paths{i} = fullfile(orig_images_path, orig_images(i).name);
seg_paths{i} = fullfile(ground_truth_path, seg_images(i).name);
end

% Create output folder
output_dir = 'frangi_output'
mkdir(output_dir)

%% Apply frangi filter to all images in the chosen folder
for i= 1:length(orig_paths)
    
    % Save image name
    match = '.tif';
    newStr = erase(orig_images(i).name,match);
    
    % Read image
    I = imread(orig_paths{i});
    I = double(I);
 
    % Apply Frangi filter
    options = struct('FrangiScaleRange', [0.5 2], 'FrangiScaleRatio', 0.5, 'FrangiBetaOne', 1,...
             'FrangiBetaTwo', 15, 'verbose',true,'BlackWhite',false);

    I_filt=FrangiFilter2D(I,options);

    % Write image
    name = strcat(newStr, '_frangi.png');
    imwrite(I_filt, strcat('./', output_dir,'/', name));
end

