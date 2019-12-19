%**************************************************************************
% INPUT: 
%   - test whole OCTA image
%   
% PROCESS:
%   - This applies OOF to OCTA image
% 
% REQUIREMENTS:
% this script require the OOF version inplemented in
% Ang, L.,Jang, Y., Congwu, D., Yiangtian, P.: Automated segmentation and quantification of OCT angiography for 
% tracking angiogenesis progression. Biomedical Optic Express \textbf{8}(12), 5604 (2017)
  
%% Clear memory

clear       % clear workspace
clc         % Clear Command Window
close all   % close all windows 

%% Load image

[filename,pathname]  = uigetfile('*.*','Select the OCTA image processing');
I = imread(strcat(pathname,filename));

%% Extract Green Channel
I = double(I);
figure,imshow(I,[], 'InitialMagnification', 'fit')
  

%% Apply  OOF
range=0.5:0.5:2; % 
sigma=0.5; % 
top_hat=0;
opts.sigma = sigma;
[I_oof, BW] =oofseg(I,range, opts, top_hat);
BW = bwareaopen(BW,20);
figure; imshow(BW, 'InitialMagnification', 'fit')

% save image
imwrite(BW, 'binary_test.png')
