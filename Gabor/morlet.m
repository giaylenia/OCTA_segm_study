function out = morlet(dims, theta, a, epsilon, k0)

% Matlab function to implement Morlet wavelet.

% dims    - size of the wavelet space 
% a       -  scale
% epsilon - elongation
% k0      - vector with the horizontal and vertical frequencies.

r = dims(1);
c = dims(2);

% X values
x = (0:(c-1))-(c-1)/2;
x = ones(r,1)*x;

% Y values
y = (0:(r-1))'-(r-1)/2;
y = y*ones(1,c);

% Rotation by -theta
rotx = x*cos(-theta)-y*sin(-theta);
roty = x*sin(-theta)+y*cos(-theta);

%Scaling
scaledrotx = rotx/a;
scaledroty = roty/a;

% The complex exponential argument
comp_exp = exp(1i*(k0(1)*scaledrotx+k0(2)*scaledroty));

% A=[epsilon^(-0.5) 0; 0 1] only corrects x.
elongatedscaledrotx = scaledrotx*(epsilon^(-0.5));

% The gaussian arguement
gaussian2D = exp((-0.5)*(elongatedscaledrotx.^2+scaledroty.^2));

out = comp_exp.*gaussian2D;