function plotSpemAnalysis(signals, SSM)
%%% For sinusoidal velocity SPEM model: Plot phase and amplitude of SPEM
%%% velocity (Fig. 9 in paper)
%
% Copyright (C) Thilo Weber 2019 (see MIT license in the README.txt file)
%
% Inputs:
%  1. Estimate 'signals' and 'SSM' parameters for given sinusoidal SPEM
%     data (e.g., using MBSD_main_simple.m)

colors.lines = lines;

time = signals.time;
t_max = max(time);
LINE_WIDTH = 1.5;
FONT_SIZE = 12;

if isfield(signals, 'aSpem') && isfield(signals, 'fSpem')
    %%% Plot SPEM velocity and amplitude of sine and cosine of SPEM:
    aSpem = signals.aSpem;
    fSpem = signals.fSpem;
    
    subplot(3,1,1)
    title('SPEM Analysis Plot:')
    hold on
%     plot(time, ...
%         smooth(abs(signals.dthetaSpem) - abs(signals.dThetaHat_spem), ...
%         1/(2*LSSM.Ts*fSpem)), ...
%         'Color', [1 0.2 0.2], 'LineWidth', LINE_WIDTH)
    
    plot(time, signals.velSpemEstim, 'Color', colors.lines(1,:), 'LineWidth', LINE_WIDTH)
%     plot(time, signalsBad.velSpemEstim, 'Color', colors.lines(2,:), 'LineWidth', LINE_WIDTH)
    
    plot(time, signals.velTarget, '--', 'Color', [0.7 0.7 0.7])
    
    ylabel('$\widehat{\dot\theta}{}^\textrm{SPEM} \; [^{\circ}$/s]', 'Interpreter', 'latex')
    legend('SPEM', 'Target');
    %set(lgd, 'Interpreter', 'latex')
    set(gca,'FontSize',FONT_SIZE)
    axis([0 t_max -inf inf])
    hold off

    xHatSpemSin = lsim(SSM.plantSSMdiscrete, SSM.Ts*cumsum(signals.xHat(SSM.xSpemId(2),:)))';
    spemVelSin = xHatSpemSin(2,:);
    xHatSpemCos = lsim(SSM.plantSSMdiscrete, SSM.Ts*cumsum(signals.xHat(SSM.xSpemId(3),:)))';
    spemVelCos = xHatSpemCos(2,:);
    
%     xHatSpemSin = lsim(SSM.plantSSMdiscrete, SSM.Ts*cumsum(signalsBad.xHat(SSM.xSpemId(2),:)))';
%     spemSinBad = xHatSpemSin(2,:);
%     xHatSpemCos = lsim(SSM.plantSSMdiscrete, SSM.Ts*cumsum(signalsBad.xHat(SSM.xSpemId(3),:)))';
%     spemCosBad = xHatSpemCos(2,:);
    
    subplot(3,1,2)
    hold on
    
    plot(time, sqrt(spemVelSin.^2 + spemVelCos.^2), 'Color', colors.lines(1,:), 'LineWidth', LINE_WIDTH)
%     plot(time, sqrt(spemSinBad.^2 + spemCosBad.^2), 'Color', colors.lines(2,:), 'LineWidth', LINE_WIDTH)
    plot(time, 2*pi*fSpem*aSpem*ones(length(time), 1), '--', 'Color', [0.7 0.7 0.7])
    
    ylabel('Amplitude [$^{\circ}$]', 'Interpreter', 'latex')
    lgd = legend('SPEM', 'Target');
    set(lgd, 'Location', 'Southeast')
    set(gca,'FontSize',FONT_SIZE)
    axis([0 4 -1 10+2*pi*fSpem*aSpem])
    hold off
    
    
    subplot(3,1,3)
    hold on
    plot(time, atan(spemVelSin ./ spemVelCos), 'Color', colors.lines(1,:), 'LineWidth', LINE_WIDTH)
%     plot(time, atan(spemSinBad ./ spemCosBad), 'Color', colors.lines(2,:), 'LineWidth', LINE_WIDTH)
    plot(time, atan(cos(2*pi*fSpem*(time-max(time)/2)) ./ ...
        -sin(2*pi*fSpem*(time-max(time)/2))), '--', 'Color', [0.7 0.7 0.7])
    
    axis([0 4 -2 4])
    ylabel('Phase', 'Interpreter', 'latex')
    xlabel('Time [s]', 'Interpreter', 'latex')
    legend('SPEM', 'Target');
    set(gca,'FontSize',FONT_SIZE)
    hold off
    
    set(gcf,'units','points','position',[10,10,500,350])
    set(0, 'DefaultFigureRenderer', 'painters');
    axis([0 4 -inf inf])
    set(gca,'FontName','Helvetica');
    

else
    disp('SPEM analysis plot only for sinusiodal SPEM model available!')
end

linkaxes(findobj(gcf,'type','axes'),'x')
end

