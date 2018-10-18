function SSM = loadSSM(sigmaNoise, sigmaFem, sigmaSpem, ...
    plantModelType, spemModelType, signals)
%%% Load complete SSM of physiological and measurement model of eye
%%% movements
%
% Copyright (C) Thilo Weber 2018 (see MIT license in the README.txt file)
%
% inputs:
%   sigmaNoise
%   sigmaFem
%   sigmaSpem
%   plantModelType: ['Zhou09Human', 'Zhou09Monkey', 'Bahill80']
%   spemModelType: ['firstOrderHold', 'sinusoidalVelocity', 'none']
%   signals.dataLen
%   signals.samplingRate

SSM.N = signals.dataLen;
SSM.Ts = 1/signals.samplingRate;

%%% Define blink model: %%%
A_blink = 1;
B_blink = 1;
C_blink = 1;
xBlinkDim = 1;
uBlinkDim = 1;

%%% Define plant model: %%%
if strcmp(plantModelType, 'Zhou09Human')
    Jp = 2.2e-3; %Jp, [Ns^2/m]
    r = 0.011; %r, [m]
    Kse = 125; %Kse, [N/m]
    Klt = 60.7; %Klt, [N/m]
    B1 = 5.6; %B1, [Ns/m]
    B2 = 0.5; %B2, [Ns/m]
    Kp = 16.34; %Kp, [N/m]
    Bp = 0.327; %Bp, [Ns/m]
    tau = 0.009; %tau, [s], TDE = 0.0054; TAC = 0.009;
elseif strcmp(plantModelType, 'Zhou09Monkey')
    Jp = 1.76e-3; %Jp, [Ns^2/m]
    r = 0.01; %r, [m]
    Kse = 125; %Kse, [N/m]
    Klt = 77.66; %Klt, [N/m]
    B1 = 4; %B1, [Ns/m]
    B2 = 0.4; %B2, [Ns/m]
    Kp = 10.21; %Kp, [N/m]
    Bp = 0.204; %Bp, [Ns/m]
    tau = 0.007; %tau, [s], TDE = 0.0054; TAC = 0.009;
elseif strcmp(plantModelType, 'Bahill80')
    Jp = 2.2e-3; %Jp, [Ns^2/m]
    r = 0.011; %r, [m]
    Kse = 125; %Kse, [N/m]
    Klt = 60; %Klt, [N/m]
    B1 = 2.36; %B1, [Ns/m]
    B2 = 0.00001; %B2, [Ns/m]
    Kp = 25; %Kp, [N/m]
    Bp = 3.1; %Bp, [Ns/m]
    tau = 0.009; %tau, [s], TDE = 0.0054; TAC = 0.009;
else
    disp(['plantModelType: ' plantModelType ...
        ' -- Invalid argument, should be [Zhou09Human, Zhou09Monkey, Bahill80]'])
end

B12 = B1 + B2;
Kst = Kse + Klt;
P3 = Jp*B12;
P2 = Jp*Kst + B12*Bp + 2*B1*B2;
P1 = 2*B1*Kse + 2*B2*Klt + B12*Kp + Kst*Bp;
P0 = Kst*Kp + 2*Klt*Kse;
delta = 57.296 / (r*P3);
R3 = delta*(Kse - B2/tau);
R2 = P2 / P3;
R1 = P1 / P3;
R0 = P0 / P3;

% Contionous-time SSM:
A_plant_cont = [0, 1, 0, 0; 0, 0, 1, 0; ...
-R0, -R1, -R2, R3; 0, 0, 0, -1/tau];
B_plant_cont = [0; 0; B2/tau; 1/tau];

% Discrete-time SSM:
sysc = ss(A_plant_cont, B_plant_cont, eye(4), 0);
SSM.plantSSMdiscrete = c2d(sysc,SSM.Ts,'zoh');
A_plant = SSM.plantSSMdiscrete.A;
B_plant = SSM.plantSSMdiscrete.B;
C_plant = [1, 0, 0, 0];
xPlantDim = 4;
B_plantComplete = zeros(xPlantDim,0);

% Initial plant model parameters:
m_X0_plant = zeros(xPlantDim,1);
SIGMA_X0_plant = zeros(xPlantDim);
SIGMA_X0_plant(1,1) = 10;
SIGMA_X0_plant(2,2) = 10;
SIGMA_X0_plant(3,3) = 10;
SIGMA_X0_plant(4,4) = 5;


%%% Define saccade model: %%%
A_sacc = 1;
B_sacc = 1;
C_sacc = 1;
xSaccDim = 1;
uSaccDim = 1;
% Initialize parameters:
m_X0_sacc = zeros(xSaccDim,1);
SIGMA_X0_sacc = zeros(xSaccDim);
SIGMA_X0_sacc(1,1) = 5;

    
%%% Define SPEM model: %%%
if strcmp(spemModelType, 'firstOrderHold')
    SSM.A_spem = [1, SSM.Ts; 0, 1];
    SSM.C_spem = [1, 0];
    B_spem = [0; sqrt(SSM.Ts)];
    xSpemDim = length(SSM.A_spem);
    uSpemDim = 1;
    % Initialize control model parameters:
    m_X0_spem = zeros(xSpemDim,1);
    SIGMA_X0_spem = [0 0; 0 5];
    
elseif strcmp(spemModelType, 'sinusoidalVelocity')
    SSM.fSpem = signals.fSpem;
    SSM.A_spem = ...
        [1, SSM.Ts, 0;
        0, cos(2*pi*SSM.fSpem*SSM.Ts), sin(2*pi*SSM.fSpem*SSM.Ts); ...
        0, -sin(2*pi*SSM.fSpem*SSM.Ts), cos(2*pi*SSM.fSpem*SSM.Ts)];
    SSM.C_spem = [1, 0, 0];
    B_spem = [0 0; sqrt(SSM.Ts) 0; 0 sqrt(SSM.Ts)];
    xSpemDim = length(SSM.A_spem);
    uSpemDim = 2;
    % Initialize parameters:
    m_X0_spem = zeros(xSpemDim,1);
    SIGMA_X0_spem = zeros(xSpemDim);
    
elseif strcmp(spemModelType, 'none')
    SSM.A_spem = [];
    SSM.C_spem = [];
    B_spem = [];
    xSpemDim = 0;
    uSpemDim = 0;
    % Initialize control model parameters:
    m_X0_spem = [];
    SIGMA_X0_spem = [];
end

%%% Define FEM model:
A_fem = exp(-SSM.Ts/0.005);
B_fem = sqrt(SSM.Ts);
C_fem = 1;
xFemDim = size(A_fem,1);
uFemDim = size(B_fem,2);
% Initialize control model parameters:
m_X0_fem = zeros(xFemDim,1);
SIGMA_X0_fem = zeros(xFemDim);


%%% Complete SSM:
SSM.A = blkdiag(A_blink, [A_plant, B_plant * [C_sacc, SSM.C_spem, C_fem]; ...
    zeros(xSaccDim+xSpemDim+xFemDim, xPlantDim), ...
    blkdiag(A_sacc, SSM.A_spem, A_fem)]);
SSM.B = blkdiag(B_blink, B_plantComplete, B_sacc, B_spem, B_fem);
%LSSM.B = LSSM.B(:,[1 3 4 2]);
SSM.C = [C_blink, C_plant, zeros(1, xSaccDim + xSpemDim + xFemDim)];

% State and input indices of different subsystems:
SSM.xBlinkId = (1:xBlinkDim);
SSM.xPlantId = (1:xPlantDim) + SSM.xBlinkId(end);
SSM.xSaccId = (1:xSaccDim) + SSM.xPlantId(end);
SSM.xSpemId = (1:xSpemDim) + SSM.xSaccId(end);
SSM.xFemId = (1:xFemDim) + SSM.xSaccId(end) + length(SSM.xSpemId);
SSM.uBlinkId = (1:uBlinkDim);
SSM.uSaccId = (1:uSaccDim) + SSM.uBlinkId(end);
SSM.uSpemId = (1:uSpemDim) + SSM.uSaccId(end);
SSM.uFemId = (1:uFemDim) + SSM.xSaccId(end) + length(SSM.xSpemId);

SSM.xDim = size(SSM.A, 1);
SSM.uDim = size(SSM.B, 2);
SSM.yDim = 1;

% Initialize SSM parameters:
SSM.m_X0 = [0; m_X0_plant; m_X0_sacc; m_X0_spem; m_X0_fem];
SSM.SIGMA_X0 = blkdiag(0, SIGMA_X0_plant, SIGMA_X0_sacc, SIGMA_X0_spem, SIGMA_X0_fem);

SSM.m_U = zeros(SSM.uDim, SSM.N);
SSM.SIGMA_U = zeros(SSM.uDim, SSM.uDim, SSM.N);
for k=1:SSM.N
    SSM.SIGMA_U(:,:,k) = blkdiag(1, 1, sigmaSpem^2 * eye(uSpemDim), sigmaFem^2);
end

SSM.SIGMA_Z = sigmaNoise^2;

end
