function plotIVTthresholds(signalsPre, signalsPost, saccadeParamsEstimPost)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

saccId = 13; % Nr. of saccade in data (for sinusoidal data 4: saccId = 13)

colors.lines = lines;
colors.data = [0.7 0.7 0.7];
colors.estim = [0 0 0];
colors.pulse = colors.lines(1,:);
colors.slide = colors.lines(2,:);
colors.true = [0.7 0.7 0.7];
colors.filt = colors.lines(3,:);

time = 1000*signalsPre.time; % 1:length(signals.time); %

%MIN_PEAK_VEL = [25*ones(signals.dataLen,1), -25*ones(signals.dataLen,1)];
%VEL_THRES1 = [5*ones(signalsPre.dataLen,1), -5*ones(signalsPre.dataLen,1)];
VEL_THRES2 = [20*ones(signalsPre.dataLen,1), -20*ones(signalsPre.dataLen,1)];
ACC_THRES = [3000*ones(signalsPre.dataLen,1), -3000*ones(signalsPre.dataLen,1)];

LINE_WIDTH = 1.5;
MARKER_SIZE = 7;
MARKER_LINE_WIDTH = 0.8;
saccSign = -1;
LINESTYLE = '--';

startId = saccadeParamsEstimPost.startIds(saccId);
time = time-time(startId);
pos = saccSign*(signalsPre.posSaccEstim-signalsPre.posSaccEstim(1,startId));
posPost = saccSign*(signalsPost.posSaccEstim-signalsPost.posSaccEstim(1,startId));
vel = saccSign*signalsPre.velSaccEstim;
acc = saccSign*signalsPre.accSaccEstim;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Position plot:
subplot(3,1,1)
hold on
% plot(time, signals.data, 'Color', colors.data, 'LineWidth', LINE_WIDTH)
% if isfield(signals, 'posSaccTrue')
%     plot(time, signals.posSaccTrue, 'Color', colors.true, 'LineWidth', LINE_WIDTH)
% end
plot(time, pos, ...
    'Color', colors.data, 'LineWidth', LINE_WIDTH)
plot(time, posPost, 'Color', colors.estim, 'LineWidth', LINE_WIDTH/2);
        
% Plot estimated saccade indices:
plot(time(saccadeParamsEstimPost.startIds), ...
     pos(saccadeParamsEstimPost.startIds), ...
     'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.data)

plot(time(saccadeParamsEstimPost.peakVelocityIds), ...
     pos(saccadeParamsEstimPost.peakVelocityIds), ...
     'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.data)
 
plot(time(saccadeParamsEstimPost.endIds), ...
     pos(saccadeParamsEstimPost.endIds), ...
     's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.data)

plot(time(saccadeParamsEstimPost.psoEndIds), ...
     pos(saccadeParamsEstimPost.psoEndIds), ...
     'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.data)


ylabel('$\theta$', 'Interpreter', 'latex')
lgd = legend('$\widehat{\theta}$', '$\widehat{\theta}$');

axis([-20 60 -0.3 2])
%axis('tight')
%set(gca,'xtick',[])
set(gca,'xticklabel',[])
%set(gca,'ytick',[])
%set(gca,'yticklabel',[])
%set(lgd, 'Location','southeast');
%set(lgd, 'Interpreter', 'latex')
set(gca,'FontSize',12)
%set(gca,'TickLabelInterpreter', 'latex');
set(gca,'FontName','Helvetica');
hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Velocity plot:
subplot(3,1,2)
hold on
%plot(time, zeros(1,length(time)), 'k')

h1=plot(time, vel, 'Color', colors.data, 'LineWidth', LINE_WIDTH);

%h2=plot(time', MIN_PEAK_VEL, 'LineWidth', 1, 'Color', colors.lines(1,:), 'LineWidth', LINE_WIDTH);

h4=plot(time', VEL_THRES2, LINESTYLE, 'Color', colors.lines(1,:), 'LineWidth', LINE_WIDTH);

%plot(time, signals.velFilt)

plot(time(saccadeParamsEstimPost.startIds), ...
     vel(saccadeParamsEstimPost.startIds), ...
     'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.data)
 
plot(time(saccadeParamsEstimPost.peakVelocityIds), ...
     vel(saccadeParamsEstimPost.peakVelocityIds), ...
     'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.data)

plot(time(saccadeParamsEstimPost.endIds), ...
     vel(saccadeParamsEstimPost.endIds), ...
     's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.data)

plot(time(saccadeParamsEstimPost.psoEndIds), ...
     vel(saccadeParamsEstimPost.psoEndIds), ...
     'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.data)

ylabel('$\dot\theta$', 'Interpreter', 'latex')

lgd = legend([h1(1) h4(1)], '$\widehat{\dot\theta}$', '$B_\textrm{Vel2}$');

axis([-20 60 -40 180])
%set(gca,'xtick',[])
set(gca,'xticklabel',[])
%set(gca,'ytick',[])
%set(gca,'yticklabel',[])
%axis('tight')
set(lgd, 'Interpreter', 'latex')
set(gca,'FontSize',12)
%set(gca,'TickLabelInterpreter', 'latex');
set(gca,'FontName','Helvetica');
hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Acceleration plot:
subplot(3,1,3)
hold on
plot(time, acc, 'Color', colors.data, 'LineWidth', LINE_WIDTH)

plot(time', ACC_THRES, LINESTYLE, 'LineWidth', LINE_WIDTH, 'Color', colors.lines(1,:));

        
% Plot estimated saccade indices:
plot(time(saccadeParamsEstimPost.startIds), ...
     acc(saccadeParamsEstimPost.startIds), ...
     'o', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.data)
 
plot(time(saccadeParamsEstimPost.peakVelocityIds), ...
     pos(saccadeParamsEstimPost.peakVelocityIds), ...
     'x', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.data)
 
plot(time(saccadeParamsEstimPost.endIds), ...
     acc(saccadeParamsEstimPost.endIds), ...
     's', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.data)

plot(time(saccadeParamsEstimPost.psoEndIds), ...
     acc(saccadeParamsEstimPost.psoEndIds), ...
     'd', 'MarkerSize', MARKER_SIZE, 'LineWidth', MARKER_LINE_WIDTH, 'Color', colors.data)

xlabel('Time [ms]')
ylabel('$\ddot\theta$', 'Interpreter', 'latex')
lgd = legend('$\widehat{\ddot\theta}$', '$B_\textrm{Acc}$');

axis([-20 60 -18000 34200])
%set(gca,'xtick',[])
%set(gca,'xticklabel',[])
%set(gca,'ytick',[])
%set(gca,'yticklabel',[])
%axis('tight')
set(lgd, 'Interpreter', 'latex')
set(gca,'FontSize',12)
%set(gca,'TickLabelInterpreter', 'latex');
set(gca,'FontName','Helvetica');
hold off


set(0, 'DefaultFigureRenderer', 'painters');
set(gcf,'units','points','position',[10,10,250,350])
linkaxes(findobj(gcf,'type','axes'),'x')

end

