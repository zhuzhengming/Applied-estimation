% This function performs the ML data association
%           S_bar(t)                 4XM
%           z(t)                     2Xn
%           association_ground_truth 1Xn | ground truth landmark ID for
%           every measurement  
% Outputs: 
%           outlier                  1Xn    (1 means outlier, 0 means not outlier) 
%           Psi(t)                   1XnXM
%           c                        1xnxM
function [outlier, Psi, c] = associate(S_bar, z, association_ground_truth)
    if nargin < 3
        association_ground_truth = [];
    end
    global DATA_ASSOCIATION
    global lambda_psi % threshold on average likelihood for outlier detection
    global Q % covariance matrix of the measurement model
    global M % number of particles
    global N % number of landmarks
    if size(DATA_ASSOCIATION,1) == 0
    	DATA_ASSOCIATION="on";
    end

    % YOUR IMPLEMENTATION
    n = size(z,2);
    Q_M = repmat(diag(Q),[1,M,N]);%  [Q_diag, Q_diag, ......]
    Psi = zeros(n,M);
    phi = zeros(1,M,N);
    z_hat = zeros(2,M,N);
    outlier = zeros(1,n);
    for k = 1:N
        z_hat(:,:,k) = observation_model(S_bar, k);
    end

    for i = 1: n
        z_M = repmat(z(:,i) , 1 , M, N);
        nu = z_M - z_hat;
        nu(2,:,:) = mod(nu(2,:,:) + pi, 2 * pi) -pi; % modify the range of angle
    
        phi = prod(2 * pi * Q_M).^(-0.5)  ...    %M particles
        .* exp(-0.5 * sum(nu.^2 ./ Q_M , 1 ) );

        [Psi(i,:), c] = max(phi, [], 3);

        if mean(Psi(i,:)) <= lambda_psi
            outlier(i) = 1;
        else
            outlier(i) = 0;
        end
    end

    Psi = reshape(Psi,[1,n,M]);
end
