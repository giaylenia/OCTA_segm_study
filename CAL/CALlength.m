function L = CALlength(Sg, S, radius)

% compute skeletons 
SgSkel = bwmorph(Sg, 'thin', Inf);
SSkel = bwmorph(S, 'thin', Inf);

se = strel('disk', radius);
SgDil  = imdilate(SgSkel, se);
SDil  = imdilate(SSkel, se);

lnum = (SSkel & SgDil) | (SDil & SgSkel);
lden = SSkel | SgSkel;
L = length(nonzeros(lnum))/length(nonzeros(lden));
end