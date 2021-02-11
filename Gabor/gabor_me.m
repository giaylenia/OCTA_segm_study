function [outIm, scales, response] = gabor_me(image, scales, pSize, epsilon, k0y)

% Matlab function to apply 2D Gabor filters to an input image

% inputs:
% image     - input image
% mask      - depicts file of view
% scales    - gabor filter sizes to use
% pSize     - padding applied to image

% outputs:
% out       - output image after filtering
% scales    - vector indicating scales of the Morlet wavelet used
% response  - angular/directional response of filtering

% get computer architecture
archstr = computer('arch');

if nargin < 4
    pSize = 0;
end

out = [];
response = [];

% fft image
Ifft = fft2(image);

% parameters with values set as in Soares et al. 2006
k0x = 0;
k0y = k0y;


if isempty(scales)
    scales = [2, 3, 4, 5];
end

for i = 1:numel(scales)
    % Maximum transform over angles
    [Mtrans, Atrans] = maxmorlet(Ifft, scales(i), epsilon, [k0x k0y]);

    % crop to original size
    Mtrans = Mtrans(pSize+1:end-pSize, pSize+1:end-pSize);
    Atrans = Atrans(pSize+1:end-pSize, pSize+1:end-pSize);
    
    out = cat(3, out, Mtrans);
    response = cat(3, response, uint8(Atrans));
    
 end

% add to bank of images
out = cat(3, image, out);
outIm =  max(out,[], 3);
