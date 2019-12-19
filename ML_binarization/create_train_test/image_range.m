function im_range = image_range(I, neigh)
pad = floor(neigh/2);

I_pad = padarray(I,[pad pad],'symmetric','both');

im_range = zeros(size(I));
for i = (1+pad):(size(I,1)+pad)
    for j = (1+pad):(size(I,1)+pad)
        I_n = I_pad(i-pad:i+pad,j-pad:j+pad);
        im_range(i-pad,j-pad) = I_pad(i,j) - (max(I_n(:))-min(I_n(:)));
        
    end
end