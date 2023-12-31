% This function performs the maximum likelihood association and outlier detection.
% Note that the bearing error lies in the interval [-pi,pi)
%           mu_bar(t)           3X1
%           sigma_bar(t)        3X3
%           z(t)                2Xn
% Outputs: 
%           c(t)                1Xn
%           outlier             1Xn
%           nu_bar(t)           2nX1
%           H_bar(t)            2nX3
function [c, outlier, nu_bar, H_bar] = batch_associate(mu_bar, sigma_bar, z)
        
        % YOUR IMPLEMENTATION %
        nu_bar = [];
        H_bar = [];
        n = size(z,2);
        for i = 1:n
            [c_i, outlier_i, nu_bar_i, ~, H_bar_i] = ...
            associate(mu_bar, sigma_bar, z(:,i));
            c(i) = c_i;
            outlier(i) = outlier_i;
            nu_bar = [nu_bar ; nu_bar_i(:,c_i)];
            H_bar = [H_bar ; H_bar_i(:,:,c_i)];
        end
end