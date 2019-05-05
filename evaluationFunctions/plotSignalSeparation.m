function plotSignalSeparation(signals)
%%% Plot estimated physical signals (Fig. 8 in paper)
%
% Copyright (C) Thilo Weber 2019 (see MIT license in the README.txt file)
%
% Inputs:
%  1. Estimate 'signals' for given data (e.g., using MBSD_main_simple.m)
%

time = signals.time;

colors.lines = lines;
colors.data = [0.7 0.7 0.7];
colors.estim = [0 0 0];
colors.sacc = colors.lines(1,:);
colors.spem = colors.lines(2,:);
colors.res = colors.lines(3,:);
LINE_WIDTH = 1.5;
FONT_SIZE = 12;

subplot(3,1,1)
title('Signal Separation Plot:')
hold on
plot(time, signals.data, '.', 'Color', colors.data, 'MarkerSize', 8)
plot(time, signals.posEstim, 'Color', colors.estim, 'LineWidth', LINE_WIDTH/2);
plot(time, signals.posSaccEstim, 'Color', colors.sacc, 'LineWidth', LINE_WIDTH);
plot(time, signals.posSpemEstim, 'Color', colors.spem, 'LineWidth', LINE_WIDTH);
plot(time, signals.posFemEstim, 'Color', colors.res, 'LineWidth', LINE_WIDTH/2);

ylabel('Pos. $\theta \; [^{\circ}]$', 'Interpreter', 'latex')
set(groot, 'defaultLegendInterpreter','latex');
% if isfield(signals, 'posTarget')
%     plot(time, signals.posTarget, 'k:');
%     lgd = legend('Data $\tilde y$', '$\widehat{\theta}$', '$\widehat{\theta}_{Sacc}$', ...
%         '$\widehat{\theta}_{SPEM}$', '$\widehat{\theta}_{Fem}$', 'Target');
% else
    lgd = legend('$y$ (Data)', '$\widehat{\theta}$', '$\widehat{\theta}_\textrm{Sacc}$', ...
        '$\widehat{\theta}_\textrm{SPEM}$', '$\widehat{\theta}_\textrm{FEM}$');
% end
set(lgd, 'Interpreter', 'latex')
set(gca,'xticklabel',[])
set(gca,'FontSize',FONT_SIZE)
grid on
set(gca,'FontName','Helvetica');
%set(gca,'TickLabelInterpreter', 'latex');
%set(lgd, 'Location','southeastoutside');
%axis([0 t_max -12 12])
axis 'tight'


subplot(3,1,2)
hold on
plot(time, signals.velEstim, 'Color', colors.estim, 'LineWidth', LINE_WIDTH/2);
plot(time, signals.velSaccEstim, 'Color', colors.sacc, 'LineWidth', LINE_WIDTH);
plot(time, signals.velSpemEstim, 'Color', colors.spem, 'LineWidth', LINE_WIDTH);
plot(time, signals.velFemEstim, 'Color', colors.res, 'LineWidth', LINE_WIDTH/2);

ylabel('Vel. $\dot\theta \; [^{\circ}/\textrm{s}]$', 'Interpreter', 'latex')
lgd = legend('$\widehat{\dot\theta}$', '$\widehat{\dot\theta}_\textrm{Sacc}$', ...
    '$\widehat{\dot\theta}_\textrm{SPEM}$', '$\widehat{\dot\theta}_\textrm{FEM}$');

set(lgd, 'Interpreter', 'latex')
%set(lgd, 'Location','southeastoutside');
set(gca,'FontSize',FONT_SIZE)
set(gca,'FontName','Helvetica');
set(gca,'xticklabel',[])
%set(gca,'TickLabelInterpreter', 'latex');
hold off
%axis([0 t_max -330 330])
axis 'tight'
grid on


subplot(3,1,3)
hold on
plot(time, signals.controlEstim, 'Color', colors.estim, 'LineWidth', LINE_WIDTH/2)
plot(time, signals.controlSaccEstim, 'Color', colors.sacc, 'LineWidth', LINE_WIDTH)
plot(time, signals.controlSpemEstim, 'Color', colors.spem, 'LineWidth', LINE_WIDTH)
plot(time, signals.controlFemEstim, 'Color', colors.res, 'LineWidth', LINE_WIDTH/2)
xlabel('Time [s]', 'Interpreter', 'latex')
ylabel('Ctrl. $\Delta N$ [N]', 'Interpreter', 'latex')
lgd = legend('$\widehat{\Delta N}$', '$\widehat{\Delta N}_\textrm{Sacc}$', ...
    '$\widehat{\Delta N}_\textrm{SPEM}$', '$\widehat{\Delta N}_\textrm{FEM}$');
set(lgd, 'Interpreter', 'latex')
%set(lgd, 'Location','southeastoutside');
set(gca,'FontSize',FONT_SIZE)
set(gca,'FontName','Helvetica');
%set(gca,'TickLabelInterpreter', 'latex');
%axis([0 t_max -2.8 2.8])
grid on
axis 'tight'

linkaxes(findobj(gcf,'type','axes'),'x')
%axis([0 4 -inf inf])
%xlim([0 4])
set(gcf,'units','points','position',[10,10,500,500])

end


