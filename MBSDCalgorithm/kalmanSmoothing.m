function [messages, logLikelihood] = kalmanSmoothing(SSM, y)
%%% Kalman Smoothing by Gaussian message passing
%
% Copyright (C) Thilo Weber 2019 (see MIT license in the README.txt file)
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
%   y   % observation, data
%
% Outputs:
%   messages.      % Means and variances of posterior distributions over latent variables
%       ... ==> see bottom
%
%   logLikelihood  % of observation y given SSM


N = SSM.N;

A = SSM.A;
xDim = SSM.xDim;

if isfield(SSM, 'SIGMA_W')
    SIGMA_W = SSM.SIGMA_W;
else
    SIGMA_W = zeros(xDim);
end

if isfield(SSM, {'uDim', 'm_U', 'SIGMA_U', 'B'})
    m_fwdU = SSM.m_U;
    V_fwdU = SSM.SIGMA_U;
    B = SSM.B;
    uDim = SSM.uDim;
else
    uDim = 0;
    m_fwdU = zeros(uDim,N);
    V_fwdU = zeros(uDim,uDim,N);
    B = zeros(xDim,uDim);
end

C = SSM.C;
yDim = SSM.yDim;
SIGMA_Z = SSM.SIGMA_Z;

G = zeros(yDim, yDim, N);
F = zeros(xDim, xDim, N);

logLikelihood = 0;
%logLikelihood = zeros(1,N);

%%% Forward message passing:
m_fwdX = zeros(xDim, N);
V_fwdX = zeros(xDim, xDim, N);

m_fwdXprm = zeros(xDim, N);
V_fwdXprm = zeros(xDim, xDim, N);

for k=1:N
    if k==1
        m_fwdX(:,k) = A * SSM.m_X0 + B * m_fwdU(:,k);
        V_fwdX(:,:,k) = A * SSM.SIGMA_X0 * A' ...
            + B * V_fwdU(:,:,k) * B' + SIGMA_W;
    else
        m_fwdX(:,k) = A * m_fwdXprm(:,k-1) + B * m_fwdU(:,k);
        V_fwdX(:,:,k) = A * V_fwdXprm(:,:,k-1) * A' ...
            + B * V_fwdU(:,:,k) * B' + SIGMA_W;
    end
    
    if length(SIGMA_Z)>1
        G(:,:,k) = (SIGMA_Z(k) + C * V_fwdX(:,:,k) * C')^(-1);
    else
        G(:,:,k) = (SIGMA_Z + C * V_fwdX(:,:,k) * C')^(-1);
    end
    F(:,:,k) = eye(xDim, xDim) - V_fwdX(:,:,k) * C' * G(:,:,k) * C;
    alpha_k = y(:,k) - C * m_fwdX(:,k);
    
    m_fwdXprm(:,k) = m_fwdX(:,k) + V_fwdX(:,:,k) * C' * G(:,:,k) * alpha_k;
    V_fwdXprm(:,:,k) = F(:,:,k) * V_fwdX(:,:,k);
    
    logLikelihood = logLikelihood ...
        - 0.5*(log(2 * pi * det(G(:,:,k))^(-1)) + alpha_k' * G(:,:,k) * alpha_k);
    %logLikelihood(k) = - 0.5*(log(2 * pi * det(G(:,:,k))^(-1)) + alpha_k' * G(:,:,k) * alpha_k);
end


%%% Backward massage passing:
m_mrgX = zeros(xDim, N);
V_mrgX = zeros(xDim, xDim, N);

m_mrgU = zeros(uDim, N);
V_mrgU = zeros(uDim, uDim, N);

m_mrgY = zeros(yDim, N);
V_mrgY = zeros(yDim, yDim, N);

zeta_mrgX = zeros(xDim, N);
W_mrgX = zeros(xDim, xDim, N);

% zeta_mrgU = zeros(uDim, N);
% W_mrgU = zeros(uDim, uDim, N);

for k=N:-1:1
    if k==N
        zeta_mrgX(:,k) = -C' * G(:,:,k) * (y(:,k) - C * m_fwdX(:,k));
        W_mrgX(:,:,k) = C' * G(:,:,k) * C;
        
%         W_mrgXNp1 = (A*F(:,:,n)*V_fwdX(:,:,n)*A' + LSSM.V_XNp1)^(-1);
%         zeta_mrgXNp1 = W_mrgXNp1 * A*(m_fwdX(:,n) ...
%             + V_fwdX(:,:,n)*C'*G(:,:,n)*(yTld(:,n)-C*m_fwdX(:,n)));
%         zeta_mrgX(:,k) = F(:,:,k)' * A' * zeta_mrgXNp1 ...
%             - C' * G(:,:,k) * (yTld(:,k) - C * m_fwdX(:,k));
%         W_mrgX(:,:,k) = F(:,:,k)' * A' * W_mrgXNp1 * A * F(:,:,k) ...
%             + C' * G(:,:,k) * C;
    else
        zeta_mrgX(:,k) = F(:,:,k)' * A' * zeta_mrgX(:,k+1) ...
            - C' * G(:,:,k) * (y(:,k) - C * m_fwdX(:,k));
        W_mrgX(:,:,k) = F(:,:,k)' * A' * W_mrgX(:,:,k+1) * A * F(:,:,k) ...
            + C' * G(:,:,k) * C;
    end
    
    m_mrgX(:,k) = m_fwdX(:,k) - V_fwdX(:,:,k) * zeta_mrgX(:,k);
    V_mrgX(:,:,k) = V_fwdX(:,:,k) ...
        - V_fwdX(:,:,k) * W_mrgX(:,:,k) * V_fwdX(:,:,k);
    
    m_mrgU(:,k) = m_fwdU(:,k) - V_fwdU(:,:,k) * B' * zeta_mrgX(:,k);
    V_mrgU(:,:,k) = V_fwdU(:,:,k) ...
        - V_fwdU(:,:,k) * B' * W_mrgX(:,:,k) * B * V_fwdU(:,:,k);
    
    m_mrgY(:,k) = C * m_mrgX(:,k);
    V_mrgY(:,:,k) = C * V_mrgX(:,:,k) * C';
    
    % Backward message uBwd:
    %for i=1:LSSM.uDim
%     W_mrgU(:,:,k) = B' * W_mrgX(:,:,k) * B;
%     %V_bwdU(:,:,k) = (V_fwdU(:,:,k) * (W_mrgU(:,:,k)+0.00001))^(-1) * V_mrgU(:,:,k);
%     zeta_mrgU(:,k) = B' * zeta_mrgX(:,k);
%     %m_bwdU(:,k) = m_mrgU(:,k) - V_bwdU(:,:,k) * zeta_mrgU(:,k);
%     m_bwdU(:,k) = (m_mrgU(:,k)*V_fwdU(:,:,k) - m_fwdU(:,k)*V_mrgU(:,:,k)) / (V_fwdU(:,:,k) - V_mrgU(:,:,k));
%     V_bwdU(:,:,k) = max(0,V_mrgU(:,:,k)*V_fwdU(:,:,k) / (V_fwdU(:,:,k) - V_mrgU(:,:,k)));
%     %end
    
end

% Marginal distribution of X0:
zeta_mrgX0 = A' * zeta_mrgX(:,1);
W_mrgX0 = A' * W_mrgX(:,:,1) * A;
m_mrgX0 = SSM.m_X0 - SSM.SIGMA_X0 * zeta_mrgX0;
V_mrgX0 = SSM.SIGMA_X0 - SSM.SIGMA_X0 * W_mrgX0 * SSM.SIGMA_X0;


%%% Outputs:
messages.xMrg.m = m_mrgX;
messages.xMrg.V = V_mrgX;
messages.xMrg.zeta = zeta_mrgX;
messages.xMrg.W = W_mrgX;

messages.xFwd.m = m_fwdX;
messages.xFwd.V = V_fwdX;

messages.uMrg.m = m_mrgU;
messages.uMrg.V = V_mrgU;

messages.yMrg.m = m_mrgY;
messages.yMrg.V = V_mrgY;

messages.x0Mrg.m = m_mrgX0;
messages.x0Mrg.V = V_mrgX0;

%messages.uBwd.m = m_bwdU;
%messages.uBwd.V = V_bwdU;
%messages.uMrg.zeta = zeta_mrgU;
%messages.uMrg.W = W_mrgU;

%SSM.F = F;
%SSM.G = G;

end