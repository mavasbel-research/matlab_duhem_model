close all
clc

% Paremeters
ref = - 0.2 - 0.3582;
pulse = 0.85;
gain = 0.5;
initializationAmp = 1.0;
inputSamples = 200;
errorThreshold = 0.001;
iterationLimit = 20;

% Video parameters
videoName = 'video.avi';
videoWidth = 720;
videoHeight = 480;

disp(['Target Output: ', num2str(ref)])
disp(['Error Threshold: ', num2str(errorThreshold)])

% Loop Initialization
pulses = [];
remnants = [];
errors = [];
iteration = 0;
preisachRelayModel.resetRelaysOn();
fig = figure;
plotHandler = plot(0, ref, 'ro', 'markersize', 4);
lineHandler = animatedline(gca);

% Video initialization
% videoWriter = VideoWriter(videoName);
% open(videoWriter);
while(true)
    % Update iteration counter
    iteration = iteration + 1;
    
    % Generate input signal
    [input, times] = generateInputSignal(initializationAmp, pulse, inputSamples);
    output = zeros(inputSamples, 1);
    for i=1:inputSamples
        % Apply input value
        preisachRelayModel.updateRelays(input(i));
        output(i) = preisachRelayModel.getOutput();
        addpoints(lineHandler, input(i), output(i));
        drawnow limitrate;
        % Write video
%         frame = getframe(fig);
%         writeVideo(videoWriter, frame);
    end
    error = (ref - output(end));
    
    % Print stats
    disp('-------------------------')
    disp(['Iteration: ', num2str(iteration)])
    disp(['Pulse Amplitude: ', num2str(pulse)])
    disp(['Final Output: ', num2str(output(end))])
    disp(['Error: ', num2str(error)])
    
    % Save iteration params and stats
    pulses = [pulses; pulse];
    remnants = [remnants; output(end)];
    errors = [errors; error];
    
    % Break cycle condition
    if abs(error)<=errorThreshold
        disp('-------------------------')
        disp('Error threshold achieved')
        disp('-------------------------')
        break
    elseif iteration>iterationLimit
        disp('-------------------------')
        disp('Iterations limit achieved!')
        disp('-------------------------')
        break
    end
    
    % Update pulse value for next iteration
    pulse = pulse + gain*error;
end

% Close video
% close(videoWriter);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to generate input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function [signal, times] = generateInputSignal(initAmp, pulseAmp, numSamples)
%     pointTimes = [0; 0.25; 0.5; 0.75; ...
%             1; 1.25; 1.5; 1.75; ...
%             2; 3; ...
%             3.25; 3.5; ...
%             4.5;];
%     pointSignal = [0; initAmp; 0; -initAmp; ...
%             0; initAmp; 0; -initAmp; ...
%             0; 0; ...
%             pulseAmp; 0; ...
%             0;];
%     times = linspace(0, pointTimes(end), numSamples);
%     signal = interp1(pointTimes, pointSignal, times);
%     
%     times = times(:);
%     signal = signal(:);
% end

function [signal, times] = generateInputSignal(initAmp, pulseAmp, numSamples)
    pointTimes = [0; 0.25; 0.5; ...
            0.75; 1; 1.25; ...
            1.5];
    pointSignal = [0; -initAmp; 0;...
            0; pulseAmp; 0; ...
            0;];
    times = linspace(0, pointTimes(end), numSamples);
    signal = interp1(pointTimes, pointSignal, times);
    
    times = times(:);
    signal = signal(:);
end