% This function performs the maximum likelihood association and outlier detection given a single measurement.
% Note that the bearing error lies in the interval [-pi,pi)
%           mu_bar(t)           3X1
%           sigma_bar(t)        3X3
%           z_i(t)              2X1
% Outputs: 
%           c(t)                1X1
%           outlier             1X1
%           nu^i(t)             2XN
%           S^i(t)              2X2XN
%           H^i(t)              2X3XN
function [c, outlier, nu, S, H] = associate(mu_bar, sigma_bar, z_i)

    % Import global variables
    global Q % measurement covariance matrix | 1X1
    global lambda_m % outlier detection threshold on mahalanobis distance | 1X1
    global map % map | 2Xn
    
    % YOUR IMPLEMENTATION %
    n = size(map,2);
    for j = 1:n
        z_hat(:,j) = observation_model(mu_bar, j);
        H(:,:,j) = jacobian_observation_model(mu_bar, j, z_hat(:,j));
        S(:,:,j) = H(:,:,j) * sigma_bar * H(:,:,j)' + Q;
        nu(:,j) = z_i - z_hat(:,j);
        nu(2,j) = mod(nu(2,j) + pi, 2 * pi) -pi; % modify the range of angle
        psi(j) = det(2*pi*S(:,:,j))^(-1/2) * ...
            exp( (-1/2)*nu(:,j)' / S(:,:,j) * nu(:,j) );
    end

    [M, c] = max(psi);
    nu_c = nu(:,c);
    S_c = S(:,:,c);
    H_c = H(:,:,c);

%      Outlier Detection

    D_M = nu_c' / S_c * nu_c;
    if D_M >= lambda_m
        outlier = 1;  % it is a outlier
    else
        outlier = 0;
    end
    



end