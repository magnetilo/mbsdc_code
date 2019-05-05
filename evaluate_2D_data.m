%% Evaluating MBSDC framework for 2D eye movement data %%%
%
% Copyright (C) Thilo Weber 2019 (see MIT license in the README.txt file)
%
% E.g. for data used by Andersson et. al., "One algorithm to rule them all?
% An evaluation and discussion of ten eye movement event-detection 
% algorithms", Behav Res Methods. April 2017.
%

% Add that folder plus all subfolders to the path:
addpath(genpath('.'));

%% Load annotated data from Andersson 2017:
%  The data sets can be downloaded at:
%  https://github.com/richardandersson/EyeMovementDetectorEvaluation
dataset = 'dots'; %'images'; %'videos'; %
path = ['data/annotatedData/annotated_data/' dataset '/*.mat'];
[signalsAllH, signalsAllV, saccadeParamsTrueAll] = loadAnnotatedData(path);

% Index for choosing a subset of the loaded data set for evaluation
useSignals = 1:length(signalsAllH);

%% Algorithm parameters:
sigmaFem = 0.8;   % [N/s]
sigmaSpem = 0.5;  % [N/s^2]
alphaNoise = 0;
alphaSacc = 1;
alphaBlink = 8;
separationHeuristics = true;

%% Run MBSDC framework and compute evaluation measures for each recording:
% Initialize required cell arrays:
SSMAllH = cell(length(signalsAllH),1);
SSMAllV = cell(length(signalsAllH),1);
saccadeParamsEstimAllH = cell(length(signalsAllH),1);
saccadeParamsEstimAllV = cell(length(signalsAllH),1);
saccadeParamsEstimAll = cell(length(signalsAllH),1);
blinksEstimAllH = cell(length(signalsAllH),1);
blinksEstimAllV = cell(length(signalsAllH),1);
evaluationAll = cell(length(signalsAllH),1);
sampleClassEstimAll = cell(length(signalsAllH),1);

for i=useSignals
    disp(['progress: ' num2str(i) '/' num2str(useSignals(end))])
    
    %%% MBSDC on horizontal data:
    [signalsAllH{i}, ...
     SSMAllH{i}, ...
     saccadeParamsEstimAllH{i}, ...
     blinksEstimAllH{i}] ...
        = MBSDC(signalsAllH{i}, ...
            'sigmaFem', sigmaFem, ...
            'sigmaSpem', sigmaSpem, ...
            'alphaNoise', alphaNoise, ...
            'alphaSacc', alphaSacc, ...
            'alphaBlink', alphaBlink, ...
            'separationHeuristics', separationHeuristics, ...
            'verbose', false);
    
    %%% MBSDC on vertical data:
    [signalsAllV{i}, ...
     SSMAllV{i}, ...
     saccadeParamsEstimAllV{i}, ...
     blinksEstimAllV{i}] ...
        = MBSDC(signalsAllV{i}, ...
            'sigmaFem', sigmaFem, ...
            'sigmaSpem', sigmaSpem, ...
            'alphaNoise', alphaNoise, ...
            'alphaSacc', alphaSacc, ...
            'alphaBlink', alphaBlink, ...
            'separationHeuristics', separationHeuristics, ...
            'verbose', false);
        
        
    % Combine sample classifications:
    sampleClassEstimAll{i} = max(signalsAllH{i}.sampleClassEstim, signalsAllV{i}.sampleClassEstim);

    % Combine saccade parameters:
    saccadeParamsEstimAll{i} = sampleClass2saccadeParams(sampleClassEstimAll{i});

    %%% Evaluation:
    if isfield(signalsAllH{i}, 'sampleClassTrue')
        % Cohen's Kappa per signal:
        evaluationAll{i}.cohensKappa = getCohensKappa( ...
            signalsAllH{i}.sampleClassTrue, sampleClassEstimAll{i});
    end

    if exist('saccadeParamsTrueAll', 'var')
        % Precision, Recall and
        % Relative peak velocity error (mean and standard deviation):
        [evaluationAll{i}.precision, ...
            evaluationAll{i}.recall] = getPrecisionRecall( ...
                saccadeParamsTrueAll{i}, ...
                saccadeParamsEstimAll{i}, ...
                signalsAllH{i}.dataLen);
    end
    
end


%%% Evaluation over all recordings:
sampleClassTrueCollected = [];
sampleClassEstimCollected = [];
evaluationCollected.precision = 0;
PosTot = 0;
evaluationCollected.recall = 0;
TruesTot = 0;
for i=useSignals
    % Cohen's Kappa arrays:
    if isfield(signalsAllH{i}, 'sampleClassTrue')
        sampleClassTrueCollected = [sampleClassTrueCollected, signalsAllH{i}.sampleClassTrue];
        sampleClassEstimCollected = [sampleClassEstimCollected, sampleClassEstimAll{i}];
    end
    
    % Precision, Recall:
    if exist('saccadeParamsTrueAll', 'var')
        evaluationCollected.precision = evaluationCollected.precision ...
            + evaluationAll{i}.precision * length(saccadeParamsEstimAllH);
        PosTot = PosTot + length(saccadeParamsEstimAllH);
        evaluationCollected.recall = evaluationCollected.recall ...
            + evaluationAll{i}.recall * length(saccadeParamsTrueAll);
        TruesTot = TruesTot + length(saccadeParamsTrueAll);
    end
end

if ~isempty(sampleClassTrueCollected) && ~isempty(sampleClassEstimCollected)
    evaluationCollected.cohensKappaAll = getCohensKappa(sampleClassTrueCollected, sampleClassEstimCollected);
end

% Precision, Recall:
if exist('saccadeParamsTrueAll', 'var')
    evaluationCollected.precision = evaluationCollected.precision / PosTot;
    evaluationCollected.recall = evaluationCollected.recall / TruesTot;
end


%% Print evaluation:
if isfield(signalsAllH{i}, 'sampleClassTrue')
    disp(' ')
    disp('Cohens kappa:')
    disp(['All classes: ' num2str(evaluationCollected.cohensKappaAll(1))])
    disp(['Fixations: ' num2str(evaluationCollected.cohensKappaAll(2))])
    disp(['Saccades: ' num2str(evaluationCollected.cohensKappaAll(5))])
    disp(['PSOs: ' num2str(evaluationCollected.cohensKappaAll(4))])
    disp(['SPEM: ' num2str(evaluationCollected.cohensKappaAll(3))])
    if length(evaluationCollected.cohensKappaAll)>5 % if there are blinks
        disp(['Blinks: ' num2str(evaluationCollected.cohensKappaAll(6))])
    end
end

if exist('saccadeParamsTrueAll', 'var')
    disp(' ')
    disp(['Precision/Recall: ' num2str(evaluationCollected.precision) ...
        '/' num2str(evaluationCollected.recall)])
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function for determination of saccade parameters (start/end point, ...) for given classification:
function saccadeParams = sampleClass2saccadeParams(sampleClass)
n = length(sampleClass);
saccCount = 0;
isSacc = false;
for k=1:n
    % Get saccade parameters (start, end and PSO end inidices):
    if ~isSacc && sampleClass(k)==4 && k<n
        isSacc = true;
        saccCount = saccCount + 1;
        saccadeParams.startIds(saccCount) = k;
        saccadeParams.peakVelocities(saccCount) = nan;
    elseif isSacc && sampleClass(k)==3 ...
            && sampleClass(k-1)==4
        % Saccade end:
        saccadeParams.endIds(saccCount) = k - 1;
    elseif isSacc && sampleClass(k)~=3 ...
            && sampleClass(k)~=4
        % PSO end:
        isSacc = false;
        saccadeParams.psoEndIds(saccCount) = k - 1;
        if sampleClass(k-1)==4
            saccadeParams.endIds(saccCount) = k - 1;
        end
    elseif isSacc && k==n
        isSacc = false;
        saccadeParams.psoEndIds(saccCount) = n;
        if sampleClass(n)==4
            saccadeParams.endIds(saccCount) = n;
        end
    end
end
end