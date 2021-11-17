% clear all
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Adjust data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fitPlotter = FitPlotter();
% fitPlotter.subfigInput(1:dataHandler.origSampleLength, dataHandler.origInputSeq, 'Original Input', 'r');
% fitPlotter.subfigOutput(1:dataHandler.origSampleLength, dataHandler.origOutputSeq, 'Original Output', 'r');
fitPlotter.subfigInput(dataHandler.indexesSeq, dataHandler.inputSeq, 'Adjusted Input', 'b');
fitPlotter.subfigOutput(dataHandler.indexesSeq, dataHandler.outputSeq, 'Adjusted Output', 'b');
% fitPlotter.figLoop(dataHandler.origInputSeq, dataHandler.origOutputSeq, 'Original data', 'r');
fitPlotter.figLoop(dataHandler.inputSeq, dataHandler.outputSeq, 'Adjusted data', 'b');
drawnow;

% ascLims = [1,35;
%             99,168;
%             234,301;
%             366,401];
% descLims = [37,97;
%             168,234;
%             301,366];

ascLims = [99,169;
            232,302];
descLims = [169,232;
            302,366];
   
% ascLims = [349,450];
% descLims = [451,549];
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Miller model
paramsLength = 3;
delta = @(params) params(3)*( log((1+params(2)/params(1))/(1-params(2)/params(1))) )^(-1);

% Saturation curves
PsatPlus   = @(E,params)  params(1)*tanh(( E-params(3))/(2*delta(params)));
PsatMinus  = @(E,params) -params(1)*tanh((-E-params(3))/(2*delta(params)));

% Derivatives of saturation curves
dPsatPlus  = @(E,params) params(1)*( sech(( E-params(3))/(2*delta(params))) ).^2 * (1/(2*delta(params)));
dPsatMinus = @(E,params) params(1)*( sech((-E-params(3))/(2*delta(params))) ).^2 * (1/(2*delta(params)));

% Gamma term
GammaPlus  = @(E,Pd,params) 1 - tanh(  ( (Pd -  PsatPlus(E,params))/( params(1)-Pd ) ).^(1/2)  );
GammaMinus = @(E,Pd,params) 1 - tanh(  ( (Pd - PsatMinus(E,params))/(-params(1)-Pd ) ).^(1/2)  );

% Model f1 & f2 functions
f1 = @(u,y,params)  GammaPlus(u,y,params) * dPsatPlus(u,params);
f2 = @(u,y,params) GammaMinus(u,y,params) * dPsatMinus(u,params);

% Create miller model nonlinear constraint functions
dPSatPlusSech = @(E,params) sech(( E-params(3))/(2*delta(params)));
dPSatMinusSech = @(E,params) sech((-E-params(3))/(2*delta(params)));
nonLinConst = {};
for i=1:size(ascLims,1)
    nonLinConst{i} = ...
        @(params)-dPSatPlusSech(...
                        dataHandler.inputSeq(ascLims(i,1):ascLims(i,2)),...
                        params);
end
for i=1:size(descLims,1)
    nonLinConst{i+size(ascLims,1)} = ...
        @(params)-dPSatMinusSech(...
                        dataHandler.inputSeq(descLims(i,1):descLims(i,2)),...
                        params);
end
                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Bouc-wen
% bw_n = 3;
% bw_eta = 1;
% paramsLength = 3;
% f1 = @(u,x,params) bw_eta*(params(1) - params(2)*abs(x)^bw_n - params(3)*x*abs(x)^(bw_n-1));
% f2 = @(u,x,params) bw_eta*(params(1) - params(2)*abs(x)^bw_n + params(3)*x*abs(x)^(bw_n-1));
% nonLinConst = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Polynomial of 5th grade
% paramsLength = 10;
% f1 = @(u,x,params)   ( params(1) + params(2)*u + params(3)*u^2 + params(4)*u^3 +  params(5)*u^4 - x );
% f2 = @(u,x,params) - ( params(6) + params(7)*u + params(8)*u^2 + params(9)*u^3 + params(10)*u^4 - x );
% nonLinConst = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create objective functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

objFuncs = {};
nonLinConst = {};
for i=1:size(ascLims,1)
    objFuncs{i} = ...
        @(params)compSumSqrError(...
                        dataHandler.inputSeq(ascLims(i,1):ascLims(i,2)),...
                        dataHandler.outputSeq(ascLims(i,1):ascLims(i,2)),...
                        f1,params);
end
for i=1:size(descLims,1)
    objFuncs{i+size(ascLims,1)} = ...
        @(params)compSumSqrError(...
                        dataHandler.inputSeq(descLims(i,1):descLims(i,2)),...
                        dataHandler.outputSeq(descLims(i,1):descLims(i,2)),...
                        f2,params);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optimizer parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fminconOptions = optimoptions('fmincon',...
                    'Algorithm','interior-point',...
                    'StepTolerance',1.0000e-200,...
                    'FunctionTolerance',1.0000e-50,...
                    'OptimalityTolerance',1.0000e-50,...
                    'ConstraintTolerance',1.0000e-50,...
                    'FiniteDifferenceType','central',...
                    'FiniteDifferenceStepSize',eps^(1/2),...
                    'MaxFunctionEvaluations',1.0000e+5,...
                    'MaxIterations',1.0000e+5,...
                    'Display','iter-detailed',...
                    'PlotFcn','optimplotfvalconstr',...
                    'UseParallel',true);

swarmOptions = optimoptions('particleswarm',...                   
                    'SwarmSize',50,...
                    'MaxIterations',2000,...
                    'MaxStallIterations',100,...
                    'MaxStallTime',Inf,...
                    'MaxTime',Inf,...
                    'Display','iter',...
                    'PlotFcn','pswplotbestf',...
                    'UseParallel',true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% params0 = rand(paramsLength,1)+2;
params0 = [30;29;20];
% params0 = params + 20*rand(paramsLength,1);
ub = params0 + 100.0 + 0.1*rand(paramsLength,1);
lb = zeros(paramsLength,1) + 0.1*rand(paramsLength,1);

% [params,fval,exitflag,output] = fmincon(@(params)objFuncRandom(objFuncs,params),...
%                 params0,...
%                 [-1 1 0],...
%                 [0],...
%                 [],[],lb,ub,...
%                 @(params)evalConstFuncs(nonLinConst,params),...
%                 fminconOptions)
[params,fval,exitflag,output] = fmincon(@(params)sumObjFuncs(objFuncs,params),...
                params0,...
                [-1 1 0],...
                [0],[],[],lb,ub,...
                @(params)evalConstFuncs(nonLinConst,params),...
                fminconOptions)

% [params,fval,exitflag,output] = fmincon(@(params)objFuncRandom(objFuncs,params),...
%                 params0,[],[],[],[],lb,ub,[],fminconOptions)
% [params,fval,exitflag,output] = fmincon(@(params)sumObjFuncs(objFuncs,params),...
%                 params0,[],[],[],[],lb,ub,[],fminconOptions)

% [params,fval,exitflag,output] = particleswarm(@(params)objFuncRandom(objFuncs,params),...
%                             paramsLength,lb,ub,swarmOptions)
% [params,fval,exitflag,output] = particleswarm(@(params)sumObjFuncs(objFuncs,params),...
%                             paramsLength,lb,ub,swarmOptions)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Auxiliary functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function error = compSumSqrError(uVec,yVec,fHand,params)
    uVec = uVec(:);
    yVec = yVec(:);
    params = params(:);
    fVec = zeros(length(uVec),1);
    FVec = zeros(length(uVec),1);
    
    fVec(1) = fHand(uVec(1),yVec(1),params);
    for i=2:length(uVec)
        fVec(i) = fHand(uVec(i),yVec(i),params);
        FVec(i) = FVec(i-1) + trapz(uVec(i-1:i), fVec(i-1:i));
    end
    
    error = sum(  ((yVec-(FVec+yVec(1))).^2)  );
end

function res = sumObjFuncs(objFuncs,params)
    res = 0;
    for i=1:length(objFuncs)
        res = res + objFuncs{i}(params);
    end
end

function res = objFuncRandom(objFuncs,params)
    i = randi(length(objFuncs),1);
    res = objFuncs{i}(params);
end

function [cons,ceq] = evalConstFuncs(constFuncs,params)
    cons = [];
    for i=1:length(constFuncs)
        temp = constFuncs{i}(params);
        cons = [cons; temp(:)];
    end
	ceq = [];
end