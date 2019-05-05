function plotBlinkThresholds(signalsPre, blinksEstimPre, saccadeParamsEstimPost, signalsPost)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

colors.lines = lines;
colors.data = [0.7 0.7 0.7];
colors.estim = [0 0 0];
colors.thres = colors.lines(2,:);

time = 1000*signalsPre.time; % 1:length(signals.time); %
time = time - time(blinksEstimPre.startIds(1));

%MIN_PEAK_VEL = [25*ones(signals.dataLen,1), -25*ones(signals.dataLen,1)];
VEL_THRES = [20*ones(signalsPre.dataLen,1), -20*ones(signalsPre.dataLen,1)];
ACC_THRES = [3000*ones(signalsPre.dataLen,1), -3000*ones(signalsPre.dataLen,1)];
VEL_THRES2 = [5*ones(signalsPre.dataLen,1), -5*ones(signalsPre.dataLen,1)];

LINE_WIDTH = 1.5;
MARKER_SIZE = 7;
MARKER_LINE_WIDTH = 0.8;
LINESTYLE = '--';
saccSign = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Position plot:
subplot(3,1,1)
hold on
%plot(time, signalsPre.data, '.', 'Color', colors.data, 'MarkerSize', 8)
signalsPre.posEstim = signalsPre.posEstim+7;
signalsPost.posEstim = signalsPost.posEstim+7;
h1 = plot(time, signalsPre.posEstim, 'Color', colors.data, 'LineWidth', LINE_WIDTH);

% Plot estimated blink indices:
plot(time(blinksEstimPre.startIds), ...
     saccSign*signalsPre.posEstim(blinksEstimPre.startIds), ...
     '^', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
 
plot(time(blinksEstimPre.endIds), ...
     saccSign*signalsPre.posEstim(blinksEstimPre.endIds), ...
     'v', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)

h3 = plot(time, signalsPost.posEstim, 'Color', colors.estim, 'LineWidth', LINE_WIDTH/2);
 
yyaxis right
uBlink = signalsPre.uHat(1,:);
uBlink(uBlink==0) = nan;
h2 = stem(time, uBlink, 'Color', colors.lines(4,:), 'LineWidth', LINE_WIDTH/2, 'Marker', '.', 'Markersize', 10);
plot(time, zeros(1,length(time)), '-', 'Color', colors.lines(4,:), 'LineWidth', LINE_WIDTH/2);

ylabel('$\theta$', 'Interpreter', 'latex')
lgd = legend([h1 h3 h2], '$\widehat{\theta}$', '$\widehat{\theta}$', '$\widehat{u}^\textrm{Blink}$');

yyaxis left
axis([-90 580 -24 inf])
yyaxis right
axis([-90 580 -30 120])
%axis('tight')
%set(gca,'xtick',[])
set(gca,'xticklabel',[])
%set(gca,'ytick',[])
%set(gca,'yticklabel',[])
set(lgd, 'Location','southeast');
set(lgd, 'Interpreter', 'latex')
set(gca,'FontSize',12)
%set(gca,'TickLabelInterpreter', 'latex');
set(gca,'FontName','Helvetica');
hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Velocity plot:
subplot(3,1,2)
hold on
h1 = plot(time, saccSign*signalsPre.velEstim, 'Color', colors.data, 'LineWidth', LINE_WIDTH);

h2 = plot(time', VEL_THRES, LINESTYLE, 'LineWidth', 1, 'Color', colors.lines(1,:), 'LineWidth', LINE_WIDTH);

h3 = plot(time', VEL_THRES2, '-.', 'LineWidth', 1, 'Color', colors.lines(2,:), 'LineWidth', LINE_WIDTH);

%plot(time, signals.velFilt)

% blinks:
plot(time(blinksEstimPre.startIds), ...
     saccSign*signalsPre.velEstim(blinksEstimPre.startIds), ...
     '^', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
 
plot(time(blinksEstimPre.endIds), ...
     saccSign*signalsPre.velEstim(blinksEstimPre.endIds), ...
     'v', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)



ylabel('$\dot\theta$', 'Interpreter', 'latex')

lgd = legend([h1(1) h2(1) h3(1)], '$\widehat{\dot\theta}$', '$B_\textrm{Vel}$', '$0.5^\circ/s$');

axis([-90 580 -50 100])
%axis('tight')
%set(gca,'xtick',[])
set(gca,'xticklabel',[])
%set(gca,'ytick',[])
%set(gca,'yticklabel',[])
set(lgd, 'Interpreter', 'latex')
set(gca,'FontSize',12)
%set(gca,'TickLabelInterpreter', 'latex');
set(gca,'FontName','Helvetica');
hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Acceleration plot:
subplot(3,1,3)
hold on
plot(time, saccSign*signalsPre.accEstim, 'Color', colors.data, 'LineWidth', LINE_WIDTH)

plot(time', ACC_THRES, LINESTYLE, 'LineWidth', LINE_WIDTH, 'Color', colors.lines(1,:));

        
% Plot estimated saccade indices:
plot(time(blinksEstimPre.startIds), ...
     saccSign*signalsPre.accEstim(blinksEstimPre.startIds), ...
     '^', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)
 
plot(time(blinksEstimPre.endIds), ...
     saccSign*signalsPre.accEstim(blinksEstimPre.endIds), ...
     'v', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.estim)

xlabel('Time [ms]')
ylabel('$\ddot\theta$', 'Interpreter', 'latex')
lgd = legend('$\widehat{\ddot\theta}$', '$B_\textrm{Acc}$');

axis([-90 580 -18000 34200])
%axis('tight')
%set(gca,'xtick',[])
%set(gca,'xticklabel',[])
%set(gca,'ytick',[])
%set(gca,'yticklabel',[])
set(lgd, 'Interpreter', 'latex')
set(gca,'FontSize',12)
%set(gca,'TickLabelInterpreter', 'latex');
set(gca,'FontName','Helvetica');
hold off


set(0, 'DefaultFigureRenderer', 'painters');
set(gcf,'units','points','position',[10,10,250,350])
linkaxes(findobj(gcf,'type','axes'),'x')

end