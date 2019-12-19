%**************************************************************************
%  author: Ylenia Giarratano
%  e-mail: ylenia.giarratano@ed.ac.uk 
%  date: November 2019
%  Overview: Compute dice similarity coefficient and CAL metric for each
%  pair of images
%**************************************************************************

% INPUT: 
%   - folder with binary images obtained from ML classifier
%   - folder with ground truth
%   
% OUTPUT:
% Display performances 
% 
%  REQUIREMENTS:
%  Order files https://uk.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort
%
% Note: Choose your directories
% -------------------------------------------------------------------------

%% Setup & Clear memory
 clc 
 clear all
 close all
 
%% Add utils paths
addpath('../../CAL/')

% Path to images
orig_images_path =  './output_ml';
ground_truth_path = '../../images/masks/test/';

orig_images = dir(fullfile(orig_images_path,  '*.png'));
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
%% 
% DICE
dice_ml = zeros(length(orig_paths),1);

% number of connected components
cc= zeros(length(orig_paths),1);
cc_gt = zeros(length(orig_paths),1);

% CAl measure
cal = zeros(length(orig_paths),1);

% size of the largest cc
size_cc_gt = zeros(length(orig_paths),1);
size_cc_ml = zeros(length(orig_paths),1);
LCC_ratio = zeros(length(orig_paths),1);


%%
for i= 1:length(orig_paths)

   % Read ground image
    GT_I = imread(seg_paths{i});
    GT_I = logical(GT_I);
    
    % Compute skeleton
    sk_gt = bwmorph(GT_I,'thin', Inf);
 
    % Compute cc components 
    CC = bwconncomp(sk_gt);
    numOfPixels = cellfun(@numel,CC.PixelIdxList);
    [size_cc,indexOfMax] = max(numOfPixels);
    cc_gt(i) = CC.NumObjects;
    size_cc_gt(i) = size_cc;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    % Read original image
    I = imread(orig_paths{i});
    % Rotate and flip
    I = imrotate(I, 90);
    I = flipdim(I, 1);
   
    bw = logical(I);
    bw =  bwareaopen(bw,7);
    imwrite(bw*255, strcat('./flip/', NAMES{i}))
    
    % Compute skeleton
    sk_ml = bwmorph(bw,'thin', Inf);
    % Connected components
    CC = bwconncomp(sk_ml);
    numOfPixels = cellfun(@numel,CC.PixelIdxList);
    [size_cc,indexOfMax] = max(numOfPixels);
    cc(i) = CC.NumObjects;
    size_cc_ml(i) = size_cc;
     
    % DICE
    dice_ml(i)= dice(GT_I, bw);

        
    %% Compute connectivity
    C = CALconnectivity(GT_I, bw);
    A = CALarea(GT_I, bw, 1);
    L = CALlength(GT_I, bw, 1);
    CAL = C*A*L;
    cal(i) = CAL;
    
    LCC_ratio(i) =1-( abs( size_cc_ml(i) -  size_cc_gt(i))/ size_cc_gt(i));
 
end
%%
fprintf('CAL threshold: %d\n', mean(cal));
fprintf('################################################ \n');

fprintf('LCC ratio: %d\n', mean(LCC_ratio));
fprintf('################################################ \n');

fprintf('mean size of LCC in gt: %d \n', mean(size_cc_gt));
fprintf('mean size of LCC : %d \n', mean(size_cc_ml));

fprintf('################################################ \n');


fprintf('mean cc threshold: %d\n', mean(cc))
fprintf('mean gt ground truth: %d \n', mean(cc_gt))

fprintf('################################################ \n');

fprintf('mean dice threshold: %d \n', mean(dice_ml));

 
T = table(NAMES, dice_ml ,cc_gt, cc, size_cc_gt, size_cc_ml, LCC_ratio); 
writetable(T, 'table_performances.txt')

