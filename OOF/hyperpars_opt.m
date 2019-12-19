%**************************************************************************
%  author: Ylenia Giarratano
%  e-mail: ylenia.giarratano@ed.ac.uk 
%  date: November 2019
%  Overview: Parameters optimization for OOF on OCTA images                  
%**************************************************************************
% 
%
% INPUT: 
%   - Folder with training images
%   - folder with ground truth
%
% OUTPUT:
%   - display optimal configuration
%
% REQUIREMENTS:
% this script require the OOF version inplemented in
% Ang, L.,Jang, Y., Congwu, D., Yiangtian, P.: Automated segmentation and quantification of OCT angiography for 
% tracking angiogenesis progression. Biomedical Optic Express \textbf{8}(12), 5604 (2017)
% Order files https://uk.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort
% -------------------------------------------------------------------------

%% Setup & Clear memory

clear       % clear workspace
clc         % Clear Command Window
close all   % close all windows 

%% Add utils paths
addpath('../CAL/')

orig_images_path =  '../images/original/training';
ground_truth_path =  '../images/masks/training';

% Read files
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

%% Performances and parameters
best_dice = [];
best_sigma = [];

range=0.5:0.5:2; 
sigma = [0.5, 1];  
top_hat=0;

% Parameters
tic
for i= 1:length(orig_paths)
    I = imread(orig_paths{i});
    GT_I = imread(seg_paths{i});
    GT_I = logical(GT_I);
    I_filt = double(I);
    best_sim = 0;
    for ii = 1:length(sigma)
        opts.sigma = sigma(ii);
        [I_filt, BW]=oofseg(I_filt,range,opts, top_hat); % modify oofseg by Ang Lee to get two outputs
        %I_filt = (I_filt-min(I_filt(:)))/(max(I_filt(:)-min(I_filt(:))));
        similarity = dice(BW, GT_I);
        if max(similarity)> best_sim
           [best_sim,idx] = max(similarity);
           best_sig = sigma(ii);
          
        end
    
    end
    best_dice = [best_dice, best_sim];
    best_sigma = [best_sigma, best_sig];
    

    

end
disp(['The best sigma is: [' num2str(mode(best_sigma(:)).') ']']) ;

best_dice = best_dice';
best_sigma = best_sigma';


best_dice = mat2cell(best_dice, ones(1, size(best_dice,1)));
best_sigma = mat2cell(best_sigma, ones(1, size(best_sigma,1)));


T = table(NAMES, best_dice , best_sigma); 
writetable(T, 'table_parameters-oof.txt')



    
    
