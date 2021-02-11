function [wtmodmax, anglemax] = maxmorlet(Ifft, a, epsilon, k0)

% Matlab function to calculate the maximum modulus morlet wavelet 

% inputs:
% Ifft    - fft2 transform of the original image
% a       - the scale
% k0      - vector with the horizontal and vertical frequencies
% epsilon - 

% outputs:
% wtmodmax - maximum response to wavelet transform
% anglemax - angle of orientation assoicated with max response of filter

[r,c] = size(Ifft);

% large_r and large_c are used so that the convolution fits
% exactly to the original image.
large_r = r + 1 + mod(r,2);
large_c = c + 1 + mod(c,2);

% pre allocate arrays
wtmodmax = -Inf*ones(r,c);
anglemax = single(zeros(r,c));

angle_step = 5;

for t = 0:angle_step:180-angle_step
  % Convert to radians
  theta = t*(pi/180);
  
  % Calculate wavelet in space domain
  wvlt = morlet([large_r large_c], theta, a, epsilon, k0);
  wvlt = wvlt(1:r,1:c);

  % Complex conjugate
  cwvlt = conj(wvlt);
  % Shift
  cwvlt = fftshift(cwvlt);
  % Convert to the frequency domain
  fcwvlt = fft2(cwvlt);

  % Multiply image by wavelet conjugate in frequency domain. The
  % conjugate below indicates correlation in space, instead of
  % convolution
  Ifftwv = Ifft.*conj(fcwvlt);

  % Convert back to space domain
  imgwv = ifft2(Ifftwv);
  % Normalize by scale a
  imgwv = imgwv/a;
  % Modulus of the result
  modimgwv = abs(imgwv);
  
  % Update the maximum
  wtmodmax = max(modimgwv,wtmodmax);
  % Update angle
  anglemax(modimgwv >= wtmodmax) = t;
end