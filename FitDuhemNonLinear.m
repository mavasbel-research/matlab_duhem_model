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

% Indexes of the ascending and descending intervals of the input 
ascLims = [1,35;
            99,168;
            234,301;
            366,401];
descLims = [37,97;
            168,234;
            301,366];
% ascLims = [99,169;
%             232,302];
% descLims = [169,232;
%             302,366];
% ascLims = [349,450];
% descLims = [451,549];
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Miller model
paramsLength = 3;
delta = @(params) params(3)*( log((1+params(2)/params(1))/(1-params(2)/params(1))) )^(-1);

% Saturation curves
PsatPlus   = @(E,params)  params(1)*tanh( ( E-params(3))/(2*delta(params)) );
PsatMinus  = @(E,params) -params(1)*tanh( (-E-params(3))/(2*delta(params)) );

% Derivatives of saturation curves
dPsatPlus  = @(E,params) params(1)*( sech(( E-params(3))/(2*delta(params))) ).^2 * (1/(2*delta(params)));
dPsatMinus = @(E,params) params(1)*( sech((-E-params(3))/(2*delta(params))) ).^2 * (1/(2*delta(params)));

% Gamma term
GammaPlus  = @(E,Pd,params) 1 - (tanh(  (( (Pd -  PsatPlus(E,params))./( params(1)-Pd ) )).^(1/2)  ));
GammaMinus = @(E,Pd,params) 1 - (tanh(  (( (Pd - PsatMinus(E,params))./(-params(1)-Pd ) )).^(1/2)  ));

% Model f1Params & f2Params functions
f1Params = @(u,y,params)  abs(GammaPlus(u,y,params) .* dPsatPlus(u,params));
f2Params = @(u,y,params) abs(GammaMinus(u,y,params) .* dPsatMinus(u,params));

% Create miller model nonlinear constraint functions
argGammaPlus =  @(E,Pd,params) ( (Pd -  PsatPlus(E,params))./( params(1)-Pd ) );
argGammaMinus = @(E,Pd,params) ( (Pd - PsatMinus(E,params))./(-params(1)-Pd ) );
nonLinConst = {};
constSize = length(nonLinConst);
for i=1:size(ascLims,1)
    nonLinConst{i+constSize} = ...
        @(params)-argGammaPlus(...
                        dataHandler.inputSeq(ascLims(i,1):ascLims(i,2)),...
                        dataHandler.outputSeq(ascLims(i,1):ascLims(i,2)),...
                        params);
end
constSize = length(nonLinConst);
for i=1:size(descLims,1)
    nonLinConst{i+constSize} = ...
        @(params)-argGammaMinus(...
                        dataHandler.inputSeq(descLims(i,1):descLims(i,2)),...
                        dataHandler.outputSeq(descLims(i,1):descLims(i,2)),...
                        params);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Asymmetric Miller model
% paramsLength = 6;
% % PsPlus  = params(1); PrPlus  = params(2); EcPlus  = params(3);
% % PsMinus = params(4); PrMinus = params(5); EcMinus = params(6);
% 
% % Delta parameter
% deltaPlus =  @(params) params(3)*( log((1+params(2)/params(1))/(1-params(2)/params(1))) )^(-1);
% deltaMinus = @(params) params(6)*( log((1+params(5)/params(4))/(1-params(5)/params(4))) )^(-1);
% 
% % Saturation curves
% PsatPlus   = @(E,params)  params(1)*tanh( ( E-params(3))/(2*deltaPlus(params) ) );
% PsatMinus  = @(E,params) -params(4)*tanh( (-E-params(6))/(2*deltaMinus(params)) );
% 
% % Derivatives of saturation curves
% dPsatPlus  = @(E,params) params(1)*( sech(( E-params(3))/(2*deltaPlus(params)))  ).^2 * (1/(2*deltaPlus(params)) );
% dPsatMinus = @(E,params) params(4)*( sech((-E-params(6))/(2*deltaMinus(params))) ).^2 * (1/(2*deltaMinus(params)));
% 
% % Gamma term
% GammaPlus  = @(E,Pd,params) 1 - (tanh(  (( (Pd -  PsatPlus(E,params))./( params(1)-Pd ) )).^(1/2)  ));
% GammaMinus = @(E,Pd,params) 1 - (tanh(  (( (Pd - PsatMinus(E,params))./(-params(4)-Pd ) )).^(1/2)  ));
% 
% % Duhem model f1Params & f2Params functions
% f1Params = @(u,x,params)  abs(GammaPlus(u,x,params) .* dPsatPlus(u,params));
% f2Params = @(u,x,params) abs(GammaMinus(u,x,params) .* dPsatMinus(u,params));
% 
% % Create miller model nonlinear constraint functions
% argGammaPlus =  @(E,Pd,params) ( (Pd -  PsatPlus(E,params))./( params(1)-Pd ) );
% argGammaMinus = @(E,Pd,params) ( (Pd - PsatMinus(E,params))./(-params(4)-Pd ) );
% nonLinConst = {};
% constSize = length(nonLinConst);
% for i=1:size(ascLims,1)
%     nonLinConst{i+constSize} = ...
%         @(params)-argGammaPlus(...
%                         dataHandler.inputSeq(ascLims(i,1):ascLims(i,2)),...
%                         dataHandler.outputSeq(ascLims(i,1):ascLims(i,2)),...
%                         params);
% end
% constSize = length(nonLinConst);
% for i=1:size(descLims,1)
%     nonLinConst{i+constSize} = ...
%         @(params)-argGammaMinus(...
%                         dataHandler.inputSeq(descLims(i,1):descLims(i,2)),...
%                         dataHandler.outputSeq(descLims(i,1):descLims(i,2)),...
%                         params);
% end
                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Bouc-wen
% bw_n = 3;
% bw_eta = 1;
% paramsLength = 3;
% f1Params = @(u,x,params) bw_eta*(params(1) - params(2)*abs(x)^bw_n - params(3)*x*abs(x)^(bw_n-1));
% f2Params = @(u,x,params) bw_eta*(params(1) - params(2)*abs(x)^bw_n + params(3)*x*abs(x)^(bw_n-1));
% nonLinConst = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Polynomial of 5th grade
% paramsLength = 10;
% f1Params = @(u,x,params)   ( params(1) + params(2)*u + params(3)*u^2 + params(4)*u^3 +  params(5)*u^4 - x );
% f2Params = @(u,x,params) - ( params(6) + params(7)*u + params(8)*u^2 + params(9)*u^3 + params(10)*u^4 - x );
% nonLinConst = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create objective functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

objFuncs = {};
objSize = length(objFuncs);
for i=1:size(ascLims,1)
    objFuncs{i+objSize} = ...
        @(params)compSumSqrError(...
                        dataHandler.inputSeq(ascLims(i,1):ascLims(i,2)),...
                        dataHandler.outputSeq(ascLims(i,1):ascLims(i,2)),...
                        f1Params,params);
end
objSize = length(objFuncs);
for i=1:size(descLims,1)
    objFuncs{i+objSize} = ...
        @(params)compSumSqrError(...
                        dataHandler.inputSeq(descLims(i,1):descLims(i,2)),...
                        dataHandler.outputSeq(descLims(i,1):descLims(i,2)),...
                        f2Params,params);
end
objSize = length(objFuncs);
objFuncs{1+objSize} = @(params) params'*(0.01*eye(paramsLength))*params;
% objFuncs{1+objSize} = @(params) params'*(0.1*diag([1,1,1,1,1,1]))*params;
% objFuncs{2+objSize} = @(params) (params(1:paramsLength/2)-params(paramsLength/2+1:paramsLength))'...
%                                *(0.1*eye(paramsLength/2))...
%                                *(params(1:paramsLength/2)-params(paramsLength/2+1:paramsLength));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optimizer parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fminconOptions = optimoptions('fmincon',...
                    'Algorithm','interior-point',...
                    'ConstraintTolerance',1.0000e-12,...
                    'OptimalityTolerance',1.0000e-12,...
                    'StepTolerance',1.0000e-12,...
                    'FunctionTolerance',1.0000e-12,...
                    'MaxFunctionEvaluations',15.0000e+3,...
                    'MaxIterations',3.0000e+3,...
                    'FiniteDifferenceType','central',...
                    'FiniteDifferenceStepSize',eps^(1/2),...
                    'Display','iter-detailed',...
                    'PlotFcn','optimplotfvalconstr',...
                    'UseParallel',true);

swarmOptions = optimoptions('particleswarm',...                   
                    'SwarmSize',100,...
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

% Initial parameters
% params0 = 5*rand(paramsLength,1)+2;
params0 = [35;29;20]*10 + 10*rand(paramsLength,1);
% params0 = [35;29;20;35;29;20] + 5*rand(paramsLength,1);
% params0 = [1897;1800;2000];
% params0 = [1897;1800;2000;1897;1800;2000];

% Upper and lower bounds for the parameters
ub = 5000.0 + 0.1*rand(paramsLength,1);
lb = -5000.0 - 0.1*rand(paramsLength,1);
% lb = zeros(paramsLength,1) + 0.1*rand(paramsLength,1);

% Optimization with constraints
% [params,fval,exitflag,output] = fmincon(...
%                 @(params)objFuncRandom(objFuncs,params),...
%                 params0,...
%                 zeros(1,paramsLength),...
%                 [0],...
%                 [],[],lb,ub,...
%                 @(params)evalConstFuncs(nonLinConst,params),...
%                 fminconOptions)
[params,fval,exitflag,output] = fmincon(...
                @(params)sumObjFuncs(objFuncs,params),...
                params0,...
                zeros(1,paramsLength),...
                [0],[],[],lb,ub,...
                @(params)evalConstFuncs(nonLinConst,params),...
                fminconOptions)

% Optimization without constraints
% [params,fval,exitflag,output] = fmincon(@(params)objFuncRandom(objFuncs,params),...
%                 params0,[],[],[],[],lb,ub,[],fminconOptions)
% [params,fval,exitflag,output] = fmincon(@(params)sumObjFuncs(objFuncs,params),...
%                 params0,[],[],[],[],lb,ub,[],fminconOptions)

% Optimization with particle swarm
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
    
%     fVec = [fHand(uVec(1),yVec(1),params); zeros(length(uVec)-1,1)];
%     FVec = zeros(length(uVec),1);
%     for i=2:length(uVec)
%         fVec(i) = fHand(uVec(i),yVec(i),params);
%         FVec(i) = FVec(i-1) + trapz(uVec(i-1:i), fVec(i-1:i));
%     end
    
    fVec = fHand(uVec,yVec,params);
    FVec = cumtrapz(uVec, fVec);
    
    error = sum(  ((yVec-(FVec+yVec(1))).^2)  );
end

function res = sumObjFuncs(objFuncs,params)
    res = 0;
    for j=1:length(objFuncs)
        res = res + objFuncs{j}(params);
    end
end

function res = objFuncRandom(objFuncs,params)
    j = randi(length(objFuncs),1);
    res = objFuncs{j}(params);
end

function [cons,ceq] = evalConstFuncs(constFuncs,params)
    cons = [];
    for j=1:length(constFuncs)
        temp = constFuncs{j}(params);
        cons = [cons; temp(:)];
    end
	ceq = [];
end