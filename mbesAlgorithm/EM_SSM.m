function [SSM, logEvidence] = EM_SSM(SSM, y, varargin)
%%% EM algorithm for learning variances of sparse inputs and observation
%%% noise
%
% Copyright (C) Thilo Weber 2018 (see MIT license in the README.txt file)
%
% Inputs:
%   SSM.
%       A
%       B
%       C
%       SIGMA_U
%       SIGMA_Z
%       SIGMA_X0
%       SIGMA_W
%       xDim
%       uDim
%
%   y   % observation/data
%
% Outputs:
%   SSM with learned variances SIGMA_U, SIGMA_Z
%
%   logEvidence  % logLikelihood x log(prior(SIGMA_U, SIGMA_Z)), i.e. our learning objective

p = inputParser;
addOptional(p, 'SIGMA_U_updates', [], @isnumeric);
addOptional(p, 'SIGMA_U_prior', [], @isnumeric);
addOptional(p, 'SIGMA_Z_update', true, @islogical);
addOptional(p, 'SIGMA_Z_prior', 0, @isnumeric);
addOptional(p, 'maxsteps', 30, @isnumeric);
addOptional(p, 'verbose', false, @islogical);
parse(p,varargin{:});

logEvidence = zeros(p.Results.maxsteps,1);

for EM_count=1:p.Results.maxsteps
    if p.Results.verbose
        disp(['EM step: ' num2str(EM_count)])
    end
    
    %%% E-step:
    % Kalman Smoothing:
    [msg, logLikelihood] = kalmanSmoothing(SSM, y);
    logEvidence(EM_count) = logLikelihood;
    
    %%% M-step:
    % Sigma_Z update:
    sumE_X_X = zeros(SSM.xDim);
    for k=1:SSM.N
        sumE_X_X = sumE_X_X + msg.xMrg.V(:,:,k) + msg.xMrg.m(:,k) * msg.xMrg.m(:,k)';
    end
    if p.Results.SIGMA_Z_update
        alphaZ = p.Results.SIGMA_Z_prior;
        logEvidence(EM_count) = logEvidence(EM_count) ...
            - SSM.N * alphaZ * log(SSM.SIGMA_Z);
        SSM.SIGMA_Z = (1 / (SSM.N) * (norm(y)^2 - 2 * SSM.C * msg.xMrg.m * y' ...
            + SSM.C * sumE_X_X * SSM.C')) / (2*alphaZ + 1);
    end
        
    % Sigma_U update:
    for j=1:length(p.Results.SIGMA_U_updates)
        iu = p.Results.SIGMA_U_updates(j);
        alphaU = p.Results.SIGMA_U_prior(j,1);
        betaU = p.Results.SIGMA_U_prior(j,2);
        for k=1:SSM.N
            logEvidence(EM_count) = logEvidence(EM_count) ...
               - alphaU * log(SSM.SIGMA_U(iu,iu,k)) - betaU / SSM.SIGMA_U(iu,iu,k);
            SSM.SIGMA_U(iu,iu,k) = (msg.uMrg.m(iu,k)^2 + msg.uMrg.V(iu,iu,k) + 2*betaU) ...
                / (2*alphaU + 1);
        end
    end
    
    %%% Stop if logEvidence is converged:
    if EM_count>1
        if p.Results.verbose
            disp(['logEvidence diff: ' num2str(logEvidence(EM_count)-logEvidence(EM_count-1))])
        end
        if (logEvidence(EM_count)-logEvidence(EM_count-1))...
                /max(abs(logEvidence(EM_count)),abs(logEvidence(EM_count-1)))<0.001
            break
        end
    end
    
end

%%% Hard sparsity by setting all input variances < threshold to zero:
for iu=p.Results.SIGMA_U_updates
    alphaU = p.Results.SIGMA_U_prior(iu,1);
    betaU = p.Results.SIGMA_U_prior(iu,2);
    threshold = 50 * 2*betaU/(2*alphaU + 1);
    zeroIds = squeeze(abs(SSM.SIGMA_U(iu,iu,:))) < threshold;
    SSM.SIGMA_U(iu,iu,zeroIds) = 0;
end

end
