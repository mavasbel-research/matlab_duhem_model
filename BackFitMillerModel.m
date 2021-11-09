% clear all
close all
clc

syms Ps positive
syms Pr positive
syms Ec positive

% Ps = 4;
% Pr = 2;
% Ec = 20;
delta = Ec * ( log((1+Pr/Ps)/(1-Pr/Ps)) )^(-1);

% Saturation curves
PsatPlus   = @(E)  Ps*tanh(( E-Ec)/(2*delta));
PsatMinus  = @(E) -Ps*tanh((-E-Ec)/(2*delta));

% Derivatives of saturation curves
dPsatPlus  = @(E) Ps*( sech(( E-Ec)/(2*delta)) ).^2 * (1/(2*delta));
dPsatMinus = @(E) Ps*( sech((-E-Ec)/(2*delta)) ).^2 * (1/(2*delta));

% Gamma term
% GammaPlus  = @(E,Pd) 1 - tanh(  abs(( (Pd -  PsatPlus(E))/( Ps-Pd ) )).^(1/2)  );
% GammaMinus = @(E,Pd) 1 - tanh(  abs(( (Pd - PsatMinus(E))/(-Ps-Pd ) )).^(1/2)  );
GammaPlus  = @(E,Pd) 1 - tanh(  ( (Pd -  PsatPlus(E))/( Ps-Pd ) )  );
GammaMinus = @(E,Pd) 1 - tanh(  ( (Pd - PsatMinus(E))/(-Ps-Pd ) )  );

% Duhem model f1 & f2 functions
f1 = @(u,y)  GammaPlus(u,y) * dPsatPlus(u);
f2 = @(u,y) GammaMinus(u,y) * dPsatMinus(u);

syms uSym ySym real
intf1 = simplify(int(f1(uSym,ySym),uSym));
intf2 = simplify(int(f2(uSym,ySym),uSym));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fminconOptions = optimoptions( 'fmincon',...
                    'Algorithm','active-set',...
                    'StepTolerance',1.0000e-12,...
                    'FunctionTolerance',1.0000e-100,...
                    'UseParallel',true,...
                    'FiniteDifferenceType','central',...
                    'FiniteDifferenceStepSize',eps^(1/2),...
                    'MaxFunctionEvaluations',1.0000e+10,...
                    'MaxIterations',1.2000e+3,...
                    'RelLineSrchBndDuration',10,...
                    'PlotFcn','optimplotfval' );

intf1Vec = [];
f1IntYVec = [];

idx0 = 99;
idx1 = 169;
u0 = dataHandler.inputSeq(idx0);
y0 = dataHandler.outputSeq(idx0);
uVec = [];
yVec = [];
intf10Vec = subs(intf1,[uSym,ySym],[u0,y0]);
for idx=idx0+1:idx1
    u = dataHandler.inputSeq(idx);
    y = dataHandler.outputSeq(idx);
    uVec = [uVec;u];
    yVec = [yVec;y];
    intf1Vec = [intf1Vec; subs(intf1,[uSym,ySym],[u,y]) ];
end

objFunc1 = @(reg) sum(   (yVec-y0) - (double(subs(intf1Vec,[Ps;Pr;Ec],reg(:))) - double(subs(intf10Vec,[Ps;Pr;Ec],reg(:))))   ).^2;
f1Regressor = rand(3,1);
f1Regressor = fmincon(objFunc1,f1Regressor,[],[],[],[],[],[],[],fminconOptions)


% Ps = 
% Pr =  
% f1Par = @(PsPar,PrPar,EcPar) vpa(subs(f1IntF1Mat,[Ps,Pr,Ec],[PsPar,PrPar,EcPar]));
% f1Int = @(PsPar,PrPar,EcPar) trapz( dataHandler.inputSeq(idx0:UUUUUUUUU), vpa(subs(f1IntF1Mat,[Ps,Pr,Ec],[PsPar,PrPar,EcPar])) );
% objFunc1 = @(regressor)...
%                 sum( ...
%                     ( f1IntUMat*regressor(:) - f1IntYVec(:)...
%                         - ( dataHandler.outputSeq(idx0+1:idx1)...
%                             - dataHandler.outputSeq(idx0+1) )...
%                     ).^2 ...
%                 ) + sum( (f1RegTerm*regressor(:)).^2 ) ;
% syms u real
% syms y real
% intf1 = int(f1(u,y),u)
% intf2 = int(f2(u,y),u) 
% pretty(PsatPlus(u))
% pretty(dPsatPlus(u))
% pretty(GammaPlus(u,y))