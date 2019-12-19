%**************************************************************************
%  author: Ylenia Giarratano
%  e-mail: ylenia.giarratano@ed.ac.uk 
%  date: November 2019
%  Overview: Apply Gabor Filter to the OCTA images                  
%**************************************************************************
% INPUT: 
%   - images folder: training/test
%   
% PROCESS:
%   - Apply Gabor filter to OCTA images
%
% OUTPUT:
%   - folder with images enhanced: training/test
%   
% 
% NOTES: 
%   - To set suitable parameters of the Gabor Filter, run hyperpar_opts.m
% 
% REQUIREMENTS:
%   - This script requires morlet wavelets, please contact Tom Macgillivray: tom.macgillivray@ed.ac.uk
%   - Order files https://uk.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort
% -------------------------------------------------------------------------
%% Setup & Clear memory

clear       % clear workspace
clc         % Clear Command Window
close all   % close all windows 

%% Add Matlab paths required to run the code

% Image paths
orig_images_path = '../images/original/train';
ground_truth_path = '../images/masks/train';

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
output_dir = 'gabor_output'
mkdir(output_dir)

%% Parameters
scales = [0.5, 1, 1.5 2];
pSize = 0;
epsilon = 2 ;
k0y=5;
%%
for i= 1:length(orig_paths)
    match = '.tif';
    newStr = erase(orig_images(i).name,match);
    
    % Read image
    I = imread(orig_paths{i});
    I_filt = double(I);
    [out, scales, response] = gabor_me(I_filt, scales, pSize, epsilon, k0y);
    figure; imshow(out,[], 'InitialMagnification', 'fit')
    out = (out-min(out(:)))/(max(out(:))-min(out(:)));

    % Save enhanced image
    name = strcat(newStr, '_gabor.png');
    imwrite(out, strcat('./', output_dir,'/', name));
  
end

   



    
    
