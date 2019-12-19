
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

% SCIRD-TS Parameters
ridges_color = 'white';
%set filter bank parameters
fb_parameters.sigma_1 = [1 2]; 
fb_parameters.sigma_1_step = 0.5;
fb_parameters.sigma_2 = [1 2]; 
fb_parameters.sigma_2_step = 0.5; 
fb_parameters.k = [-0.1 0.1]; 
fb_parameters.k_step = 0.025; 
fb_parameters.angle_step =  20;
fb_parameters.filter_size = 9;
%set contrast-adaptation parameter
alpha = 0.0; 
    
%% Apply SCIRD-TS
[I_filt, properties, ALLfiltered] = SCIRD_TS(I,alpha,ridges_color,fb_parameters);
     
% Normalize
I_filt = (I_filt - min(I_filt(:)))./(max(I_filt(:)-min(I_filt(:))));
figure, imshow(I_filt, 'InitialMagnification', 'fit')
    
%% Binarization
T = adaptthresh(I_filt, 0.7, 'NeighborhoodSize',[51 51],'Statistic', 'gaussian');
BW = imbinarize(I_filt, T);

% remove small components
BW=bwareaopen(BW,15);

figure, imshow(BW, 'InitialMagnification', 'fit')