function C = CALconnectivity(Sg, S)

% compute connected components in Sg
ccSg = bwconncomp(Sg);
ccSg = ccSg.NumObjects;

% compute connected components in S
ccS = bwconncomp(S);
ccS = ccS.NumObjects;

% compute number of white pixels in ground truth
numSg = length(nonzeros(Sg));

C = 1 - min(abs(ccSg-ccS)/numSg);
end

