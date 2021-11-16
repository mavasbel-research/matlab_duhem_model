clear all
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sigmoids
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% yWidth = 50;
% xWidth = 50;
% xyCenter = [0, 0];
% 
% evalLim = [-50,50];
% samples = 500;
% 
% center = 0; slope = 1.5; scale = 10.0; shift = -5.0;
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = sigmf(uVals,[slope, center])*scale+shift;
% curve1 = [uVals,yVals];
% 
% center = 0; slope = 1.5; scale = -10.0; shift = 5.0;
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = sigmf(uVals,[slope, center])*scale+shift;
% curve2 = [uVals,yVals];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Vertical sigmoids
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% yWidth = 50;
% xWidth = 25;
% xyCenter = [0, 0];
% 
% evalLim = [-50,50];
% samples = 500;
% 
% center = 0; slope = 0.25; scale = 10.0; shift = -5.0;
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = sigmf(uVals,[slope, center])*scale+shift;
% curve1 = [yVals,uVals];
% 
% center = 0; slope = 0.25; scale = -10.0; shift = 5.0;
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = sigmf(uVals,[slope, center])*scale+shift;
% curve2 = [yVals,uVals];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Logarithms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% yWidth = 50;
% xWidth = 50;
% xyCenter = [0, 0];
% 
% evalLim = [0,200];
% samples = 500;
% 
% scaleU = -0.15; scaleY = -3; shift = 0;
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = log(uVals)*scaleY+shift;
% curve1 = [scaleU*(uVals-evalLim(end)/2),yVals];
% 
% scaleU = -0.15; scaleY = -3; shift = 0;
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = log(uVals)*scaleY+shift;
% curve2 = [-scaleU*((uVals-evalLim(end)/2)),yVals];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lines 45
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% yWidth = 50;
% xWidth = 50;
% xyCenter = [0, 0];
% 
% evalLim = [-50,50];
% samples = 500;
% 
% slope = 1; shift = 10;
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = uVals*slope+shift;
% curve1 = [uVals,yVals];
% 
% slope = -1; shift = 10;
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = uVals*slope+shift;
% curve2 = [uVals,yVals];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lines + sines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% yWidth = 50;
% xWidth = 50;
% xyCenter = [0, 0];
% 
% evalLim = [-50,50];
% samples = 500;
% 
% slope = 0.75; shift = 0.5; amp=3; freq=0.075;
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = uVals*slope+shift + amp*sin(2*pi*freq*uVals);
% curve1 = [uVals,yVals];
% 
% slope = -0.75; shift = 0; amp=-3; freq=0.075;
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = uVals*slope+shift + amp*sin(2*pi*freq*uVals);
% curve2 = [uVals,yVals];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lines experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% yWidth = 50;
% xWidth = 50;
% xyCenter = [0, 0];
% 
% evalLim = [-50,50];
% samples = 500;
% 
% slope = -0.5; shift = 0;
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = uVals*slope+shift;
% curve1 = [uVals,yVals];
% 
% slope = 1; shift = 0;
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = uVals*slope+shift;
% curve2 = [uVals,yVals];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hiperbolic sine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% yWidth = 50;
% xWidth = 50;
% xyCenter = [0, 0];
% 
% evalLim = [-50,50];
% samples = 500;
% 
% scale = 2; shift = 0;
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = -sinh(uVals);
% curve1 = [yVals,uVals*scale+shift];
% 
% scale = 2; shift = 0;
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = -sinh(uVals);
% curve2 = [-yVals,uVals*scale+shift];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Butterfly cubic polynomial paper 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% yWidth = 20;
% xWidth = 30;
% xyCenter = [0, 0];
% 
% evalLim = [-15,15];
% samples = 2000;
% 
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = 0.1*uVals.^3 + 0.1*uVals + 1.0;
% curve1 = [uVals,yVals];
% 
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = - 0.1*uVals.^3 - 0.1*uVals - 1.0;
% curve2 = [uVals,yVals];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Butterfly cubic polynomial negative paper 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% yWidth = 20;
% xWidth = 30;
% xyCenter = [0, 0];
% 
% evalLim = [-15,15];
% samples = 2000;
% 
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = 0.1*uVals.^3 + 0.1*uVals - 1.0;
% curve1 = [uVals,-yVals];
% 
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = - 0.1*uVals.^3 - 0.1*uVals + 1.0;
% curve2 = [uVals,-yVals];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Multiloop sine paper
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% yWidth = 20;
% xWidth = 30;
% xyCenter = [0, 0];
% 
% evalLim = [-20,20];
% samples = 500;
% 
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals =  10*sin((2*pi/12)*uVals+pi/8);
% curve1 = [uVals,yVals];
% 
% uVals = linspace(evalLim(1),evalLim(2),samples)';
% yVals = -8*sin((2*pi/12)*uVals-pi/8);
% curve2 = [uVals,yVals];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fitted curves with nonlinear identification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
yWidth = 6;
xWidth = 3;
xyCenter = [0, 0];

evalLim = [-3,3];
samples = 1000;

f1Regressor = [1 -2 -3 1 -1];
f2Regressor = [2  3 -1 -1  1];
params = [f1Regressor, f2Regressor];
paramsLength = length(params);

% f1Regressor = params(1:paramsLength/2);
% f2Regressor = params(paramsLength/2+1:end);

uVals = linspace(evalLim(1),evalLim(2),samples)';
yVals = 0;
for n=0:paramsLength/2-1
    yVals = yVals + uVals.^n*f1Regressor(n+1);
end
curve1 = [uVals,yVals];

uVals = linspace(evalLim(1),evalLim(2),samples)';
yVals = 0;
for n=0:paramsLength/2-1
    yVals = yVals + uVals.^n*f2Regressor(n+1);
end
curve2 = [uVals,yVals];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [curve1(:,1),idxs] = sort(curve1(:,1));
% curve1(:,2) = curve1(idxs,2);
% [curve2(:,1),idxs] = sort(curve2(:,1));
% curve2(:,2) = curve2(idxs,2);

run('./ButterflyPlot_c1c2.m')