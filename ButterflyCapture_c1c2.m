close all
clc

% Parameters
lineWidth = 1.2;
markerSize = 8;
samplesInterp = 500;
yWidth = 50;
xWidth = 50;
xyCenter = [0, 0];

% Show selection of curve
if ~exist('curveToCreate'), curveToCreate = 1; end;
[curveToCreate,tf] = listdlg('PromptString','Curve to capture:',...
    'ListString',{'1','2'},...
    'InitialValue',curveToCreate,...
    'SelectionMode','single');

% Create axes
xMin = xyCenter(1)-xWidth/2;
xMax = xyCenter(1)+xWidth/2;
yMin = xyCenter(2)-yWidth/2;
yMax = xyCenter(2)+yWidth/2;
axHandler = axes(); hold on; grid on;
% axis equal; 
axis([xMin xMax yMin yMax]);
xlim([xyCenter(1)-xWidth/2 xyCenter(1)+xWidth/2]);
ylim([xyCenter(2)-yWidth/2 xyCenter(2)+yWidth/2]);

% Configure color and plot other curve
if curveToCreate==1
    color='r';
    colorRGB='#FF0000';
    if(exist('curve2'))
        plot(axHandler,curve2(:,1),curve2(:,2),'b','DisplayName','f_2=0');
    end
elseif curveToCreate==2
    color='b';
    colorRGB='#0000FF';
    if(exist('curve1'))
        plot(axHandler,curve1(:,1),curve1(:,2),'r','DisplayName','f_1=0');
    end
else
    color='k';
    colorRGB='#000000';
end

% Capture loop
i=0;
key=-1;
capX=double([]);
capY=double([]);
capCurveX=double([]);
capCurveY=double([]);
line = animatedline(axHandler,'Color',colorRGB);
while(true)
    % Capture and validate
    try [capX,capY,key] = ginput(1); catch end;
    if(isempty(capX) || isempty(capX) || key < 0 || key==27 || key==8) break, end
    
    % Add point to vectors
    capCurveX(i+1)=capX;
    capCurveY(i+1)=capY;

    % Plot
    plot(axHandler,capX,capY,strcat(color,'.'),'MarkerSize',markerSize);
    addpoints(line,capX,capY);
    drawnow

    % Prepare for next capture
    capX=double([]);
    capY=double([]);
    i=i+1;
end
if(exist('axHandler'))close(ancestor(axHandler,'figure','toplevel')); end

if(length(capCurveX)>2)
    % Sort vectors from min to max horizontal value
    [capCurveX,idxs] = sort(capCurveX);
    capCurveY = capCurveY(idxs);
    
    % Interpolate and create curve
    uVals = interp1(capCurveX, linspace(1,length(capCurveX),samplesInterp), 'spline');
    yVals = interp1(capCurveY, linspace(1,length(capCurveY),samplesInterp), 'spline');
    
    if curveToCreate==1
        curve1 = [uVals(:),yVals(:)];
    elseif curveToCreate==2
        curve2 = [uVals(:),yVals(:)];
    end

    run('./ButterflyPlot_c1c2')
end