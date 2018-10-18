
function [signals, saccadeParamsTrue] = generateSaccades(varargin)
% Generating saccades with Enderle and Zhou's 2009 model

p = inputParser;
addOptional(p, 'sigmaNoise', 0.1, @isnumeric);
addOptional(p, 'Ts', 0.001, @isnumeric);
addOptional(p, 'strangeSacc', false, @islogical);
addOptional(p, 'concatenate', true, @islogical);
addOptional(p, 'repeat', 1, @isnumeric);
addOptional(p, 'plotMainSeq', true, @islogical);
parse(p,varargin{:});

sigmaNoise = p.Results.sigmaNoise;
Ts = p.Results.Ts;
strangeSacc = p.Results.strangeSacc;
concatenate = p.Results.concatenate;
repeat = p.Results.repeat;
plotMainSeq = p.Results.plotMainSeq;

time = 0:Ts:0.2; %1 second
n = length(time);
saccStart = 0.05; %seconds


%%% Model:
Jp = 2.2e-3; %Jp, [Ns^2/m]
r = 0.011; %r, [m]
Kse = 125; %Kse, [N/m]
Klt = 60.7; %Klt, [N/m]
B1 = 5.6; %B1, [Ns/m]
B2 = 0.5; %B2, [Ns/m]
Kp = 16.34; %Kp, [N/m]
Bp = 0.327; %Bp, [Ns/m]
tau = 0.009; %tau, [s], TDE = 0.0054; TAC = 0.009;

B12 = B1 + B2;
Kst = Kse + Klt;

P3 = Jp*B12;
P2 = Jp*Kst + B12*Bp + 2*B1*B2;
P1 = 2*B1*Kse + 2*B2*Klt + B12*Kp + Kst*Bp;
P0 = Kst*Kp + 2*Klt*Kse;

delta = 57.296 / (r*P3);
R3 = delta*(Kse - B2/tau);
R2 = P2 / P3;
R1 = P1 / P3;
R0 = P0 / P3;

A_plant_cont = [0, 1, 0, 0; 0, 0, 1, 0; ...
-R0, -R1, -R2, R3; 0, 0, 0, -1/tau];
B_plant_cont = [0; 0; B2/tau; 1/tau];
sysc = ss(A_plant_cont, B_plant_cont, [1 0 0 0], 0);
sysd = c2d(sysc,Ts,'zoh');
A_disc = sysd.A;
B_disc = sysd.B;

C_pos = [1, 0, 0, 0];
sysDiscPos = ss(A_disc,B_disc,C_pos,0,Ts);

C_vel = [0, 1, 0, 0];
sysDiscVel = ss(A_disc,B_disc,C_vel,0,Ts);

C_acc = [0, 0, 1, 0];
sysDiscAcc = ss(A_disc,B_disc,C_acc,0,Ts);

%%% 0.6 degree saccade, pulse-slide-step:
tauSlide = 0.0015; %s
slideSize1 = 0.015; %N
slideSize2 = 0.15; %N
PH = 0.18; %N
PW = 0.012; %s
SH = 0.03; %N
u = zeros(1,n);
u(saccStart/Ts:saccStart/Ts+PW/Ts) = PH + slideSize1*exp(-(0:Ts:PW)/tauSlide);
u(saccStart/Ts+PW/Ts+1:end) = SH + slideSize2*exp(-(0:Ts:n*Ts-PW-saccStart-Ts)/tauSlide);

signals{1}.posTrue = lsim(sysDiscPos, u, time)';
signals{1}.velTrue = lsim(sysDiscVel, u, time)';
signals{1}.accTrue = lsim(sysDiscAcc, u, time)';
signals{1}.controlSaccTrue = u;

%%% 1.2 degree saccade, pulse-slide-step:
tauSlide = 0.0015; %s
slideSize1 = 0.05; %N
slideSize2 = 0.27; %N
PH = 0.33; %N
PW = 0.013; %s
SH = 0.06; %N
u = zeros(1,n);
u(saccStart/Ts:saccStart/Ts+PW/Ts) = PH + slideSize1*exp(-(0:Ts:PW)/tauSlide);
u(saccStart/Ts+PW/Ts+1:end) = SH + slideSize2*exp(-(0:Ts:n*Ts-PW-saccStart-Ts)/tauSlide);

signals{2}.posTrue = lsim(sysDiscPos, u, time)';
signals{2}.velTrue = lsim(sysDiscVel, u, time)';
signals{2}.accTrue = lsim(sysDiscAcc, u, time)';
signals{2}.controlSaccTrue = u;

%%% 2.5 degree saccade, pulse-slide-step:
tauSlide = 0.002; %s
slideSize1 = 0.1; %N
slideSize2 = 0.38; %N
PH = 0.75; %N
PW = 0.013; %s
SH = 0.13; %N
u = zeros(1,n);
u(saccStart/Ts:saccStart/Ts+PW/Ts) = PH + slideSize1*exp(-(0:Ts:PW)/tauSlide);
u(saccStart/Ts+PW/Ts+1:end) = SH + slideSize2*exp(-(0:Ts:n*Ts-PW-saccStart-Ts)/tauSlide);

signals{3}.posTrue = lsim(sysDiscPos, u, time)';
signals{3}.velTrue = lsim(sysDiscVel, u, time)';
signals{3}.accTrue = lsim(sysDiscAcc, u, time)';
signals{3}.controlSaccTrue = u;

%%% 5 degree saccade, pulse-slide-step:
tauSlide = 0.003; %s
slideSize1 = 0.25; %N
slideSize2 = 0.7; %N
PH = 1.22; %N
PW = 0.015; %s
SH = 0.25; %N
u = zeros(1,n);
u(saccStart/Ts:saccStart/Ts+PW/Ts) = PH + slideSize1*exp(-(0:Ts:PW)/tauSlide);
u(saccStart/Ts+PW/Ts+1:end) = SH + slideSize2*exp(-(0:Ts:n*Ts-PW-saccStart-Ts)/tauSlide);

signals{4}.posTrue = lsim(sysDiscPos, u, time)';
signals{4}.velTrue = lsim(sysDiscVel, u, time)';
signals{4}.accTrue = lsim(sysDiscAcc, u, time)';
signals{4}.controlSaccTrue = u;
    
if strangeSacc
    %%% Strange 5 degree saccade, pulse-slide-step:
    tauSlide = 0.003; %s
    slideSize1 = 0.3; %N
    slideSize2 = 0.7; %N
    PH1 = 1.6; %N
    PH2 = 1.3;
    PW1 = 0.006; %s
    PW2 = 0.006;
    PW3 = 0.006;
    SH = 0.25; %N
    u = zeros(1,n);
    u(saccStart/Ts:saccStart/Ts+PW1/Ts) = PH1 + slideSize1*exp(-(0:Ts:PW1)/tauSlide);
    u(saccStart/Ts+PW1/Ts:saccStart/Ts+(PW1+PW2)/Ts) = 0;
    u(saccStart/Ts+(PW1+PW2)/Ts:saccStart/Ts+(PW1+PW2+PW3)/Ts) = PH2 + slideSize1*exp(-(0:Ts:PW3)/tauSlide);
    u(saccStart/Ts+(PW1+PW2+PW3)/Ts+1:end) = SH + slideSize2*exp(-(0:Ts:n*Ts-PW1-PW2-PW3-saccStart-Ts)/tauSlide);

    signals{4}.posTrue = lsim(sysDiscPos, u, time)';
    signals{4}.velTrue = lsim(sysDiscVel, u, time)';
    signals{4}.accTrue = lsim(sysDiscAcc, u, time)';
    signals{4}.controlSaccTrue = u;
end

%%% 10 degree saccade, pulse-slide-step:
tauSlide = 0.003; %s
slideSize1 = 0.3; %N
slideSize2 = 1.3; %N
PH = 1.83; %N
PW = 0.022; %s
SH = 0.5; %N
u = zeros(1,n);
u(saccStart/Ts:saccStart/Ts+PW/Ts) = PH + slideSize1*exp(-(0:Ts:PW)/tauSlide);
u(saccStart/Ts+PW/Ts+1:end) = SH + slideSize2*exp(-(0:Ts:n*Ts-PW-saccStart-Ts)/tauSlide);

signals{5}.posTrue = lsim(sysDiscPos, u, time)';
signals{5}.velTrue = lsim(sysDiscVel, u, time)';
signals{5}.accTrue = lsim(sysDiscAcc, u, time)';
signals{5}.controlSaccTrue = u;

if strangeSacc
    %%% Strange 10 degree saccade, pulse-slide-step:
    tauSlide = 0.003; %s
    slideSize1 = 0.5; %N
    slideSize2 = 1.3; %N
    PH1 = 2.6; %N
    PH2 = 2.6;
    PW1 = 0.006; %s
    PW2 = 0.004;
    PW3 = 0.006;
    SH = 0.5; %N
    u = zeros(1,n);
    u(saccStart/Ts:saccStart/Ts+PW1/Ts) = PH1 + slideSize1*exp(-(0:Ts:PW1)/tauSlide);
    u(saccStart/Ts+PW1/Ts:saccStart/Ts+(PW1+PW2)/Ts) = 0;
    u(saccStart/Ts+(PW1+PW2)/Ts:saccStart/Ts+(PW1+PW2+PW3)/Ts) = PH2 + slideSize1*exp(-(0:Ts:PW3)/tauSlide);
    u(saccStart/Ts+(PW1+PW2+PW3)/Ts+1:end) = SH + slideSize2*exp(-(0:Ts:n*Ts-PW1-PW2-PW3-saccStart-Ts)/tauSlide);

    signals{5}.posTrue = lsim(sysDiscPos, u, time)';
    signals{5}.velTrue = lsim(sysDiscVel, u, time)';
    signals{5}.accTrue = lsim(sysDiscAcc, u, time)';
    signals{5}.controlSaccTrue = u;
end

%%% 20 degree saccade, pulse-slide-step:
tauSlide = 0.0035; %s
slideSize1 = 0.4; %N
slideSize2 = 1.2; %N
PH = 2.61; %N
PW = 0.036; %s
SH = 1; %N
u = zeros(1,n);
u(saccStart/Ts:saccStart/Ts+PW/Ts) = PH + slideSize1*exp(-(0:Ts:PW)/tauSlide);
u(saccStart/Ts+PW/Ts+1:end) = SH + slideSize2*exp(-(0:Ts:n*Ts-PW-saccStart-Ts)/tauSlide);

signals{6}.posTrue = lsim(sysDiscPos, u, time)';
signals{6}.velTrue = lsim(sysDiscVel, u, time)';
signals{6}.accTrue = lsim(sysDiscAcc, u, time)';
signals{6}.controlSaccTrue = u;    
    

for i=1:length(signals)
    signals{i}.data = signals{i}.posTrue + sigmaNoise*randn(1,n);
    signals{i}.time = time;
    signals{i}.samplingRate = 1/Ts;
    signals{i}.dataLen = n;
    saccadeParamsTrue{i} = saccadeDetection( ...
        signals{i}.posTrue, ...
        signals{i}.velTrue, ...
        signals{i}.accTrue, ...
        signals{i}.time);
end

if repeat>1
    clear saccadeParamsTrue
    for i=1:length(signals)
        signals{i}.posTrue = [signals{i}.posTrue, ...
            (-1)*signals{i}.posTrue + signals{i}.posTrue(1,end)];
        signals{i}.posTrue = [zeros(1,10*n), repmat(signals{i}.posTrue, 1, ceil(repeat/2)), zeros(1,5*n)];
        signals{i}.velTrue = [signals{i}.velTrue, ...
            (-1)*signals{i}.velTrue + signals{i}.velTrue(1,end)];
        signals{i}.velTrue = [zeros(1,10*n), repmat(signals{i}.velTrue, 1, ceil(repeat/2)), zeros(1,5*n)];
        signals{i}.accTrue = [signals{i}.accTrue, ...
            (-1)*signals{i}.accTrue + signals{i}.accTrue(1,end)];
        signals{i}.accTrue = [zeros(1,10*n), repmat(signals{i}.accTrue, 1, ceil(repeat/2)), zeros(1,5*n)];
        signals{i}.controlSaccTrue = [signals{i}.controlSaccTrue, ...
            (-1)*signals{i}.controlSaccTrue + signals{i}.controlSaccTrue(1,end)];
        signals{i}.controlSaccTrue = [zeros(1,10*n), repmat(signals{i}.controlSaccTrue, 1, ceil(repeat/2)), zeros(1,5*n)];
        
        signals{i}.dataLen = length(signals{i}.posTrue);
        signals{i}.time = 0:Ts:Ts*(signals{i}.dataLen-1);
        
        signals{i}.data = signals{i}.posTrue + sigmaNoise*randn(1,signals{i}.dataLen);
        
        saccadeParamsTrue{i} = saccadeDetection( ...
            signals{i}.posTrue, ...
            signals{i}.velTrue, ...
            signals{i}.accTrue, ...
            signals{i}.time);
    end
    
end

if concatenate
    %n = signals{i}.dataLen;
    n = length(signals);
    for i=1:n-1
        signals{n}.posTrue = [signals{n}.posTrue, ...
            (-1)^(i)*signals{i}.posTrue + signals{n}.posTrue(1,end)];
        signals{n}.velTrue = [signals{n}.velTrue, ...
            (-1)^(i)*signals{i}.velTrue + signals{n}.velTrue(1,end)];
        signals{n}.accTrue = [signals{n}.accTrue, ...
            (-1)^(i)*signals{i}.accTrue + signals{n}.accTrue(1,end)];
        signals{n}.controlSaccTrue = [signals{n}.controlSaccTrue, ...
            (-1)^(i)*signals{i}.controlSaccTrue + signals{n}.controlSaccTrue(1,end)];
        signals{n}.time = [signals{n}.time, signals{i}.time + signals{n}.time(1,end) + signals{n}.time(2)];
        signals{n}.dataLen = signals{n}.dataLen + signals{i}.dataLen;
    end
    
    signals{n}.data = signals{n}.posTrue + sigmaNoise*randn(1,signals{n}.dataLen);
    signals{1} = signals{n};
    signals(2:n) = [];
    
    signals = signals{1};
    clear saccadeParamsTrue
    saccadeParamsTrue = saccadeDetection( ...
        signals.posTrue, ...
        signals.velTrue, ...
        signals.accTrue, ...
        signals.time);
end

if plotMainSeq && concatenate
    figure(1)
    title('Main Sequence')
    x = linspace(0, 20, 100);
    
    subplot(2,1,1)
    %plot(x, 684 * (1 - exp(-x/10)), 'k')
    hold on
    plot(x, x*1000./(18 + 1.2*abs(x)), 'k')
    for i=1:length(saccadeParamsTrue)
        plot(abs(saccadeParamsTrue.amplitudes), abs(saccadeParamsTrue.peakVelocities), '.')
    end
    lgd=legend('Inchingolo 1985', 'Simulated Saccades');
    set(lgd, 'Location','southeast')
    xlabel('Amplitude')
    ylabel('Peak Velocity')
    
    subplot(2,1,2)
    plot(x, 1.38 * x + 35.5, 'k')
    hold on
    for i=1:length(saccadeParamsTrue)
        plot(abs(saccadeParamsTrue.amplitudes), saccadeParamsTrue.durations*1000, '.')
    end
    lgd=legend('Inchingolo 1985', 'Simulated Saccades');
    set(lgd, 'Location','southeast')
    xlabel('Amplitude')
    ylabel('Duration')
    linkaxes(findobj(gcf,'type','axes'),'x')
    
    figure(2)
    for i=1:length(saccadeParamsTrue)
        subplot(2,1,1)
        hold on

        plot(signals.posTrue)

        subplot(2,1,2)
        hold on
        plot(signals.controlSaccTrue)
    end
    subplot(2,1,1)
    legend('Simulated Eye Position');

    subplot(2,1,2)
    legend('Simulated Neural Controller Signal');
    linkaxes(findobj(gcf,'type','axes'),'x')
end

end
