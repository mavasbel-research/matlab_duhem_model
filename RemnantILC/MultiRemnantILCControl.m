close all
clc

% Model parameters
% totalPreisachs = 3;
% couplingFactor = 0.5;
% resetAmp = -1.0;
% pulseAmpMax = 1;
% pulseAmpMin = 0.5;
% reachableMax = -0.34;
% reachableMin = -0.83;

totalPreisachs = 3;
couplingFactor = 0.50;
resetAmp = inputMin;
pulseAmpMax = inputMax;
pulseAmpMin = 0;
reachableMax = 400;
reachableMin = -200;
% reachableMin = 100;

% Control objective and initial pulse amp
refs = rand(1,totalPreisachs)*(reachableMax - reachableMin) + reachableMin;
pulseAmps = rand(1,totalPreisachs)*(pulseAmpMax - pulseAmpMin) + pulseAmpMin;
refs = [+140 70 +280];
refs = [+220 100 +380];
pulseAmps = 800*[1,1,1];

% Control paremeters
K0 = 0.28;
errorThreshold = 0.005;
iterationsLimit = 30;
inputSamples = 400;

% Plot paramenters
resetColor = [0 0 1];
selectedColor = [0.9 0 0];
couplingColor = [0 0 0];
errorColor = [0.75 0.75 0];
doneColor = [0 0.75 0];
iterLimitColor = [0.5 0.5 0];

% Video name
% videoName = 'video.avi';

% Truncate total refs and pulses to total Preisachs
refs = refs(1:totalPreisachs);
pulseAmps = pulseAmps(1:totalPreisachs);

% Truncate values refs and pulses to 2 decimals
refs = refs - rem(refs, 10^-2);
pulseAmps = pulseAmps - rem(pulseAmps, 10^-2);

% Bounds values refs and pulses to given intervals
refs = max(min(refs', reachableMax), reachableMin)';
pulseAmps = max(min(pulseAmps', pulseAmpMax), pulseAmpMin)';

% Reset all Preisach models
for j=1:totalPreisachs, preisachArray(j).resetRelaysOff(); end

% Create axes for plots
iterationInputLines = [];
iterationResetLines = [];
axesHandlers = [];
fig = figure;
fig.WindowState = 'maximized';
axesHandlers = [];
for i=1:totalPreisachs
    axesHandler = subplot(1, totalPreisachs, i);
    xlim(axesHandler, [-1.2 1.2]);
    ylim(axesHandler, [-1.0 0.8]);
    
    % Axis for simulation with real data
    xlim([inputMin-0.2*(inputMax-inputMin),inputMax+0.2*(inputMax-inputMin)]);
    ylim([-1000 1500]);
    
    grid(axesHandler, 'on');
    hold(axesHandler, 'on');
    plot(axesHandler, 0, refs(i), 'ro', 'markersize', 4);
    axesHandlers = [axesHandlers, axesHandler];
end

%Create video writer
% videoWriter = VideoWriter(videoName);
% open(videoWriter);

% Create reset signal
% resetSignal = generateSignal(resetAmp, inputSamples);
resetSignal = generateResetSignal(-800, inputMax, inputSamples);

% Start main loop
iteration = 1;
inputs = [];

inputSeries = [];
outputSeries = [];
sortSeries = [];
ampsSeries = [];
finalOutputSeries = [];
errorsSeries = [];


    for i=1:inputSamples
        for j=1:totalPreisachs
            preisachArray(j).updateRelays(resetSignal(i));
        end
    end

while(true)
    % Print stats
    disp('-------------------------')
    disp(['Iteration: ', num2str(iteration)])
    disp(['Pulse:     ', num2str(pulseAmps, '   %+6.6f')])
    disp(['Ref:       ', num2str(refs, '   %+6.6f')])
    
    % Clear previous reset lines
%     if exist('iterationResetLines','var') && ~isempty(iterationResetLines)
%         for j=1:length(iterationResetLines)
%             clearpoints(iterationResetLines(j)); 
%         end
%     end
%     % Generate animated line handlers for reset and set xlabel
%     iterationResetLines = [];
%     for j=1:totalPreisachs
%         resetLine = animatedline(axesHandlers(j), 'Color', resetColor);
%         iterationResetLines = [iterationResetLines, resetLine];
%         title(axesHandlers(j), 'Resetting', 'Color', resetColor);
%     end
    
    % Apply reset signal to Preisachs
%     for i=1:inputSamples
%         inputSeries = cat(1,inputSeries,NaN(1,totalPreisachs));
%         outputSeries = cat(1,outputSeries,NaN(1,totalPreisachs));
%         for j=1:totalPreisachs
%             inputSeries(end,j) = resetSignal(i);
%             preisachArray(j).updateRelays(resetSignal(i));
%             outputSeries(end,j) = preisachArray(j).getOutput();
%             addpoints(iterationResetLines(j), resetSignal(i), outputSeries(end,j));
%         end
%         drawnow limitrate;
% %         frame = getframe(fig);
% %         writeVideo(videoWriter, frame);
%     end
    
    % Clear previous input lines if exists
    if exist('iterationInputLines','var') && ~isempty(iterationInputLines)
        for j=1:size(iterationInputLines,1)
            for jj=1:size(iterationInputLines,2)
                clearpoints(iterationInputLines(j,jj));
            end
        end
        drawnow limitrate;
    end
    iterationInputLines = [];
    
    % Sort pulse amps and start application loop
%     [~,sortedPulseAmpsIdx] = sort(pulseAmps);
    sortedPulseAmpsIdx = [1:totalPreisachs];
%     sortedPulseAmpsIdx = flip(sortedPulseAmpsIdx);
    ampsSeries = cat(1,ampsSeries,pulseAmps);
    sortSeries = cat(1,sortSeries,sortedPulseAmpsIdx);
    finalOutputs = NaN(1,totalPreisachs);
    for j=sortedPulseAmpsIdx
        % Generate animated line handlers and set xlabel with
        % corresponding colors
        inputLines = [];
        for jj=1:totalPreisachs
            if jj==j
                inputLine = animatedline(axesHandlers(jj), 'Color', selectedColor);
                title(axesHandlers(jj), ...
                    horzcat('Amplitude: ', num2str(pulseAmps(j),'%+4.6f')), ...
                    'Color', selectedColor);
            else
                inputLine = animatedline(axesHandlers(jj), 'Color', couplingColor);
                title(axesHandlers(jj), ...
                    'Electric coupling effect', ...
                    'Color', couplingColor);
            end
            inputLines = [inputLines, inputLine];
        end
        iterationInputLines = [iterationInputLines; inputLines];
        
        % Generation and application and saving of input signal with 
        % coupling effect to neightbours
        inputSignal = generateSignal(pulseAmps(j),inputSamples);  
        for i=1:inputSamples
            inputSeries = cat(1,inputSeries,NaN(1,totalPreisachs));
            outputSeries = cat(1,outputSeries,NaN(1,totalPreisachs));
        
            inputSeries(end,j) = inputSignal(i);
            preisachArray(j).updateRelays(inputSignal(i));
            outputSeries(end,j) = preisachArray(j).getOutput();
            addpoints(inputLines(j),inputSignal(i),outputSeries(end,j))
            
            for jj=1:totalPreisachs
                if jj==j, continue, end
                inputSeries(end,jj) = couplingFactor*inputSignal(i);
                preisachArray(jj).updateRelays(inputSeries(end,jj)); % This is the neightbour input
                outputSeries(end,jj) = preisachArray(jj).getOutput(); % This is the neightbour output
                addpoints(inputLines(jj),inputSeries(end,jj),outputSeries(end,jj));
            end
            
            drawnow limitrate;
%             frame = getframe(fig);
%             writeVideo(videoWriter, frame);
        end
        
        finalOutputs(j) = outputSeries(end,j);
    end
    
    % Compute and print errors
    errors = (refs - finalOutputs);
    disp(['Remnant:   ', num2str(finalOutputs, '   %+6.6f')])
    disp(['Error:     ', num2str(errors, '   %+6.6f')])
    
    % Save for postprocessing
    finalOutputSeries = cat(2,finalOutputSeries,finalOutputs);
    errorsSeries = cat(2,errorsSeries,errors);
    
    % Update error labels
    for j=1:totalPreisachs
        if abs(errors(j)) > abs(errorThreshold)
            xlabel(axesHandlers(j), ...
                horzcat('Last error: ', num2str(errors(j), '%+6.6f')), ...
                'Color', errorColor);
        else
            xlabel(axesHandlers(j), ...
                horzcat('Last error: ', num2str(errors(j), '%+6.6f')), ...
                'Color', doneColor);
        end
    end
    
    % Validate error in threshold
    if max(abs(errors))<=errorThreshold
        for j=1:totalPreisachs
            title(axesHandlers(j), 'Done', ...
                'Color', doneColor);
        end
        disp('-------------------------')
        disp('Error threshold achieved')
        disp('-------------------------')
        break
    end
    
    if iteration>=iterationsLimit
        for j=1:totalPreisachs
            title(axesHandlers(j), 'Iteration limit', ...
                'Color', iterLimitColor);
        end
        disp('-------------------------')
        disp('Iteration limit achieved')
        disp('-------------------------')
        break
    end
    
    % Compute pulses amps for next iteration and update iteration counter
    pulseAmps = pulseAmps + K0*errors;
    pulseAmps = max(min(pulseAmps', pulseAmpMax), pulseAmpMin)';
    iteration = iteration + 1;
end

% Close video writer
% close(videoWriter);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to generate pulse signal with relaxation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ampVals, timeVals] = generateSignal(amp, numSamples)
    timePoints = [0; 0.25; 0.5; 0.60];
    ampPoints = [0; amp; 0; 0];
    timeVals = linspace(0, timePoints(end), numSamples);
    ampVals = interp1(timePoints, ampPoints, timeVals);
    timeVals = timeVals(:);
    ampVals = ampVals(:);
end

function [ampVals, timeVals] = generateResetSignal(minAmp, maxAmp, numSamples)
    timePoints = [0; 0.25; 0.5; 0.75; 1.0];
    ampPoints = [0; maxAmp; 0; minAmp; 0];
    timeVals = linspace(0, timePoints(end), numSamples);
    ampVals = interp1(timePoints, ampPoints, timeVals);
    timeVals = timeVals(:);
    ampVals = ampVals(:);
end