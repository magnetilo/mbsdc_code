%%% Main file for running MBSDC framework (for one 1D measurement of
%%% horizontal eye position) %%%
%
% Copyright (C) Thilo Weber 2019 (see MIT license in the README.txt file)
%
% First, the script loads the struct 'signals' in the workspace containing:
%
%   signals.
%       data            % 1D eye position data (dimension 1xN)
%       time            % Time vector (dimension 1xN)
%       samplingRate    % Sampling rate of the data
%       dataLen         % # samples of the data (dataLen==N)
%
% Optionally for evaluation purpose, the struct 'signals' could also contain the following
% data (if known, e.g., from simulation):
%
%   signals.
%       posTrue         % True (noise-free) eye position
%       velTrue         % True eye velocity
%       accTrue         % True eye acceleration
%       controlTrue     % True neural control signal
%       controlMeas     % Measured neural spike rate (e.g., in monkey brains)
%
%   saccadeParamsTrue.
%       startIds        % True start indices of saccades (dimension 1xnumOfSaccades)
%       endIds          %   "  end indices    "
%       psoEndIds       %   "  post saccadic oscillation end indices  "
%       peakVelocityIds %   "  peak velocity indices  "
%       peakVelocities
%       amplitudes
%       durations
%       numOfSaccades   % # true saccades in the data
%
% After running this script, the struct 'signals' contain all the signals
% calculated by the MBSDC framework:
%
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
%   
%   evaluation.           % Struct containing quantitative evaluations, 
%       MSEposEstim         only if the needed ground-truths are provided
%       MSEvelEstim         (see optinal signals and saccParamsTrue above)
%       MSEposFilt
%       MSEvelFilt
%       precision
%       recall
%       cohensKappa       % [kappaTotal, kappaFixations, kappaSpem,
%                            kappaPSOs, kappaSaccades, kappaBlinks]

% Add that folder plus all subfolders to the path:
addpath(genpath('.'));

%% Load sinusoidal SPEM recording:
recording = 'naiveSPEM'; %'trainedSPEM'; %
path = ['data/sineTarget/' recording '.folge'];
signals = loadSineTargetData(path);

% %% Simulate saccade data:
% [signals, saccadeParamsTrue] = generateSaccades('repeat', 3, 'sigmaNoise', 0.1, 'concatenate', true);

% %% Load monkey data:
% %  (For obtaining the monkey data, please see README.txt)
% signalsAll = loadMonkeyData(); % First choose data file and then eye 1!
% signals = signalsAll{8};

%% Algorithm parameters:
%  For details how to chose the parameters see section III.H of the paper
plantModelType = 'Zhou09Human'; %'Zhou09Monkey'; %'Bahill80' %
spemModelType = 'sinusoidalVelocity'; %'firstOrderHold'; %

sigmaFem = 0.2;   % [N/s]
sigmaSpem = 0.5;  % [N/s^2]

structuredSparse = true;       % [true/false] Filtering std. devs. for structured sparse input estimation?
structuredSparseDecay = 0.004; % [ms]

separationHeuristics = true; % [true/false] Apply separation heuristic and smooth blink interpolation?

sigmaNoiseInit = 0.5;    % Observation noise std. dev. initialisation
sigmaNoiseUpdate = true; % [true/false] Estimate sigmaNoise? (otherwise fixed to sigmaNoiseInit)
alphaNoise = 0.5;

alphaSacc = 0.5;
betaSacc = 10e-7;

alphaBlink = 8;
betaBlink = 10e-7;


%% Run MBSDC framework:
[signals, ...
 SSM, ...
 saccadeParamsEstim, ...
 blinksEstim] ...
    = MBSDC(signals, ...
        'sigmaNoiseInit', sigmaNoiseInit, ...
        'sigmaNoiseUpdate', sigmaNoiseUpdate, ...
        'alphaNoise', alphaNoise, ...
        'sigmaFem', sigmaFem, ...
        'sigmaSpem', sigmaSpem, ...
        'alphaSacc', alphaSacc, ...
        'betaSacc', betaSacc, ...
        'alphaBlink', alphaBlink, ...
        'betaBlink', betaBlink, ...
        'separationHeuristics', separationHeuristics, ...
        'plantModelType', plantModelType, ...
        'spemModelType', spemModelType, ...
        'structuredSparse', structuredSparse, ...
        'structuredSparseDecay', structuredSparseDecay, ...
        'verbose', false);

%% Plots:
figure(1)
plotSignalSeparation(signals)

figure(2)
plotSaccades(signals, saccadeParamsEstim)

if strcmp(spemModelType, 'sinusoidalVelocity')
    figure(3)
    plotSpemAnalysis(signals, SSM)
else
    disp('SPEM analysis plot only for sinusiodal SPEM model available!')
end

