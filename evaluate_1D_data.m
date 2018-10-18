%%% Evaluating MBSD framework for 1D eye movement data %%%
%
% Copyright (C) Thilo Weber 2018 (see MIT license in the README.txt file)
%
% E.g. for simulated saccade data
%

%% Simulate saccade data:
[signalsAll, saccadeParamsTrueAll] = generateSaccades('repeat', 3, 'sigmaNoise', 0.1, 'concatenate', false);

% Index for choosing a subset of the loaded data set for evaluation
useSignals = 1:length(signalsAll);

%% Algorithm parameters:
spemModelType = 'none';
structuredSparse = false;       % [true/false] Filtering std. devs. for structured sparse input estimation?
structuredSparseDecay = 0.004; % [ms]
sigmaFem = 0.2;   % [N/s]
sigmaSpem = 0.5;  % [N/s^2]
alphaNoise = 0.5;
alphaSacc = 0.4;
alphaBlink = 8;
separationHeuristics = false;

%% Run MBSD framework and compute evaluation measures for each recording:
% Initialize required cell arrays:
SSMAll = cell(length(signalsAll),1);
saccadeParamsEstimAll = cell(length(signalsAll),1);
saccadeParamsFiltAll = cell(length(signalsAll),1);
blinksEstimAll = cell(length(signalsAll),1);
evaluationAll = cell(length(signalsAll),1);

for i=useSignals
    disp(['i: ' num2str(i)])
    
    %%% MBSD on horizontal data:
    [signalsAll{i}, ...
     SSMAll{i}, ...
     saccadeParamsEstimAll{i}, ...
     blinksEstimAll{i}] ...
        = MBSD(signalsAll{i}, ...
            'spemModelType', spemModelType, ...
            'structuredSparse', structuredSparse, ...
            'structuredSparseDecay', structuredSparseDecay, ...
            'sigmaFem', sigmaFem, ...
            'sigmaSpem', sigmaSpem, ...
            'alphaNoise', alphaNoise, ...
            'alphaSacc', alphaSacc, ...
            'alphaBlink', alphaBlink, ...
            'separationHeuristics', separationHeuristics, ...
            'verbose', false);
            
    %%% Evaluation:
    % Estimate signals by lowpass filtering and numerical differentiation
    % for comparison (with "optimal" lowpass parameters from Mack 2017):
    signalsAll{i} = filterSignals(signalsAll{i}, min(sqrt(SSMAll{i}.SIGMA_Z)), SSMAll{i}.Ts);
    saccadeParamsFiltAll{i} = saccadeDetection( ...
        signalsAll{i}.posFilt, ...
        signalsAll{i}.velFilt, ...
        signalsAll{i}.accFilt, ...
        signalsAll{i}.time, ...
        [], ...
        'MIN_PEAK_VEL', 20);
    
    if isfield(signalsAll{i}, 'sampleClassTrue')
        % Cohen's Kappa per signal:
        evaluationAll{i}.cohensKappa = getCohensKappa( ...
            signalsAll{i}.sampleClassTrue, signalsAll{i}.sampleClassEstim);
    end

    if exist('saccadeParamsTrueAll', 'var')
        % Precision, Recall
        [evaluationAll{i}.precisionEstim, ...
            evaluationAll{i}.recallEstim] = getPrecisionRecall( ...
                saccadeParamsTrueAll{i}, ...
                saccadeParamsEstimAll{i}, ...
                signalsAll{i}.dataLen);
        [evaluationAll{i}.precisionFilt, ...
            evaluationAll{i}.recallFilt] = getPrecisionRecall( ...
                saccadeParamsTrueAll{i}, ...
                saccadeParamsFiltAll{i}, ...
                signalsAll{i}.dataLen);
    end
    
    % MSE:
    if isfield(signalsAll{i}, 'posTrue')
        % MSE between estimated and true position:
        evaluationAll{i}.MSEposEstim = norm(signalsAll{i}.posEstim - signalsAll{i}.posTrue)^2 / signalsAll{i}.dataLen;
        % MSE between filtered and true position:
        evaluationAll{i}.MSEposFilt = norm(signalsAll{i}.posFilt - signalsAll{i}.posTrue)^2 / signalsAll{i}.dataLen;
    end
    if isfield(signalsAll{i}, 'velTrue')
        % MSE between estimated and true velocity:
        evaluationAll{i}.MSEvelEstim = norm(signalsAll{i}.velEstim - signalsAll{i}.velTrue)^2 / signalsAll{i}.dataLen;
        % MSE between filtered and true velocity:
        evaluationAll{i}.MSEvelFilt = norm(signalsAll{i}.velFilt - signalsAll{i}.velTrue)^2 / signalsAll{i}.dataLen;
    end
    
end

%%% Evaluation over all recordings:
sampleClassTrueCollected = [];
sampleClassEstimCollected = [];
evaluationCollected.precisionEstim = 0;
evaluationCollected.recallEstim = 0;
evaluationCollected.precisionFilt = 0;
evaluationCollected.recallFilt = 0;
evaluationCollected.MSEposEstim = 0;
evaluationCollected.MSEposFilt = 0;
evaluationCollected.MSEvelEstim = 0;
evaluationCollected.MSEvelFilt = 0;
PosTotEstim = 0;
TruesTot = 0;
PosTotFilt = 0;
for i=useSignals
    % Cohen's Kappa arrays:
    if isfield(signalsAll{i}, 'sampleClassTrue')
        sampleClassTrueCollected = [sampleClassTrueCollected, signalsAll{i}.sampleClassTrue];
        sampleClassEstimCollected = [sampleClassEstimCollected, signalsAll{i}.sampleClassEstim];
    end
    
    % Precision, Recall:
    if exist('saccadeParamsTrueAll', 'var')
        evaluationCollected.precisionEstim = evaluationCollected.precisionEstim ...
            + min(evaluationAll{i}.precisionEstim, 1) * length(saccadeParamsEstimAll);
        PosTotEstim = PosTotEstim + length(saccadeParamsEstimAll);
        evaluationCollected.recallEstim = evaluationCollected.recallEstim ...
            + evaluationAll{i}.recallEstim * length(saccadeParamsTrueAll);
        TruesTot = TruesTot + length(saccadeParamsTrueAll);
        
        evaluationCollected.precisionFilt = evaluationCollected.precisionFilt ...
            + min(evaluationAll{i}.precisionFilt,1) * length(saccadeParamsFiltAll);
        PosTotFilt = PosTotFilt + length(saccadeParamsEstimAll);
        evaluationCollected.recallFilt = evaluationCollected.recallFilt ...
            + evaluationAll{i}.recallFilt * length(saccadeParamsTrueAll);
    end
    
    % MSE:
    if isfield(signalsAll{i}, 'posTrue')
        evaluationCollected.MSEposEstim = evaluationCollected.MSEposEstim + evaluationAll{i}.MSEposEstim / length(signalsAll);
        evaluationCollected.MSEposFilt = evaluationCollected.MSEposFilt + evaluationAll{i}.MSEposFilt / length(signalsAll);
    end
    if isfield(signalsAll{i}, 'velTrue')
        evaluationCollected.MSEvelEstim = evaluationCollected.MSEvelEstim + evaluationAll{i}.MSEvelEstim / length(signalsAll);
        evaluationCollected.MSEvelFilt = evaluationCollected.MSEvelFilt + evaluationAll{i}.MSEvelFilt / length(signalsAll);
    end
end

if ~isempty(sampleClassTrueCollected) && ~isempty(sampleClassEstimCollected)
    evaluationCollected.cohensKappaAll = getCohensKappa(sampleClassTrueCollected, sampleClassEstimCollected);
end

% Precision, Recall:
if exist('saccadeParamsTrueAll', 'var')
    evaluationCollected.precisionEstim = evaluationCollected.precisionEstim / PosTotEstim;
    evaluationCollected.recallEstim = evaluationCollected.recallEstim / TruesTot;
    
    evaluationCollected.precisionFilt = evaluationCollected.precisionFilt / PosTotFilt;
    evaluationCollected.recallFilt = evaluationCollected.recallFilt / TruesTot;
end


%% Print evaluation:
if isfield(signalsAll{i}, 'sampleClassTrue')
    disp('Cohens kappa:')
    disp(['All classes: ' num2str(evaluationCollected.cohensKappaAll(1))])
    disp(['Fixations: ' num2str(evaluationCollected.cohensKappaAll(2))])
    disp(['Saccades: ' num2str(evaluationCollected.cohensKappaAll(5))])
    disp(['PSOs: ' num2str(evaluationCollected.cohensKappaAll(4))])
    disp(['SPEM' num2str(evaluationCollected.cohensKappaAll(3))])
    if length(evaluationCollected.cohensKappaAll)>5 % if there are blinks
        disp(['Blinks: ' num2str(evaluationCollected.cohensKappaAll(6))])
    end
end

if exist('saccadeParamsTrueAll', 'var')
%     disp(' ')
%     disp(['Precision/Recall 0.6° (MBSD): ' num2str(evaluationAllCollected.precisionEstim) ...
%         '/' num2str(evaluationAllCollected.recallEstim)])
%     disp(['Precision/Recall 0.6° (Filt): ' num2str(evaluationAllCollected.precisionFilt) ...
%         '/' num2str(evaluationAllCollected.recallFilt)])
    
    disp(' ')
    disp(['Precision/Recall 0.6° (MBSD): ' num2str(evaluationAll{1}.precisionEstim) ...
        '/' num2str(evaluationAll{1}.recallEstim)])
    disp(['Precision/Recall 0.6° (Filt): ' num2str(evaluationAll{1}.precisionFilt) ...
        '/' num2str(evaluationAll{1}.recallFilt)])
    disp(['Precision/Recall 1.2° (MBSD): ' num2str(evaluationAll{2}.precisionEstim) ...
        '/' num2str(evaluationAll{2}.recallEstim)])
    disp(['Precision/Recall 1.2° (Filt): ' num2str(evaluationAll{2}.precisionFilt) ...
        '/' num2str(evaluationAll{2}.recallFilt)])
    disp(['Precision/Recall 2.5° (MBSD): ' num2str(evaluationAll{3}.precisionEstim) ...
        '/' num2str(evaluationAll{3}.recallEstim)])
    disp(['Precision/Recall 2.5° (Filt): ' num2str(evaluationAll{3}.precisionFilt) ...
        '/' num2str(evaluationAll{3}.recallFilt)])
    disp(['Precision/Recall 5° (MBSD): ' num2str(evaluationAll{4}.precisionEstim) ...
        '/' num2str(evaluationAll{4}.recallEstim)])
    disp(['Precision/Recall 5° (Filt): ' num2str(evaluationAll{4}.precisionFilt) ...
        '/' num2str(evaluationAll{4}.recallFilt)])

%     disp(['Precision/Recall ?° (MBSD): ' num2str(evaluationAll{i}.precisionEstim) ...
%         '/' num2str(evaluationAll{i}.recallEstim)])
%     disp(['Precision/Recall ?° (Filt): ' num2str(evaluationAll{i}.precisionFilt) ...
%         '/' num2str(evaluationAll{i}.recallFilt)])
end

if isfield(signalsAll{i}, 'posTrue')
    disp(' ')
    disp(['RMSE position (MBSD): ' num2str(sqrt(evaluationCollected.MSEposEstim))])
    disp(['RMSE velocity (MBSD): ' num2str(sqrt(evaluationCollected.MSEvelEstim))])
    disp(['RMSE position (Filt): ' num2str(sqrt(evaluationCollected.MSEposFilt))])
    disp(['RMSE velocity (Filt): ' num2str(sqrt(evaluationCollected.MSEvelFilt))])
end


