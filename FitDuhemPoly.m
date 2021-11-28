close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Adjust data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% scaleInput = 10;
% scaleOutput = 10;
% dataHandler.resetOrigSequences();
% dataHandler.normalizeInput(scaleInput);
% dataHandler.normalizeOutput(scaleOutput);
% dataHandler.trimFirstSecondMaxInput();
% dataHandler.maxInputPeakIdx
% dataHandler.minInputPeakIdx
% dataHandler.sampleLength

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uGridSize = 800;
yGridSize = 800;
uPad = 0.1; 
yPad = 0.2;
uMin = dataHandler.inputMin;
uMax = dataHandler.inputMax;
yMin = dataHandler.outputMin;
yMax = dataHandler.outputMax;
yRange = yMax-yMin;
uRange = uMax-uMin;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fitting parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f1PolyDeg = 5;
f2PolyDeg = 5;
f1RegTerm = 0.0*eye(f1PolyDeg+1);
f2RegTerm = 0.0*eye(f2PolyDeg+1);
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fit f1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f1IntUMat = [];
f1IntYVec = [];

% idx0 = 3001;
% idx1 = 4000;
% idx0 = dataHandler.minInputPeakIdx;
% idx1 = dataHandler.sampleLength;
% idx0 = 98;
% idx1 = 169;
idx0 = 99;
idx1 = 169;
% idx0 = 1424;
% idx1 = 1577;
for idx=idx0+1:idx1
    f1IntURow = buildUMatRow(dataHandler.inputSeq(idx0:idx),f1PolyDeg);
    f1IntYasc = trapz(dataHandler.inputSeq(idx0:idx),...
                            dataHandler.outputSeq(idx0:idx));
    f1IntUMat = [f1IntUMat; f1IntURow];
    f1IntYVec = [f1IntYVec; f1IntYasc];
end
objFunc1 = @(regressor)...
                sum( ...
                    ( f1IntUMat*regressor(:) - f1IntYVec(:)...
                        - ( dataHandler.outputSeq(idx0+1:idx1)...
                            - dataHandler.outputSeq(idx0+1) )...
                    ).^2 ...
                ) + sum( (f1RegTerm*regressor(:)).^2 ) ;
f1Regressor = inv(f1IntUMat'*f1IntUMat + f1RegTerm)*f1IntUMat'...
                *( dataHandler.outputSeq(idx0+1:idx1)...
                            - dataHandler.outputSeq(idx0+1)...
                            + f1IntYVec(:) );
error1 = objFunc1(f1Regressor)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fit f2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f2IntUMat = [];
f2IntYVec = [];

% idx0 = 2001;
% idx1 = 3000;
% idx0 = 1;
% idx1 = dataHandler.minInputPeakIdx;
% idx0 = 169;
% idx1 = 234;
idx0 = 169;
idx1 = 233;
% idx0 = 1577;
% idx1 = 1724;
for idx=idx0+1:idx1
    f2IntURow = buildUMatRow(dataHandler.inputSeq(idx0:idx),f2PolyDeg);
    f2IntYdes = trapz(dataHandler.inputSeq(idx0:idx),...
                            dataHandler.outputSeq(idx0:idx));
    f2IntUMat = [f2IntUMat; f2IntURow];
    f2IntYVec = [f2IntYVec; f2IntYdes];
end
objFunc2 = @(regressor)...
                sum( ...
                    ( - f2IntUMat*regressor(:) + f2IntYVec(:)...
                        - ( dataHandler.outputSeq(idx0+1:idx1)...
                            - dataHandler.outputSeq(idx0+1) )...
                    ).^2 ...
                ) + sum( (f2RegTerm*regressor(:)).^2 ) ;
f2Regressor = - inv(f2IntUMat'*f2IntUMat + f2RegTerm)*f2IntUMat'...
                *( dataHandler.outputSeq(idx0+1:idx1)...
                            - dataHandler.outputSeq(idx0+1)...
                            - f2IntYVec(:) );
error2 = objFunc2(f2Regressor)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot level sets f1=0 and f2=0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xyCenter = [(uMax+uMin)/2, (yMax+yMin)/2];
evalLim = [uMin,uMax];
samples = 1000;

uVals = linspace(evalLim(1),evalLim(2),samples)';
yVals = 0;
for n=0:f1PolyDeg
    yVals = yVals + uVals.^n*f1Regressor(n+1);
end
curve1 = [uVals,yVals];

uVals = linspace(evalLim(1),evalLim(2),samples)';
yVals = 0;
for n=0:f2PolyDeg
    yVals = yVals + uVals.^n*f2Regressor(n+1);
end
curve2 = [uVals,yVals];

figure();
axHandler = axes(); hold on;
plot(axHandler,dataHandler.inputSeq,dataHandler.outputSeq,'g',...
    'lineWidth',1.2,...
    'DisplayName','Experimental Data');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Anhysteresis function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
distanceFunc = @ButterflyUtils.verticalDistance;

plot(axHandler,curve1(:,1),curve1(:,2),...
    'r','DisplayName','$f_1(u,y)=0$',...
    'LineWidth',1.2); hold on;
f1 = @(u,x)-distanceFunc([u,x],curve1);

plot(axHandler,curve2(:,1),curve2(:,2),'b',...
    'DisplayName','$f_2(u,y)=0$',...
    'LineWidth',1.2); hold on;
f2 = @(u,x)distanceFunc([u,x],curve2);

duhemModel = DuhemModel(f1,f2); % Create duhem model
[anHystCurves, avgHystCurves] = ...
    DuhemModel.findAnhysteresisCurve(duhemModel,[uMin,uMax],uGridSize,[yMin,yMax],yGridSize);
for i=1:size(anHystCurves,2) % Plot anhysteresis curve
    lineHandler = plot(axHandler,...
        anHystCurves{i}(:,1),anHystCurves{i}(:,2),...
        'Color','k',...
        'LineWidth',1.2,...
        'LineStyle','--',...
        'DisplayName','Anhysteresis curve $\mathcal{A}$'); hold on;
%         'DisplayName','$f_1-f_2=0$' ); hold on;
    if(i>1) set(lineHandler,'handleVisibility','off'); end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xlim([uMin-uRange*uPad uMax+uRange*uPad]);
ylim([yMin-yRange*yPad yMax+yRange*yPad]);

% leg = legend(...
%     'Interpreter','latex',...
%     'Location','southeast');
leg = legend(...
    'Interpreter','latex',...
    'Location','northeast');
xlabel('$u$','Interpreter','latex');
ylabel('$y$','Interpreter','latex');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function UMatRow = buildUMatRow(uVec,polyDeg)
    uVec = uVec(:);
    UMatRow = [];
    for n=0:polyDeg
        UVecPow = uVec.^n ;
        UMatRow = [UMatRow, trapz(uVec,UVecPow)];
    end
end
