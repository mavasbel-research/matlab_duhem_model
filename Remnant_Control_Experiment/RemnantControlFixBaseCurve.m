%% Initialize
% clear all
close all
% clc

%% Get scales in case thy exists
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

%% Miller model
% Ps = 21; Pr = 14; Ec = 10;
Ps = params(1); Pr = params(2); Ec = params(3);

% Delta paramter
delta = Ec*( log((1+Pr/Ps)/(1-Pr/Ps)) )^(-1);

% Saturation curves
PsatPlus   = @(E)  Ps*tanh(( E-Ec)/(2*delta));
PsatMinus  = @(E) -Ps*tanh((-E-Ec)/(2*delta));

% Derivatives of saturation curves
dPsatPlus  = @(E) Ps*( sech(( E-Ec)/(2*delta)) ).^2 * (1/(2*delta));
dPsatMinus = @(E) Ps*( sech((-E-Ec)/(2*delta)) ).^2 * (1/(2*delta));

% Gamma term
GammaPlus  = @(E,Pd) 1 - (tanh(  (( (Pd -  PsatPlus(E))./( Ps-Pd ) )).^(1/2)  ));
GammaMinus = @(E,Pd) 1 - (tanh(  (( (Pd - PsatMinus(E))./(-Ps-Pd ) )).^(1/2)  ));

% % Scaled Duhem model f1 & f2 functions
f1Fitted = @(v,z)    abs(GammaPlus(v,z) .* dPsatPlus(v));
f2Fitted = @(v,z)   abs(GammaMinus(v,z) .* dPsatMinus(v));

% % Duhem model f1 & f2 without scales
f1 = @(u,y) ((inputScale/outputScale)*f1Fitted( inputTrans(u),outputTrans(y) ));
f2 = @(u,y) ((inputScale/outputScale)*f2Fitted( inputTrans(u),outputTrans(y) ));

% Create model
duhemModel = DuhemModel(f1,f2);

%% Asym miller model
% PsPlus  = params(1); PrPlus  = params(2); EcPlus  = params(3);
% PsMinus = params(4); PrMinus = params(5); EcMinus = params(6);
% % PsMinus = params(1); PrMinus = params(2); EcMinus = params(3);
% % syms PsPlus PrPlus EcPlus
% % syms PsMinus PrMinus EcMinus
% 
% % Delta parameter
% deltaPlus =   EcPlus * ( log(  (1+PrPlus/PsPlus)/(1-PrPlus/PsPlus)  ) )^(-1);
% deltaMinus = EcMinus * ( log((1+PrMinus/PsMinus)/(1-PrMinus/PsMinus)) )^(-1);
% 
% % Saturation curves
% PsatPlus   = @(E)  PsPlus *tanh( ( E-EcPlus )/(2*deltaPlus)  );
% PsatMinus  = @(E) -PsMinus*tanh( (-E-EcMinus)/(2*deltaMinus) );
% 
% % Derivatives of saturation curves
% dPsatPlus  = @(E) PsPlus *( sech(( E-EcPlus )./(2*deltaPlus))  ).^2 * ( 1/(2*deltaPlus)  );
% dPsatMinus = @(E) PsMinus*( sech((-E-EcMinus)./(2*deltaMinus)) ).^2 * ( 1/(2*deltaMinus) );
% 
% % Gamma term
% GammaPlus  = @(E,Pd) 1 - (tanh(  (( (Pd - PsatPlus(E) )./( PsPlus-Pd ) )).^(1/2)  ));
% GammaMinus = @(E,Pd) 1 - (tanh(  (( (Pd - PsatMinus(E))./(-PsMinus-Pd) )).^(1/2)  ));
% 
% % Scaled Duhem model f1 & f2 functions
% f1Fitted = @(v,z)    abs(GammaPlus(v,z) .* dPsatPlus(v));
% f2Fitted = @(v,z) abs((GammaMinus(v,z)) .* dPsatMinus(v));
% 
% % Duhem model f1 & f2 without scales
% f1 = @(u,y) ((inputScale/outputScale)*f1Fitted( inputTrans(u), outputTrans(y) ));
% f2 = @(u,y) ((inputScale/outputScale)*f2Fitted( inputTrans(u), outputTrans(y) ));

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

%% Create polynomial model

% % Scaled Duhem model f1 & f2 functions
% f1Fitted = @(u,x)   ( params(1) + params(2)*u + params(3)*u^2 + params(4)*u^3 +  params(5)*u^4 - x );
% f2Fitted = @(u,x) - ( params(6) + params(7)*u + params(8)*u^2 + params(9)*u^3 + params(10)*u^4 - x );
% 
% % Duhem model f1 & f2 without scales
% f1 = @(u,y) (inputScale/outputScale)*f1Fitted( inputTrans(u), outputTrans(y) );
% f2 = @(u,y) (inputScale/outputScale)*f2Fitted( inputTrans(u), outputTrans(y) );
% 
% % Create model
% duhemModel = DuhemModel(f1,f2);

%% Create plots

% Create plot paramters and obtain anhysteresis curves
hGridSize = 1000; hLims = [-1.0 1.0]*3000; 
vGridSize = 1000; vLims = hLims;
if(exist('PsatPlus','var')) % Plot saturations
    vLims = [outputInvTrans(PsatPlus(inputTrans(hLims(1))))...
        outputInvTrans(PsatPlus(inputTrans(hLims(2))))]*1;
end
[anHystCurves, avgHystCurves] = ...
    DuhemModel.findAnhysteresisCurve(duhemModel,...
    [hLims(1), hLims(2)],hGridSize,...
    [vLims(1), vLims(2)],vGridSize);
figure; axHandler = axes(); hold on; % Create axes
% if(exist('curve1','var'))% Plot level f1=0
%     plot(axHandler,curve1(:,1),curve1(:,2),'r',...
%         'DisplayName','$c_1(\upsilon)$'); hold on;
% end
% if(exist('curve2','var'))% Plot level f2=0
%     plot(axHandler,curve2(:,1),curve2(:,2),'b',...
%         'DisplayName','$c_2(\upsilon)$'); hold on;
% end
for i=1:size(anHystCurves,2) % Plot anhysteresis curve
    lineHandler = plot(axHandler,...
        anHystCurves{i}(:,1),anHystCurves{i}(:,2),...
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
%         'DisplayName','f_1+f_2=0'); hold on;
%     if(i>1) set(lineHandler,'handleVisibility','off'); end
% end
if(exist('dataHandler','var')) % Plot experimental data
    expDataPlot = plot(axHandler,...
                        inputInvTrans(dataHandler.inputSeq),...
                        outputInvTrans(dataHandler.outputSeq),...
                        'g','lineWidth',1.2,...
                        'DisplayName','Experimental data');
end
if(exist('PsatPlus','var')) % Plot saturations
    uSat = linspace(-3000,3000,3000);
    plot(uSat,outputInvTrans(PsatPlus(inputTrans(uSat))),...
        'Color','r',...
        'LineWidth',1.2,...
        'DisplayName','$P_{sat}^+$',...
        'HandleVisibility','on');
    plot(uSat,outputInvTrans(PsatMinus(inputTrans(uSat))),...
        'Color','b',...
        'LineWidth',1.2,...
        'DisplayName','$P_{sat}^-$',...
        'HandleVisibility','on');
end

% Plot adjustment
autoAdjust = false;
hPad = 0.1; vPad = 0.1; 
minHPad = 0.1; minVPad = 0.1; 
hPlotLims = [-1.0 1.0]*1500; 
vPlotLims = [-35 52]*1;
hPlotRange = hPlotLims(2)-hPlotLims(1); vPlotRange = vPlotLims(2)-vPlotLims(1);
axis([hPlotLims(1)-hPlotRange*hPad,hPlotLims(2)+hPlotRange*hPad,...
      vPlotLims(1)-vPlotRange*vPad,vPlotLims(2)+vPlotRange*vPad]);
xlabel('$u$','Interpreter','latex');
ylabel('$y$','Interpreter','latex');

% Create animated plot handlers and invoke ode
anLineHand = animatedline(axHandler,...
    'LineWidth',1.2,...
    'Color','black',...,
    'DisplayName','Duhem model',...
    'HandleVisibility','on');

%% Create ode params
odeOpts = odeset(...
        'NormControl','off',...
        'Reltol',1e-5,...
        'AbsTol',1e-6,...
        'Refine',1,...
        'MaxStep',10,...
        'Stats','off');

%% Initialization

% Parameters for periodic input
samples = 5000; cycles = 1;
uMax = inputInvTrans(dataHandler.inputMax);
uMin = inputInvTrans(dataHandler.inputMin);

uVec = [linspace(uMax,uMin,samples)';
        linspace(uMin,uMax,samples)'];
uVec = circshift(uVec,samples/2);
tVec = linspace(0,1,samples*2)';
duVec = [0;diff(uVec)./diff(tVec)];

odeOpts = odeset(odeOpts,...
        'OutputFcn',@(tq,xq,flag)odeDrawing(tq,xq,flag,...
        tVec,uVec,duVec,...
        autoAdjust,hPad,vPad,minHPad,minVPad,...
        anLineHand));
xVec = 10;%outputInvTrans(dataHandler.outputSeq(1));
for i=1:5
    [tVec,xVec] = ode113(@(tq,xq)odeModel(tq,xq,tVec,uVec,duVec),...
                        tVec,xVec(end),odeOpts);
end

% Find the values of remnant max and remnant min and set reference
odeOpts = odeset(odeOpts,'OutputFcn',@(tq,xq,flag)0);
tBaseAsc = linspace(0,1,samples)';
uBaseAsc = linspace(uMin,uMax,samples)';
duBaseAsc = [0;diff(uBaseAsc)./diff(tBaseAsc)];
[tBaseAsc,xBaseAsc] = ode113(...
        @(tq,xq)odeModel(tq,xq,tBaseAsc,uBaseAsc,duBaseAsc),...
        tBaseAsc,min(xVec),odeOpts);
tBaseDesc = linspace(0,1,samples)';
uBaseDesc = linspace(uMax,uMin,samples)';
duBaseDesc = [0;diff(uBaseDesc)./diff(tBaseDesc)];
[tBaseDesc,xBaseDesc] = ode113(...
        @(tq,xq)odeModel(tq,xq,tBaseDesc,uBaseDesc,duBaseDesc),...
        tBaseDesc,max(xVec),odeOpts);
[~,idxAsc] = min(abs(uBaseAsc-0));
[~,idxDesc] = min(abs(uBaseDesc-0));
remnantMin = xBaseAsc(idxAsc);
remnantMax = xBaseDesc(idxDesc);

% Plot base curve
plot(axHandler,uBaseAsc,xBaseAsc,'--m','LineWidth',1.75);
plot(axHandler,uBaseDesc,xBaseDesc,'--m','LineWidth',1.75);
plot(0,remnantMin,'om','LineWidth',1.75,'markerSize',4)
plot(0,remnantMax,'om','LineWidth',1.75,'markerSize',4)
delete(expDataPlot)

% Set control parameters
ref = max([min([12, remnantMax]),remnantMin]);
errorThreshold = 0.001;
iterationLimit = 1000;

%% Control loop

% Loops
remnants = remnantMin;
errors = ref-remnants;
amps = 500;
iter = 1;
uMat = [];
xMat = [];
clearpoints(anLineHand)
while(true)
    % Print iteration number
    disp('-------------------------')
    disp(['Iteration: ', num2str(iter)])
    disp(['Pulse Amplitude: ', num2str(amps(end))])
    
    % Ode solver
    [uVec, duVec, tVec] = generatePulse(amps(end), samples);
    odeOpts = odeset(odeOpts,...
        'OutputFcn',@(tq,xq,flag)odeDrawing(tq,xq,flag,...
        tVec,uVec,duVec,...
        autoAdjust,hPad,vPad,minHPad,minVPad,...
        anLineHand));
    [tVec,xVec] = ode113(...
            @(tq,xq)odeModel(tq,xq,tVec,uVec,duVec),...
            tVec,xVec(end),odeOpts);
    
    % Store simulation results
    uMat = [uMat, uVec(:)];
    xMat = [xMat, xVec(:)];
	remnants(end+1) = xVec(end);
    errors(end+1) = ref-xVec(end);
    
    % Print final output and error
    disp(['Final Output: ', num2str(remnants(end))])
    disp(['Error: ', num2str(errors(end))])
    
    % Break cycle condition
    if abs(errors(end))<=errorThreshold
        disp('-------------------------')
        disp('Error threshold achieved')
        disp('-------------------------')
        break
    elseif iter>=iterationLimit
        disp('-------------------------')
        disp('Iterations limit achieved!')
        disp('-------------------------')
        break
    end
    
    % Find reset curve and amplitude
    odeOpts = odeset(odeOpts,'OutputFcn',@(tq,xq,flag)0);
    tResAsc = linspace(0,1,samples)';
    uResAsc = linspace(0,uMax,samples)';
    duResAsc = [0;diff(uResAsc)./diff(tResAsc)];
    [tResAsc,xResAsc] = ode113(...
            @(tq,xq)-odeModel(tq,xq,tResAsc,uResAsc,-duResAsc),...
            tResAsc,xVec(end),odeOpts);
    tResDesc = linspace(0,1,samples)';
    uResDesc = linspace(0,uMin,samples)';
    duResDesc = [0;diff(uResDesc)./diff(tResDesc)];
    [tResDesc,xResDesc] = ode113(...
            @(tq,xq)odeModel(tq,xq,tResDesc,uResDesc,duResDesc),...
            tResDesc,xVec(end),odeOpts);
    xRes = interp1([wrev(uResDesc);uResAsc(2:end)],[wrev(xResDesc);xResAsc(2:end)],uBaseAsc);
    resetCurve = plot(axHandler,uBaseAsc,xRes,'--b','LineWidth',1.5);
    [~,idx] = min(abs(xRes(1:end/2)-xBaseAsc(1:end/2)));
    resetAmp = uBaseAsc(idx);
    disp(['Reset amp: ', num2str(resetAmp)])
    
    % Apply reset
    [uVec, duVec, tVec] = generatePulse(resetAmp, samples);
    odeOpts = odeset(odeOpts,...
        'OutputFcn',@(tq,xq,flag)odeDrawing(tq,xq,flag,...
        tVec,uVec,duVec,...
        autoAdjust,hPad,vPad,minHPad,minVPad,...
        anLineHand));
    [tVec,xVec] = ode113(...
            @(tq,xq)odeModel(tq,xq,tVec,uVec,duVec),...
            tVec,remnants(end),odeOpts);
    delete(resetCurve)
    
    % Compute next amp and update iteration counter 
    amps(end+1) = amps(end) + 25*errors(end);
    iter = iter+1;
end

%% Auxiliary functions
function [uVec, duVec, tVec] = generatePulse(pulseAmp, samples)
    timesVals = [0; 0.5; 1.0];
    uVals = [0; pulseAmp; 0];
    
    tVec = linspace(0, timesVals(end), samples);
    uVec = interp1(timesVals, uVals, tVec);
    duVec = [0,diff(uVec)./diff(tVec)];
    
    tVec = tVec(:);
    uVec = uVec(:);
    duVec = duVec(:);
end

function output = odeDrawing(tq,xq,flag,...
    tVec,uVec,duVec,...
    autoAdjust,hPad,vPad,minHPad,minVPad,...
    anLineHand)

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