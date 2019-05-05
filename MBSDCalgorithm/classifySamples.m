function sampleClass = classifySamples(saccadeParams, blinks, velSpem, accSpem, Ts)
%%% Classify eye movements on a sample-by-sample basis
%
% Copyright (C) Thilo Weber 2019 (see MIT license in the README.txt file)
%
% Output:
%   @ sampleClass: Signal of length n that indicates the label of every sample of the 
%   observation signal by one of the classes:
%       - 1: Fixation
%       - 2: Smooth Pursuit
%       - 3: Post Saccadic Oscillations (PSOs)
%       - 4: Saccades
%       - 5: Blinks/Unknown

%%% Threshold parameters:
MIN_SPEM_VEL = 1.5;
MIN_SPEM_ACC = 50;

n = length(velSpem);

%%% Start with classifying everything as fixation:
sampleClass = ones(1,n);

%%% Identify SPEM samples:
for k=1:n
    if abs(smooth(velSpem(k),300)) > MIN_SPEM_VEL ...
            || abs(accSpem(k)) > MIN_SPEM_ACC
        sampleClass(k) = 2;
    end
end

%%% Identify PSO samples:
for i=1:saccadeParams.numOfSaccades
    sampleClass(saccadeParams.endIds(i) : saccadeParams.psoEndIds(i)) = 3;
end

%%% Identify saccade samples:
for i=1:saccadeParams.numOfSaccades
    %sampleClass(saccadeParams.startIds(i) : saccadeParams.endIds(i)) = 4;
    
    % Heuristic: Our detected saccade start points on the velocity profile are
    % usually a bit earlier than the manually labeled ones, hence, we add 
    % some constant time of 3 ms to the detected start point... 
    sampleClass(min(saccadeParams.startIds(i)+round(0.002/Ts), saccadeParams.peakVelocityIds(i)) ...
        : saccadeParams.endIds(i)) = 4;
end

%%% Identify blink samples:
for i=1:length(blinks.startIds)
    val = 5;
%     for j=1:length(lostSampleIds)
%         if sum((blinks.startIds(i):blinks.endIds(i))==lostSampleIds(j))>0
%            val = 6;
%         end
%     end
    sampleClass(blinks.startIds(i) : blinks.endIds(i)) = val;
end

%%% Identify unknown samples:
% for i=1:length(lostSampleIds)
%     sampleClass(lostSampleIds(i)) = 6;
% end

end

