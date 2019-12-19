function im_std = image_std(I_avg, neigh)
pad = floor(neigh/2);

I_pad = padarray(I_avg,[pad pad],'symmetric','both');

im_std = zeros(size(I_avg));
for i = (1+pad):(size(I_avg,1)+pad)
    for j = (1+pad):(size(I_avg,1)+pad)
        I_n = I_pad(i-pad:i+pad,j-pad:j+pad);
        S = sum(I_n(:).^2);
        R = S/(neigh^2);
        im_std(i-pad,j-pad) = sqrt(R);
    end
end
