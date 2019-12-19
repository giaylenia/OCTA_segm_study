%**************************************************************************
%  Overview: This script create a dataset in which each sample represents a
%  pixel and each column a features (7) computed in the pixel neighborhood
%  
%  Note: change the paths according to your folders
%
%  REQUIREMENTS:
%  Order files https://uk.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort
%**************************************************************************

%% Setup & Clear memory
 clear all 
 clc
 close all

 %% Set paths train
orig_images_path_train = '../../filter/fiter_training/'; % where filter can be Frangi, Gabor, SCIRD-TS
% Sort them by date
ground_truth_path_train = '../../images/masks/training/';
 
% Read files
orig_images = dir(fullfile(orig_images_path_train,  '*.png'));
[~,id] = natsortfiles({orig_images.name});
orig_images = orig_images(id)
seg_images = dir(fullfile(ground_truth_path_train,  '*.png'));
[~,id] = natsortfiles({seg_images.name});
seg_images = seg_images(id)

% create space to allocate images
orig_paths = cell(length(orig_images), 1);
seg_paths = cell(length(orig_images), 1);
NAMES = cell(length(orig_images), 1);

% initialize your variables
for i= 1:length(orig_paths)
NAMES{i} = orig_images(i).name;
orig_paths{i} = fullfile(orig_images_path_train, orig_images(i).name);
seg_paths{i} = fullfile(ground_truth_path_train, seg_images(i).name);

end
%% X_train
data = zeros(8281, 7, 30); %8281 pixels, 7 features, 30 images

tic
parpool(4)
parfor im= 1:length(orig_paths), data(:,:,im) = compute(orig_paths{im});end
toc 

data_p = permute(data,[1 3 2]);
data_flat = reshape(data_p,[],size(data,2),1);

ds = mat2dataset(data_flat);
export(ds,'file','../filter/X_train.txt','Delimiter','\t','WriteVarNames',false)


%% y_train
y_train = zeros(30*8281, 1);
count = 0;
for im= 1:length(orig_paths)
    GT_I = imread(seg_paths{im});
    GT_I(GT_I==255) = 1;
    labels((count*8281 +1):im*8281, 1) = GT_I(:);
    count = count +1;
end
la = mat2dataset(labels);
export(la,'file','../filer/y_train.txt','Delimiter','\t','WriteVarNames',false)
%%
function data = compute(image_path)
    % Read image
    I = double(imread(image_path))/255.0;
    
    % Compute features
    I_avg = image_avg(I, 3);
    I_std = image_std(I_avg, 3);
    I_entropy = image_entropy(I, 3);
    I_range = image_range(I,3);
    [L1,L2] = image_hess_eig(I,3,1);
    
    % Create data 
    data = zeros(8281,7);
    data(:, 1)= I(:)';
    data(:, 2)= I_avg(:)';
    data(:, 3)= I_std(:)';
    data(:, 4)= I_range(:)';
    data(:, 5)= I_entropy(:)';
    data(:, 6)= L1(:)';
    data(:, 7)= L2(:)';
    data = normalize(data, 'range', [-1,1]);
end