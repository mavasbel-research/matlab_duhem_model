%% Initialize
% clear all
close all
clc

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

% bw_alpha = params(1);
% bw_beta = params(2);
% bw_zeta = params(3);
% f1 = @(u,x) bw_eta*(bw_alpha - bw_beta*abs(x)^bw_n - bw_zeta*x*abs(x)^(bw_n-1));
% f2 = @(u,x) bw_eta*(bw_alpha - bw_beta*abs(x)^bw_n + bw_zeta*x*abs(x)^(bw_n-1));

% Parameters for polynomial fitted duhem
% f1 = @(u,x)   ( params(1) + params(2)*u + params(3)*u^2 + params(4)*u^3 +  params(5)*u^4 - x );
% f2 = @(u,x) - ( params(6) + params(7)*u + params(8)*u^2 + params(9)*u^3 + params(10)*u^4 - x );

% Create model
duhemModel = DuhemModel(f1,f2);

%% Create plots

% Create plot paramters and obtain anhysteresis curves
hPad = 0.1; vPad = 0.1; 
minHPad = 0.1; minVPad = 0.1; 
autoAdjust = true;
% hGridSize = 500; hLims = [-1.0 1.0]*1; 
% vGridSize = 500; vLims = [-1 5]*1;
hGridSize = 500; hLims = [-1.0 1.0]*1; 
vGridSize = 500; vLims = [-1.0 1.0]*1;
% hGridSize = 500; hLims = [-1.0 1.0]*5.0; 
% vGridSize = 500; vLims = [-8.0 10.0]*1.0;
% hGridSize = 500; hLims = [-1.0 1.0]*13.0; 
% vGridSize = 500; vLims = [-15.0 11.0]*1.0;
% hGridSize = 500; hLims = [-1.0 1.0]*5.0;  
% vGridSize = 500; vLims = [-11.0 6.0]*1.0;
% hGridSize = 800; hLims = [-1.0 1.0]*10; 
% vGridSize = 800; vLims = [-5.0 12.0]*1;
% hGridSize = 800; hLims = [min([curve1(:,1);curve2(:,1)]),...
%                                 max([curve1(:,1);curve2(:,1)])];
% vGridSize = 800; vLims = [min([curve1(:,2);curve2(:,2)]),...
%                                 max([curve1(:,2);curve2(:,2)])];
hRange = hLims(2)-hLims(1); vRange = vLims(2)-vLims(1);
% [anHystCurves, avgHystCurves] = ...
%     DuhemModel.findAnhysteresisCurve(duhemModel,...
%     [hLims(1)-hRange*hPad, hLims(2)+hRange*hPad],hGridSize,...
%     [vLims(1)-vRange*vPad, vLims(2)+vRange*vPad],vGridSize);
[anHystCurves, avgHystCurves] = ...
    DuhemModel.findAnhysteresisCurve(duhemModel,...
    [hLims(1), hLims(2)],hGridSize,...
    [vLims(1), vLims(2)],vGridSize);
figure; axHandler = axes(); hold on; % Create axes
if(exist('curve1','var'))% Plot level f1=0
    plot(axHandler,curve1(:,1),curve1(:,2),'r',...
        'DisplayName','$c_1(\upsilon)$'); hold on;
end
if(exist('curve2','var'))% Plot level f2=0
    plot(axHandler,curve2(:,1),curve2(:,2),'b',...
        'DisplayName','$c_2(\upsilon)$'); hold on;
end

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
%     dataHandler = DataHandler(uVec,xTime);
    plot(axHandler,dataHandler.inputSeq,dataHandler.outputSeq,'g',...
        'lineWidth',1.2,...
        'DisplayName','Experimental Data');
end
axis([hLims(1)-hRange*hPad,hLims(2)+hRange*hPad,...
      vLims(1)-vRange*vPad,vLims(2)+vRange*vPad]);
xlabel('$u$','Interpreter','latex');
ylabel('$y$','Interpreter','latex');

%%  Input creation

% Simulation parameters for periodic input
samplesPerCycle = 150; 
cycles = 10;
% uMin = -12; 
% uMax =  12;
x0 = 0.5;
uMin = -2; 
uMax =  2;
% x0 = dataHandler.outputSeq(1);
% uMin = -10; 
% uMax =  10;
% 
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

% Simulation parameters for peaks input
% samples = 500;
% t0 = 0; tend = 20;
% x0 = 0;
% peaks = [-3 2.8 -2.6 2.4 -2.2 2.0 -1.8 1.6 -1.4];
% peaks = [0 10 0 -10 0 8 0 -8 0 5 0 -5 0 3 0 -3 0];
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
    anLineHand,...
    autoAdjust,hPad,vPad,minHPad,minVPad);
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
    anLineHand,...
    autoAdjust,hPad,vPad,minHPad,minVPad)
    if strcmp(flag,'init')
        [uq,duq] = odeuVecduVecSolver(tq(1),tVec,uVec,duVec);
        addpoints(anLineHand,uq,xq(1,:));
    elseif strcmp(flag,'done')
    else
        [uq,duq] = odeuVecduVecSolver(tq,tVec,uVec,duVec);
        addpoints(anLineHand,uq,xq);
    end
    if(autoAdjust)
        autoAdjustPlot(anLineHand,hPad,vPad,minHPad,minVPad);
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
%         duhemModel = evalin('base', 'duhemModel');
    end
    [uq,duq] = odeuVecduVecSolver(tq,tVec,uVec,duVec);
    dyq = duhemModel.getdydt(uq,xq,duq);
end

function [uq,duq] = odeuVecduVecSolver(tq,tVec,uVec,duVec)
    uq = interp1(tVec,uVec,tq);
    duq = interp1(tVec,duVec,tq);
end