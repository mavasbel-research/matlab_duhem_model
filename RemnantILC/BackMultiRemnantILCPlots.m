close all

% iters = iteration;
iters = 12;

totalSampleSeries = iters*inputSamples*(totalPreisachs+1);
xLinVals = 1:totalSampleSeries;
lineWidth = 1.2;
markerSize = 4;
refLineWidth = 0.60;
resetColor = "b";
selectedColor = "r";
coupledColor = "k";

stepSize = 5;
iterBeginIdx = [0: inputSamples*(totalPreisachs+1): iters*inputSamples*(totalPreisachs+1) ];
iterNumStr = cellstr(string([1:iters]));
ticksVals = iterBeginIdx(1:stepSize:end);
ticksLabels = iterNumStr(1:stepSize:end);


inputColorSeries = [];
outputColorSeries = [];
for ii=1:iters
    inputColorSeries = cat(1,inputColorSeries,repmat(resetColor,1,totalPreisachs));
    outputColorSeries = cat(1,outputColorSeries,repmat(resetColor,1,totalPreisachs));
    
    [~,sortedColorIdx] = sort(sortSeries(ii,:));
    for jj=1:totalPreisachs
        inputColorSeries = cat(1,inputColorSeries,repmat(coupledColor,1,totalPreisachs));
        outputColorSeries = cat(1,outputColorSeries,repmat(coupledColor,1,totalPreisachs));
        inputColorSeries(end,sortedColorIdx(jj)) = selectedColor;
        outputColorSeries(end,sortedColorIdx(jj)) = selectedColor;
    end
end


figure(1)
for ii=1:totalPreisachs
    subplot(totalPreisachs,1,ii); hold on;
%     plot(xLinVals,inputSeries(:,ii),'-b','LineWidth',lineWidth);
    for jj=1:iters*(totalPreisachs+1)
        plot(xLinVals((jj-1)*inputSamples+1:jj*inputSamples),...
            inputSeries((jj-1)*inputSamples+1:jj*inputSamples,ii),...
            strcat('-',inputColorSeries(jj,ii)),...
            'LineWidth',lineWidth);
    end
    for jj=1:iters
        idx = (iterBeginIdx(jj))...
            +inputSamples...
            +inputSamples*(find(sortSeries(jj,:)==ii)-1)...
            +floor(inputSamples/2)-30;
        plot(idx,inputSeries(idx,ii),...
            'o','color',selectedColor,...
            'LineWidth',lineWidth,...
            'markerSize',markerSize); hold on;
    end
    xticks(ticksVals);
    xticklabels(ticksLabels);
    ylabel(strcat('$u_',string(ii),'$'),'Interpreter','Latex');
    xlim([1,totalSampleSeries]);
end
xlabel('Iteration','Interpreter','Latex');


figure(2)
for ii=1:totalPreisachs
    subplot(totalPreisachs,1,ii); hold on;
    for jj=1:iters*(totalPreisachs+1)
        plot(xLinVals((jj-1)*inputSamples+1:jj*inputSamples),...
            outputSeries((jj-1)*inputSamples+1:jj*inputSamples,ii),...
            strcat('-',outputColorSeries(jj,ii)),...
            'LineWidth',lineWidth);
    end
    for jj=1:iters
        idx = (iterBeginIdx(jj))...
            +inputSamples...
            +inputSamples*(find(sortSeries(jj,:)==ii));
        plot(idx,outputSeries(idx,ii),...
            'o','color',selectedColor,...
            'LineWidth',lineWidth,...
            'markerSize',markerSize); hold on;
    end
    plot(xLinVals,...
        linspace(refs(ii),refs(ii),iters*inputSamples*(totalPreisachs+1)),...
        '--k','LineWidth',refLineWidth);
    xticks(ticksVals);
    xticklabels(ticksLabels);
    ylabel(strcat('$\Phi_',string(ii),'$'),'Interpreter','Latex');
    xlim([1,totalSampleSeries]);
end
xlabel('Iteration','Interpreter','Latex');


figure(3)
for ii=1:totalPreisachs
    subplot(totalPreisachs,1,ii); hold on;
    for jj=1:iters
        idx = (iterBeginIdx(jj))...
            +inputSamples...
            +inputSamples*(find(sortSeries(jj,:)==ii));
        stem(idx,refs(ii)-outputSeries(idx,ii),...
            'o','color','k',...
            'LineWidth',lineWidth,...
            'markerSize',markerSize); hold on;
    end
    xticks(ticksVals);
    xticklabels(ticksLabels);
    ylabel(strcat('$e_',string(ii),'$'),'Interpreter','Latex');
    xlim([1,totalSampleSeries]);
end
xlabel('Iteration','Interpreter','Latex');