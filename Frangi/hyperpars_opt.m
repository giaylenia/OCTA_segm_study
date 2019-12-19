%**************************************************************************
%  author: Ylenia Giarratano
%  e-mail: ylenia.giarratano@ed.ac.uk 
%  date: November 2019
%  Overview: Hyperparameter optimization for frangi filter in OCTA images
%                     
%**************************************************************************
% INPUT: training folders:
%   - OCTA images
%   - Ground trouth 

% OUTPUT:
%   - display best choice of parameters
%   - table with parameters and performances

% REQUIREMENTS:
% this script require the Hessian based Frangi Vesselness filter available
% here:https://uk.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter
% Order files https://uk.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort
% -------------------------------------------------------------------------

%% Setup & Clear memory

clear       % clear workspace
clc         % Clear Command Window
close all   % close all windows 

%% Load images and masks
orig_images_path =  '../images/original/training';
ground_truth_path =  '../images/masks/training';

% Read files in order
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

%% Performances
best_dice = [];

% Parameters to search
best_beta = [];
best_c = [];

% Set ranges for parameters
beta = [0.5,1,2];
c = [5,10, 15 20];

%% Run through all the images
for i= 1:length(orig_paths)
    
    % Read original image
    I = imread(orig_paths{i});
    I = double(I);
    
    % Read manually segmented image
    GT_I = imread(seg_paths{i});
    GT_I = logical(GT_I);
    
    best_sim = 0;
    for b = 1:length(beta)
       for t = 1:length(c)
           options = struct('FrangiScaleRange', [0.5 2], 'FrangiScaleRatio', 0.5, 'FrangiBetaOne', beta(b),...
            'FrangiBetaTwo', c(t), 'verbose',true,'BlackWhite',false);
             I_filt=FrangiFilter2D(I,options);
             
             % Adaptive thresholding 
             T = adaptthresh(I_filt, 0.7,  'NeighborhoodSize',[41 41],'Statistic', 'gaussian');
             BW = imbinarize(I_filt, T);
           
             % compute performance
             similarity = dice(BW, GT_I);
            
            if similarity > best_sim
                best_sim = similarity;
                best_b = beta(b);
                best_t = c(t);
            end
       end
    end
    
    best_dice = [best_dice, best_sim];
    best_beta = [best_beta, best_b];
    best_c = [best_c, best_t];
end    

% We choose the combination that appears more times
C =  [best_beta(:)'; best_c(:)'; ]; 
C = C';
[uA,~,uIdx] = unique(C,'rows');
modeIdx = mode(uIdx);
modeRow = uA(modeIdx,:);

disp(['the best combination of parameters is: [' num2str(modeRow) ']']) ;

% save table of performaces
best_dice = best_dice';
best_beta = best_beta';
best_c = best_c';

best_dice = mat2cell(best_dice, ones(1, size(best_dice,1)));
best_beta = mat2cell(best_beta, ones(1, size(best_beta,1)));
best_c = mat2cell(best_c, ones(1, size(best_c,1)));


T = table(NAMES, best_dice , best_beta, best_c); 
writetable(T, 'table_parameters.txt')



    
    
