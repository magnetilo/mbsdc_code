function [signals, saccadeParamsEstim, SSM] = separationHeuristics(signals, SSM, saccadeParamsEstim, blinksEstim)
%%% Separation heuristics and blink interpolation
%
% Copyright (C) Thilo Weber 2018 (see MIT license in the README.txt file)
%
% This function interpolates eye position during blinks and ensures that
% the PSO-end point of each saccade is on exactly the same amplitude level
% as the start piont of the next succeedeng saccade by
%   1) Increasing sigmaNoise during detected blinks
%   2) Adjusting the last sparse input of each saccade
%   3) Setting sparse saccadic inputs outside of detected saccades to zero
%   4) Re-estimating and re-extracting physical signals for fixed saccadic
%      input 


SACC_MARGIN_IN_SEC = 0.02;
BLINK_MARGIN_IN_SEC = 0.04;

%%% Smoothly interpolate eye position during blinks: %%%
SigmaZ = SSM.SIGMA_Z;
SSM.SIGMA_Z = SigmaZ * ones(1,SSM.N);
for j=1:length(blinksEstim.startIds)
    startId = max(1, blinksEstim.startIds(j) - ceil(BLINK_MARGIN_IN_SEC/SSM.Ts));
    endId = min(SSM.N, blinksEstim.endIds(j) + ceil(BLINK_MARGIN_IN_SEC/SSM.Ts));
    
    % If start/end Ids are within saccade, count saccade as part of the blink:
    prevSaccNr = find(saccadeParamsEstim.endIds < blinksEstim.startIds(j), 1, 'last');
    nextSaccNr = find(saccadeParamsEstim.startIds > blinksEstim.endIds(j), 1, 'first');
    if startId<min(SSM.N, saccadeParamsEstim.endIds(prevSaccNr)+ceil(SACC_MARGIN_IN_SEC/SSM.Ts))
        prevSaccStartId = max(1, saccadeParamsEstim.startIds(prevSaccNr) - ceil(SACC_MARGIN_IN_SEC/SSM.Ts));
        startId = min(startId, prevSaccStartId);
    end
    if endId>max(1, saccadeParamsEstim.startIds(nextSaccNr)-ceil(SACC_MARGIN_IN_SEC/SSM.Ts))
        nextSaccEndId = min(SSM.N, saccadeParamsEstim.endIds(nextSaccNr) + ceil(SACC_MARGIN_IN_SEC/SSM.Ts));
        endId = max(endId, nextSaccEndId);
    end
         
    I_blink = startId:endId;
    SSM.SIGMA_Z(1,I_blink) = 1e15 * SigmaZ; % Increase sigmaNoise during blinks
%     SSM.m_U(SSM.uSaccId,I_blink) = 0;
%     SSM.SIGMA_U(SSM.uSaccId,SSM.uSaccId,I_blink) = 0;
    signals.uHat(SSM.uSaccId,I_blink) = 0;  % Set saccade inputs to zero during blinks
end
% Set blink artifact signal yBlink to all-zero signal:
SSM.m_U(SSM.uBlinkId,:) = 0;
SSM.SIGMA_U(SSM.uBlinkId,SSM.uBlinkId,:) = 0;





%%% Separation heristics: %%%

%%% Remove all sparse inputs which are not part of a saccade:
I_sacc_blink = [];
for j=1:length(saccadeParamsEstim.startIds)
    kStartPre = max(1, saccadeParamsEstim.presoStartIds(j)-ceil(SACC_MARGIN_IN_SEC/SSM.Ts));
    kPSOendPost = min(SSM.N, saccadeParamsEstim.psoEndIds(j)+ceil(SACC_MARGIN_IN_SEC/SSM.Ts));
    % Time indices detected to be part of saccade:
    I_sacc_blink = [I_sacc_blink, kStartPre:kPSOendPost];
end
I_notSaccBlink = 1:SSM.N;
I_notSaccBlink(I_sacc_blink) = [];
signals.uHat(SSM.uSaccId,I_notSaccBlink) = 0;

% Simulate new saccadic kinematic signals:
x0_plant = signals.x0Hat(SSM.xPlantId,1);
controlSaccEstim = signals.x0Hat(SSM.xSaccId,1)+cumsum(signals.uHat(SSM.uSaccId,:));
xHatSacc = lsim(SSM.plantSSMdiscrete, controlSaccEstim, signals.time-min(signals.time), x0_plant)';
signals.posSaccEstim = xHatSacc(1,:);
signals.velSaccEstim = xHatSacc(2,:);
signals.accSaccEstim = xHatSacc(3,:);

% Get posSize2neural factor:
posStep = lsim(SSM.plantSSMdiscrete, ones(1,SSM.N), signals.time-min(signals.time))';
posSize2neural = posStep(1,:).^(-1);

% Adjust last sparse input of each saccade (iterate 4 times):
for i=1:4
    
%     fig = figure(1);
%     plot(signals.posSaccEstim)
%     hold on
%     plot(saccadeParamsEstim.psoEndIds, signals.posSaccEstim(saccadeParamsEstim.psoEndIds), 'x')
%     plot(saccadeParamsEstim.startIds, signals.posSaccEstim(saccadeParamsEstim.startIds), 'x')
%     waitfor(fig)
    
    %I_sacc_blink = [];
    
    for j=1:length(saccadeParamsEstim.startIds)
        kStartPre = max(1, saccadeParamsEstim.presoStartIds(j)-ceil(SACC_MARGIN_IN_SEC/SSM.Ts));
        kPSOendPost = min(SSM.N, saccadeParamsEstim.psoEndIds(j)+ceil(SACC_MARGIN_IN_SEC/SSM.Ts));

        if j==length(saccadeParamsEstim.startIds)
            kStartNext = SSM.N;
        else
            kStartNext = saccadeParamsEstim.startIds(j+1) - ceil(SACC_MARGIN_IN_SEC/SSM.Ts);
        end
        
        % Last non-zero input of current saccade:
        kUiLast = kStartPre-1 + find(abs(signals.uHat(SSM.uSaccId,kStartPre:kPSOendPost))>0.01, 1, 'last');

        if i<=2
            % First 2 steps adjust saccade step size to kUiLast+marg level:
            if ~isempty(kUiLast)
                marg = ceil(0.01/SSM.Ts);
                if kStartNext>kUiLast+marg+10
                    controlStepDiff = posSize2neural(1,kStartNext-(kUiLast+marg)) ...
                        * (signals.posSaccEstim(1,kStartNext) - signals.posSaccEstim(1,kUiLast+marg));
                else
                    controlStepDiff = 0;
                end
            else
                controlStepDiff = 0;
            end       
        else
            % Adjust saccade step size to kPSOendPost level two more times:
            if kStartNext > kPSOendPost+10
                controlStepDiff = posSize2neural(1,kStartNext-kPSOendPost) ...
                    * (signals.posSaccEstim(1,kStartNext) - signals.posSaccEstim(1,kPSOendPost));
            else
                controlStepDiff = 0;
            end
        end

        % Adjust step size by changing last sparse input of saccade:
        signals.uHat(SSM.uSaccId,kUiLast) = signals.uHat(SSM.uSaccId,kUiLast) - controlStepDiff;
        
        
    end
    
    %%% Remove all sparse inputs which are not part of a saccade:
%     I_notSaccBlink = 1:SSM.N;
%     I_notSaccBlink(I_sacc_blink) = [];
%     signals.uHat(SSM.uSaccId,I_notSaccBlink) = 0;
    
    % Simulate new saccadic kinematic signals:
    x0_plant = signals.x0Hat(SSM.xPlantId,1);
    controlSaccEstim = signals.x0Hat(SSM.xSaccId,1)+cumsum(signals.uHat(SSM.uSaccId,:));
    xHatSacc = lsim(SSM.plantSSMdiscrete, controlSaccEstim, signals.time-min(signals.time), x0_plant)';
    signals.posSaccEstim = xHatSacc(1,:);
    signals.velSaccEstim = xHatSacc(2,:);
    signals.accSaccEstim = xHatSacc(3,:);
    
    % Detect new PSO-end points:
    saccadeParamsEstim = saccadeDetection( ...
        signals.posSaccEstim, ...
        signals.velSaccEstim, ...
        signals.accSaccEstim, ...
        signals.time);

end


% Fix inputs saccadic inputs:
SSM.m_U(SSM.uSaccId,:) = signals.uHat(SSM.uSaccId,:);
SSM.SIGMA_U(SSM.uSaccId,SSM.uSaccId,:) = 0;

% Adjust initial state X0[SSM.xSaccId] of neural controller signal:
% fig = figure(1);
% plot(signals.posSaccEstim)
% hold on
% plot(saccadeParamsEstim.psoEndIds, signals.posSaccEstim(saccadeParamsEstim.psoEndIds), 'x')
% plot(saccadeParamsEstim.startIds, signals.posSaccEstim(saccadeParamsEstim.startIds), 'x')
% waitfor(fig)
if ~isempty(saccadeParamsEstim.startIds)
    kStartFirst = max(1, saccadeParamsEstim.presoStartIds(1)-ceil(SACC_MARGIN_IN_SEC/SSM.Ts));
else
    kStartFirst = SSM.N;
end
if kStartFirst > 10
    controlStepDiff = posSize2neural(1,kStartFirst)*(signals.posSaccEstim(1,kStartFirst) - signals.posSaccEstim(1,1));
else
    controlStepDiff = 0;
end

% Fix initial state X0[SSM.xSaccId]
SSM.m_X0(SSM.xSaccId,1) = signals.x0Hat(SSM.xSaccId,1) - controlStepDiff;
SSM.SIGMA_X0(SSM.xSaccId,SSM.xSaccId) = 0;

% Re-estimate states, and SPEM and FEM inputs, for fixed saccade and blink inputs:
msg = kalmanSmoothing(SSM, signals.data);
signals.xHat = msg.xMrg.m;
signals.uHat = msg.uMrg.m;
signals.x0Hat = msg.x0Mrg.m;

% Extract estimated signals:
signals = extractSignals(signals, SSM);

% fig = figure(1);
% plot(signals.posSaccEstim)
% hold on
% plot(saccadeParamsEstim.psoEndIds, signals.posSaccEstim(saccadeParamsEstim.psoEndIds), 'x')
% plot(saccadeParamsEstim.startIds, signals.posSaccEstim(saccadeParamsEstim.startIds), 'x')
% waitfor(fig)

end