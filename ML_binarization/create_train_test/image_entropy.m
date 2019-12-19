function im_entropy = image_entropy(I, neigh)
pad = floor(neigh/2);

I_pad = padarray(I,[pad pad],'symmetric','both');

im_entropy = zeros(size(I));
for i = (1+pad):(size(I,1)+pad)
    for j = (1+pad):(size(I,1)+pad)
        I_n = I_pad(i-pad:i+pad,j-pad:j+pad);
        im_entropy(i-pad,j-pad) = entropy(I_n);
        
    end
end