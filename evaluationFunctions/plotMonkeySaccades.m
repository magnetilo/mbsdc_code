function plotMonkeySaccades(signals, saccadeParamsEstim, varargin)
%%% Plot monkey saccades (Fig. 7 in paper)
%
% Copyright (C) Thilo Weber 2018 (see MIT license in the README.txt file)
%
% Inputs:
%  1. Estimated 'signals' for given menkey data (containing in addition to
%  eye position signals.data also motorneuron-spike-rate maeasurements
%  signals.controlMeas), e.g., using MBSD_main_simple.m
%

p = inputParser;
addOptional(p, 'withYLabel', true, @islogical);
addOptional(p, 'time', 1000*signals.time, @isnumeric);
addOptional(p, 'posOffset', 0, @isnumeric);
addOptional(p, 'sign', 1, @isnumeric);
addOptional(p, 'sparsePulse', [], @isnumeric);

parse(p,varargin{:});
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
set(gcf,'units','points','position',[10,10,250,250])

%time = 1000*signals.time - 51;% - 352.294;% - 300.4;
time = p.Results.time;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Position/Velocity plot:
subplot(2,1,1)
hold on
h1 = plot(time, sign*signals.data+posOffset, '.', 'Color', colors.data, 'MarkerSize', 8);
h2 = plot(time, sign*signals.posEstim+posOffset, 'Color', colors.pulse, 'LineWidth', LINE_WIDTH/2);

% Plot estimated pulse-step saccade indices:
% plot(time(saccadeParamsEstim.startIds), ...
%     sign*signals.posEstim(saccadeParamsEstim.startIds)+posOffset, ...
%     'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)
% plot(time(saccadeParamsEstim.endIds), ...
%     sign*signals.posEstim(saccadeParamsEstim.endIds)+posOffset, ...
%     's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)
% plot(time(saccadeParamsEstim.psoEndIds), ...
%     sign*signals.posEstim(saccadeParamsEstim.psoEndIds)+posOffset, ...
%     'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)

if p.Results.withYLabel
    ylabel('Pos. $\theta \; [^{\circ}]$', 'Interpreter', 'latex')
else
    set(gca,'yticklabel',[])
end
axis([-20 100 -1 20])
%axis tight
grid on
set(gca,'FontName','Helvetica');
set(gca,'FontSize',FONT_SIZE)

yyaxis right

h3 = plot(time, sign*signals.velEstim, '--', 'Color', colors.pulse, 'LineWidth', LINE_WIDTH);

% Plot estimated pulse-step saccade indices:
% plot(time(saccadeParamsEstim.startIds), ...
%     sign*signals.velEstim(saccadeParamsEstim.startIds), ...
%     'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)
% plot(time(saccadeParamsEstim.endIds), ...
%     sign*signals.velEstim(saccadeParamsEstim.endIds), ...
%     's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)
% plot(time(saccadeParamsEstim.peakVelocityIds), ...
%     sign*signals.velEstim(saccadeParamsEstim.peakVelocityIds), ...
%     'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)
% plot(time(saccadeParamsEstim.psoEndIds), ...
%     sign*signals.velEstim(saccadeParamsEstim.psoEndIds), ...
%     'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)

axis([-20 100 -32.5 650])
%axis tight
grid on
set(gca,'FontName','Helvetica');
set(gca,'FontSize',FONT_SIZE)
if p.Results.withYLabel
    ylabel('Vel. $\dot\theta \; [^{\circ}]$', 'Interpreter', 'latex')
else
    set(gca,'yticklabel',[])
end

set(gca,'xticklabel',[])
lgd = legend([h1 h2 h3], '$\tilde y$', '$\widehat\theta$', '$\widehat{\dot\theta}$');
set(lgd, 'Location','southeast');
set(lgd, 'Interpreter', 'latex')
% lgd = legend('$\theta^*$', '$\widehat \theta$ (pulse-step)', ...
%         '$\widehat \theta$ (pulse-slide-step)', '$\widehat \theta_\textrm{Filt}$ (filtered)');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Neural signal plot:
subplot(2,1,2)
hold on
if isfield(signals, 'velTrue')
    plot(time, sign*signals.controlSaccTrue+posOffset/20, 'Color', colors.true, 'LineWidth', LINE_WIDTH)
elseif isfield(signals, 'controlMeas')
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
    stairs(time, sign*p.Results.sparsePulse+posOffset/20, 'Color', colors.slide, 'LineWidth', LINE_WIDTH)
end
plot(time, sign*signals.controlSaccEstim+posOffset/20, 'Color', colors.pulse, 'LineWidth', LINE_WIDTH)

% Plot estimated pulse-step saccade indices:
% plot(time(saccadeParamsEstim.startIds), ...
%     sign*signals.controlSaccEstim(saccadeParamsEstim.startIds)+posOffset/20, ...
%     'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)
% plot(time(saccadeParamsEstim.endIds), ...
%     sign*signals.controlSaccEstim(saccadeParamsEstim.endIds)+posOffset/20, ...
%     's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)
% plot(time(saccadeParamsEstim.psoEndIds), ...
%     sign*signals.controlSaccEstim(saccadeParamsEstim.psoEndIds)+posOffset/20, ...
%     'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.pulse)


xlabel('Time [ms]')
if p.Results.withYLabel
    ylabel('Ctrl. $\Delta N$ [N]', 'Interpreter', 'latex')
else
    set(gca,'yticklabel',[])
end
if isfield(signals, 'controlMeas')
    lgd = legend('$\Delta\tilde N$', '$\widehat{\Delta N}$');    
else
    if isempty(p.Results.sparsePulse)
        lgd = legend('$\widehat{\Delta N}_\textrm{Sacc}$');
    else
        lgd = legend('$\widehat{\Delta N}_\textrm{Sacc}$ (Sprs)', ...
            '$\widehat{\Delta N}_\textrm{Sacc}$ (Strc)');
    end
end
set(lgd, 'Interpreter', 'latex')

axis([-20 100 -0.3 2.8])
%axis tight
grid on
set(lgd, 'Location','northeast');
set(gca,'FontSize',FONT_SIZE)
set(gca,'FontName','Helvetica');


linkaxes(findobj(gcf,'type','axes'),'x')
%xlim([-20 100])
set(0, 'DefaultFigureRenderer', 'painters');


end