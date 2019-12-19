%**************************************************************************
%  author: Ylenia Giarratano
%  e-mail: ylenia.giarratano@ed.ac.uk 
%  date: November 2019
%  Overview: Hyperparameter optimization for frangi filter in OCTA images                   
%**************************************************************************
% INPUT: chose the training folders for
%   - OCTA images
%   - Ground trouth 
%
% OUTPUT:
%   - display best choice of params
%   - table with parameters and performances

% REQUIREMENTS:
% this script requires  morlet wavelet: please contact Tom Macgillivray: tom.macgillivray@ed.ac.uk
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

%% Performance
best_dice = [];

% Parameters 
best_eps = [];
best_k0y = [];
scales = [0.5,1,1.5, 2];
pSize = 0;

% Set ranges for parameters
eps = 2:8;
k0y = 2:7;

for i= 1:length(orig_paths)
    
    % Read original image
    I = imread(orig_paths{i});
    I = double(I);
    
    % Read manually segmented image
    GT_I = imread(seg_paths{i});
    GT_I = logical(GT_I);
    
    best_sim = 0;
    for e = 1:length(eps)
        for k = 1: length(k0y)
 %     I_filt = max(gabormag,[], 3);
       [out, scales, response] = gabor_me(I, scales, pSize,e, k);
             % Rescale
             out = (out-min(out(:)))/(max(out(:))-min(out(:)));
             % Adaptive thresholding 
             T = adaptthresh(out, 0.7,  'NeighborhoodSize',[41 41],'Statistic', 'gaussian');
             BW = imbinarize(out, T);
           
             % compute performance
             similarity = dice(BW, GT_I);
            
            if similarity > best_sim
                best_sim = similarity;
                best_epsilon =  eps(e);
                best_y = k0y(k);
                figure, imshow(BW, 'InitialMagnification', 'fit')
               
            end
       end
   
    
    best_dice = [best_dice, best_sim];
    best_eps = [best_eps, best_epsilon];
    best_k0y = [best_k0y, best_y];
    end
 end


% We choose the combination that appears more times
C =  [best_eps(:)'; best_k0y(:)'; ]; 
C = C';
[uA,~,uIdx] = unique(C,'rows');
modeIdx = mode(uIdx);
modeRow = uA(modeIdx,:);

disp(['the best combination of parameters is: [' num2str(modeRow) ']']) ;

% save table of performaces
best_dice = best_dice';
best_eps = best_eps';

best_dice = mat2cell(best_dice, ones(1, size(best_dice,1)));
best_eps = mat2cell(best_eps, ones(1, size(best_eps,1)));

T = table(NAMES, best_dice , best_eps); 
writetable(T, 'table_parameters.txt')



    
    
