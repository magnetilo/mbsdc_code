function signalsAll = loadMonkeyData()
%%% Script for creating 'signals{}'-cell with averaged monkey saccades and
%%% averaged neural control signal
%
% Copyright (C) Thilo Weber 2019 (see MIT license in the README.txt file)


%% Step 1 - Get position, spikecounnts and time signals with David's script:
[pEyeSort, xSIsSort, time] = showData(); %(Choose eye 1)


%% Step 2 - Choose good saccades:
%          plot(pEyeSort{1}(:,:))
% 'Hercules_Data/Abducens/h080409_004move.mat':
saccadeSelect ...
    = { [2:10 12:14], ...
        [1 3:8], ...
        [1:8 10:16], ...
        [2:3 5:9 11:13], ...
        [1:6 8:9], ...
        [1 4:10 12:17], ...
        [1 3 5 10:13 15:19], ...
        [1 3:13] };

% 'Hercules_Data/Abducens/h081109_002move.mat':
% saccadeSelect ...
%     = { [1:5 7:10], ...
%         [2:7 9], ...
%         [1:2 4:10 12:14], ...
%         [1:2 4 6:10], ...
%         [1:3 5 7:10], ...
%         [2:8 11:13], ...
%         [1:8], ...
%         [1 2:5 7:8 10 12:13 16] };


%% Step 3 - Collect avg. of positions and neural control signals to 
%          'signalsAll{}'-cell:
    
for i=1:length(saccadeSelect)
    signalsAll{i}.data = sum(pEyeSort{i}(7:end-3,saccadeSelect{i}),2)' / length(saccadeSelect{i});
    %signals{i}.data = pEyeSort{i}(7:end-3,saccadeSelect{i}(1))';
    signalsAll{i}.controlMeas = sum(xSIsSort{i}(3:end-7,saccadeSelect{i}),2)' / length(saccadeSelect{i});
    signalsAll{i}.time = time{i}(7:end-3)' / 1000;
    signalsAll{i}.samplingRate = 1000;
    signalsAll{i}.dataLen = length(signalsAll{i}.data);
end

end

