function mainSeqPlot(saccadeParamsTrueAll, signalsAllMBSD, signalsAllOptimFilt, signalsAllWeakFilt, signalsAllStrongFilt)
%%% Function for peak-velocity mean and std. dev. plot (Fig. 6 in paper)
%
% Copyright (C) Thilo Weber 2019 (see MIT license in the README.txt file)
%
% Prerequisited steps:
%  1. Generate saccade data with 
%     [signalsAll, saccadeParamsTrueAll] = generateZhou09Saccades()
%  2. Run MBSD algorithm, e.g., with evaluate_1D_data.m, for generating
%     signalsAllMBSD
%  3. Get estimates by applying lowpass filters of different cutoff-freqs.
%     (e.g., by outcommenting MBSD part in evaluate_1D_data.m)


%%% Main sequence plot:
% Compute mean and stdDev for different saccade sizes:
numData = length(saccadeParamsTrueAll)-1;
meanEstim = zeros(1,numData);
stdDevEstim = zeros(1,numData);
meanFilt = zeros(1,numData);
stdDevFilt = zeros(1,numData);
meanWeakFilt = zeros(1,numData);
stdDevWeakFilt = zeros(1,numData);
meanStrongFilt = zeros(1,numData);
stdDevStrongFilt = zeros(1,numData);
amplitudes = zeros(1,numData);

for i=1:numData
    amplitudes(1,i) = abs(saccadeParamsTrueAll{i}.amplitudes(1));
    numSaccs = length(saccadeParamsTrueAll{i}.startIds);
    for j=1:numSaccs
        startId = saccadeParamsTrueAll{i}.startIds(j);
        endId = saccadeParamsTrueAll{i}.endIds(j);
        
        peakVelEstim = max(abs(signalsAllMBSD{i}.velEstim(startId:endId)));
        meanEstim(1,i) = meanEstim(1,i) + peakVelEstim;
        stdDevEstim(1,i) = stdDevEstim(1,i) + peakVelEstim^2;
        
        peakVelFilt = max(abs(signalsAllOptimFilt{i}.velFilt(startId:endId)));
        meanFilt(1,i) = meanFilt(1,i) + peakVelFilt;
        stdDevFilt(1,i) = stdDevFilt(1,i) + peakVelFilt^2;
        
        peakVelWeakFilt = max(abs(signalsAllWeakFilt{i}.velFilt(startId:endId)));
        meanWeakFilt(1,i) = meanWeakFilt(1,i) + peakVelWeakFilt;
        stdDevWeakFilt(1,i) = stdDevWeakFilt(1,i) + peakVelWeakFilt^2;
        
        peakVelStrongFilt = max(abs(signalsAllStrongFilt{i}.velFilt(startId:endId)));
        meanStrongFilt(1,i) = meanStrongFilt(1,i) + peakVelStrongFilt;
        stdDevStrongFilt(1,i) = stdDevStrongFilt(1,i) + peakVelStrongFilt^2;
    end
    meanEstim(1,i) = meanEstim(1,i)/numSaccs;
    stdDevEstim(1,i) = sqrt(stdDevEstim(1,i)/numSaccs - meanEstim(1,i)^2);
    
    meanFilt(1,i) = meanFilt(1,i)/numSaccs;
    stdDevFilt(1,i) = sqrt(stdDevFilt(1,i)/numSaccs - meanFilt(1,i)^2);
    
    meanWeakFilt(1,i) = meanWeakFilt(1,i)/numSaccs;
    stdDevWeakFilt(1,i) = sqrt(stdDevWeakFilt(1,i)/numSaccs - meanWeakFilt(1,i)^2);
    
    meanStrongFilt(1,i) = meanStrongFilt(1,i)/numSaccs;
    stdDevStrongFilt(1,i) = sqrt(stdDevStrongFilt(1,i)/numSaccs - meanStrongFilt(1,i)^2);
        
%     corrI = saccadeParamsEstimAll{i}.correctDetects;
%     numSaccsEstim = length(saccadeParamsEstimAll{i}.peakVelocities(corrI==true));
%     meanEstim(1,i) = mean(abs(saccadeParamsEstimAll{i}.peakVelocities(corrI==true)));
%     stdDevEstim(1,i) = sqrt(norm(saccadeParamsEstimAll{i}.peakVelocities(corrI==true))^2 / numSaccsEstim - meanEstim(1,i)^2);
%     amplitudesEstim(1,i) = mean(abs(saccadeParamsEstimAll{i}.amplitudes(corrI==true)));
%     
%     corrI = saccadeParamsFiltAll{i}.correctDetects;
%     numSaccsFilt = length(saccadeParamsFiltAll{i}.peakVelocities(corrI==true));
%     meanFilt(1,i) = mean(abs(saccadeParamsFiltAll{i}.peakVelocities(corrI==true)));
%     stdDevFilt(1,i) = sqrt(norm(saccadeParamsFiltAll{i}.peakVelocities(corrI==true))^2 / numSaccsFilt - meanFilt(1,i)^2);
%     amplitudesFilt(1,i) = mean(abs(saccadeParamsFiltAll{i}.amplitudes(corrI==true)));
    
%     corrI = saccadeParamsEstimAll10{i}.correctDetects;
%     numSaccsEstim = length(saccadeParamsEstimAll10{i}.peakVelocities(corrI==true));
%     meanEstim10(1,i) = mean(abs(saccadeParamsEstimAll10{i}.peakVelocities(corrI==true)));
%     stdDevEstim10(1,i) = sqrt(norm(saccadeParamsEstimAll10{i}.peakVelocities(corrI==true))^2 / numSaccsEstim - meanEstim10(1,i)^2);
%     amplitudesEstim10(1,i) = mean(abs(saccadeParamsEstimAll10{i}.amplitudes(corrI==true)));
%     
%     corrI = saccadeParamsFiltAll10{i}.correctDetects;
%     numSaccsFilt = length(saccadeParamsFiltAll10{i}.peakVelocities(corrI==true));
%     meanFilt10(1,i) = mean(abs(saccadeParamsFiltAll10{i}.peakVelocities(corrI==true)));
%     stdDevFilt10(1,i) = sqrt(norm(saccadeParamsFiltAll10{i}.peakVelocities(corrI==true))^2 / numSaccsFilt - meanFilt10(1,i)^2);
%     amplitudesFilt10(1,i) = mean(abs(saccadeParamsFiltAll10{i}.amplitudes(corrI==true)));
    
end

% Plot:
colors.lines = lines;
colors.true = [0.7 0.7 0.7];
colors.estim = colors.lines(1,:);
colors.filt = colors.lines(2,:);
LINE_WIDTH = 1.5;

x = linspace(0, 10.3, 100);
%plot(x, 684 * (1 - exp(-x/10)), 'k')
plot(x, x*1000./(18 + 1.2*abs(x)), 'Color', colors.true, 'LineWidth', LINE_WIDTH)
hold on
% errorbar(amplitudesEstim10, meanEstim10, stdDevEstim10, 'x:', 'Linewidth', LINE_WIDTH/2, 'Color', colors.lines(3,:))
% errorbar(amplitudesFilt10, meanFilt10, stdDevFilt10, '+:', 'Linewidth', LINE_WIDTH/2, 'Color', colors.lines(5,:))
errorbar(amplitudes+0, meanWeakFilt, stdDevWeakFilt, '.', 'Linewidth', LINE_WIDTH, 'Color', colors.lines(3,:), 'Markersize', 10)
errorbar(amplitudes-0, meanStrongFilt, stdDevStrongFilt, '.', 'Linewidth', LINE_WIDTH, 'Color', colors.lines(4,:), 'Markersize', 1)
errorbar(amplitudes+0.07, meanFilt, stdDevFilt, '+', 'Linewidth', LINE_WIDTH, 'Color', colors.filt)
errorbar(amplitudes-0.07, meanEstim, stdDevEstim, 'x', 'Linewidth', LINE_WIDTH, 'Color', colors.estim)

set(gca,'FontName','Helvetica');
lgd =   legend('Main sequence', 'Filt (weak)', 'Filt (strong)', 'Filt (optimal)', 'MBSD');
%set(lgd, 'Interpreter', 'latex')
set(lgd, 'Location','southeast');
%set(lgdd,'FontName','Helvetica')
grid on
set(gcf,'units','points','position',[10,10,500,350])
set(gca,'FontSize',12)
set(gca,'xtick',0:2:20)%[0.6 1.2 2.5 5 10 20])
set(0, 'DefaultFigureRenderer', 'painters');
axis tight

ylabel('Peak Velocity [?/s]')
xlabel('Amplitude [?]')
