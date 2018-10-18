function [precision, ...
    recall] = getPrecisionRecall( ...
                    saccadeParamsTrue, ...
                    saccadeParamsEstim, dataLen)
%%% Calculates precision and recall for given true and detected saccade
%%% parameters (detected with MBSD.m)
%
% Copyright (C) Thilo Weber 2018 (see MIT license in the README.txt file)
%

num_saccs_true = length(saccadeParamsTrue.startIds);
num_saccs_estim = length(saccadeParamsEstim.startIds);

% Indicator of true saccades:
%   == 1 during true saccade
%   == 0 else
saccs_I_true = zeros(1,dataLen);
saccs_cntr_true = zeros(1,dataLen);
for i=1:num_saccs_true
    saccs_I_true(saccadeParamsTrue.startIds(i): saccadeParamsTrue.endIds(i)) = 1;
    saccs_cntr_true(saccadeParamsTrue.startIds(i) : dataLen) = ...
        saccs_cntr_true(saccadeParamsTrue.startIds(i) : dataLen) + 1;
end

% Indicator of estimated saccades:
%   == 1 during estimated saccade
%   == 0 else
saccs_I_estim = zeros(1,dataLen);
for i=1:num_saccs_estim
    saccs_I_estim(saccadeParamsEstim.startIds(i) : saccadeParamsEstim.endIds(i)) = 1;
end

% sum_I:
%   sum_I==0 ==> TRUE NEGATIVE
%   sum_I==1 ==> FALSE POSITIVE (wrongly deteced saccades)
%   sum_I==2 ==> FALSE NEGATIVE (missed saccades)
%   sum_I==3 ==> TURE POSITIVE (correctly detected saccades)
sum_I = 2 * saccs_I_true + saccs_I_estim;

% Get number of TRUE POSITIVES for precision and recall and
% relative peak velocity error statistics of correctly detected saccades:
relpverrMean = 0;
relpverrStd = 0;
num_true_positives = 0;
correctDetecSaccs = zeros(1,num_saccs_estim);
for i=1:num_saccs_estim
    if max(sum_I(saccadeParamsEstim.startIds(i) : saccadeParamsEstim.endIds(i))) == 3
        sacc_true_index = saccs_cntr_true(saccadeParamsEstim.endIds(i));
%         isTrueSacc = false;
%         if isfield(saccadeParamsTrue, 'amplitudes')
%             if 0.71*abs(saccadeParamsTrue.amplitudes(sacc_true_index)) < abs(saccadeParamsEstim.amplitudes(i)) ...
%                     && abs(saccadeParamsEstim.amplitudes(i)) < 1.4*abs(saccadeParamsTrue.amplitudes(sacc_true_index))
%                 isTrueSacc = true;
%             end
%         else
%             isTrueSacc = true;
%         end
%         if isTrueSacc
            % TURE POSITIVE (correctly detected saccades):
            num_true_positives = num_true_positives + 1;
            relpverr = saccadeParamsEstim.peakVelocities(i) / saccadeParamsTrue.peakVelocities(sacc_true_index);
            relpverrMean = relpverrMean + relpverr;
            relpverrStd = relpverrStd + relpverr^2;
            correctDetecSaccs(1,i) = true;
%         end
    else
        correctDetecSaccs(1,i) = false;
    end
end
relpverrMean = relpverrMean / num_true_positives;
relpverrStd = sqrt(relpverrStd / num_true_positives - relpverrMean^2);

precision = num_true_positives / num_saccs_estim;
recall = num_true_positives / num_saccs_true;

end

