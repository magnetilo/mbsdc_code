function signals = filterSignals(signals, noise, Ts)
%%% Estimated eye position, velocity, and acceleration obtained from 
%%% filtering and numerical defferentiation for comparison:
% The filter parameters are taken from "Mack2017, The effect of sampling
% rate and lowpass filters on saccades - A modeling approach, Supplementary
% Methods, Table 2". The parameters depend on the sampling rate and the 
% noise in the signal. (In Mack2017 they suggest also different filter 
% parameters for different saccade amplitudes, but for simplicity we filter
% the hole signal with the same filter parameters here.)
%
%   Inputs:
%    - signals.
%       data
%    - noise (observation noise, standard deviation in [°])
%    - Ts (Sampling period of data)
%   
%   Return arguments:
%    - signals
%       .posFilt
%       .velFilt
%       .accFilt

if noise<eps
    BW = inf; %Bandwidth (of Butterworth filter)
    WS = 0;   %Windowsize (of Savitzky-Golay filter)
    ORD = 0;  %Order (of Butterworth or Savitzky-Golay filter)
elseif signals.samplingRate<45
    if noise<0.2
        BW = inf;
        WS = 0;
        ORD = 0;
    elseif noise<0.75
        BW = inf;
        WS = 11;
        ORD = 9;
    else
        BW = inf;
        WS = 15;
        ORD = 8;
    end
elseif signals.samplingRate<75
    if noise<0.2
        BW = inf;
        WS = 0;
        ORD = 0;
    elseif noise<0.4
        BW = inf;
        WS = 11;
        ORD = 9;
    elseif noise<0.75
        BW = inf;
        WS = 9;
        ORD = 7;
    elseif noise<1.5
        BW = 15;
        WS = 0;
        ORD = 3;
    else
        BW = inf;
        WS = 0;
        ORD = 0;
    end
elseif signals.samplingRate<180
    if noise<0.025
        BW = 53;
        WS = 0;
        ORD = 9;
    elseif noise<0.055
        BW = 45;
        WS = 0;
        ORD = 3;
    elseif noise<0.085
        BW = 35;
        WS = 0;
        ORD = 9;
    elseif noise<0.2
        BW = 35;
        WS = 0;
        ORD = 8;
    elseif noise<0.4
        BW = inf;
        WS = 15;
        ORD = 8;
    else
        BW = inf;
        WS = 0;
        ORD = 0;
    end
elseif signals.samplingRate<375
    if noise<0.025
        BW = inf;
        WS = 15;
        ORD = 9;
    elseif noise<0.055
        BW = 45;
        WS = 0;
        ORD = 3;
    elseif noise<0.085
        BW = 40;
        WS = 0;
        ORD = 3;
    elseif noise<0.2
        BW = inf;
        WS = 13;
        ORD = 4;
    elseif noise<0.4
        BW = 30;
        WS = 0;
        ORD = 3;
    elseif noise<0.75
        BW = 25;
        WS = 0;
        ORD = 3;
    elseif noise<1.5
        BW = inf;
        WS = 15;
        ORD = 2;
    else
        BW = inf;
        WS = 0;
        ORD = 0;
    end
elseif signals.samplingRate<750
    if noise<0.025
        BW = 57;
        WS = 0;
        ORD = 9;
    elseif noise<0.055
        BW = 45;
        WS = 0;
        ORD = 9;
    elseif noise<0.085
        BW = 40;
        WS = 0;
        ORD = 9;
    elseif noise<0.2
        BW = 40;
        WS = 0;
        ORD = 8;
    elseif noise<0.4
        BW = 30;
        WS = 0;
        ORD = 7;
    elseif noise<0.75
        BW = 30;
        WS = 0;
        ORD = 4;
    elseif noise<1.5
        BW = 25;
        WS = 0;
        ORD = 4;
    else
        BW = inf;
        WS = 0;
        ORD = 0;
    end
else % samplingRate>750
    if noise<0.025
        BW = 90; %60;
        WS = 0;
        ORD = 9;
    elseif noise<0.055
        BW = 51;
        WS = 0;
        ORD = 9;
    elseif noise<0.085
        BW = 45;
        WS = 0;
        ORD = 6;
    elseif noise<0.2
        BW = 40;
        WS = 0;
        ORD = 9;
    elseif noise<0.4
        BW = 35;
        WS = 0;
        ORD = 7;
    elseif noise<0.75
        BW = 30;
        WS = 0;
        ORD = 9;
    elseif noise<1.5
        BW = 30;
        WS = 0;
        ORD = 5;
    else
        BW = 25;
        WS = 0;
        ORD = 4;
    end
end

% Estimate position by filtering data:
if BW<inf && ORD>0
    % Butterworth filtering:
    [B,A] = butter(ORD, BW * (2*Ts));
    signals.posFilt = filtfilt(B, A, signals.data);
elseif WS>0 && ORD>0
    % Savitzky-Golay filtering:
    signals.posFilt = sgolayfilt(signals.data, ORD, WS);
else
    % No filering:
    signals.posFilt = signals.data;
end

% Estimate velocity by 2-point central difference method:
signals.velFilt = gradient(signals.posFilt, Ts);

% Estimate acceleration by 2-point central difference method:
signals.accFilt = gradient(signals.velFilt, Ts);


end
