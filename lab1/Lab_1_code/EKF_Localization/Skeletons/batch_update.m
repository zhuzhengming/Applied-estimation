% This function performs the update process (sequential update).
% You need to make sure that the output sigma_bar is symmetric.
% The last line makes sure that ouput sigma_bar is always symmetric.
% Inputs:
%           mu_bar(t)       3X1
%           sigma_bar(t)    3X3
%           H_bar(t)        2nX3
%           Q_bar(t)		2nX2n
%           nu_bar(t)       2nX1
% Outputs:
%           mu(t)           3X1
%           sigma(t)        3X3
function [mu, sigma] = batch_update(mu_bar, sigma_bar, H_bar, Q_bar, nu_bar)

        % YOUR IMPLEMENTATION %
        K = sigma_bar * H_bar' / (H_bar * sigma_bar * H_bar' + Q_bar);
        mu = mu_bar + K * nu_bar;
        sigma = (eye(3,3) - K*H_bar)*sigma_bar;

        %         make sure sigma_bar is always symmetric
        sigma = (sigma + sigma') / 2;
end
