% This function is the implementation of the measurement model.
% The bearing should be in the interval [-pi,pi)
% Inputs:
%           x(t)                           3X1
%           j                              1X1
% Outputs:  
%           h                              2X1
function z_j = observation_model(x, j)

    global map % map | 2Xn for n landmarks

    % YOUR IMPLEMENTATION %

    h = [sqrt((map(1,j)-x(1))^2+(map(2,j)-x(2))^2); 
        atan2(map(2,j)-x(2),map(1,j)-x(1))-x(3)];
    
    h(2) = mod(h(2) + pi, 2* pi) - pi;

    z_j = h;

end
