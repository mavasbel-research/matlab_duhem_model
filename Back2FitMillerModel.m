% clear all
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Adjust data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% scaleInput = 2;
% scaleOutput = 2;
% dataHandler.resetOrigSequences();
% dataHandler.normalizeInput(scaleInput);
% dataHandler.normalizeOutput(scaleOutput);

fitPlotter = FitPlotter();
fitPlotter.subfigInput(1:dataHandler.origSampleLength, dataHandler.origInputSeq, 'Original Input', 'r');
fitPlotter.subfigOutput(1:dataHandler.origSampleLength, dataHandler.origOutputSeq, 'Original Output', 'r');
%     fitPlotter.subfigInput(dataHandler.indexesSeq, dataHandler.inputSeq, 'Adjusted Input', 'b');
%     fitPlotter.subfigOutput(dataHandler.indexesSeq, dataHandler.outputSeq, 'Adjusted Output', 'b');
%     fitPlotter.subfigOutput(dataHandler.indexesSeq, dataHandler.outputSeq, 'Adjusted Output', 'b');
fitPlotter.figLoop(dataHandler.origInputSeq, dataHandler.origOutputSeq, 'Original data', 'r');
drawnow;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

syms Ps positive
syms Pr positive
syms Ec positive
vars = [Ps;Pr;Ec];

delta = Ec * ( log((1+Pr/Ps)/(1-Pr/Ps)) )^(-1);

% Saturation curves
PsatPlus   = @(E)  Ps*tanh(( E-Ec)/(2*delta));
PsatMinus  = @(E) -Ps*tanh((-E-Ec)/(2*delta));

% Derivatives of saturation curves
dPsatPlus  = @(E) Ps*( sech(( E-Ec)/(2*delta)) ).^2 * (1/(2*delta));
dPsatMinus = @(E) Ps*( sech((-E-Ec)/(2*delta)) ).^2 * (1/(2*delta));

% Gamma term
% GammaPlus  = @(E,Pd) 1 - tanh(  ( (Pd -  PsatPlus(E))/( Ps-Pd ) ).^(1/2)  );
% GammaMinus = @(E,Pd) 1 - tanh(  ( (Pd - PsatMinus(E))/(-Ps-Pd ) ).^(1/2)  );
GammaPlus  = @(E,Pd) 1 - tanh(  ( (Pd -  PsatPlus(E))/( Ps-Pd ) )  );
GammaMinus = @(E,Pd) 1 - tanh(  ( (Pd - PsatMinus(E))/(-Ps-Pd ) )  );

% Duhem model f1 & f2 functions
f1 = @(u,y)  GammaPlus(u,y) * dPsatPlus(u);
f2 = @(u,y) GammaMinus(u,y) * dPsatMinus(u);

% Compute symbolic integrals
syms uSym ySym real
symIntf1 = int(f1(uSym,ySym),uSym);
symIntf2 = int(f2(uSym,ySym),uSym);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fminconOptions = optimoptions( 'fmincon',...
                    'Algorithm','interior-point',...
                    'StepTolerance',1.0000e-10,...
                    'FunctionTolerance',1.0000e-6,...
                    'FiniteDifferenceType','central',...
                    'FiniteDifferenceStepSize',eps^(1/3),...
                    'MaxFunctionEvaluations',1.0000e+3,...
                    'MaxIterations',1.0000e+3,...
                    'RelLineSrchBndDuration',1,...
                    'Display','iter',...
                    'PlotFcn','optimplotfvalconstr',...
                    'UseParallel',true);
                
% fminconOptions = optimoptions('fmincon',...
%                     'Algorithm','active-set',...
%                     'StepTolerance',1.0000e-12,...
%                     'FunctionTolerance',1.0000e-100,...
%                     'UseParallel',true,...
%                     'FiniteDifferenceType','central',...
%                     'FiniteDifferenceStepSize',eps^(1/2),...
%                     'MaxFunctionEvaluations',1.0000e+10,...
%                     'MaxIterations',1.2000e+3,...
%                     'RelLineSrchBndDuration',10,...
%                     'PlotFcn','optimplotfval' );

swarmOptions = optimoptions('particleswarm','HybridFcn',{'fmincon',fminconOptions},...
                    'SwarmSize',10,...
                    'MaxIterations',50,...
                    'MaxStallIterations',10,...
                    'MaxStallTime',Inf,...
                    'MaxTime',Inf,...
                    'Display','iter',...
                    'PlotFcn','pswplotbestf',...
                    'UseParallel',true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

u1Vec = [];
y1Vec = [];
f1Vec = [];
symIntf1Vec = [];

idx0 = 1;
idx1 = 40;
u10 = dataHandler.inputSeq(idx0);
y10 = dataHandler.outputSeq(idx0);
symIntf10Vec = subs(symIntf1,[uSym,ySym],[u10,y10]);
for idx=idx0+1:idx1
    u = dataHandler.inputSeq(idx);
    y = dataHandler.outputSeq(idx);
    u1Vec = [u1Vec; u];
    y1Vec = [y1Vec; y-y10];
    f1Vec = [f1Vec; f1(u,y)];
    symIntf1Vec = [ symIntf1Vec; subs(symIntf1,[uSym,ySym],[u,y]) ];
end
% dy1Vec = [0;diff(y1Vec)./diff(u1Vec)];
% dy1Vec = [dy1Vec(1);dy1Vec(:)];

% objFunc1 = @(reg) sum(   dy1Vec - double(subs(f1Vec,vars,reg(:)))   ).^2;
% objFunc1 = @(reg) sum(   y1Vec - numIntF1(symIntf10Vec,symIntf1Vec,vars,reg)   ).^2;
objFunc1 = @(reg) sum(  y1Vec - trapzF1(u1Vec,f1Vec,vars,reg)   ).^2;

% Test with known value
% reg=[4;2;20]
% y1Vec
% trapzF1(u1Vec,f1Vec,vars,reg)
% % numIntF1(symIntf10Vec,symIntf1Vec,vars,reg)
% objFunc1(reg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

u11Vec = [];
y11Vec = [];
f11Vec = [];
symIntf11Vec = [];

idx0 = 125;
idx1 = 195;
u110 = dataHandler.inputSeq(idx0);
y110 = dataHandler.outputSeq(idx0);
symIntf110Vec = subs(symIntf1,[uSym,ySym],[u10,y10]);
for idx=idx0+1:idx1
    u = dataHandler.inputSeq(idx);
    y = dataHandler.outputSeq(idx);
    u11Vec = [u11Vec; u];
    y11Vec = [y11Vec; y-y110];
    f11Vec = [f11Vec; f1(u,y)];
    symIntf11Vec = [ symIntf11Vec; subs(symIntf1,[uSym,ySym],[u,y]) ];
end
% dy11Vec = [0;diff(y1Vec)./diff(u1Vec)];
% dy11Vec = [dy11Vec(1);dy11Vec(:)];

% objFunc11 = @(reg) sum(   dy11Vec - double(subs(f11Vec,vars,reg(:)))   ).^2;
% objFunc11 = @(reg) sum(   y1Vec - numIntF1(symIntf110Vec,symIntf11Vec,vars,reg)   ).^2;
objFunc11 = @(reg) sum(  y11Vec - trapzF1(u11Vec,f11Vec,vars,reg)   ).^2;

% Test with known value
% reg=[4;2;20]
% y11Vec
% trapzF1(u11Vec,f11Vec,vars,reg)
% % numIntF1(symIntf110Vec,symIntf1Vec,vars,reg)
% objFunc11(reg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
u2Vec = [];
y2Vec = [];
f2Vec = [];
symIntf2Vec = [];

idx0 = 41;
idx1 = 119;
u20 = dataHandler.inputSeq(idx0);
y20 = dataHandler.outputSeq(idx0);
symIntf20Vec = subs(symIntf2,[uSym,ySym],[u20,y20]);
for idx=idx0+1:idx1
    u = dataHandler.inputSeq(idx);
    y = dataHandler.outputSeq(idx);
    u2Vec = [u2Vec; u];
    y2Vec = [y2Vec; y-y20];
    f2Vec = [f2Vec; f2(u,y)];
    symIntf2Vec = [ symIntf2Vec; subs(symIntf2,[uSym,ySym],[u,y])];
end
% dy2Vec = [0;diff(y2Vec)./diff(u2Vec)];
% dy2Vec = [dy2Vec(1);dy2Vec(:)];

% objFunc2 = @(reg) sum(   dy2Vec - double(subs(f2Vec,vars,reg(:)))   ).^2;
% objFunc2 = @(reg) sum(   y2Vec - numIntF2(symIntf20Vec,symIntf2Vec,vars,reg)   ).^2;
objFunc2 = @(reg) sum(   y2Vec - trapzF2(u2Vec,f2Vec,vars,reg)   ).^2;

% Test with known value
% reg=[4;2;20]
% y2Vec
% trapzF2(u2Vec,f2Vec,vars,reg)
% % numIntF2(symIntf20Vec,symIntf2Vec,vars,reg)
% objFunc2(reg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

reg = [5,1,24];
reg = fmincon(@(reg)(objFunc1(reg)...
                    +objFunc2(reg)),...
    reg,[-1 1 0],[0],[],[],[0.75;0.5;0.5],[30;30;30],[],fminconOptions)
% [x,fval,exitflag,output] = particleswarm(@(reg)(objFunc1(reg)+objFunc2(reg)),...
%                             3,[0.5,0.5,0.5],[30,30,30],swarmOptions);

PsFound = reg(1)
PrFound = reg(2)
EcFound = reg(3)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function intf1Vec = numIntF1(symIntf10Vec,symIntf1Vec,vars,reg)
    intf10 = double(subs(symIntf10Vec,vars(:),reg(:)));
    intf1Vec = double(subs(symIntf1Vec,vars(:),reg(:))) - intf10;
end

function intf2Vec = numIntF2(symIntf20Vec,symIntf2Vec,vars,reg)
    intf20 = double(subs(symIntf20Vec,vars(:),reg(:)));
    intf2Vec = double(subs(symIntf2Vec,vars(:),reg(:))) - intf20;
end

function intf1Vec = trapzF1(u1Vec,f1Vec,vars,reg)
    intf1Vec = zeros(length(f1Vec),1);
    f1Vec = subs(f1Vec,vars(:),reg(:));
    parfor i=2:length(f1Vec)
        intf1Vec(i) = trapz(u1Vec(1:i), f1Vec(1:i));
    end
end

function intf2Vec = trapzF2(u2Vec,f2Vec,vars,reg)
    intf2Vec = zeros(length(f2Vec),1);
    f2Vec = subs(f2Vec,vars(:),reg(:));
    parfor i=2:length(f2Vec)
        intf2Vec(i) = trapz(u2Vec(1:i), f2Vec(1:i));
    end
end
