% clear all
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Adjust data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% scaleInput = 5;
% scaleOutput = 5;
% dataHandler.resetOrigSequences();
% dataHandler.zeroMeanInput();
% dataHandler.zeroMeanOutput();
% dataHandler.normalizeInput(scaleInput);
% dataHandler.normalizeOutput(scaleOutput);

fitPlotter = FitPlotter();
% fitPlotter.subfigInput(1:dataHandler.origSampleLength, dataHandler.origInputSeq, 'Original Input', 'r');
% fitPlotter.subfigOutput(1:dataHandler.origSampleLength, dataHandler.origOutputSeq, 'Original Output', 'r');
fitPlotter.subfigInput(dataHandler.indexesSeq, dataHandler.inputSeq, 'Adjusted Input', 'b');
fitPlotter.subfigOutput(dataHandler.indexesSeq, dataHandler.outputSeq, 'Adjusted Output', 'b');
% fitPlotter.figLoop(dataHandler.origInputSeq, dataHandler.origOutputSeq, 'Original data', 'r');
fitPlotter.figLoop(dataHandler.inputSeq, dataHandler.outputSeq, 'Adjusted data', 'b');
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
% GammaPlus  = @(E,Pd) 1 - tanh(  (  abs((Pd -  PsatPlus(E))/( Ps-Pd ))  ).^(1/2)  );
% GammaMinus = @(E,Pd) 1 - tanh(  (  abs((Pd - PsatMinus(E))/(-Ps-Pd ))  ).^(1/2)  );
GammaPlus  = @(E,Pd) 1 - tanh(  ( (Pd -  PsatPlus(E))/( Ps-Pd ) )  );
GammaMinus = @(E,Pd) 1 - tanh(  ( (Pd - PsatMinus(E))/(-Ps-Pd ) )  );

% Duhem model f1 & f2 functions
f1 = @(u,y)  GammaPlus(u,y) * dPsatPlus(u);
f2 = @(u,y) GammaMinus(u,y) * dPsatMinus(u);

% Compute symbolic integrals
% syms uSym ySym real
% symIntf1 = int(f1(uSym,ySym),uSym);
% symIntf2 = int(f2(uSym,ySym),uSym);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Classic Duhem Model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bw_alpha = 10.0;
bw_beta = 2.0;
bw_zeta = -1;

bw_n = 3;
bw_eta = 1;
syms bw_alpha positive
syms bw_beta positive
syms bw_zeta positive
vars = [bw_alpha;bw_beta;bw_zeta];

f1 = @(u,x) bw_eta*(bw_alpha - bw_beta*abs(x)^bw_n - bw_zeta*x*abs(x)^(bw_n-1));
f2 = @(u,x) bw_eta*(bw_alpha - bw_beta*abs(x)^bw_n + bw_zeta*x*abs(x)^(bw_n-1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% ascLims = [1,35;
%             100,169;
%             235,300];
% descLims = [38,98;
%             172,230;
%             302,360];

ascLims = [235,300];
descLims = [302,360];

objFuncs = {};
for i=1:size(ascLims,1)
    objFuncs{i} = createObjFun(dataHandler.inputSeq(ascLims(1,1):ascLims(1,2)),...
                        dataHandler.outputSeq(ascLims(1,1):ascLims(1,2)),...
                        f1,vars);
end
for i=1+size(ascLims,1):size(descLims,1)+size(ascLims,1)
    objFuncs{i} = createObjFun(dataHandler.inputSeq(descLims(1,1):descLims(1,2)),...
                        dataHandler.outputSeq(descLims(1,1):descLims(1,2)),...
                        f2,vars);
end
                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reg0 = [8.3629    7.0728    2.4571];
reg0 = reg;
ub = reg0 + 10.0 + 0.1*rand(1,3);
lb = reg0 - 10.0 - 0.1*rand(1,3);

lb = max([0.12,0.11,0.1]-0.00*rand(1,3),lb);
% [reg,fval,exitflag,output] = fmincon(@(reg)objFuncRandom(objFuncs,reg),...
%                 reg0,[-1 1 0],[0],[],[],lb,ub,[],fminconOptions)
% [reg,fval,exitflag,output] = fmincon(@(reg)objFuncRandom(sumObjFuncs,reg),...
%                 reg0,[-1 1 0],[0],[],[],lb,ub,[],fminconOptions)
% [reg,fval,exitflag,output] = particleswarm(@(reg)objFuncRandom(objFuncs,reg),...
%                             length(vars),lb,ub,swarmOptions)
[reg,fval,exitflag,output] = particleswarm(@(reg)sumObjFuncs(objFuncs,reg),...
                            length(vars),lb,ub,swarmOptions)

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