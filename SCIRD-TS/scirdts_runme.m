%**************************************************************************
%  author: Ylenia Giarratano
%  e-mail: ylenia.giarratano@ed.ac.uk 
%  date: November 2019
%  Overview: Apply SCIRD-TS Filter to OCTA images
%                     
%**************************************************************************
% INPUT: 
%    - folder containing original images
%    - folder containing ground truth
%
% OUTPUT:
%   - folder with enhanced images
% 
%% Requerements:
% SCIRD-TS package available at http://staff.computing.dundee.ac.uk/rannunziata/
% Order files https://uk.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort
% -------------------------------------------------------------------------
%% Setup & Clear memory

clear       % clear workspace
clc         % Clear Command Window
close all   % close all windows 

%% Add utils paths
addpath('../CAL/')
addpath('../ordering/')

%% Add Matlab paths required to run my code
orig_images_path =  '../images/original/training';
ground_truth_path =  '../images/masks/training';

% Read files
orig_images = dir(fullfile(orig_images_path,  '*.tif'));
[~,id] = natsortfiles({orig_images.name});
orig_images = orig_images(id)
seg_images  = dir(fullfile(ground_truth_path,  '*.png'));
[~,id] = natsortfiles({seg_images.name});
seg_images = seg_images(id)

orig_paths = cell(length(orig_images), 1);
seg_paths = cell(length(orig_images), 1);
NAMES = cell(length(orig_images), 1);

for i= 1:length(orig_paths)
NAMES{i} = orig_images(i).name;
orig_paths{i} = fullfile(orig_images_path, orig_images(i).name);
seg_paths{i} = fullfile(ground_truth_path, seg_images(i).name);

end

%% Create output folder
output_dir = 'scird-ts_output'
mkdir(output_dir)
%%

% SCIRD-TS Parameters
ridges_color = 'white';
%set filter bank parameters
fb_parameters.sigma_1 = [1 2]; 
fb_parameters.sigma_1_step = 0.5;
fb_parameters.sigma_2 = [1 2]; 
fb_parameters.sigma_2_step = 0.5; 
fb_parameters.k = [-0.1 0.1]; 
fb_parameters.k_step = 0.025; 
fb_parameters.angle_step =  20;
fb_parameters.filter_size = 9;
%set contrast-adaptation parameter
alpha = 0; 

%%

for i= 1:length(orig_paths)
    match = '.tif';
    newStr = erase(orig_images(i).name,match);
     
    % Read image
    I = imread(orig_paths{i});
    I = double(I);
    
    % Read the Ground truth
    GT_I = imread(seg_paths{i});
    GT_I = logical(GT_I);
    
    % apply SCIRD_TS
    [I_filt, properties, ALLfiltered] = SCIRD_TS(I,alpha,ridges_color,fb_parameters);
     
    % Normalize
    I_filt = (I_filt - min(I_filt(:)))./(max(I_filt(:)-min(I_filt(:))));
    imwrite(I_filt, strcat('./', output_dir,'/', newStr, '_scird-ts.png'));
    
end
