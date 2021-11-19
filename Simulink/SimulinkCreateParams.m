% Create simulink parameters
T = 2;
amp = 15;
bias = 0;
u0 = -10;
y0 = -10;

% T = 2;
% amp = 1;
% bias = 0;
% u0 = 0.6;
% y0 = 1.01;

% Computed parameters
freq = 2*pi/T;
phase = pi-asin(sign(u0)*min([abs(u0),amp])/amp);

% xRange = 2;
% yRange = 20;
% pad = 0.2;
% xMin = 0-xRange*(1+pad)/2;
% xMax = 0+xRange*(1+pad)/2;
% yMin = 0-yRange*(1+pad)/2;
% yMax = 0+yRange*(1+pad)/2;