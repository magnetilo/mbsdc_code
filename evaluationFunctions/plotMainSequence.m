function plotMainSequence(saccadeParamsEstim, colors, saccadeParamsFilt)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

subplot(2,1,1)
hold on
max_amplitude = 0;

if exist('saccadeParamsFilt', 'var')
    h1 = plot(abs(saccadeParamsFilt.amplitudes)', abs(saccadeParamsFilt.peakVelocities)', ...
        '.', 'Color', colors.true, 'Markersize', 10);
end

h2 = plot(abs(saccadeParamsEstim.amplitudes)', abs(saccadeParamsEstim.peakVelocities)', ...
        '.', 'Color', colors.estim, 'Markersize', 10);

x = linspace(0, 20, 100);
%h3 = plot(x, 551 * (1 - exp(-x/14)), 'k');
h3 = plot(x, 684 * (1 - exp(-x/10)), 'k');
xlabel('Amplitude $[^{\circ}]$', 'Interpreter', 'latex')
ylabel('Peak velocity $[^{\circ}/s]$', 'Interpreter', 'latex')

if exist('saccadeParamsFilt', 'var')
    lgd = legend([h1(1) h2(1) h3], ...
        'Main sequence (filtered)', ...
        'Main sequence (estimated)', ...
        'Main sequence (Baloh 1975)', ...
        'Location', 'northwest');
else
    lgd = legend([h2(1) h3], ...
        'Main sequence (detected)', ...
        'Main sequence (Baloh 1975)', ...
        'Location', 'northwest');
end
set(lgd, 'Interpreter', 'latex')
% set(gca,'XScale','log')
% set(gca,'YScale','log')
axis([0 20 0 1000])
set(gca,'FontSize',13)


subplot(2,1,2)
hold on

if exist('saccadeParamsFilt', 'var')
    h1 = plot(abs(saccadeParamsFilt.amplitudes)', saccadeParamsFilt.durations'*1000, ...
        '.', 'Color', colors.true, 'Markersize', 10);
end

h2 = plot(abs(saccadeParamsEstim.amplitudes)', saccadeParamsEstim.durations'*1000, ...
        '.', 'Color', colors.estim, 'Markersize', 10);

%h3 = plot(x, 2.7 * x + 37, 'k');
h3 = plot(x, 1.38 * x + 35.5, 'k');
xlabel('Amplitude $[^{\circ}]$', 'Interpreter', 'latex')
ylabel('Duration $[ms]$', 'Interpreter', 'latex')
if exist('saccadeParamsFilt', 'var')
    lgd = legend([h1(1), h2(1), h3], ...
        'Main sequence (filtered)', ...
        'Main sequence (detected)', ...
        'Main sequence (Baloh 1975)', ...
        'Location', 'northwest');
else
    lgd = legend([h2(1), h3], ...
        'Main sequence (detected)', ...
        'Main sequence (Baloh 1975)', ...
        'Location', 'northwest');
end
set(lgd, 'Interpreter', 'latex')
axis([0 20 -inf inf])
set(gca,'FontSize',13)

linkaxes(findobj(gcf,'type','axes'),'x')

end

