function signals = loadSineTargetData(path)
%%% Load sineTarget data into signals cell

load(path, '-mat')

signals.data = data';
signals.time = time';

signals.aSpem = amplitude;
signals.fSpem = frequenz;

signals.dataLen = length(signals.data);
signals.samplingRate = 1 / (signals.time(2) - signals.time(1));

signals.posTarget = signals.aSpem * sin(2*pi * signals.fSpem * signals.time);
signals.velTarget = signals.aSpem * 2*pi * signals.fSpem * cos(2*pi * signals.fSpem * signals.time);

end