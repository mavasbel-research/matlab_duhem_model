%% Initialize
% clear all
close all
clc

%% Get scales in case they exists
inputScale = 1;
outputScale = 1;
inputShift = 0;
outputShift = 0;
if(exist('dataHandler','var'))
    inputScale = dataHandler.inputScale;
    outputScale = dataHandler.outputScale;
    inputShift = dataHandler.inputShift;
    outputShift = dataHandler.outputShift;
end
inputTrans = @(u) (u+inputShift)*inputScale;
outputTrans = @(y) (y+outputShift)*outputScale;
inputInvTrans  = @(u) u/inputScale-inputShift;
outputInvTrans = @(y) y/outputScale-outputShift;

%% Create model global parameters
% Dahl parameters
% dh_rho = 2;
% dh_Fc = 0.25;
% dh_r = 3/7;
% f1 = @(u,x) dh_rho*(abs(1-x/dh_Fc)^dh_r)*sign(1-x/dh_Fc);
% f2 = @(u,x) dh_rho*(abs(1+x/dh_Fc)^dh_r)*sign(1+x/dh_Fc);

% Bouc-wen parameters 
% Papers divergent parameters 
% bw_alpha = 0.1;
% bw_beta = 0.1;
% bw_zeta = -0.2;
% bw_n = 3;
% bw_eta = 1;

% % Papers convergent parameters
% bw_alpha = 1.0;
% bw_beta = 1.0;
% bw_zeta = 2.0;
% bw_n = 3;
% bw_eta = 1;

% bw_alpha = 10.0;
% bw_beta = 2.0;
% bw_zeta = -1;
% bw_n = 3;
% bw_eta = 0.1;
% 
% (bw_alpha/(bw_beta+bw_zeta))^bw_n
% (bw_alpha/(bw_beta-bw_zeta))^bw_n

% f1 = @(u,x) bw_eta*(bw_alpha - bw_beta*abs(x)^bw_n - bw_zeta*x*abs(x)^(bw_n-1));
% f2 = @(u,x) bw_eta*(bw_alpha - bw_beta*abs(x)^bw_n + bw_zeta*x*abs(x)^(bw_n-1));

% f1 = @(u,x) bw_eta*(params(1) - params(2)*abs(x)^bw_n - params(3)*x*abs(x)^(bw_n-1));
% f2 = @(u,x) bw_eta*(params(1) - params(2)*abs(x)^bw_n + params(3)*x*abs(x)^(bw_n-1));
% 
% Parameters for polynomial fitted Duhem
% f1 = @(u,x)   ( params(1) + params(2)*u + params(3)*u^2 + params(4)*u^3 +  params(5)*u^4 - x );
% f2 = @(u,x) - ( params(6) + params(7)*u + params(8)*u^2 + params(9)*u^3 + params(10)*u^4 - x );

% Create model
duhemModel = DuhemModel(f1,f2);

%% Create plot paramters and obtain anhysteresis curves
figure; axHandler = axes(); hold on; % Create axes

% hPad = 0.1; vPad = 0.1; 
% minHPad = 0.1; minVPad = 0.1; 
% autoAdjust = true;
% hGridSize = 500; hPlotLims = [-1.0 1.0]*1; 
% vGridSize = 500; vPlotLims = [-1 5]*1;
% hGridSize = 500; hPlotLims = [-1.0 1.0]*1; 
% vGridSize = 500; vPlotLims = [-1 5]*1;
% hGridSize = 500; hPlotLims = [-1.0 1.0]*6; 
% vGridSize = 500; vPlotLims = [-1.0 1.0]*6;
% hGridSize = 500; hPlotLims = [-1.0 1.0]*5.0; 
% vGridSize = 500; vPlotLims = [-8.0 10.0]*1.0;
% hGridSize = 500; hPlotLims = [-1.0 1.0]*13.0; 
% vGridSize = 500; vPlotLims = [-15.0 11.0]*1.0;
% hGridSize = 500; hPlotLims = [-1.0 1.0]*5.0;  
% vGridSize = 500; vPlotLims = [-11.0 6.0]*1.0;
% hGridSize = 800; hPlotLims = [-1.0 1.0]*10; 
% vGridSize = 800; vPlotLims = [-5.0 12.0]*1;
% hGridSize = 800; hPlotLims = [min([curve1(:,1);curve2(:,1)]),...
%                                 max([curve1(:,1);curve2(:,1)])];
% vGridSize = 800; vPlotLims = [min([curve1(:,2);curve2(:,2)]),...
%                                 max([curve1(:,2);curve2(:,2)])];
% hPlotRange = hPlotLims(2)-hPlotLims(1); vPlotRange = vPlotLims(2)-vPlotLims(1);
% [anHystCurves, avgHystCurves] = ...
%     DuhemModel.findAnhysteresisCurve(duhemModel,...
%     [hPlotLims(1)-hPlotRange*hPad, hPlotLims(2)+hPlotRange*hPad],hGridSize,...
%     [vPlotLims(1)-vPlotRange*vPad, vPlotLims(2)+vPlotRange*vPad],vGridSize);
% [anHystCurves, avgHystCurves] = ...
%     DuhemModel.findAnhysteresisCurve(duhemModel,...
%     [hPlotLims(1), hPlotLims(2)],hGridSize,...
%     [vPlotLims(1), vPlotLims(2)],vGridSize);
% 
% axis([hPlotLims(1)-hPlotRange*hPad,hPlotLims(2)+hPlotRange*hPad,...
%       vPlotLims(1)-vPlotRange*vPad,vPlotLims(2)+vPlotRange*vPad]);
% xlabel('$u\ (Volts)$','Interpreter','latex');
% ylabel('$y\ (nm)$','Interpreter','latex');

%% Paramters for simulation with real data and data handler normalization
autoAdjust = false;
hGridSize = 1000; hLims = [-1.0 1.0]*12; 
vGridSize = 1000; vLims = hLims;
hPad = 0.1; vPad = 0.1; 
minHPad = 0.1; minVPad = 0.1; 
hPlotLims = [-1.0 1.0]*12; 
vPlotLims = [-12 16]*1;
hPlotRange = hPlotLims(2)-hPlotLims(1); vPlotRange = vPlotLims(2)-vPlotLims(1);
axis([hPlotLims(1)-hPlotRange*hPad,hPlotLims(2)+hPlotRange*hPad,...
      vPlotLims(1)-vPlotRange*vPad,vPlotLims(2)+vPlotRange*vPad]);
[anHystCurves, avgHystCurves] = ...
    DuhemModel.findAnhysteresisCurve(duhemModel,...
    [-10, 10],hGridSize,...
    [vPlotLims(1)-vPlotRange*vPad, vPlotLims(2)+vPlotRange*vPad],vGridSize);

axis([-1600,1600,-400,1700]);
xticks([-2100 -1400 -700 0 700 1400 2100])
yticks([-600 -300 0 300 600 900 1200 1500 1800])

%% Plotting
if(exist('curve1','var'))% Plot level f1=0
    plot(axHandler,inputInvTrans(curve1(:,1)),outputInvTrans(curve1(:,2)),'r',...
        'DisplayName','$c_1(\upsilon)$'); hold on;
end
if(exist('curve2','var'))% Plot level f2=0
    plot(axHandler,inputInvTrans(curve2(:,1)),outputInvTrans(curve2(:,2)),'b',...
        'DisplayName','$c_2(\upsilon)$'); hold on;
end
for i=1:size(anHystCurves,2) % Plot anhysteresis curve
    lineHandler = plot(axHandler,...
        inputInvTrans(anHystCurves{i}(:,1)),outputInvTrans(anHystCurves{i}(:,2)),...
        'Color','k',...
        'LineWidth',1.0,...
        'LineStyle','--',...
        'DisplayName','Anhysteresis curve $\mathcal{A}$'); hold on;
    if(i>1) set(lineHandler,'handleVisibility','off'); end
end
% for i=1:size(avgHystCurves,2) % Plot average curve
%     lineHandler = plot(axHandler,...
%         avgHystCurves{i}(:,1),avgHystCurves{i}(:,2),...
%         'color','m',...
%         'DisplayName','$f_1+f_2=0$'); hold on;
%     if(i>1) set(lineHandler,'handleVisibility','off'); end
% end
if(exist('dataHandler','var'))
%     dataHandler = DataHandler(uVec,xTime);
    plot(axHandler,inputInvTrans(dataHandler.inputSeq),outputInvTrans(dataHandler.outputSeq),'g',...
        'lineWidth',1.2,...
        'DisplayName','Experimental Data');
end

%%  Input creation

% Simulation parameters for periodic input
samplesPerCycle = 150; 
cycles = 2;
% uMin = -12; 
% uMax =  12;
% x0 = 0.5;
% uMin = -10; 
% uMax =  10;
uMin = dataHandler.inputMin*0.98; 
uMax = dataHandler.inputMax*0.98;
x0 = dataHandler.outputSeq(1);
% uMin = -10; 
% uMax =  10; 
t0 = 0; tend = 1*cycles;
uVec = [];
for i=1:cycles
    uVec = [uVec;linspace(uMax,uMin,samplesPerCycle)'];
    uVec = [uVec;linspace(uMin,uMax,samplesPerCycle)'];
%     uVec = [uVec;linspace(uMax,uMin,samplesPerCycle)'];
end
uVec = circshift(uVec,samplesPerCycle/2);
tVec = linspace(t0,tend,2*samplesPerCycle*cycles)';
duVec = [0;diff(uVec)./diff(tVec)];

% Simulation parameters for peaks input
% samples = 500;
% t0 = 0; tend = 60;
% % x0 = 0;
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
% uMin = min(peaks); uMax = max(peaks);

%% Simulation ode

% Create animated plot handlers and invoke ode
% if (exist('anLineHand','var')); clearpoints(anLineHand); end;
anLineHand = animatedline(axHandler,...
    'LineWidth',1.2,...
    'Color','k',...,
    'DisplayName','Duhem model',...
    'HandleVisibility','on');
odeOutFunc = @(tq,xq,flag)odeDrawing(...
    tq,xq,flag,...
    tVec,uVec,duVec,...
    autoAdjust,hPad,vPad,minHPad,minVPad,...
    inputTrans,outputTrans,inputInvTrans,outputInvTrans,...
    anLineHand);
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

% Create data handler for fitting test
% dataHandler = DataHandler(uVec, xTime, tTime);

% Create data handler with simulation data
dataHandlerSim = DataHandler(uVec, xTime, tTime);

% Mark initial and final
plot(uVec(1),xTime(1),'o',...
    'Color','k',...
    'LineWidth',1.2,...
    'HandleVisibility','off');
% plot(uVec(end),xTime(end),'x',...
%     'Color','k',...
%     'LineWidth',1.2,...
%     'HandleVisibility','off');

% Adjust plot
% leg = legend(...
%     'Interpreter','latex',...
%     'Location','southeast');
leg = legend(...
    'Interpreter','latex',...
    'Location','northeast');

%% Ode plotting functions

function output = odeDrawing(tq,xq,flag,...
    tVec,uVec,duVec,...
    autoAdjust,hPad,vPad,minHPad,minVPad,...
    inputTrans,outputTrans,inputInvTrans,outputInvTrans,...
    anLineHand)

    if strcmp(flag,'init')
        [uq,duq] = odeuVecduVecSolver(tq(1),tVec,uVec,duVec);
        addpoints(anLineHand,inputInvTrans(uq),outputInvTrans(xq(1,:)));
    elseif strcmp(flag,'done')
    else
        [uq,duq] = odeuVecduVecSolver(tq,tVec,uVec,duVec);
        addpoints(anLineHand,inputInvTrans(uq),outputInvTrans(xq));
    end
    if(autoAdjust)
        autoAdjustPlot(anLineHand,hPad,vPad,minHPad,minVPad);
    end
    drawnow limitrate;
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