function A = CALarea(Sg, S, radius)
% evaluate the degree of overlapping

se = strel('disk', radius);
SgDil  = imdilate(Sg, se);
SDil  = imdilate(S, se);

Anum = (SDil & Sg) | (S & SgDil);
Aden = S | Sg;

A = length(nonzeros(Anum))/length(nonzeros(Aden));

end



