function plotSaccades(signals, saccadeParamsEstim, varargin)
%%% Plot estimated saccades (Fig. 5 in paper)
%
% Copyright (C) Thilo Weber 2018 (see MIT license in the README.txt file)
%
% Inputs:
%  1. Estimate 'signals' for given data (e.g., using MBSD_main_simple.m)
%
% Possible calls:
%   strange Sacc Meas 4: plotSaccades(signalsAll{i}, saccadeParamsEstimAll{i}, 'saccadeParamsFilt', saccadeParamsFiltAll{i}, 'withYLabel', true, 'time', 1000*signalsAll{i}.time-1380+3.785, 'sign', -0.7, 'posOffset', +1.62, 'sparsePulse', signalsAll{i}.controlSaccEstimSprs)
%   sinTarget 5: plotSaccades(signalsAll{5}, saccadeParamsEstimAll{5}, 'withYLabel', false, 'time', 1000*signalsAll{5}.time - 352.294, 'saccadeParamsFilt', saccadeParamsFiltAll{5})
%   simulatedStrange: plotSaccades(signalsAll{4}, saccadeParamsEstimAll{4}, 'withYLabel', false, 'time', 1000*signalsAll{4}.time - 51, 'saccadeParamsTrue', saccadeParamsTrueAll{4}, 'saccadeParamsFilt', saccadeParamsFiltAll{4})
%   sinTarget 1: plotSaccades(signalsAll{1}, saccadeParamsEstimAll{1}, 'withYLabel', false, 'time', 1000*signalsAll{1}.time - 300.4, 'saccadeParamsFilt', saccadeParamsFiltAll{1})
%   sinTarget 4: plotSaccades(signalsAll{i}, saccadeParamsEstimAll{i}, 'saccadeParamsFilt', saccadeParamsFiltAll{i}, 'withYLabel', false, 'time', 1000*signalsAll{i}.time-1380+3.785, 'sign', -1, 'posOffset', -1.62, 'sparsePulse', sparsePulse)
%

p = inputParser;
addOptional(p, 'saccadeParamsTrue', [], @isstruct);
addOptional(p, 'saccadeParamsFilt', [], @isstruct);
addOptional(p, 'withYLabel', true, @islogical);
addOptional(p, 'time', 1000*signals.time, @isnumeric);
addOptional(p, 'posOffset', 0, @isnumeric);
addOptional(p, 'sign', 1, @isnumeric);
addOptional(p, 'sparsePulse', [], @isnumeric);

parse(p,varargin{:});
saccadeParamsTrue = p.Results.saccadeParamsTrue;
saccadeParamsFilt = p.Results.saccadeParamsFilt;
posOffset = p.Results.posOffset;
sign = p.Results.sign;


colors.lines = lines;
colors.data = [0.7 0.7 0.7];
colors.estim = [0 0 0];
colors.pulse = colors.lines(1,:);
colors.slide = colors.lines(2,:);
colors.true = [0.7 0.7 0.7];
colors.filt = colors.lines(3,:);
LINE_WIDTH = 1.5;
MARKER_SIZE = 7;
MARKER_LINE_WIDTH = 0.8;
FONT_SIZE = 12;
set(gcf,'units','points','position',[10,10,250,350])

%time = 1000*signals.time - 51;% - 352.294;% - 300.4;
time = p.Results.time;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Position plot:
subplot(3,1,1)
title('Saccade Detection Plot:')
hold on
plot(time, sign*(signals.data+posOffset), '.', 'Color', colors.data, 'MarkerSize', 8)
%plot(time, signals2.posEstim, 'Color', colors.slide, 'LineWidth', LINE_WIDTH)
if ~isempty(saccadeParamsFilt)
    plot(time, sign*(signals.posFilt+posOffset), 'Color', colors.filt, 'LineWidth', LINE_WIDTH)
end
plot(time, sign*(signals.posEstim+posOffset), 'Color', colors.pulse, 'LineWidth', LINE_WIDTH/2)

% Plot estimated pulse-slide-step saccade indices:
% plot(time(saccadeParamsEstim2.startIds), ...
%     signals2.posEstim(saccadeParamsEstim2.startIds), ...
%     'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.slide)
% plot(time(saccadeParamsEstim2.endIds), ...
%     signals2.posEstim(saccadeParamsEstim2.endIds), ...
%     's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.slide)
% plot(time(saccadeParamsEstim2.psoEndIds), ...
%     signals2.posEstim(saccadeParamsEstim2.psoEndIds), ...
%     'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.slide)

% Plot filter saccade indices:
if ~isempty(saccadeParamsFilt)
    plot(time(saccadeParamsFilt.startIds), ...
        sign*(signals.posFilt(saccadeParamsFilt.startIds)+posOffset), ...
        'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
    plot(time(saccadeParamsFilt.endIds), ...
        sign*(signals.posFilt(saccadeParamsFilt.endIds)+posOffset), ...
        's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
    plot(time(saccadeParamsFilt.psoEndIds), ...
        sign*(signals.posFilt(saccadeParamsFilt.psoEndIds)+posOffset), ...
        'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
end

% Plot estimated pulse-step saccade indices:
plot(time(saccadeParamsEstim.startIds), ...
    sign*(signals.posEstim(saccadeParamsEstim.startIds)+posOffset), ...
    'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)
plot(time(saccadeParamsEstim.endIds), ...
    sign*(signals.posEstim(saccadeParamsEstim.endIds)+posOffset), ...
    's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)
plot(time(saccadeParamsEstim.psoEndIds), ...
    sign*(signals.posEstim(saccadeParamsEstim.psoEndIds)+posOffset), ...
    'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)

if p.Results.withYLabel
    ylabel('Pos. $\theta \; [^{\circ}]$', 'Interpreter', 'latex')
else
    set(gca,'yticklabel',[])
end
set(gca,'xticklabel',[])
if isempty(saccadeParamsFilt)
    lgd = legend('$y$ (Data)', '$\widehat\theta$');
else
    lgd = legend('$y$ (Data)', '$\widehat\theta$ (Filt)', '$\widehat\theta$ (Strc)');
end
set(lgd, 'Location','southeast');
set(lgd, 'Interpreter', 'latex')
% lgd = legend('$\theta^*$', '$\widehat \theta$ (pulse-step)', ...
%         '$\widehat \theta$ (pulse-slide-step)', '$\widehat \theta_\textrm{Filt}$ (filtered)');

%axis([-20 80 -0.7 5.5])
axis tight
grid on
set(gca,'FontName','Helvetica');
set(gca,'FontSize',FONT_SIZE)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Velocity plot:
subplot(3,1,2)
hold on

%plot(time, signals2.velEstim, 'Color', colors.slide, 'LineWidth', LINE_WIDTH)
if ~isempty(saccadeParamsFilt)
    plot(time, sign*signals.velFilt, 'Color', colors.filt, 'LineWidth', LINE_WIDTH)
end
plot(time, sign*signals.velEstim, 'Color', colors.pulse, 'LineWidth', LINE_WIDTH)
if isfield(signals, 'velTrue')
    plot(time, sign*signals.velTrue, '--', 'Color', colors.true, 'LineWidth', LINE_WIDTH)
end

% Plot estimated pulse-step saccade indices:
plot(time(saccadeParamsEstim.startIds), ...
    sign*signals.velEstim(saccadeParamsEstim.startIds), ...
    'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)
plot(time(saccadeParamsEstim.endIds), ...
    sign*signals.velEstim(saccadeParamsEstim.endIds), ...
    's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)
plot(time(saccadeParamsEstim.peakVelocityIds), ...
    sign*signals.velEstim(saccadeParamsEstim.peakVelocityIds), ...
    'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)
plot(time(saccadeParamsEstim.psoEndIds), ...
    sign*signals.velEstim(saccadeParamsEstim.psoEndIds), ...
    'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)

% Plot estimated pulse-slide-step saccade indices:
% plot(time(saccadeParamsEstim2.startIds), ...
%     signals2.velEstim(saccadeParamsEstim2.startIds), ...
%     'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.slide)
% plot(time(saccadeParamsEstim2.peakVelocityIds), ...
%     signals2.velEstim(saccadeParamsEstim2.peakVelocityIds), ...
%     'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.slide)
% plot(time(saccadeParamsEstim2.endIds), ...
%     signals2.velEstim(saccadeParamsEstim2.endIds), ...
%     's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.slide)
% plot(time(saccadeParamsEstim2.psoEndIds), ...
%     signals2.velEstim(saccadeParamsEstim2.psoEndIds), ...
%     'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.slide)

% Plot filter saccade indices:
if ~isempty(saccadeParamsFilt)
    plot(time(saccadeParamsFilt.startIds), ...
        sign*signals.velFilt(saccadeParamsFilt.startIds), ...
        'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
    plot(time(saccadeParamsFilt.peakVelocityIds), ...
        sign*signals.velFilt(saccadeParamsFilt.peakVelocityIds), ...
        'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
    plot(time(saccadeParamsFilt.endIds), ...
        sign*signals.velFilt(saccadeParamsFilt.endIds), ...
        's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
    plot(time(saccadeParamsFilt.psoEndIds), ...
        sign*signals.velFilt(saccadeParamsFilt.psoEndIds), ...
        'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
end

% Plot true saccade indices:
if ~isempty(saccadeParamsTrue)
    plot(time(saccadeParamsTrue.startIds), ...
         sign*signals.velTrue(saccadeParamsTrue.startIds), ...
         'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
    plot(time(saccadeParamsTrue.peakVelocityIds), ...
        sign*signals.velTrue(saccadeParamsTrue.peakVelocityIds), ...
        'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
    plot(time(saccadeParamsTrue.endIds), ...
         sign*signals.velTrue(saccadeParamsTrue.endIds), ...
         's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
    plot(time(saccadeParamsTrue.psoEndIds), ...
        sign*signals.velTrue(saccadeParamsTrue.psoEndIds), ...
        'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
end

if p.Results.withYLabel
    ylabel('Vel. $\dot\theta \; [^{\circ}]$', 'Interpreter', 'latex')
else
    set(gca,'yticklabel',[])
end
set(gca,'xticklabel',[])
if isfield(signals, 'velTrue') && ~isempty(saccadeParamsFilt)
    lgd = legend('$\widehat{\dot\theta}$ (Filt)', '$\widehat{\dot\theta}$ (Strc)', '$\dot\theta^{*}$');
elseif ~isempty(saccadeParamsFilt)
    lgd = legend('$\dot\theta$ (Filt)', '$\widehat{\dot\theta}$ (Strc)');
else
    lgd = legend('$\widehat{\dot\theta}$');
end
set(lgd, 'Interpreter', 'latex')

%axis([-20 80 -50 260])
axis tight
grid on
set(gca,'FontName','Helvetica');
set(gca,'FontSize',FONT_SIZE)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Neural signal plot:
subplot(3,1,3)
hold on
if isfield(signals, 'controlMeas')
    [~,idx] = max(abs(signals.controlSaccEstim));
    absmax_estim = signals.controlSaccEstim(idx);
    [~,idx] = max(abs(signals.controlMeas));
    absmax_meas = signals.controlMeas(idx);
    a_start = absmax_estim / absmax_meas;
    %b_start = mean(signals.controlSaccEstim) - mean(signals.controlMeas);
    scaleFit = fit(signals.controlMeas(saccadeParamsEstim.startIds(1):saccadeParamsEstim.endIds(1))', ...
        signals.controlSaccEstim(saccadeParamsEstim.startIds(1):saccadeParamsEstim.endIds(1))', ...
        'a*x', 'Start', a_start);
    N_ag = scaleFit(signals.controlMeas);
    %N_ag = signals.controlMeas * absmax_estim / absmax_meas;
    plot(time, sign*N_ag+posOffset/20, 'Color', colors.data, 'LineWidth', LINE_WIDTH);
end
if ~isempty(p.Results.sparsePulse)
    stairs(time, sign*(p.Results.sparsePulse+posOffset/20), 'Color', colors.slide, 'LineWidth', LINE_WIDTH)
end
plot(time, sign*(signals.controlSaccEstim+posOffset/20), 'Color', colors.pulse, 'LineWidth', LINE_WIDTH)
if isfield(signals, 'velTrue')
    plot(time, sign*(signals.controlSaccTrue+posOffset/20), '--', 'Color', colors.true, 'LineWidth', LINE_WIDTH)
end

% % Plot true saccade indices:
% if ~isempty(saccadeParamsTrue)
%     plot(time(saccadeParamsTrue.startIds), ...
%          sign*(signals.controlSaccTrue(saccadeParamsTrue.startIds)+posOffset/20), ...
%          'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
%     plot(time(saccadeParamsTrue.endIds), ...
%          sign*(signals.controlSaccTrue(saccadeParamsTrue.endIds)+posOffset/20), ...
%          's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
%     plot(time(saccadeParamsTrue.psoEndIds), ...
%         sign*(signals.controlSaccTrue(saccadeParamsTrue.psoEndIds)+posOffset/20), ...
%         'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
% end
% 
% % Plot estimated pulse-step saccade indices:
% plot(time(saccadeParamsEstim.startIds), ...
%     sign*(signals.controlSaccEstim(saccadeParamsEstim.startIds)+posOffset/20), ...
%     'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)
% plot(time(saccadeParamsEstim.endIds), ...
%     sign*(signals.controlSaccEstim(saccadeParamsEstim.endIds)+posOffset/20), ...
%     's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)
% plot(time(saccadeParamsEstim.psoEndIds), ...
%     sign*(signals.controlSaccEstim(saccadeParamsEstim.psoEndIds)+posOffset/20), ...
%     'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)

% Plot estimated pulse-slide-step saccade indices:
% plot(time(saccadeParamsEstim2.startIds), ...
%     signals2.controlSaccEstim(saccadeParamsEstim2.startIds), ...
%     'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.slide)
% plot(time(saccadeParamsEstim2.endIds), ...
%     signals2.controlSaccEstim(saccadeParamsEstim2.endIds), ...
%     's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.slide)
% plot(time(saccadeParamsEstim2.psoEndIds), ...
%     signals2.controlSaccEstim(saccadeParamsEstim2.psoEndIds), ...
%     'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.slide)


xlabel('Time [ms]')
if p.Results.withYLabel
    ylabel('Ctrl. $\Delta N$ [N]', 'Interpreter', 'latex')
else
    set(gca,'yticklabel',[])
end
if isfield(signals, 'controlSaccTrue')
    if isempty(p.Results.sparsePulse)
        lgd = legend('${\Delta N}^{*}_\textrm{Sacc}$', '$\widehat{\Delta N}_\textrm{Sacc}$');
    else
        lgd = legend('$\widehat{\Delta N}_\textrm{Sacc}$ (Sprs)', ...
            '$\widehat{\Delta N}_\textrm{Sacc}$ (Strc)', '${\Delta N}^{*}_\textrm{Sacc}$');
    end
elseif isfield(signals, 'controlMeas')
    lgd = legend('Data', '$\widehat{\Delta N}_\textrm{Sacc}$');    
else
    if isempty(p.Results.sparsePulse)
        lgd = legend('$\widehat{\Delta N}_\textrm{Sacc}$');
    else
        lgd = legend('$\widehat{\Delta N}_\textrm{Sacc}$ (Sprs)', ...
            '$\widehat{\Delta N}_\textrm{Sacc}$ (Strc)');
    end
end
set(lgd, 'Interpreter', 'latex')

%axis([-20 80 -0.8 3])
axis tight
grid on
set(lgd, 'Location','northeast');
set(gca,'FontSize',FONT_SIZE)
set(gca,'FontName','Helvetica');


linkaxes(findobj(gcf,'type','axes'),'x')
%xlim([-20 100])
set(0, 'DefaultFigureRenderer', 'painters');


end



% time = 1000*signals.time; %1:length(signals.time); %
% 
% showFilt = false;
% 
% %t_max = max(time);
% 
% LINE_WIDTH = 1.5;
% MARKER_SIZE = 7;
% MARKER_LINE_WIDTH = 0.8;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%% Position plot:
% subplot(4,1,1)
% hold on
% plot(time, signals.data, 'Color', colors.data, 'LineWidth', 3*LINE_WIDTH)
% % if isfield(signals, 'posTrue')
% %     plot(time, signals.posTrue, 'Color', colors.true, 'LineWidth', LINE_WIDTH)
% % end
% plot(time, signals.posSaccEstim, 'Color', colors.estim, 'LineWidth', LINE_WIDTH)
% if ~isempty(saccadeParamsFilt)
%     plot(time, signals.posFilt, 'Color', colors.filt, 'LineWidth', LINE_WIDTH)
% end
% 
% 
% % Plot true saccade indices:
% if ~isempty(saccadeParamsTrue)
%     if isfield(signals, 'posTrue')
%         plot(time(saccadeParamsTrue.startIds), ...
%              signals.posTrue(saccadeParamsTrue.startIds), ...
%              'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
%         
% %         plot(time(saccadeParamsTrue.peakVelocityIds), ...
% %              signals.posTrue(saccadeParamsTrue.peakVelocityIds), ...
% %              'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
%         
%         plot(time(saccadeParamsTrue.endIds), ...
%              signals.posTrue(saccadeParamsTrue.endIds), ...
%              's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
%         
% %         plot(time(saccadeParamsTrue.psoEndIds), ...
% %              signals.posTrue(saccadeParamsTrue.psoEndIds), ...
% %              'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
%         
%     else
%         plot(time(saccadeParamsTrue.startIds), ...
%              signals.data(saccadeParamsTrue.startIds), ...
%              'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.data)
%         
% %         plot(time(saccadeParamsTrue.peakVelocityIds), ...
% %              signals.data(saccadeParamsTrue.peakVelocityIds), ...
% %              'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.data)
%          
%         plot(time(saccadeParamsTrue.endIds), ...
%              signals.data(saccadeParamsTrue.endIds), ...
%              's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.data)
%         
%         plot(time(saccadeParamsTrue.psoEndIds), ...
%              signals.data(saccadeParamsTrue.psoEndIds), ...
%              'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.data)
%     end
% end
%         
% % Plot estimated saccade indices:
% plot(time(saccadeParamsEstim.startIds), ...
%      signals.posSaccEstim(saccadeParamsEstim.startIds), ...
%      'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
%  
% % plot(time(saccadeParamsEstim.peakVelocityIds), ...
% %      signals.posSaccEstim(saccadeParamsEstim.peakVelocityIds), ...
% %      'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
% 
% plot(time(saccadeParamsEstim.endIds), ...
%      signals.posSaccEstim(saccadeParamsEstim.endIds), ...
%      's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
% 
% plot(time(saccadeParamsEstim.psoEndIds), ...
%      signals.posSaccEstim(saccadeParamsEstim.psoEndIds), ...
%      'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
% 
% if ~isempty(saccadeParamsFilt)
%     % Plot filter saccade indices:
%     plot(time(saccadeParamsFilt.startIds), ...
%          signals.posFilt(saccadeParamsFilt.startIds), ...
%          'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
% 
% %     plot(time(saccadeParamsFilt.peakVelocityIds), ...
% %          signals.posFilt(saccadeParamsFilt.peakVelocityIds), ...
% %          'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
% 
%     plot(time(saccadeParamsFilt.endIds), ...
%          signals.posFilt(saccadeParamsFilt.endIds), ...
%          's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
% 
%     plot(time(saccadeParamsFilt.psoEndIds), ...
%          signals.posFilt(saccadeParamsFilt.psoEndIds), ...
%          'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
% end
% 
% 
% ylabel('$\theta \; [^{\circ}]$', 'Interpreter', 'latex')
% if isfield(signals, 'posTrue')
% %     lgd = legend('Data', 'Simulated SPEM-free position', 'Estimated SPEM-free position');
%     lgd = legend('Data $\tilde y$', '$\widehat \theta_{Sparse}$');
% elseif ~isempty(saccadeParamsFilt)
%     lgd = legend('Data $\tilde y$', '$\widehat \theta_{Sparse}$', 'Filt');
% else
%     lgd = legend('Data', 'Estimated');
% end
% 
% %axis([-25 100 -3 13])
% axis('tight')
% set(lgd, 'Location','northeast');
% set(lgd, 'Interpreter', 'latex')
% set(gca,'FontSize',15)
% set(gca,'TickLabelInterpreter', 'latex');
% 
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%% Velocity plot:
% subplot(4,1,2)
% hold on
% if isfield(signals, 'velTrue')
%     plot(time, signals.velTrue, 'Color', colors.true, 'LineWidth', LINE_WIDTH)
% end
% plot(time, signals.velSaccEstim, 'Color', colors.estim, 'LineWidth', LINE_WIDTH)
% if ~isempty(saccadeParamsFilt)
%     plot(time, signals.velFilt, 'Color', colors.filt, 'LineWidth', LINE_WIDTH)
% end
% 
% 
% % Plot true saccade indices:
% if ~isempty(saccadeParamsTrue) && isfield(signals, 'velTrue')
%     plot(time(saccadeParamsTrue.startIds), ...
%          signals.velTrue(saccadeParamsTrue.startIds), ...
%          'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
% 
%     plot(time(saccadeParamsTrue.peakVelocityIds), ...
%          signals.velTrue(saccadeParamsTrue.peakVelocityIds), ...
%          'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
% 
%     plot(time(saccadeParamsTrue.endIds), ...
%          signals.velTrue(saccadeParamsTrue.endIds), ...
%          's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
% 
%     plot(time(saccadeParamsTrue.psoEndIds), ...
%          signals.velTrue(saccadeParamsTrue.psoEndIds), ...
%          'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
% end
%         
% % Plot estimated saccade indices:
% plot(time(saccadeParamsEstim.startIds), ...
%      signals.velSaccEstim(saccadeParamsEstim.startIds), ...
%      'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
%  
% plot(time(saccadeParamsEstim.peakVelocityIds), ...
%      signals.velSaccEstim(saccadeParamsEstim.peakVelocityIds), ...
%      'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
% 
% plot(time(saccadeParamsEstim.endIds), ...
%      signals.velSaccEstim(saccadeParamsEstim.endIds), ...
%      's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
% 
% plot(time(saccadeParamsEstim.psoEndIds), ...
%      signals.velSaccEstim(saccadeParamsEstim.psoEndIds), ...
%      'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
% 
% 
% if ~isempty(saccadeParamsFilt)
%     % Plot filter saccade indices:
%     plot(time(saccadeParamsFilt.startIds), ...
%          signals.velFilt(saccadeParamsFilt.startIds), ...
%          'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
% 
%     plot(time(saccadeParamsFilt.peakVelocityIds), ...
%          signals.velFilt(saccadeParamsFilt.peakVelocityIds), ...
%          'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
% 
%     plot(time(saccadeParamsFilt.endIds), ...
%          signals.velFilt(saccadeParamsFilt.endIds), ...
%          's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
% 
%     plot(time(saccadeParamsFilt.psoEndIds), ...
%          signals.velFilt(saccadeParamsFilt.psoEndIds), ...
%          'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
% end
%  
% ylabel('$\dot\theta \; [^{\circ}/\textrm{s}]$', 'Interpreter', 'latex')
% 
% if isfield(signals, 'velTrue')
%     %lgd = legend('Simulated SPEM-free velocity', 'Estimated SPEM-free velocity');
%     lgd = legend('$\dot\theta^\ast$', '$\widehat{\dot\theta}_{Sparse}$');
% elseif ~isempty(saccadeParamsFilt)
%     lgd = legend('$\widehat{\dot\theta}_{Sparse}$', 'Filt');
% else
%     lgd = legend('Estimated');
% end
% %axis([-25 100 -80 420])
% axis('tight')
% set(lgd, 'Interpreter', 'latex')
% set(lgd, 'Location','southeast');
% set(gca,'FontSize',15)
% set(gca,'TickLabelInterpreter', 'latex');
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%% Acceleration plot:
% subplot(4,1,3)
% hold on
% if isfield(signals, 'accTrue')
%     plot(time, signals.accTrue, 'Color', colors.true, 'LineWidth', LINE_WIDTH)
% end
% plot(time, signals.accSaccEstim, 'Color', colors.estim, 'LineWidth', LINE_WIDTH)
% if ~isempty(saccadeParamsFilt)
%     plot(time, signals.accFilt, 'Color', colors.filt, 'LineWidth', LINE_WIDTH)
% end
% 
% 
% % Plot true saccade indices:
% if ~isempty(saccadeParamsTrue) && isfield(signals, 'accTrue')
%     plot(time(saccadeParamsTrue.startIds), ...
%          signals.accTrue(saccadeParamsTrue.startIds), ...
%          'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
% 
% %     plot(time(saccadeParamsTrue.peakVelocityIds), ...
% %          signals.accTrue(saccadeParamsTrue.peakVelocityIds), ...
% %          'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
% 
%     plot(time(saccadeParamsTrue.endIds), ...
%          signals.accTrue(saccadeParamsTrue.endIds), ...
%          's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
% 
%     plot(time(saccadeParamsTrue.psoEndIds), ...
%          signals.accTrue(saccadeParamsTrue.psoEndIds), ...
%          'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
% end
%         
% % Plot estimated saccade indices:
% plot(time(saccadeParamsEstim.startIds), ...
%      signals.accSaccEstim(saccadeParamsEstim.startIds), ...
%      'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
%  
% % plot(time(saccadeParamsEstim.peakVelocityIds), ...
% %      signals.accSaccEstim(saccadeParamsEstim.peakVelocityIds), ...
% %      'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
% 
% plot(time(saccadeParamsEstim.endIds), ...
%      signals.accSaccEstim(saccadeParamsEstim.endIds), ...
%      's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
% 
% plot(time(saccadeParamsEstim.psoEndIds), ...
%      signals.accSaccEstim(saccadeParamsEstim.psoEndIds), ...
%      'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
% 
%  
% if ~isempty(saccadeParamsFilt)
%     % Plot filter saccade indices:
%     plot(time(saccadeParamsFilt.startIds), ...
%          signals.accFilt(saccadeParamsFilt.startIds), ...
%          'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
% 
% %     plot(time(saccadeParamsFilt.peakVelocityIds), ...
% %          signals.accFilt(saccadeParamsFilt.peakVelocityIds), ...
% %          'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
% 
%     plot(time(saccadeParamsFilt.endIds), ...
%          signals.accFilt(saccadeParamsFilt.endIds), ...
%          's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
% 
%     plot(time(saccadeParamsFilt.psoEndIds), ...
%          signals.accFilt(saccadeParamsFilt.psoEndIds), ...
%          'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.filt)
% end
%  
%  
% ylabel('$\ddot\theta \; [^{\circ}/\textrm{s}^2]$', 'Interpreter', 'latex')
% if isfield(signals, 'accTrue')
%     %lgd = legend('Simulated SPEM-free velocity', 'Estimated SPEM-free velocity');
%     lgd = legend('$\ddot\theta^\ast$', '$\widehat{\ddot\theta}_{Sparse}$');
% elseif ~isempty(saccadeParamsFilt)
%     lgd = legend('$\widehat{\ddot\theta}_{Sparse}$', 'Filt');
% else
%     lgd = legend('Estimated');
% end
% 
% %axis([-25 100 -30000 35000])
% axis('tight')
% set(lgd, 'Interpreter', 'latex')
% set(lgd, 'Location','southeast');
% set(gca,'FontSize',15)
% set(gca,'TickLabelInterpreter', 'latex');
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%% Control signal plot:
% subplot(4,1,4)
% hold on
% if isfield(signals, 'controlSaccTrue')
%     plot(time, signals.controlSaccTrue, 'Color', colors.true, 'LineWidth', LINE_WIDTH)
% end
% if isfield(signals, 'controlMeas')
%     [~,idx] = max(abs(signals.controlSaccEstim));
%     absmax_estim = signals.controlSaccEstim(idx);
%     [~,idx] = max(abs(signals.controlMeas));
%     absmax_meas = signals.controlMeas(idx);
%     a_start = absmax_estim / absmax_meas;
%     %b_start = mean(signals.controlSaccEstim) - mean(signals.controlMeas);
%     scaleFit = fit(signals.controlMeas(saccadeParamsEstim.startIds(1):saccadeParamsEstim.endIds(1))', ...
%         signals.controlSaccEstim(saccadeParamsEstim.startIds(1):saccadeParamsEstim.endIds(1))', ...
%         'a*x', 'Start', a_start);
%     N_ag = scaleFit(signals.controlMeas);
%     %N_ag = signals.controlMeas * absmax_estim / absmax_meas;
%     plot(time, N_ag, 'Color', [0.6 0.8 0.4], 'LineWidth', 1);
% end
% plot(time, signals.controlSaccEstim, 'Color', colors.estim, 'LineWidth', LINE_WIDTH)
% 
% % Plot true saccade indices:
% if ~isempty(saccadeParamsTrue) && isfield(signals, 'controlSaccTrue')
%     plot(time(saccadeParamsTrue.startIds), ...
%          signals.controlSaccTrue(saccadeParamsTrue.startIds), ...
%          'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
% 
% %     plot(time(saccadeParamsTrue.peakVelocityIds), ...
% %          signals.controlSaccTrue(saccadeParamsTrue.peakVelocityIds), ...
% %          'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
% 
%     plot(time(saccadeParamsTrue.endIds), ...
%          signals.controlSaccTrue(saccadeParamsTrue.endIds), ...
%          's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
% 
%     plot(time(saccadeParamsTrue.psoEndIds), ...
%          signals.controlSaccTrue(saccadeParamsTrue.psoEndIds), ...
%          'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.true)
% end
%         
% % Plot estimated saccade indices:
% plot(time(saccadeParamsEstim.startIds), ...
%      signals.controlSaccEstim(saccadeParamsEstim.startIds), ...
%      'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
%  
% % plot(time(saccadeParamsEstim.peakVelocityIds), ...
% %      signals.controlSaccEstim(saccadeParamsEstim.peakVelocityIds), ...
% %      'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
% 
% plot(time(saccadeParamsEstim.endIds), ...
%      signals.controlSaccEstim(saccadeParamsEstim.endIds), ...
%      's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
% 
% plot(time(saccadeParamsEstim.psoEndIds), ...
%      signals.controlSaccEstim(saccadeParamsEstim.psoEndIds), ...
%      'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
% 
% 
% xlabel('Time [ms]', 'Interpreter', 'latex')
% ylabel('$\Delta N$ [N]', 'Interpreter', 'latex')
% if isfield(signals, 'controlSaccTrue')
%     lgd = legend('$\Delta N^\ast$', '$\widehat{\Delta N}_{Sparse}$');
% elseif isfield(signals, 'controlMeas')
%     lgd = legend('Monkey data', '$\widehat{\Delta N}$');
% else
%     lgd = legend('$\widehat{\Delta N}_{Sparse}$');
% end
% %axis([-25 100 -0.5 2.5])
% axis('tight')
% set(lgd, 'Interpreter', 'latex')
% set(lgd, 'Location','southeast');
% set(gca,'FontSize',15)
% set(gca,'TickLabelInterpreter', 'latex');
% 
% 
% linkaxes(findobj(gcf,'type','axes'),'x')
% %xlim([-50 110])
% %axis([-50 100 -inf inf])
% end

