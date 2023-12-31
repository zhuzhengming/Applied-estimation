% This function performs systematic re-sampling
% Inputs:   
%           S_bar(t):       4XM
% Outputs:
%           S(t):           4XM
function S = systematic_resample(S_bar)
	
    global M % number of particles 
    
    % YOUR IMPLEMENTATION
    cdf = cumsum(S_bar(4,:));
    S = zeros(4,M);
    r_0 = rand / M;
    for m = 1 : M
        i = find(cdf >= r_0, 1, 'first');
        S(1:3,m) = S_bar(1:3,i);
        r_0 = r_0 + 1/M;
    end
    S(4,:) = 1 / M * ones(1,M);
end