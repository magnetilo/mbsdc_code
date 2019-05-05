function [signalsAllH, signalsAllV, saccadeParamsTrueAll] = loadAnnotatedData(path)
%%% Load the annotated data sets from Andersson 2017 into
%%% cell-arrays signalsAllH and signalsAllV
%
% Copyright (C) Thilo Weber 2019 (see MIT license in the README.txt file)
%
% The data sets can be downloaded at:
% https://github.com/richardandersson/EyeMovementDetectorEvaluation
%

%%% !!ATTENTION!!: We believe that some of the measurements in the data set
%%% have smaller sampling rates than the reported 500 Hz. An indication is,
%%% e.g., an abnormally large velocity-amplitude main sequence for certain
%%% measurements. Here, we propose a list of measurements for which we set
%%% the sampling rate to 250 Hz and 125 Hz, respectively. Note, that these
%%% values come without warranty, we just observed that they lead to better
%%% main sequences for the particular measurements.
list250Hz = { ...
    ...'TL48_video_TrafikEhuset_labelled_RA.mat'; ...
    ...'UL47_video_BiljardKlipp_labelled_RA.mat'; ...
    ...'UH47_video_BergoDalbana_labelled_MN.mat'; ...
    ...'UH47_video_BergoDalbana_labelled_RA.mat'; ...
    'UL23_video_triple_jump_labelled_RA.mat'; ...
    'UL31_video_triple_jump_labelled_RA.mat'; ...
    'TL48_img_Europe_labelled_RA.mat'; ...
    'TL48_img_Rome_labelled_RA.mat'; ...
    'UH47_img_Europe_labelled_MN.mat'; ...
    'UH47_img_Europe_labelled_RA.mat'; ...
    'UL47_img_konijntjes_labelled_MN.mat'; ...
    'UL47_img_konijntjes_labelled_RA.mat'; ...
    'UL47_trial1_labelled_RA.mat'; ...
    'UL39_img_konijntjes_labelled_MN.mat'; ...
    'UL39_img_konijntjes_labelled_RA.mat'};
list125Hz = { ...
    'TL48_video_TrafikEhuset_labelled_RA.mat'; ...
    'UH47_video_BergoDalbana_labelled_MN.mat'; ...
    'UH47_video_BergoDalbana_labelled_RA.mat'; ...
    'UL47_video_BiljardKlipp_labelled_RA.mat'};

files = dir(path);

if ~isempty(files)
    clear signalsH
    clear signalsV
    clear saccadeParamsTrue
    signalsAllH = cell(length(files),1);
    signalsAllV = cell(length(files),1);
    saccadeParamsTrueAll = cell(length(signalsAllH),1);
else
    disp(['++++++No .mat files in directory: ' path '+++++++'])
end

for i=1:length(signalsAllH)
    load(files(i).name)
    
    % Convert pixel values to angular eye position:
    signalsAllH{i}.data = atand((ETdata.pos(:,4) - ETdata.screenRes(1)/2) * ETdata.screenDim(1) ...
        / (ETdata.screenRes(1) * ETdata.viewDist))';
    signalsAllV{i}.data = atand((ETdata.pos(:,5) - ETdata.screenRes(2)/2) * ETdata.screenDim(2) ...
        / (ETdata.screenRes(2) * ETdata.viewDist))';
%     signalsAllH{i}.data = atand((ETdata.pos(:,4)) * ETdata.screenDim(1) ...
%         / (ETdata.screenRes(1) * ETdata.viewDist))';
%     signalsAllV{i}.data = atand((ETdata.pos(:,5)) * ETdata.screenDim(2) ...
%         / (ETdata.screenRes(2) * ETdata.viewDist))';

    % Signal length:
    n = length(signalsAllH{i}.data);
    signalsAllH{i}.dataLen = n;
    signalsAllV{i}.dataLen = n;
    
    % Sampling rate:
    signalsAllH{i}.samplingRate = ETdata.sampFreq;
    signalsAllV{i}.samplingRate = ETdata.sampFreq;
    
    % Time:
    signalsAllH{i}.time = 0:1/signalsAllH{i}.samplingRate:1/signalsAllH{i}.samplingRate*(n-1);
    signalsAllV{i}.time = signalsAllH{i}.time;
        
    % Labels:
    lables = ETdata.pos(:,6)';
    signalsAllH{i}.sampleClassTrue = zeros(1,n);
    signalsAllH{i}.sampleClassTrue(lables==1) = 1; %Fixations
    signalsAllH{i}.sampleClassTrue(lables==2) = 4; %Saccades
    signalsAllH{i}.sampleClassTrue(lables==3) = 3; %PSOs
    signalsAllH{i}.sampleClassTrue(lables==4) = 2; %Smooth Pursuit
    signalsAllH{i}.sampleClassTrue(lables==5) = 5; %Blinks
    signalsAllH{i}.sampleClassTrue(lables==6) = 5; %Unknown
    %signalsAllH{i}.sampleClassTrue(signalsAllH{i}.sampleClassTrue==0) = 5; %Blinks/Unknown
    
    signalsAllV{i}.sampleClassTrue = signalsAllH{i}.sampleClassTrue;
    
    %%% Create saccadeParamsTrue:
    saccCount = 0;
    isSacc = false;
    for k=1:n
        % Get saccade parameters (start, end and PSO end inidices):
        if ~isSacc && signalsAllH{i}.sampleClassTrue(k)==4
            isSacc = true;
            saccCount = saccCount + 1;
            saccadeParamsTrueAll{i}.startIds(saccCount) = k;
            saccadeParamsTrueAll{i}.peakVelocities(saccCount) = nan;
            saccadeParamsTrueAll{i}.peakVelocityIds(saccCount) = nan;
        elseif isSacc && signalsAllH{i}.sampleClassTrue(k)==3 ...
                && signalsAllH{i}.sampleClassTrue(k-1)==4
            % Saccade end:
            saccadeParamsTrueAll{i}.endIds(saccCount) = k - 1;
        elseif isSacc && signalsAllH{i}.sampleClassTrue(k)~=3 ...
                && signalsAllH{i}.sampleClassTrue(k)~=4
            % PSO end:
            isSacc = false;
            saccadeParamsTrueAll{i}.psoEndIds(saccCount) = k - 1;
            if signalsAllH{i}.sampleClassTrue(k-1)==4
                saccadeParamsTrueAll{i}.endIds(saccCount) = k - 1;
            end
        elseif isSacc && k==n
            isSacc = false;
            saccadeParamsTrueAll{i}.psoEndIds(saccCount) = n;
            if signalsAllH{i}.sampleClassTrue(n)==4
                saccadeParamsTrueAll{i}.endIds(saccCount) = n;
            end
        end
    end
    
end

% Adjust sampling rates for signals in list250Hz, list125Hz:
for i=1:length(signalsAllH)
    %disp([num2str(i) ' ' files(i).name])
    for j=1:length(list250Hz)
        if strcmp(files(i).name, list250Hz{j})
            signalsAllH{i}.samplingRate = 250;
            signalsAllH{i}.time = 2*signalsAllH{i}.time;
            signalsAllV{i}.samplingRate = 250;
            signalsAllV{i}.time = 2*signalsAllV{i}.time;
        end
    end
    for j=1:length(list125Hz)
        if strcmp(files(i).name, list125Hz{j})
            signalsAllH{i}.samplingRate = 125;
            signalsAllH{i}.time = 4*signalsAllH{i}.time;
            signalsAllV{i}.samplingRate = 125;
            signalsAllV{i}.time = 4*signalsAllV{i}.time;
        end
    end
end

end