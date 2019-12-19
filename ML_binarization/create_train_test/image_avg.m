function im_avg = image_avg(I, neigh)
pad = floor(neigh/2);

I_pad = padarray(I,[pad pad],'symmetric','both');

im_avg = zeros(size(I));
for i = (1+pad):(size(I,1)+pad)
    
    for j = (1+pad):(size(I,1)+pad)
       
        I_n = I_pad(i-pad:i+pad,j-pad:j+pad) ;
        im_avg(i-pad,j-pad) = I_pad(i,j) - mean(I_n(:));
        
    end
end

