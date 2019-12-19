%**************************************************************************
% INPUT: 
%   - test whole OCTA image
%   
% PROCESS:
%   - Apply Frangi filter to OCTA image
% 
% REQUIREMENTS:
% this script requires the Hessian based Frangi Vesselness filter available
% here:https://uk.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter
% -------------------------------------------------------------------------
  
%% Clear memory

clear       % clear workspace
clc         % Clear Command Window
close all   % close all windows 

%% Load image

[filename,pathname]  = uigetfile('*.*','Select the OCTA image processing');
I = imread(strcat(pathname,filename));

%% Extract Green Channel
I = double(I(:,:,2));
figure,imshow(I,[], 'InitialMagnification', 'fit')
  
%% Apply Frangi filter
options = struct('FrangiScaleRange', [0.5, 2], 'FrangiScaleRatio',0.5 , 'FrangiBetaOne', 1,...
             'FrangiBetaTwo', 15, 'verbose',true,'BlackWhite',false);
     
I_filt=FrangiFilter2D(I,options);

%% Binarization
T = adaptthresh(I_filt, 0.7, 'NeighborhoodSize',[41 41],'Statistic', 'gaussian');
BW = imbinarize(I_filt, T);

% remove small components
BW=bwareaopen(BW,15);

figure, imshow(BW, 'InitialMagnification', 'fit')

% save image
imwrite(BW, 'binary_test.png')
