%% Initialize
% clear all
close all
% clc

%% Miller model
% Ps = 21; Pr = 14; Ec = 10;
% Ps = params(1); Pr = params(2); Ec = params(3);
% delta = Ec*( log((1+Pr/Ps)/(1-Pr/Ps)) )^(-1);
% 
% % Saturation curves
% PsatPlus   = @(E)  Ps*tanh(( E-Ec)/(2*delta));
% PsatMinus  = @(E) -Ps*tanh((-E-Ec)/(2*delta));
% 
% % Derivatives of saturation curves
% dPsatPlus  = @(E) Ps*( sech(( E-Ec)/(2*delta)) ).^2 * (1/(2*delta));
% dPsatMinus = @(E) Ps*( sech((-E-Ec)/(2*delta)) ).^2 * (1/(2*delta));
% 
% % Gamma term
% GammaPlus  = @(E,Pd) 1 - tanh(  ( (Pd -  PsatPlus(E))/( Ps-Pd ) ).^(1/2)  );
% GammaMinus = @(E,Pd) 1 - tanh(  ( (Pd - PsatMinus(E))/(-Ps-Pd ) ).^(1/2)  );
% 
% % Duhem model f1 & f2 functions
% f1 = @(u,x)  GammaPlus(u,x) * dPsatPlus(u);
% f2 = @(u,x) GammaMinus(u,x) * dPsatMinus(u);

%% Asym miller model
PsPlus  = params(1); PrPlus  = params(2); EcPlus  = params(3);
PsMinus = params(4); PrMinus = params(5); EcMinus = params(6);

% Delta parameter
deltaPlus =   EcPlus * ( log(  (1+PrPlus/PsPlus)/(1-PrPlus/PsPlus)  ) )^(-1);
deltaMinus = EcMinus * ( log((1+PrMinus/PsMinus)/(1-PrMinus/PsMinus)) )^(-1);

% Saturation curves
PsatPlus   = @(E)  PsPlus *tanh( ( E-EcPlus )/(2*deltaPlus)  );
PsatMinus  = @(E) -PsMinus*tanh( (-E-EcMinus)/(2*deltaMinus) );

% Derivatives of saturation curves
dPsatPlus  = @(E) PsPlus *( sech(( E-EcPlus )/(2*deltaPlus))  ).^2 * ( 1/(2*deltaPlus)  );
dPsatMinus = @(E) PsMinus*( sech((-E-EcMinus)/(2*deltaMinus)) ).^2 * ( 1/(2*deltaMinus) );

% Gamma term
GammaPlus  = @(E,Pd) 1 - tanh(  ( (Pd - PsatPlus(E) )/( PsPlus-Pd ) ).^(1/2)  );
GammaMinus = @(E,Pd) 1 - tanh(  ( (Pd - PsatMinus(E))/(-PsMinus-Pd) ).^(1/2)  );

% Duhem model f1 & f2 functions
f1 = @(u,x)  GammaPlus(u,x) * dPsatPlus(u);
f2 = @(u,x) GammaMinus(u,x) * dPsatMinus(u);

% Create model
duhemModel = DuhemModel(f1,f2);

%% Create modified miller model global parameters
% Vc = 1;
% Vo = 1;
% Vi = 1;
% pupi = 1;
% fup = @(V) 1/(    Vo*( 1+exp(-(V-Vc)/Vo) )    );
% 
% % Duhem model f1 & f2 functions
% f1 = @(u,x) (1-x)*fup(u);
% f2 = @(u,x) 1-f1(u,x);
% 
% % Create model
% duhemModel = DuhemModel(f1,f2);

%% Experiments
% u = linspace(-50,50,1000);
% yp = dPsatp(u);
% ym = dPsatm(u);
% plot(u,yp,u,ym);
% plot(u,ym)

%% Create plots

% Create plot paramters and obtain anhysteresis curves
hPad = 0.1; vPad = 0.1; 
minHPad = 0.1; minVPad = 0.1; 
autoAdjust = false;
hGridSize = 500; hLims = [-1.0 1.0]*10; 
vGridSize = 500; vLims = [-1.0 1.0]*5;
hRange = hLims(2)-hLims(1); vRange = vLims(2)-vLims(1);
% [anHystCurves, avgHystCurves] = ...
%     DuhemModel.findAnhysteresisCurve(duhemModel,...
%     [hLims(1), hLims(2)],hGridSize,...
%     [vLims(1), vLims(2)],vGridSize);
figure; axHandler = axes(); hold on; % Create axes
% if(exist('curve1','var'))% Plot level f1=0
%     plot(axHandler,curve1(:,1),curve1(:,2),'r',...
%         'DisplayName','$c_1(\upsilon)$'); hold on;
% end
% if(exist('curve2','var'))% Plot level f2=0
%     plot(axHandler,curve2(:,1),curve2(:,2),'b',...
%         'DisplayName','$c_2(\upsilon)$'); hold on;
% end
% for i=1:size(anHystCurves,2) % Plot anhysteresis curve
%     lineHandler = plot(axHandler,...
%         anHystCurves{i}(:,1),anHystCurves{i}(:,2),...
%         'Color','k',...
%         'LineWidth',1.0,...
%         'LineStyle','--',...
%         'DisplayName','Anhysteresis curve $\mathcal{A}$'); hold on;
%     if(i>1) set(lineHandler,'handleVisibility','off'); end
% end
% for i=1:size(avgHystCurves,2) % Plot average curve
%     lineHandler = plot(axHandler,...
%         avgHystCurves{i}(:,1),avgHystCurves{i}(:,2),...
%         'color','m',...
%         'DisplayName','f_1+f_2=0'); hold on;
%     if(i>1) set(lineHandler,'handleVisibility','off'); end
% end
if(exist('dataHandler','var'))
    plot(axHandler,dataHandler.inputSeq,dataHandler.outputSeq,'g',...
        'lineWidth',1.2,...
        'DisplayName','Experimental Data');
end
axis([hLims(1)-hRange*hPad,hLims(2)+hRange*hPad,...
      vLims(1)-vRange*vPad,vLims(2)+vRange*vPad]);
xlabel('$u$','Interpreter','latex');
ylabel('$y$','Interpreter','latex');

% Plot saturations
uSat = linspace(-500,500,2000);
if(exist('PsatPlus','var'))
    plot(uSat,PsatPlus(uSat),...
        'Color','r',...
        'LineWidth',1.2,...
        'DisplayName','$P_{sat}^+$',...
        'HandleVisibility','on');
    plot(uSat,PsatMinus(uSat),...
        'Color','b',...
        'LineWidth',1.2,...
        'DisplayName','$P_{sat}^-$',...
        'HandleVisibility','on');
% plot(uSat,dPsatPlus(uSat),...
%     'Color','r',...
%     'LineWidth',1.2,...
%     'HandleVisibility','off');
% plot(uSat,dPsatMinus(uSat),...
%     'Color','b',...
%     'LineWidth',1.2,...
%     'HandleVisibility','off');
end

%%  Input creation

% Parameters for periodic input
samplesPerCycle = 10000;
cycles = 5;
uMin = -5; 
uMax =  5;
x0 = dataHandler.outputSeq(1);
t0 = 0; tend = 5*cycles;
uVec = [];
for i=1:cycles
    uVec = [uVec;linspace(uMax,uMin,samplesPerCycle)'];
    uVec = [uVec;linspace(uMin,uMax,samplesPerCycle)'];
%     uVec = [uVec;linspace(uMax,uMin,samplesPerCycle)'];
end
uVec = circshift(uVec,samplesPerCycle/2);
tVec = linspace(t0,tend,2*samplesPerCycle*cycles)';
duVec = [0;diff(uVec)./diff(tVec)];

% Parameters for fading triangular input
% samples = 1000;
% t0 = 0; tend = 60;
% x0 = dataHandler.outputSeq(1);
% % peaks = [-3 2.8 -2.6 2.4 -2.2 2.0 -1.8 1.6 -1.4];
% % peaks = [0 10 0 -10 0 8 0 -8 0 5 0 -5 0 3 0 -3 0];
% peaks = [0 5 0 -5 0 3.741 0 -3.659 0 2.796 0 -2.812 0];
% uVec = [];
% for i=1:length(peaks)-1
%     uVec = [uVec;linspace(peaks(i),peaks(i+1),samples)'];
% end
% tVec = linspace( t0,tend,samples*(length(peaks)-1) )';
% duVec = [0;diff(uVec)./diff(tVec)];

%% Simulation ode

% Create animated plot handlers and invoke ode
% if (exist('anLineHand','var')); clearpoints(anLineHand); end;
anLineHand1 = animatedline(axHandler,...
    'LineWidth',1.2,...
    'Color','black',...,
    'DisplayName','Duhem model',...
    'HandleVisibility','on');
anLineHand2 = animatedline(axHandler,...
    'LineWidth',1.2,...
    'Color','magenta',...,
    'DisplayName','Convex output',...
    'HandleVisibility','on');
odeOutFunc = @(tq,xq,flag)odeDrawing(tq,xq,flag,...
    tVec,uVec,duVec,...
    autoAdjust,hPad,vPad,minHPad,minVPad,...
    anLineHand1,...
    anLineHand2);
[tTime,xTime] = ode113(...
    @(tq,xq)odeModel(tq,xq,tVec,uVec,duVec),...
    tVec,x0,...
    odeset(...
        'OutputFcn',odeOutFunc,...
        'NormControl','off',...
        'Reltol',1e-5,...
        'AbsTol',1e-6,...
        'Refine',1,...
        'MaxStep',10,...
        'Stats','on'));

% Mark initial and final
plot(uVec(1),xTime(1),'o',...
    'Color','black',...
    'LineWidth',1.2,...
    'HandleVisibility','off');
plot(uVec(end),xTime(end),'x',...
    'Color','black',...
    'LineWidth',1.2,...
    'HandleVisibility','off');

% Create data handler with simulation data
% dataHandler = DataHandler(uVec, xTime, tTime);

% Adjust plot
leg = legend(...
    'Interpreter','latex',...
    'Location','southeast');
% leg = legend(...
%     'Interpreter','latex',...
%     'Location','northeast');

%% Ode plotting functions

function output = odeDrawing(tq,xq,flag,...
    tVec,uVec,duVec,...
    autoAdjust,hPad,vPad,minHPad,minVPad,...
    anLineHand1,...
    anLineHand2)

%     conv = @(x) 0.2*(0.7*x.^2 - 2*x - 10);
    if strcmp(flag,'init')
        [uq,duq] = odeuVecduVecSolver(tq(1),tVec,uVec,duVec);
        addpoints(anLineHand1,uq,xq(1,:));
%         addpoints(anLineHand2,uq,conv(xq(1,:)));
    elseif strcmp(flag,'done')
    else
        [uq,duq] = odeuVecduVecSolver(tq,tVec,uVec,duVec);
        addpoints(anLineHand1,uq,xq);
%         addpoints(anLineHand2,uq,conv(xq));
    end
    if(autoAdjust)
        autoAdjustPlot(anLineHand1,hPad,vPad,minHPad,minVPad);
    end
    drawnow limitrate;
%     drawnow;
    output = 0;
end

function autoAdjustPlot(anLineHand,hPad,vPad,minHPad,minVPad)
    axesHand = get(anLineHand,'Parent');
    [uVec,yVec] = getpoints(anLineHand);
    uMin = min(uVec); uMax = max(uVec); uRange = uMax-uMin;
    xlim(axesHand,[ uMin-max([uRange*hPad,minHPad]),...
                    uMax+max([uRange*hPad,minHPad]) ]);
    yMin = min(yVec); yMax = max(yVec); yRange = yMax-yMin;
    ylim(axesHand,[ yMin-max([yRange*vPad,minVPad]),...
                    yMax+max([yRange*vPad,minVPad]) ]);
end

function dyq = odeModel(tq,xq,tVec,uVec,duVec)
    persistent duhemModel
    if isempty(duhemModel)
        f1 = evalin('base','f1');
        f2 = evalin('base','f2');
        duhemModel = DuhemModel(f1,f2);
    end
    [uq,duq] = odeuVecduVecSolver(tq,tVec,uVec,duVec);
    dyq = duhemModel.getdydt(uq,xq,duq);
end

function [uq,duq] = odeuVecduVecSolver(tq,tVec,uVec,duVec)
    uq = interp1(tVec,uVec,tq);
    duq = interp1(tVec,duVec,tq);
end