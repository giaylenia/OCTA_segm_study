%**************************************************************************
%  author: Ylenia Giarratano
%  e-mail: ylenia.giarratano@ed.ac.uk 
%  date: November 2019
%**************************************************************************
% INPUT: 
%   - folder with enhanced images
%   
% PROCESS:
%   - binarize images
%
% Requirements
%   - add CAL functions
%   - order files https://uk.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort
% OUTPUT:
%   - folder with binary images
%   - table of performaces
% -------------------------------------------------------------------------
%% Setup & Clear memory
clear       % clear workspace
clc         % Clear Command Window
close all   % close all windows 
%% Retrieve paths

% Add utils paths
addpath('../../CAL/')
addpath('../ordering');

% Path to images
orig_images_path =  './gabor_test/';
ground_truth_path =  '../images/masks/test/';

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

%% Create output folder
output_dir = 'binary_images';
mkdir(output_dir)
%% Initialise measuraments

% DICE
dice_ad = zeros(length(orig_paths),1);

% number of connected components
cc_ad = zeros(length(orig_paths),1);
cc_gt = zeros(length(orig_paths),1);

% CAl measures

cal_ad = zeros(length(orig_paths),1);

% size of teh largest cc
size_cc_gt = zeros(length(orig_paths),1);
size_cc_ad = zeros(length(orig_paths),1);
LCC_ratio = zeros(length(orig_paths),1);


%% Binarize all images and compute performances
for i= 1:length(orig_paths)    

   % Read manually segmented image
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
    I = double(I)/255.0;

    % Binarization
    T = adaptthresh(I, 0.7, 'NeighborhoodSize', [41 41],'Statistic', 'gaussian');
    bw_ad = imbinarize(I,T);
    
    % Remove small noise
    bw_ad = bwareaopen(bw_ad,7);
    figure;imshow(bw_ad, 'InitialMagnification', 'fit')
    
    % DICE
    dice_ad(i)= dice(GT_I, bw_ad);
    
    % Compute skeleton
    sk_ad = bwmorph(bw_ad,'thin', Inf);
    
    % Connected components
    CC = bwconncomp(sk_ad);
    numOfPixels = cellfun(@numel,CC.PixelIdxList);
    [size_cc,indexOfMax] = max(numOfPixels);
    cc_ad(i) = CC.NumObjects;
    size_cc_ad(i) = size_cc;
            
    %% Compute connectivity
    C = CALconnectivity(GT_I, bw_ad);
    A = CALarea(GT_I, bw_ad, 1);
    L = CALlength(GT_I, bw_ad, 1);
    CAL = C*A*L;
    cal_ad(i) = CAL;
    
    LCC_ratio(i) =  1 - (abs( size_cc_ad(i) -  size_cc_gt(i))/ size_cc_gt(i));
    imwrite(bw_ad, strcat('./', output_dir,'/', NAMES{i}));
end
%%
fprintf('CAL threshold: %d\n', mean(cal_ad));
fprintf('################################################ \n');

fprintf('LCC ratio: %d\n', mean(LCC_ratio));
fprintf('################################################ \n');

fprintf('mean size of LCC in gt: %d \n', mean(size_cc_gt));
fprintf('mean size of LCC : %d \n', mean(size_cc_ad));

fprintf('################################################ \n');

fprintf('mean dice threshold: %d \n', mean(dice_ad));

fprintf('mean cc threshold: %d\n', mean(cc_ad))
fprintf('mean gt ground truth: %d \n', mean(cc_gt))

 
T = table(NAMES, dice_ad , cc_gt, cc_ad,  size_cc_gt, size_cc_ad, LCC_ratio); 
writetable(T, 'table_performances.txt')

