clear all
close all
clc

% Control Paremeters
% ref = - 0.2 - 0.3582;
ref = 0.5;
pulse = -1.23;
gain = 0.5;
inputSamples = 1200;
errorThreshold = 0.001;
iterationLimit = 100;
x0 = 2;

% Duhem parameters
bw_alpha = 1.0;
bw_beta = 2.0;
bw_zeta = 5.0;
bw_n = 3;
bw_eta = 1;
(bw_alpha/(bw_beta+bw_zeta))^bw_n
(bw_alpha/(bw_beta-bw_zeta))^bw_n
f1 = @(u,x) bw_eta*(bw_alpha - bw_beta*abs(x)^bw_n - bw_zeta*x*abs(x)^(bw_n-1));
f2 = @(u,x) bw_eta*(bw_alpha - bw_beta*abs(x)^bw_n + bw_zeta*x*abs(x)^(bw_n-1));

% Create model
duhemModel = DuhemModel(f1,f2);

% Video parameters
videoName = 'video.avi';
videoWidth = 720;
videoHeight = 480;

% Print control objective
disp(['Target Output: ', num2str(ref)])
disp(['Error Threshold: ', num2str(errorThreshold)])

% Loop Initialization
pulses = [];
remnants = [];
errors = [];
iteration = 0;

% Plotting parameters
hPad = 0.1; vPad = 0.1; 
minHPad = 0.1; minVPad = 0.1; 
autoAdjust = true;
hGridSize = 500; hLims = [-1.0 1.0]*1; 
vGridSize = 500; vLims = [-1.0 1.0]*1;
hRange = hLims(2)-hLims(1); vRange = vLims(2)-vLims(1);

% Plots initialization
fig = figure;
plotHandler = plot(0, ref, 'ro', 'markersize', 4); hold on;
axHandler = gca;
anLineHand = animatedline(axHandler,...
            'LineWidth',1.2,...
            'Color','k',...,
            'DisplayName','Duhem model',...
            'HandleVisibility','on');

[anHystCurves, avgHystCurves] = ...
    DuhemModel.findAnhysteresisCurve(duhemModel,...
    [hLims(1), hLims(2)],hGridSize,...
    [vLims(1), vLims(2)],vGridSize);
for i=1:size(anHystCurves,2) % Plot anhysteresis curve
    lineHandler = plot(axHandler,...
        anHystCurves{i}(:,1),anHystCurves{i}(:,2),...
        'Color','k',...
        'LineWidth',1.0,...
        'LineStyle','--',...
        'DisplayName','Anhysteresis curve $\mathcal{A}$'); hold on;
    if(i>1) set(lineHandler,'handleVisibility','off'); end
end
% axHandler = plotHandler; % Create axes
% if(exist('curve1','var'))% Plot level f1=0
%     plot(axHandler,curve1(:,1),curve1(:,2),'r',...
%         'DisplayName','$c_1(\upsilon)$'); hold on;
% end
% if(exist('curve2','var'))% Plot level f2=0
%     plot(axHandler,curve2(:,1),curve2(:,2),'b',...
%         'DisplayName','$c_2(\upsilon)$'); hold on;
% end
% if(exist('dataHandler','var'))
%     plot(axHandler,dataHandler.inputSeq,dataHandler.outputSeq,'g',...
%         'lineWidth',1.2,...
%         'DisplayName','Experimental Data');
% end
axis([hLims(1)-hRange*hPad,hLims(2)+hRange*hPad,...
      vLims(1)-vRange*vPad,vLims(2)+vRange*vPad]);
xlabel('$u$','Interpreter','latex');
ylabel('$y$','Interpreter','latex');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Video initialization
% videoWriter = VideoWriter(videoName);
% open(videoWriter);
while(true)
    % Update iteration counter
    iteration = iteration + 1;
    
    % Generate input signal
    [uVec, tVec] = generateInputSignal(pulse, inputSamples);
    output = zeros(inputSamples, 1);
    duVec = [0;diff(uVec)./diff(tVec)];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    odeOutFunc = @(tq,xq,flag)odeDrawing(...
                tq,xq,flag,...
                tVec,uVec,duVec,...
                anLineHand,... videoWriter,...
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    error = (ref - xTime(end));
    
    % Print stats
    disp('-------------------------')
    disp(['Iteration: ', num2str(iteration)])
    disp(['Pulse Amplitude: ', num2str(pulse)])
    disp(['Final Output: ', num2str(xTime(end))])
    disp(['Error: ', num2str(error)])
    
    % Save iteration params and stats
    pulses = [pulses; pulse];
    remnants = [remnants; output(end)];
    errors = [errors; error];
    
    % Break cycle condition
    if abs(error)<=errorThreshold
        disp('-------------------------')
        disp('Error threshold achieved')
        disp('-------------------------')
        break
    elseif iteration>iterationLimit
        disp('-------------------------')
        disp('Iterations limit achieved!')
        disp('-------------------------')
        break
    end
    
    % Update pulse value for next iteration
    pulse = pulse - gain*error;
    x0 = xTime(end);
end

% Close video
% close(videoWriter);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to generate input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [signal, times] = generateInputSignal(pulseAmp, numSamples)
    pointTimes = [0; 0.25; 0.5; 0.75; 1; 1.25;];
    pointSignal = [0; pulseAmp; 0; 0; -pulseAmp/6; 0];
    times = linspace(0, pointTimes(end), numSamples);
    signal = interp1(pointTimes, pointSignal, times);
    
    times = times(:);
    signal = signal(:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions for ode solver and animated plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function output = odeDrawing(tq,xq,flag,...
    tVec,uVec,duVec,...
    anLineHand,... videoWriter,...
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
%     frame = getframe(get(get(anLineHand,'Parent'),'Parent')));
%     writeVideo(videoWriter, frame);
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