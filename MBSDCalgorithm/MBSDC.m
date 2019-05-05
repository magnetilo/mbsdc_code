function [signals, SSM, saccadeParamsEstim, blinksEstim] = MBSD(signals, varargin)
%%% MBSD framework as described in Weber et. al. 2018
%
% Copyright (C) Thilo Weber 2019 (see MIT license in the README.txt file)
%
% input:
%   signals.
%       data            % 1D eye position data (dimension 1xN)
%       time            % Time vector (dimension 1xN)
%       samplingRate    % Sampling rate of the data
%       dataLen         % # samples of the data (dataLen==N)
%
% outputs:
%   signals.
%       posEstim          % Estimated eye position (dimension 1xN)
%       velEstim          % Estimated eye velocity (dimension 1xN)
%       accEstim          % Estimated eye acceleration (dimension 1xN)
%       controlEstim      % Estimated neural control signal
%       posSaccEstim      % Separated saccades (interconnected by phases of fixation)
%       velSaccEstim      % ...
%       accSaccEstim      % ...
%       controlSaccEstim  % ...
%       posSpemEstim      % Separated smooth pursuit
%       velSpemEstim      % ...
%       accSpemEstim      % ...
%       controlSpemEstim  % ...
%       posFemEstim       % Separated FEM (e.g, tremer, drift, and 
%       velFemEstim         possibly microsaccades)
%       accFemEstim      
%
%   saccadeParamsEstim.   % Detected saccade parameters (arrays of
%       startIds            dimension 1xnumOfSaccades)
%       endIds          
%       psoEndIds       
%       peakVelocityIds 
%       peakVelocities
%       amplitudes
%       durations
%       numOfSaccades     % # detected saccades in the data
%
%   blinksEstim.          % Detected blink parameters (arrays of
%       startIds            dimension 1xnumOfBlinks)
%       endIds          
%       numOfBlinks       % # detected blinks in the data
%      
%   SSM.                  % Struct containing the physiological and
%       ...                 measurement model (with learned std. deviations
%                           sigma_Sacc, sigma_Blink, sigma_Noise)

%%% Parse arguments:
p = inputParser;
addOptional(p, 'sigmaNoiseInit', 0.5, @isnumeric);
addOptional(p, 'sigmaNoiseUpdate', true, @islogical);
addOptional(p, 'alphaNoise', 0, @isnumeric);
addOptional(p, 'alphaSacc', 0.5, @isnumeric);
addOptional(p, 'betaSacc', 10e-6, @isnumeric);
addOptional(p, 'alphaBlink', 8, @isnumeric);
addOptional(p, 'betaBlink', 10e-6, @isnumeric);
addOptional(p, 'sigmaFem', 0.5, @isnumeric);
addOptional(p, 'sigmaSpem', 0.5, @isnumeric);
addOptional(p, 'plantModelType', 'Zhou09Human', @ischar);
addOptional(p, 'spemModelType', 'firstOrderHold', @ischar);
addOptional(p, 'structuredSparse', true, @islogical);
addOptional(p, 'structuredSparseDecay', 0.004, @isnumeric);
addOptional(p, 'separationHeuristics', true, @islogical);
addOptional(p, 'verbose', false, @islogical);
parse(p,varargin{:});

%%% Load complete SSM of physiological and measurement model for eye movements:
SSM = loadSSM(...
    p.Results.sigmaNoiseInit, ...
    p.Results.sigmaFem, ...
    p.Results.sigmaSpem, ...
    p.Results.plantModelType, ...
    p.Results.spemModelType, ...
    signals);

%%% Learn SIGMA_Uk's and SIGMA_Z by EM algorithm
SSM = EM_SSM(SSM, signals.data, ...
    'SIGMA_U_updates', [SSM.uBlinkId, SSM.uSaccId], ...
    'SIGMA_U_prior', [p.Results.alphaBlink, p.Results.betaBlink; ...
                      p.Results.alphaSacc,  p.Results.betaSacc], ...
    'SIGMA_Z_update', p.Results.sigmaNoiseUpdate, ...
    'SIGMA_Z_prior', p.Results.alphaNoise, ...
    'maxsteps', 30, ...
    'verbose', p.Results.verbose);

if p.Results.verbose
    disp(['sigmaNoiseEstim: ' num2str(sqrt(SSM.SIGMA_Z))])
end

%%% SIGMA_U filtering for pulse-slide-step estimation:
if p.Results.structuredSparse
    % First get true sparse pulse-step signal for comparison:
    msg = kalmanSmoothing(SSM, signals.data);
    signals.controlSaccEstimSprs = msg.xMrg.m(SSM.xSaccId,:);
    
    % Filter variances:
    t = 0:SSM.Ts:0.02;
    decayFilt = t .* exp(-t / (0.5*p.Results.structuredSparseDecay));
    decayFilt = 2 * decayFilt / sum(decayFilt);
    [~, maxIdx] = max(decayFilt);
    maxIdx = maxIdx + 0;
    SIGMA_U_filt = conv(squeeze(SSM.SIGMA_U(2,2,:))', decayFilt);
    SSM.SIGMA_U(2,2,:) = SIGMA_U_filt(maxIdx:end-(length(t)-maxIdx));
end

%%% State and input estimation:
msg = kalmanSmoothing(SSM, signals.data);
signals.xHat = msg.xMrg.m;
signals.uHat = msg.uMrg.m;
signals.x0Hat = msg.x0Mrg.m;

%%% Extract physical signals:
signals = extractSignals(signals, SSM);

%%% Detect blinks: (Put here your favorite blink detection algorithm)
blinksEstim = blinkDetection(signals.uHat(SSM.uBlinkId,:), ...
    signals.velEstim, ...
    signals.accEstim, ...
    SSM.Ts);

%%% Detect saccades: (Put here your favorite saccade detection algorithm)
saccadeParamsEstim = saccadeDetection( ...
    signals.posSaccEstim + signals.posFemEstim, ...
    signals.velSaccEstim + signals.velFemEstim, ...
    signals.accSaccEstim + signals.accFemEstim, ...
    signals.time, ...
    'blinksEstim', blinksEstim, ...
    'sparseInputs', signals.uHat(SSM.uSaccId,:));

%%% Separation heuristics:
if p.Results.separationHeuristics
    [signals, saccadeParamsEstim, SSM] = separationHeuristics(signals, SSM, saccadeParamsEstim, blinksEstim);
end

%%% Classify samples:
signals.sampleClassEstim = classifySamples( ...
    saccadeParamsEstim, ...
    blinksEstim, ...
    signals.velSpemEstim, ...
    signals.accSpemEstim, ...
    SSM.Ts);

end

