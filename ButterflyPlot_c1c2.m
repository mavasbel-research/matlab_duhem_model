close all
clc

% Parameters
axHandler = axes(); hold on;
xMin = xyCenter(1)-xWidth/2;
xMax = xyCenter(1)+xWidth/2;
yMin = xyCenter(2)-yWidth/2;
yMax = xyCenter(2)+yWidth/2;
xRange = xWidth; xGridSize = 500;
yRange = yWidth; yGridSize = 800;
xPad = 0.1; yPad = 0.1;
xlim([xMin-xRange*xPad xMax+xRange*xPad]);
ylim([yMin-yRange*yPad yMax+yRange*yPad]);

% Distance function
distanceFunc = @DuhemUtils.verticalDistance;

% Test point
% testPoint = [10,20];
if(exist('curve1'))
    % Create f1 handler and plot level set f1=0
    plot(axHandler,curve1(:,1),curve1(:,2),'r','DisplayName','f_1=0'); hold on;
    f1 = @(u,x)-distanceFunc([u,x],curve1);
end
if(exist('curve2'))
    % Create f2 handler plot level set f2=0
    plot(axHandler,curve2(:,1),curve2(:,2),'b','DisplayName','f_2=0'); hold on;
    f2 = @(u,x)distanceFunc([u,x],curve2);
end

% Obtain anhysteresis curve 
if(exist('curve1') && exist('curve2'))
    duhemModel = DuhemModel(f1,f2); % Create duhem model
    [anHystCurves, avgHystCurves] = ...
        DuhemModel.findAnhysteresisCurve(duhemModel,[xMin,xMax],xGridSize,[yMin,yMax],yGridSize);
    for i=1:size(anHystCurves,2) % Plot anhysteresis curve
        lineHandler = plot(axHandler,anHystCurves{i}(:,1),anHystCurves{i}(:,2),'k',...
            'DisplayName','f_1-f_2=0'); hold on;
        if(i>1) set(lineHandler,'handleVisibility','off'); end
    end
%     for i=1:size(avgHystCurves,2) % Plot average curve
%         lineHandler = plot(axHandler,avgHystCurves{i}(:,1),avgHystCurves{i}(:,2),'m',...
%             'DisplayName','f_1+f_2=0'); hold on;
%         if(i>1) set(lineHandler,'handleVisibility','off'); end
%     end
end

% Show legends
% legend();

% Create simulink params
% run('./SimulinkCreateParams')

% Cycle to capture clics
key = -1; capX=double([]); capY=double([]);
while(false)
    % Capture and validate
    try [capX,capY,key] = ginput(1); catch end;
    if(isempty(capX) || isempty(capX) || key < 0 || key==27 || key==8) break, end

    % Plot point
    f1Val = '?';
    plot(axHandler,capX,capY,'ko','LineWidth',1.5,'MarkerSize',4,'handleVisibility','off');
    if(exist('curve1')) % Compute f1 and plot closest point line
        [distance,index] = distanceFunc([capX,capY],curve1);
        plot(axHandler,[capX;curve1(index,1)],[capY;curve1(index,2)],'r','handleVisibility','off');
        f1Val = f1(capX,capY);
    end
    f2Val = '?';
    if(exist('curve2'))% Compute f2 and plot closest point line
        [distance,index] = distanceFunc([capX,capY],curve2);
        plot(axHandler,[capX;curve2(index,1)],[capY;curve2(index,2)],'b','handleVisibility','off');
        f2Val = f2(capX,capY);
    end
    
    % Display f1 and f2
    disp('Captured point:')
    disp('[u,y] = [' + string(capX) + ', ' + string(capY) + ']')
    disp('[f1,f2] = [' + string(f1Val) + ', ' + string(f2Val) + ']')
    if(isnumeric(f1Val) && isnumeric(f2Val))
        disp('[F,G]=[(f1-f2)/2,(f1+f2)/2] = [' + string((f1Val-f2Val)/2) + ', ' + string((f1Val+f2Val)/2) + ']')
    end
    disp('-----------------------------------')

    % Prepare for next capture
    capX=double([]);
    capY=double([]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%