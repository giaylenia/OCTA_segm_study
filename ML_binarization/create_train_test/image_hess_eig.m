function [L1, L2] = image_hess_eig (I, neigh, sigma)
pad = floor(neigh/2);

I_pad = padarray(I,[pad pad],'symmetric','both');
L1 = zeros(size(I));
L2 = zeros(size(I));


for i = (1+pad):(size(I,1)+pad)
    for j = (1+pad):(size(I,1)+pad)
        I_n = I_pad(i-pad:i+pad,j-pad:j+pad);
        
        [Dxx,Dxy,Dyy] = Hessian2D(I_n, sigma);
        [Lambda1,Lambda2,Ix,Iy]=eig2image(Dxx,Dxy,Dyy);
        L1(i-pad, j-pad) = Lambda1(2,2);
        L2(i-pad, j-pad) = Lambda2(2,2);
 
        
    end
end