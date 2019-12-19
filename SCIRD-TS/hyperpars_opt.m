%**************************************************************************
%  author: Ylenia Giarratano
%  e-mail: ylenia.giarratano@ed.ac.uk 
%  date: November 2019
%  Overview: find best parameters for SCIRD-TS on OCTA images
%                     
%**************************************************************************
%
% INPUT: 
%   - folder with OCTA images
%   - folder with ground truth
%
%
% OUTPUT:
%   - print the best parameters configuration
%
% Requerements:
% SCIRD-TS package available at http://staff.computing.dundee.ac.uk/rannunziata/
% Order files https://uk.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort
% -------------------------------------------------------------------------

%% Setup & Clear memory

clear       % clear workspace
clc         % Clear Command Window
close all   % close all windows 

%% Add utils paths
addpath('../CAL/')

%% Load images and masks
orig_images_path =  '../images/original/training';
ground_truth_path =  '../images/masks/training';
% Read files
orig_images = dir(fullfile(orig_images_path,  '*.tif'));
[~,id] = natsortfiles({orig_images.name});
orig_images = orig_images(id);
seg_images = dir(fullfile(ground_truth_path,  '*.png'));
[~,id] = natsortfiles({seg_images.name});
seg_images = seg_images(id);

orig_paths = cell(length(orig_images), 1);
seg_paths = cell(length(orig_images), 1);
NAMES = cell(length(orig_images), 1);

for i= 1:length(orig_paths)
NAMES{i} = orig_images(i).name;
orig_paths{i} = fullfile(orig_images_path, orig_images(i).name);
seg_paths{i} = fullfile(ground_truth_path, seg_images(i).name);
end

%% SCIRD-TS Parameters
ridges_color = 'white';

%set filter bank parameters
fb_parameters.sigma_1 = [1 2]; 
fb_parameters.sigma_1_step = 0.5;
fb_parameters.sigma_2 = [1  2]; 
fb_parameters.sigma_2_step = 0.5; 
fb_parameters.k = [-0.1 0.1]; 
fb_parameters.k_step = 0.025; 


% set of parameter to change
angle = [5, 10, 15, 20];
filter_size = [9 15 21, 27];
alphas = [-0.1, -0.05 0, 0.05, 0.1, 0.5, 1];

%%
best_dice = [];
best_angle = [];
best_al = [];
best_fsize = [];

for  i= 1:length(orig_paths)
    best_sim = 0;
    for aa = 1:length(angle)
        for ff  = 1:length(filter_size)
            for ap  = 1:length(alphas)
                fb_parameters.angle_step = angle(aa);
                fb_parameters.filter_size = filter_size(ff);
                alpha = alphas(ap);
    
                I = imread(orig_paths{i});
                I = double(I);
                GT_I = imread(seg_paths{i});
                GT_I = logical(GT_I);
                [I_filt, properties, ALLfiltered] = SCIRD_TS(I,alpha,ridges_color,fb_parameters);

                I_filt = I_filt./max(I_filt);
                T = adaptthresh(I_filt, 0.7, 'NeighborhoodSize',[51 51],'Statistic', 'gaussian');
                BW = imbinarize(I_filt, T);
    
                
                %BW = imbinarize(I_filt, 'adaptive');
                similarity = dice(BW, GT_I);
            
                if similarity > best_sim
                   best_sim = similarity;
                   best_aa = angle(aa);
                   best_ff = filter_size(ff);
                   best_alpha = alphas(ap);
                end
             end 
        end
    end
    best_dice = [best_dice, best_sim];
    best_fsize = [best_fsize, best_ff];
    best_angle = [best_angle, best_aa];
    best_al = [best_al, best_alpha];
end

%% Save table of parameters

best_dice2 = mat2cell(best_dice(:), ones(1, size(NAMES,1)));
filter_size2 =  mat2cell(best_fsize(:), ones(1, size(NAMES,1)));
angle2 = mat2cell(best_angle(:), ones(1, size(NAMES,1)));
alpha2 = mat2cell(best_al(:), ones(1, size(NAMES,1)));
S = table(NAMES, best_dice2 , angle2, filter_size2, alpha2); 
writetable(S, 'table_parameters.txt')

C =  [best_angle(:)'; best_fsize(:)'; best_al(:)']; 
C = C';
[uA,~,uIdx] = unique(C,'rows');
modeIdx = mode(uIdx);
modeRow = uA(modeIdx,:) %# the first output argument
whereIdx = find(uIdx==modeIdx) %# the second output argument

    
    
