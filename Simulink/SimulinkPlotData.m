close all
clc

% Parameters
simLineWidth =  1.5;

% Create axes and plot level curves
axHandler = axes(); hold on;
% axis equal;
axis([xMin xMax yMin yMax]);
plot(axHandler,curve1(:,1),curve1(:,2),'r','DisplayName','f_1=0');
plot(axHandler,curve2(:,1),curve2(:,2),'b','DisplayName','f_2=0');

for i=1:size(anHystCurves,2)
    lineHandler = plot(axHandler,anHystCurves{i}(:,1),anHystCurves{i}(:,2),'k',...
        'DisplayName','f_1-f_2=0');
    if(i>1) set(lineHandler,'handleVisibility','off'); end
end
for i=1:size(avgHystCurves,2)
    lineHandler = plot(axHandler,avgHystCurves{i}(:,1),avgHystCurves{i}(:,2),'m',...
        'DisplayName','f_1+f_2=0');
    if(i>1) set(lineHandler,'handleVisibility','off'); end
end

for i=1:size(attractiveManifoldsC1,2)
    lineHandler = plot(axHandler,attractiveManifoldsC1{i}(:,1),attractiveManifoldsC1{i}(:,2),'--r',...
        'DisplayName','f_1= ^{dc_1}/_{du}'); hold on;
    if(i>1) set(lineHandler,'handleVisibility','off'); end
end
for i=1:size(attractiveManifoldsC2,2)
    lineHandler = plot(axHandler,attractiveManifoldsC2{i}(:,1),attractiveManifoldsC2{i}(:,2),'--b',...
        'DisplayName','f_2 = ^{dc_2}/_{du}'); hold on;
    if(i>1) set(lineHandler,'handleVisibility','off'); end
end

% Plot simulink data
plot(axHandler,input.data,output.data,'k','handleVisibility','off',...
    'lineWidth',simLineWidth);
legend();