function saccadeParams = saccadeDetection(pos, vel, acc, time, varargin)
%%% Saccade detection
%
% Copyright (C) Thilo Weber 2018 (see MIT license in the README.txt file)
%
% Output: 
%   saccadeParams
%       .amplitudes
%       .durations
%       .peakVelocities
%       .peakVelocityIds
%       .startIds
%       .endIds
%       .psoEndIds

p = inputParser;
addOptional(p, 'MIN_PEAK_VEL', 20, @isnumeric);
addOptional(p, 'ACC_THRES', 3000, @isnumeric);
addOptional(p, 'VEL_THRES', 20, @isnumeric);
addOptional(p, 'blinksEstim', [], @isstruct);
addOptional(p, 'sparseInputs', [], @isnumeric);
parse(p,varargin{:});

%%% Threshold parameters:
MIN_PEAK_VEL = p.Results.MIN_PEAK_VEL;
ACC_THRES = p.Results.ACC_THRES;
VEL_THRES = p.Results.VEL_THRES;
SACC_WINDOW_IN_SEC = 0.04;

Ts = time(2) - time(1);

% Get peak velocity indices:
[~, peakVelocityIds] = findpeaks(abs(vel), 'MinPeakHeight', MIN_PEAK_VEL, ...
    'MinPeakDistance', ceil(SACC_WINDOW_IN_SEC / Ts));
startIds = zeros(1, length(peakVelocityIds));
endIds = zeros(1, length(peakVelocityIds));
psoEndIds = zeros(1, length(peakVelocityIds));
presoStartIds = zeros(1, length(peakVelocityIds));
peakVelocities = zeros(1, length(peakVelocityIds));
amplitudes = zeros(1, length(peakVelocityIds));
durations = zeros(1, length(peakVelocityIds));
for i=1:length(peakVelocityIds)
    % Find "Pre-saccadic-oscillation" start point:
    presoStartId = find(...
        abs(vel(1:peakVelocityIds(i)-1)) <= VEL_THRES ...
        & abs(acc(1:peakVelocityIds(i)-1)) <= ACC_THRES, 1, 'last');
    if isempty(presoStartId)
        presoStartId = 1;
    end
    
    % Find saccade start index:
    startId = find(...
        sign(vel(peakVelocityIds(i))) * vel(1:peakVelocityIds(i)-1) <= VEL_THRES, ...
        1, 'last');
    startId = max(startId, presoStartId);
    if isempty(startId)
        startId = 1;
    end
   
    % Find PSO end index:
    psoEndId = find(...
        abs(vel(peakVelocityIds(i)+1:end)) <= VEL_THRES ...%abs(vel(peakVelocityIds(i))) / 3 ...
        & abs(acc(peakVelocityIds(i)+1:end)) <= ACC_THRES, ...
        1, 'first') + peakVelocityIds(i);
    if isempty(psoEndId)
        psoEndId = length(time);
    end
    
    % Find saccade end index:
    endId = min(psoEndId, ...
        find(sign(vel(peakVelocityIds(i))) * vel(peakVelocityIds(i)+1:end) <= VEL_THRES, 1, 'first') + peakVelocityIds(i));
    if isempty(endId)
        endId = length(time);
    end
    
    % Make sure that PSO duration is maximally as long as saccade:
    psoEndId = min(psoEndId, 2*endId-startId);
    
    

    % Check again for peak velocity(ies) within (saccStartIds(i):psoEndIds(i)),
    % if there are several, take the largest in absolute value:
    vMaxIdsSacc = peakVelocityIds(peakVelocityIds>=startId & peakVelocityIds<=psoEndId);
    if isempty(vMaxIdsSacc)
        % Hack for strange signals..
        vMaxIdsSacc = peakVelocityIds(peakVelocityIds>=startId-1 & peakVelocityIds<=psoEndId+1);
    end
    [~, maxI] = max(abs(vel(vMaxIdsSacc))); %==> vMaxIdsSacc(maxI) is definitive vMax index
    peakVelocities(i) = vel(vMaxIdsSacc(maxI));
    peakVelocityIds = [peakVelocityIds(peakVelocityIds<startId), ...
        vMaxIdsSacc(maxI), ...
        peakVelocityIds(peakVelocityIds>psoEndId)];
    
    %%% Check if detected saccade is valid:
    isSacc = true;
    saccIds = startId:psoEndId;
    % Remove saccades during blinks:
    if ~isempty(p.Results.blinksEstim)
        for j=1:length(p.Results.blinksEstim.startIds)
            blinkIds = p.Results.blinksEstim.startIds(j):p.Results.blinksEstim.endIds(j);
            if ~isempty(intersect(saccIds, blinkIds))
                isSacc = false;
            end
        end
    end
    % Remove saccades without sparse input:
    if ~isempty(p.Results.sparseInputs)
        if sum(abs(p.Results.sparseInputs(saccIds))>0.01)==0
            isSacc = false;
        end
    end
    
    if isSacc
        startIds(i) = startId;
        endIds(i) = endId;
        psoEndIds(i) = psoEndId;
        presoStartIds(i) = presoStartId;
        
        % Step size and duration:
        amplitudes(i) = pos(endIds(i)) - pos(startIds(i));
        durations(i) = time(endIds(i)) - time(startIds(i));
    end
    
%     % Find saccade start index:
%     startId = max( find(abs(vel(1:peakVelocityIds(i)-1)) <= VEL_THRES2 ...
%         & abs(acc(1:peakVelocityIds(i)-1)) <= ACC_THRES, 1, 'last'), ...
%         find(sign(vel(peakVelocityIds(i))) * vel(1:peakVelocityIds(i)-1) <= VEL_THRES1, 1, 'last') );
%     if isempty(startId)
%         startIds(i) = 1;
%     else
%         startIds(i) = startId;
%     end
%     
%     % Find saccade end index:
%     endId = min(psoEndIds(i), ...
%         find(sign(peakVelocities(i)) * vel(peakVelocityIds(i)+1:end) <= VEL_THRES1, 1, 'first') + peakVelocityIds(i));
%     if isempty(endId)
%         endIds(i) = length(time);
%     else
%         endIds(i) = endId;
%     end
    
        
    if i >= length(peakVelocityIds)
        break
    end
end

saccadeParams.numOfSaccades = sum(startIds~=0);
saccadeParams.peakVelocityIds = peakVelocityIds(startIds~=0);
saccadeParams.startIds = startIds(startIds~=0);
saccadeParams.endIds = endIds(startIds~=0);
saccadeParams.psoEndIds = psoEndIds(startIds~=0);
saccadeParams.presoStartIds = presoStartIds(startIds~=0);
saccadeParams.peakVelocities = peakVelocities(startIds~=0);
saccadeParams.amplitudes = amplitudes(startIds~=0);
saccadeParams.durations = durations(startIds~=0);

end

