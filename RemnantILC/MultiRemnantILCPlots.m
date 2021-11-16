close all

% iters = iteration;
iters = 16;

totalSampleSeries = iters*inputSamples*(totalPreisachs)%+1);
xLinVals = 1:totalSampleSeries;
lineWidth = 1.2;
markerSize = 4;
refLineWidth = 0.60;

fontSize = 15;

resetColor = "b";
selectedColor = "r";
coupledColor = "b";
errorColor = 'b';

stepSize = 5;
% iterBeginIdx = [0: inputSamples*(totalPreisachs+1): iters*inputSamples*(totalPreisachs+1) ];
iterBeginIdx = [0: inputSamples*(totalPreisachs): iters*inputSamples*(totalPreisachs) ];
iterNumStr = cellstr(string([1:iters]));
ticksVals = iterBeginIdx(1:stepSize:end);
ticksLabels = iterNumStr(1:stepSize:end);


inputColorSeries = [];
outputColorSeries = [];
for ii=1:iters
    %inputColorSeries = cat(1,inputColorSeries,repmat(resetColor,1,totalPreisachs));
    %outputColorSeries = cat(1,outputColorSeries,repmat(resetColor,1,totalPreisachs));
    
    [~,sortedColorIdx] = sort(sortSeries(ii,:));
    for jj=1:totalPreisachs
        inputColorSeries = cat(1,inputColorSeries,repmat(coupledColor,1,totalPreisachs));
        outputColorSeries = cat(1,outputColorSeries,repmat(coupledColor,1,totalPreisachs));
        inputColorSeries(end,sortedColorIdx(jj)) = selectedColor;
        outputColorSeries(end,sortedColorIdx(jj)) = selectedColor;
    end
end

% sigma = [];
% nu = [];
% for ii=1:iters
%     for jj=1:totalPreisachs
%         
%     end
% end


for ii=1:totalPreisachs
    figure();
    
    
    
    subplot(3,1,1); hold on;
    for jj=1:iters*(totalPreisachs)%+1)
        plot(xLinVals((jj-1)*inputSamples+1:jj*inputSamples),...
            inputSeries((jj-1)*inputSamples+1:jj*inputSamples,ii),...
            strcat('-',inputColorSeries(jj,ii)),...
            'LineWidth',lineWidth);
    end
    for jj=1:iters
        idx = (iterBeginIdx(jj))...            %+inputSamples...
            +inputSamples*(find(sortSeries(jj,:)==ii)-1)...
            +floor(inputSamples/2)-30;
        plot(idx,inputSeries(idx,ii),...
            'o','color',selectedColor,...
            'LineWidth',lineWidth,...
            'markerSize',markerSize); hold on;
    end
    
    plot([xLinVals(end)+1:xLinVals(end)+inputSamples*2],...
            zeros(1,inputSamples*2),...
            strcat('-',coupledColor),...
            'LineWidth',lineWidth);
        
    xticks(ticksVals);
    xticklabels(ticksLabels);
    ylabel(strcat('$u_{',string(ii),',\gamma}$'),...
        'FontSize',fontSize,...
        'Interpreter','Latex');
    xlim([1,totalSampleSeries+inputSamples*2]);
    ylim([-900 1500]);
    
    
    
    
    subplot(3,1,2); hold on;
    for jj=1:iters*(totalPreisachs)%+1)
        plot(xLinVals((jj-1)*inputSamples+1:jj*inputSamples),...
            outputSeries((jj-1)*inputSamples+1:jj*inputSamples,ii),...
            strcat('-',outputColorSeries(jj,ii)),...
            'LineWidth',lineWidth);
    end
    for jj=1:iters
        idx = (iterBeginIdx(jj))...            %+inputSamples...
            +inputSamples*(find(sortSeries(jj,:)==ii));
        plot(idx,outputSeries(idx,ii),...
            'o','color',selectedColor,...
            'LineWidth',lineWidth,...
            'markerSize',markerSize); hold on;
    end
    plot(xLinVals,...
        linspace(refs(ii),refs(ii),iters*inputSamples*(totalPreisachs)),...%+1)),...
        '--k','LineWidth',refLineWidth);
    
    plot([xLinVals(end)+1:xLinVals(end)+inputSamples*2],...
            repmat(outputSeries(idx,ii),inputSamples*2,1),...
            strcat('-',coupledColor),...
            'LineWidth',lineWidth);
        
    xticks(ticksVals);
    xticklabels(ticksLabels);
    ylabel(strcat('$\mathcal{P}_',string(ii),...
            '(u_{',string(ii),',\gamma},I{',string(ii),',0})$'),...
        'FontSize',fontSize,...
        'Interpreter','Latex');
    xlim([1,totalSampleSeries+inputSamples*2]);
    ylim([-300 1100]);
    
    
    
    subplot(3,1,3); hold on;
    for jj=1:iters
        idx = (iterBeginIdx(jj))...            %+inputSamples...
            +inputSamples*(find(sortSeries(jj,:)==ii));
        stem(idx,refs(ii)-outputSeries(idx,ii),...
            'o','color',errorColor,...
            'MarkerEdgeColor','r',...
            'LineWidth',lineWidth,...
            'markerSize',markerSize); hold on;
    end
    
    xticks(ticksVals);
    xticklabels(ticksLabels);
    ylabel(strcat('$\varepsilon_{',string(ii),',i}$'),...
        'FontSize',fontSize,...
        'Interpreter','Latex');
    xlim([1,totalSampleSeries+inputSamples*2]);
    ylim([-50 450]);

    xlabel('$i$',...
        'FontSize',fontSize,...
        'Interpreter','Latex');
    
    drawnow
    saveas(gcf,strcat('simulation_actuator_',string(ii)),'epsc');
end
