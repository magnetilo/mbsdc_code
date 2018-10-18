function signals = extractSignals(signals, SSM)
%%% Extract signals
%
% Copyright (C) Thilo Weber 2018 (see MIT license in the README.txt file)
%
% Return arguments:
%   signals
%       .posEstim
%       .velEstim
%       .accEstim
%       .uSacc
%       .controlEstim
%       .controlSaccEstim
%       .controlSpemEstim
%       .controlFemEstim
%       .posSaccEstim
%       .posSpemEstim
%       .posFemEstim
%       .velSaccEstim
%       .velSpemEstim
%       .velFemEstim
%       .accSaccEstim
%       .accSpemEstim
%       .accFemEstim
%       .forceSaccEstim
%       .forceSpemEstim
%       .forceFemEstim

%%% Estimated kinematic signals:
signals.posEstim = SSM.C * signals.xHat;
signals.velEstim = signals.xHat(SSM.xPlantId(2),:);
signals.accEstim = signals.xHat(SSM.xPlantId(3),:);
signals.forceEstim = signals.xHat(SSM.xPlantId(4),:);

%%% Estimated control signals:
signals.controlSaccEstim = signals.xHat(SSM.xSaccId,:);
if ~isempty(SSM.xSpemId)
    signals.controlSpemEstim = signals.xHat(SSM.xSpemId(1),:);
else
    signals.controlSpemEstim = zeros(1,SSM.N);
end
signals.controlFemEstim = signals.xHat(SSM.xFemId,:);
signals.controlEstim = signals.controlSaccEstim + signals.controlSpemEstim + signals.controlFemEstim;

%%% Simulate saccadic kinematic signals:
x0_plant = signals.x0Hat(SSM.xPlantId,1);
xHatSacc = lsim(SSM.plantSSMdiscrete, signals.controlSaccEstim, signals.time-min(signals.time), x0_plant)';
signals.posSaccEstim = xHatSacc(1,:);
signals.velSaccEstim = xHatSacc(2,:);
signals.accSaccEstim = xHatSacc(3,:);
signals.forceSaccEstim = xHatSacc(4,:);

%%% Simulate SPEM kinematic signals:
xHatSpem = lsim(SSM.plantSSMdiscrete, signals.controlSpemEstim)';
signals.posSpemEstim = xHatSpem(1,:);
signals.velSpemEstim = xHatSpem(2,:);
signals.accSpemEstim = xHatSpem(3,:);
signals.forceSpemEstim = xHatSpem(4,:);

%%% Simulate FEM kinematic signals:
xHatFem = lsim(SSM.plantSSMdiscrete, signals.controlFemEstim)';
signals.posFemEstim = xHatFem(1,:);
signals.velFemEstim = xHatFem(2,:);
signals.accFemEstim = xHatFem(3,:);
signals.forceFemEstim = xHatFem(4,:);

end
