% This function is the implementation of the measurement model.
% The bearing should be in the interval [-pi,pi)
% Inputs:
%           S(t)                           4XM
%           j                              1X1
% Outputs:  
%           z_j                              2XM
function z_j = observation_model(S, j)

    global map % map including the coordinates of all landmarks | shape 2Xn for n landmarks
    global M % number of particles

    % YOUR IMPLEMENTATION
    h = zeros(2 , M); % pre allocation
    for i = 1:M
        h(:,i) = [sqrt((map(1,j)-S(1,i))^2+(map(2,j)-S(2,i))^2); 
                 atan2(map(2,j)-S(2,i),map(1,j)-S(1,i))-S(3,i)];
    end
    h(2,:) = mod(h(2,:) + pi, 2* pi) - pi;

    z_j = h;

end
