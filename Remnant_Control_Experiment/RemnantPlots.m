close all
clc

lineWidth = 1.2;
markerSize = 8;
iter = length(remnants)-2;
% iter = 70;

% figure
% plotHandler = plot(dataHandler.inputSeq/inputInvScale, dataHandler.outputSeq/outputInvScale,...
%     '-b','linewidth',lineWidth); hold on;
% xlim([-1600 1600])
% ylim([-5 25])
% xticks([-1400 -700 0 700 1400])
% % yticks([-600 -300 0 300 600 900 1200])
% xlabel('$V$','Interpreter','latex')
% ylabel('$nm$','Interpreter','latex')
% 
% % Plot initial and final points in phase plot
% plot(0,x0,'or',...
%     'LineWidth',lineWidth,...
%     'markerSize',markerSize-2)
% plot(0,ref,'xr',...
%     'LineWidth',lineWidth,...
%     'markerSize',markerSize)
% 
% for i=1:iter
%     plot(inputs(:,i),outputs(:,i),'--b',...
%         'LineWidth',lineWidth*0.85);
% end

% DataPlotter.plotWeightFunc(baseModel.weightFunc, baseModel.inputGrid);
% xlabel('$\beta$','Interpreter','latex')
% ylabel('$\alpha$','Interpreter','latex')
% maxZ = max(max(baseModel.weightFunc));
% plotRectangle([0,0;
%     -850,0;
%     -850,1350;
%     0,1350;
%     0,0], maxZ, QLinePoints, QLineWidth);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure();
plotHandler = plot(dataHandlerSim.inputSeq, dataHandlerSim.outputSeq,...
    '-b','linewidth',lineWidth,...
    'DisplayName','Miller model'); hold on;
xlim([-2200 2200])
ylim([-35 80])
xticks([-2100 -1400 -700 0 700 1400 2100])
% yticks([-600 -300 0 300 600 900 1200])
xlabel('$V$','Interpreter','latex')
ylabel("$P\ \ \ (\frac{\mu C}{{cm}^2})$",'Interpreter','latex')

uSat = linspace(-2500,2500,50);
plot(uSat,outputInvTrans(PsatPlus(inputTrans(uSat))),...
    '--r',...    'Color',[150,0,0]/255,...
    'LineWidth',1.2,...
    'DisplayName','$P_{sat}^+$',...
    'HandleVisibility','on');
plot(uSat,outputInvTrans(PsatMinus(inputTrans(uSat))),...
    '--b',...    'Color',[0,0,120]/255,...
    'LineWidth',1.2,...
    'DisplayName','$P_{sat}^-$',...
    'HandleVisibility','on');
for i=1:size(anHystCurves,2) % Plot anhysteresis curve
    lineHandler = plot(anHystCurves{i}(:,1),anHystCurves{i}(:,2),...
        'Color','k',...
        'LineWidth',1.0,...
        'LineStyle','--',...
        'DisplayName','Anhysteresis curve $\mathcal{A}$'); hold on;
    if(i>1) set(lineHandler,'handleVisibility','off'); end
end

leg = legend(...
    'Interpreter','latex',...
    'Location','northeast');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
subplot(3,1,1)
stem(linspace(0,iter,iter+1), inputAmps(1:iter+1), ...
    '-b', 'LineWidth', lineWidth); hold on;
% xlabel('$k$', 'Interpreter', 'Latex');
ylabel('$w_k$', 'Interpreter', 'Latex');
xlim([0,iter]);
ylim([min(inputAmps)-80, max(inputAmps)+100]);

subplot(3,1,2)
stem(linspace(0,iter,iter+1), remnants(1:iter+1), ...
    '-b', 'LineWidth', lineWidth); hold on;
plot(linspace(0,iter,1000), linspace(ref,ref,1000), ...
    '--k', 'LineWidth', lineWidth);
% xlabel('$k$', 'Interpreter', 'Latex');
ylabel('$\gamma(w_k,I_k)$', 'Interpreter', 'Latex');
xlim([0,iter]);
ylim([min(remnants)-2, max(remnants)+2]);

subplot(3,1,3)
stem(linspace(0,iter,iter+1), errors(1:iter+1), ...
    '-b', 'LineWidth', lineWidth); hold on;
xlabel('$k$', 'Interpreter', 'Latex');
ylabel('$\varepsilon_k$', 'Interpreter', 'Latex');
xlim([0,iter]);
ylim([min(errors)-1, max(errors)+3]);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

extraIter = 2;
timeVals = [linspace(0,(iter+extraIter),(iter+extraIter)*inputSamples)]';
inputVals = [reshape(inputs(:,1:iter),iter*inputSamples,1);...
    zeros(inputSamples*extraIter,1)];
outputsVals = [reshape(outputs(:,1:iter),iter*inputSamples,1);...
    outputs(end,iter)*ones(inputSamples*extraIter,1)];

figure
subplot(3,1,1)
plot(timeVals, inputVals, '-b', 'LineWidth', lineWidth); hold on;
plot(linspace(0,iter-1,iter)+0.5, inputAmps(1:iter),'or',...
    'LineWidth', lineWidth,...
    'MarkerSize', markerSize-3);
xlabel('$t$', 'Interpreter', 'Latex');
ylabel('$u_\gamma$', 'Interpreter', 'Latex');
xlim([0,iter+extraIter]);
ylim([min(inputAmps)-80, max(inputAmps)+100]);

subplot(3,1,2)
plot(timeVals, outputsVals, '-b', 'LineWidth', lineWidth); hold on;
plot(linspace(0,iter+1,1000), linspace(ref,ref,1000), '--k', ...
    'LineWidth', lineWidth);
plot(linspace(0,iter,iter+1), remnants(1:iter+1),'or',...
    'LineWidth', lineWidth,...
    'MarkerSize', markerSize-3);
xlabel('$t$', 'Interpreter', 'Latex');
ylabel('$\mathcal{D}(u_\gamma,y_0)$', 'Interpreter', 'Latex');
xlim([0,iter+extraIter]);
ylim([min(outputsVals)-2, max(outputsVals)+2]);

subplot(3,1,3)
stem(linspace(0,iter,iter+1), errors(1:iter+1), 'ob',...
    'MarkerEdgeColor', 'r',...
    'MarkerSize', markerSize-3,...
    'LineWidth', lineWidth); hold on;
xlabel('$k$', 'Interpreter', 'Latex');
ylabel('$\varepsilon_k$', 'Interpreter', 'Latex');
xlim([0,iter+extraIter]);
ylim([min(errors)-1, max(errors)+3]);