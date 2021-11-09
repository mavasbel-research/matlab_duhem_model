% clear all
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Adjust data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scaleInput = 5;
scaleOutput = 5;
dataHandler.resetOrigSequences();
% dataHandler.zeroMeanInput();
% dataHandler.zeroMeanOutput();
dataHandler.normalizeInput(scaleInput);
dataHandler.normalizeOutput(scaleOutput);

fitPlotter = FitPlotter();
% fitPlotter.subfigInput(1:dataHandler.origSampleLength, dataHandler.origInputSeq, 'Original Input', 'r');
% fitPlotter.subfigOutput(1:dataHandler.origSampleLength, dataHandler.origOutputSeq, 'Original Output', 'r');
fitPlotter.subfigInput(dataHandler.indexesSeq, dataHandler.inputSeq, 'Adjusted Input', 'b');
fitPlotter.subfigOutput(dataHandler.indexesSeq, dataHandler.outputSeq, 'Adjusted Output', 'b');
% fitPlotter.figLoop(dataHandler.origInputSeq, dataHandler.origOutputSeq, 'Original data', 'r');
fitPlotter.figLoop(dataHandler.inputSeq, dataHandler.outputSeq, 'Adjusted data', 'b');
drawnow;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

syms PsPlus positive
syms PrPlus positive
syms EcPlus positive
syms PsMinus positive
syms PrMinus positive
syms EcMinus positive
varsPlus = [PsPlus;PrPlus;EcPlus];
varsMinus = [PsMinus;PrMinus;EcMinus];

% Delta parameter
deltaPlus = EcPlus * ( log((1+PrPlus/PsPlus)/(1-PrPlus/PsPlus)) )^(-1);
deltaMinus = EcMinus * ( log((1+PrMinus/PsMinus)/(1-PrMinus/PsMinus)) )^(-1);

% Saturation curves
PsatPlus   = @(E)  PsPlus *tanh(( E-EcPlus) /(2*deltaPlus));
PsatMinus  = @(E) -PsMinus*tanh((-E-EcMinus)/(2*deltaMinus));

% Derivatives of saturation curves
dPsatPlus  = @(E) PsPlus *( sech(( E-Ec)/(2*deltaPlus)) ).^2 * (1/(2*deltaPlus));
dPsatMinus = @(E) PsMinus*( sech((-E-Ec)/(2*deltaMinus)) ).^2 * (1/(2*deltaMinus));

% Gamma term
% GammaPlus  = @(E,Pd) 1 - tanh(  ( (Pd -  PsatPlus(E))/( PsPlus -Pd ) ).^(1/2)  );
% GammaMinus = @(E,Pd) 1 - tanh(  ( (Pd - PsatMinus(E))/(-PsMinus-Pd ) ).^(1/2)  );
% GammaPlus  = @(E,Pd) 1 - tanh(  (  abs((Pd -  PsatPlus(E))/( PsPlus -Pd ))  ).^(1/2)  );
% GammaMinus = @(E,Pd) 1 - tanh(  (  abs((Pd - PsatMinus(E))/(-PsMinus-Pd ))  ).^(1/2)  );
GammaPlus  = @(E,Pd) 1 - tanh(  ( (Pd -  PsatPlus(E))/( PsPlus -Pd ) )  );
GammaMinus = @(E,Pd) 1 - tanh(  ( (Pd - PsatMinus(E))/(-PsMinus-Pd ) )  );

% Duhem model f1 & f2 functions
f1 = @(u,x)  GammaPlus(u,x) * dPsatPlus(u);
f2 = @(u,x) GammaMinus(u,x) * dPsatMinus(u);

% Create model
duhemModel = DuhemModel(f1,f2);

% Compute symbolic integrals
% syms uSym ySym real
% symIntf1 = int(f1(uSym,ySym),uSym);
% symIntf2 = int(f2(uSym,ySym),uSym);

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
                    'PlotFcn','optimplotx',...
                    'UseParallel',true);

%'HybridFcn',{'fmincon',fminconOptions},...
swarmOptions = optimoptions('particleswarm',...                   
                    'SwarmSize',11,...
                    'MaxIterations',50,...
                    'MaxStallIterations',10,...
                    'MaxStallTime',Inf,...
                    'MaxTime',Inf,...
                    'Display','iter',...
                    'PlotFcn','pswplotbestf',...
                    'UseParallel',true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ascLims = [120,200;
%             282,360;
%             442,519];
% descLims = [200,280;
%             361,441;
%             522,600];

ascLims = [1,35;
            100,169;
            235,300];
descLims = [38,98;
            172,230;
            302,360];

% ascLims = [235,300];
% descLims = [302,360];

objFuncsPlus = {};
for i=1:size(ascLims,1)
    objFuncsPlus{i} = createObjFun(dataHandler.inputSeq(ascLims(1,1):ascLims(1,2)),...
                        dataHandler.outputSeq(ascLims(1,1):ascLims(1,2)),...
                        f1,varsPlus);
end
objFuncsMinus = {};
for i=1:size(descLims,1)
    objFuncsMinus{i} = createObjFun(dataHandler.inputSeq(descLims(1,1):descLims(1,2)),...
                        dataHandler.outputSeq(descLims(1,1):descLims(1,2)),...
                        f2,varsMinus);
end
                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

reg0Plus = [5.0,5.0,5.0];
ubPlus = reg0Plus + 40.0 + 0.1*rand(1,3);
lbPlus = reg0Plus - 40.0 - 0.1*rand(1,3);
lbPlus = max([0.12,0.11,0.1],lbPlus);
% [regPlus,fvalPlus,exitflagPlus,outputPlus] = ...
%                 fmincon(@(reg)objFuncRandom(objFuncsPlus,reg),...
%                 reg0Plus,[-1 1 0],[0],[],[],lbPlus,ubPlus,[],fminconOptions)
% [regPlus,fvalPlus,exitflagPlus,outputPlus] = ...
%                 fmincon(@(reg)sumObjFuncs(objFuncsPlus,reg),...
%                 reg0Plus,[-1 1 0],[0],[],[],lbPlus,ubPlus,[],fminconOptions)
% [regPlus,fvalPlus,exitflagPlus,outputPlus] = ...
%                 particleswarm(@(reg)objFuncRandom(objFuncsPlus,reg),...
%                 length(varsPlus),lbPlus,ubPlus,swarmOptions)
[regPlus,fvalPlus,exitflagPlus,outputPlus] = ...
                particleswarm(@(reg)sumObjFuncs(objFuncsPlus,reg),...
                length(varsPlus),lbPlus,ubPlus,swarmOptions)
                        
reg0Minus = [5.0,5.0,5.0];
ubMinus = reg0Minus + 40.0 + 0.1*rand(1,3);
lbMinus = reg0Minus - 40.0 - 0.1*rand(1,3);
lbMinus = max([0.12,0.11,0.1],lbMinus);
% [regMinus,fvalMinus,exitflagMinus,outputMinus] = ...
%                 fmincon(@(reg)objFuncRandom(objFuncsMinus,reg),...
%                 reg0Minus,[-1 1 0],[0],[],[],lbMinus,ubMinus,[],fminconOptions)
% [regMinus,fvalMinus,exitflagMinus,outputMinus] = ...
%                 fmincon(@(reg)sumObjFuncs(objFuncsMinus,reg),...
%                 reg0Minus,[-1 1 0],[0],[],[],lbMinus,ubMinus,[],fminconOptions)
% [regMinus,fvalMinus,exitflagMinus,outputMinus] = ...
%                 particleswarm(@(reg)objFuncRandom(objFuncsMinus,reg),...
%                 length(varsMinus),lbMinus,ubMinus,swarmOptions)
[regMinus,fvalMinus,exitflagMinus,outputMinus] = ...
                particleswarm(@(reg)sumObjFuncs(objFuncsMinus,reg),...
                length(varsMinus),lbMinus,ubMinus,swarmOptions)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function objFunc = createObjFun(uVec,yVec,fHand,vars)
    uVec = uVec(:);
    yVec = yVec(:);
    fVec = [];
    for i=1:length(uVec)
        fVec = [fVec; fHand(uVec(i),yVec(i))];
    end
    objFunc = @(reg) (sum(  (yVec-yVec(1)) - trapzInt(uVec,fVec,vars,reg)  ).^2)...
                                                                /length(uVec);
end

function intfVec = trapzInt(uVec,fVec,vars,reg)
    intfVec = zeros(length(fVec),1);
    fVec = subs(fVec,vars(:),reg(:));
    for i=2:length(fVec)
        intfVec(i) = intfVec(i-1) + trapz(uVec(i-1:i), fVec(i-1:i));
    end
end

function res = sumObjFuncs(objFuncs,reg)
    res = 0;
    for i=1:length(objFuncs)
        res = res + objFuncs{i}(reg);
    end
end

function res = objFuncRandom(objFuncs,reg)
    i = randi(length(objFuncs),1);
    res = objFuncs{i}(reg);
end