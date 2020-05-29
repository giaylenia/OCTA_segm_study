% Create txt file that describes the cubical complex i.e. the image. 
% According to the Perseus format (which is used in teh GUDHI library)
% The first line contains a number d begin the dimension of the bitmap (2 in the example below). 
% Next d lines are the numbers of top dimensional cubes in each dimensions. 
% Next, in lexicographical order, the filtration of top dimensional cubes is given 

%% Clear environment
 clc 
 clear all
 close all
 
%% Load images 
% Path to images
images_path = './images/';
seg_images = dir(fullfile(images_path,  '*.png'));

seg_paths = cell(length(seg_images), 1);
NAMES = cell(length(seg_images), 1);

for i= 1:length(seg_paths)
 NAMES{i} = seg_images(i).name;
 seg_paths{i} = fullfile(images_path, seg_images(i).name);
end

%% Output folder
folder = './OCTAcubicalcomplex/images/'

%% Read the image 
for i= 1:length(seg_paths)
I = imread(seg_paths{i});
[path, name, ext] = fileparts(NAMES{i});

% invert image  & transform according to Perseus format
I = imcomplement(I);
I2 = flipud(I);
I3 = reshape(I2.',1,[]);
dim = 2;

% Print in  txt file
fileID = fopen(strcat(folder, name, '.txt'),'w');
fprintf(fileID,'%d\n', dim);
fprintf(fileID,'%d\n', size(I,1));
fprintf(fileID,'%d\n', size(I,2));
fprintf(fileID,'%d\n', I3);
fclose(fileID);
end
