%**************************************************************************
%  author: Ylenia Giarratano
%  e-mail: ylenia.giarratano@ed.ac.uk 
%  date: November 2019
%  Overview: Apply OOF to the OCTA images
%                     
%**************************************************************************
% INPUT: 
%   - images folder: training/test
%   
% PROCESS:
%   - This applies Frangi filter to OCTA images
%
% OUTPUT:
% folder with images binary images: training/test
%    
% REQUIREMENTS:
% -this script requires the OOF version inplemented in
% Ang, L.,Jang, Y., Congwu, D., Yiangtian, P.: Automated segmentation and quantification of OCT angiography for 
% tracking angiogenesis progression. Biomedical Optic Express \textbf{8}(12), 5604 (2017).
% -Order files https://uk.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort
% -------------------------------------------------------------------------

%% Setup & Clear memory

clear       % clear workspace
clc         % Clear Command Window
close all   % close all windows 


%% Add utils paths
addpath('../CAL/')


% Image paths
orig_images_path = '../images/original/test';
ground_truth_path = '../images/masks/test';

% Load images
orig_images = dir(fullfile(orig_images_path,  '*.tif'));
[~,id] = natsortfiles({orig_images.name});
orig_images = orig_images(id)
seg_images = dir(fullfile(ground_truth_path,  '*.png'));
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

% Create output folder
output_dir = 'OOF_binary'
mkdir(output_dir)
%% Parameters

range=0.5:0.5:2; 
sigma=0.5; 
top_hat=0;

%% Apply filter to all images
for i= 1:length(orig_paths)
    match = '.tif';
    newStr = erase(orig_images(i).name,match);
 
    I = imread(orig_paths{i});
    I = double(I);

    opts.sigma = sigma;
    [I_filt, BW]=oofseg(I,range, opts, top_hat);
    
    imwrite(BW, strcat(output_dir,'/', newStr, '_OOF.png'));

end
