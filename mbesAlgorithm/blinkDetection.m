function blinks = blinkDetection(blinkInputs, vel, acc, Ts, varargin)
%%% Blink detection
%
% Copyright (C) Thilo Weber 2018 (see MIT license in the README.txt file)
%
% Output: 
%   blinks
%       .startIds
%       .endIds

p = inputParser;
addOptional(p, 'MIN_PEAK_VEL', 1000, @isnumeric);
addOptional(p, 'ACC_THRES', 3000, @isnumeric);
addOptional(p, 'VEL_THRES', 20, @isnumeric);
addOptional(p, 'VEL_THRES2', 5, @isnumeric);
addOptional(p, 'MIN_BLINK_DURATION_IN_SEC', 0.04, @isnumeric);
parse(p,varargin{:});

MIN_PEAK_VEL = p.Results.MIN_PEAK_VEL;
ACC_THRES = p.Results.ACC_THRES;
VEL_THRES = p.Results.VEL_THRES;
VEL_THRES2 = p.Results.VEL_THRES2;
MIN_BLINK_DURATION_IN_SEC = p.Results.MIN_BLINK_DURATION_IN_SEC;

startIds = [];
endIds = [];

% Get potential blink start IDs:
[~, peakVelocityIds] = findpeaks(abs(vel), 'MinPeakHeight', MIN_PEAK_VEL);
[msg, id] = lastwarn;
warning('off',id)
blinkInputIds = find(abs(blinkInputs)>0.1);
blinkStartIds = sort([peakVelocityIds blinkInputIds]);

for i=1:length(blinkStartIds)
    % Get start index of blink:
    maxStartId = find(abs(vel(1:blinkStartIds(i)-ceil(MIN_BLINK_DURATION_IN_SEC/Ts))) ...
        >= VEL_THRES2, 1, 'last') - ceil(MIN_BLINK_DURATION_IN_SEC/Ts);
    startId = find(abs(vel(1:maxStartId-1)) <= VEL_THRES ...
        & abs(acc(1:maxStartId-1)) <= ACC_THRES, 1, 'last');
    if isempty(startId)
        startId = 1;
    end
    
    % Get end index of blink:
    minEndId = find(abs(vel(blinkStartIds(i)+ceil(MIN_BLINK_DURATION_IN_SEC/Ts):end)) ...
        >= VEL_THRES2, 1, 'first') + blinkStartIds(i) + ceil(MIN_BLINK_DURATION_IN_SEC/Ts) ...
        + ceil(MIN_BLINK_DURATION_IN_SEC/Ts);
    endId = find(abs(vel(minEndId+1:end)) <= VEL_THRES ...
        & abs(acc(minEndId+1:end)) <= ACC_THRES, 1, 'first') + minEndId;
    if isempty(endId)
        endId = length(vel);
    end
    
    if isempty(endIds)
        % First detected blink
        startIds = [startIds startId];
        endIds = [endIds endId];
    else
        if startId <= endIds(1,end) + ceil(MIN_BLINK_DURATION_IN_SEC/Ts)
            % Join current blink with previous one:
            endIds(1,end) = endId;
        else
            % New blink detected:
            startIds = [startIds startId];
            endIds = [endIds endId];
        end
    end
    
    % In case of joined blinks remove previous blink:
    blinkStartIds(blinkStartIds(i)<blinkStartIds & blinkStartIds<=endId) = [];
    
    if i+1>length(blinkStartIds)
        break
    end
end

blinks.startIds = startIds;
blinks.endIds = endIds;

end