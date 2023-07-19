close all
clear
clc

init();

% sequences of observations of three different parameters
fracChange = (Close(trainIndexes) - Open(trainIndexes))./Open(trainIndexes);
fracHigh   = (High(trainIndexes) - Open(trainIndexes)) ./Open(trainIndexes);
fracLow    = (Open(trainIndexes) - Low(trainIndexes))  ./Open(trainIndexes);

% sequences of observations grouped in a three columns matrix
continuousObservations3D = [fracChange, fracHigh, fracLow];

if exist('edgesFChange','var')==0
    % if edges are not present in .mat
    if useDynamicEdges
        edgesFChange = dynamicEdges((Close(startTrainDateIdx:end) - Open(startTrainDateIdx:end))./Open(startTrainDateIdx:end), discretizationPoints(1));
        edgesFHigh = dynamicEdges((High(startTrainDateIdx:end) - Open(startTrainDateIdx:end))./Open(startTrainDateIdx:end), discretizationPoints(2));
        edgesFLow = dynamicEdges((Open(startTrainDateIdx:end) - Low(startTrainDateIdx:end))./Open(startTrainDateIdx:end), discretizationPoints(3));
    else
        edgesFChange = linspace(-0.1, 0.1, discretizationPoints(1)+1);
        edgesFHigh = linspace(0, 0.1, discretizationPoints(2)+1);
        edgesFLow = linspace(0, 0.1, discretizationPoints(3)+1);
    end
end

% discretization of each parameter sequence (overscribed)
[fracChange, ~] = discretize(fracChange, edgesFChange);
[fracHigh,   ~] = discretize(fracHigh, edgesFHigh);
[fracLow,    ~] = discretize(fracLow, edgesFLow);

% discretized sequences mapped into a monodimensional array
discreteObservations1D = zeros(length(trainIndexes), 1);
for i = 1:length(trainIndexes)
    discreteObservations1D(i) = map3DTo1D(fracChange(i), fracHigh(i), fracLow(i), discretizationPoints(1), discretizationPoints(2), discretizationPoints(3));
end

%% Markov Chain guesses
 
if (TRAIN)
    disp("Markov Chain guesses")
    transitionMatrix = 1/underlyingStates.*ones(underlyingStates, underlyingStates);
    gaussianMixture = fitgmdist(continuousObservations3D, mixturesNumber*underlyingStates, 'CovarianceType', 'diagonal', 'RegularizationValue', 1e-10, 'Replicates', 10);
    
    % gaussin sorting
    sortedMu = zeros(mixturesNumber*underlyingStates, 3);
    [sortedMu(:,1), sortedMuIndexes] = sort(gaussianMixture.mu(:,1), 1);
    sortedMu(:,2:3) = gaussianMixture.mu(sortedMuIndexes, 2:3);    % sigma sorting 
    sortedSigma = gaussianMixture.Sigma(1, 1:3, sortedMuIndexes);
    
    % emission probabilities initialized to zeros
    emissionProbabilities = zeros(underlyingStates,totalDiscretizationPoints);

    % assigning Gaussian Mixture for each hidden state
    gaussianMixtureState = cell(underlyingStates, 1);
    for i = 1:underlyingStates
        gaussianMixtureState{i} = gmdistribution(sortedMu((1+(i-1)*mixturesNumber):(i*mixturesNumber),:), ...
                                    sortedSigma(1,:,(1+(i-1)*mixturesNumber):(i*mixturesNumber)));
        % mapping to 1D
        for x=edgesFChange(1:end-1)
            for y=edgesFHigh(1:end-1)
                for z=edgesFLow(1:end-1)
                    % probability of state i emitting observation [x,y,z]
                    p = pdf(gaussianMixtureState{i},[x y z]);
                    
                    % 3D indexes for observation [x,y,z]
                    xIdx = find(edgesFChange==x);
                    yIdx = find(edgesFHigh==y);
                    zIdx = find(edgesFLow==z);
                    % mapping 3D indexes into 1D indexcontinuous_observations3D n
                    emissionIdx = map3DTo1D(xIdx,yIdx,zIdx,discretizationPoints(1),discretizationPoints(2),discretizationPoints(3));
                    % (i,n) element filled: i = state i, n = 1D emission index 
                    emissionProbabilities(i,emissionIdx) = p;
                end
            end
        end
        % scaled probabilities of state i emitting each of total #observations = totalPoints
        emissionProbabilities(i,:) = emissionProbabilities(i,:)./sum(emissionProbabilities(i,:));
    end
end
%% train sequences
% construction of matrix triningSet containing train sequences of
% discretized monodimensional values

if (TRAIN)
    if (shiftWindowByOne) % interval shifted by #days = 1
        totalTrainSequences = length(trainIndexes) - latency + 1;
        trainingSet = zeros(totalTrainSequences, latency);
        for i = 1:totalTrainSequences
            startWindowIdx = i;
            endWindowIdx = i+latency-1;
            trainingSet(i,:) = discreteObservations1D(startWindowIdx:endWindowIdx);
        end
    else            % interval shifted by #days = latency
        % last sequence is ignored if length(trainIndexes) mod latency ~=0
        totalTrainSequences = floor(length(trainIndexes) / latency);
        trainingSet = zeros(totalTrainSequences, latency);
        for i = 1:totalTrainSequences
           startWindowIdx = (i - 1) * latency + 1;
           endWindowIdx = startWindowIdx + latency - 1;
           trainingSet(i,:) = discreteObservations1D(startWindowIdx:endWindowIdx);
        end
    end
end

%% train
if (TRAIN)
    disp("Train")
    maxIter = 1000;
    trainInfo = struct('maxIter', maxIter, 'converged', 0, 'trainingTime', -1);
    lastwarn('', '');

    tic     % start measuring time
    [ESTTR, ESTEMIT] = hmmtrain(trainingSet,transitionMatrix,emissionProbabilities,'Verbose',true,'Maxiterations',maxIter);
    trainInfo.trainingTime = toc;   % stop measuring time
    [warnMsg, warnId] = lastwarn();
    
    trainInfo.converged = isempty(warnId);
    
    filename = strcat("train/hmmtrain-", string(datetime('now', 'format', 'yyyy-MM-dd-HH-mm-ss')), ".mat");
    save(filename, "ESTTR", "ESTEMIT","trainInfo","edgesFChange","edgesFHigh","edgesFLow");
    % play sound when training is finished
    load handel
    sound(y,Fs)
end

%% predizione
disp("Prediction")
% initialization of 3D predicted observations
predictedObservations3D = zeros(predictionLength, 3);
% initialization of Close values based on predicted data 
predictedClose = zeros(predictionLength, 1);

for currentPrediction = 1:predictionLength
    % historical window indexes
    currentWindowStartIdx = startPredictionDateIdx - latency + currentPrediction;
    currentWindowEndIdx = startPredictionDateIdx - 2 + currentPrediction;
    
    % index corresponding to current predicion in Date vector
    currentPredictionIdx = currentWindowEndIdx + 1;
    currentWindowIndexes = currentWindowStartIdx:currentWindowEndIdx;
    % notice that, since the HMM was trained on sequences of length 
    % "latency", we create the currentWindow with "latency - 1"
    % observations, so that the network will predict the 10th
    
    % historical window observations
    currentWindowFracChange = (Close(currentWindowIndexes) - Open(currentWindowIndexes)) ./Open(currentWindowIndexes);
    currentWindowFracHigh   = (High(currentWindowIndexes)  - Open(currentWindowIndexes)) ./Open(currentWindowIndexes);
    currentWindowFracLow    = (Open(currentWindowIndexes)  - Low(currentWindowIndexes))  ./Open(currentWindowIndexes);
    
    % discretization of historical data used for prediction
    [currentWindowFracChange, ~] = discretize(currentWindowFracChange, edgesFChange);
    [currentWindowFracHigh, ~]   = discretize(currentWindowFracHigh, edgesFHigh);
    [currentWindowFracLow, ~]    = discretize(currentWindowFracLow, edgesFLow);
    
    currentWindow1D = zeros(1, latency-1);
    for i = 1:(latency-1)
        currentWindow1D(i) = map3DTo1D(currentWindowFracChange(i), currentWindowFracHigh(i), currentWindowFracLow(i), ...
            discretizationPoints(1), discretizationPoints(2), discretizationPoints(3));
    end

    % Fine tune
    disp("Fine-tuning of the model...")
    ft_length = 100;
    ft_windowEndIdx = currentWindowEndIdx;
    ft_windowStartIdx = ft_windowEndIdx - ft_length + 1;
    ft_indexes = ft_windowStartIdx : ft_windowEndIdx;
    [ft_fracChange, ~] = discretize((Close(ft_indexes) - Open(ft_indexes))./Open(ft_indexes), edgesFChange);
    [ft_fracHigh,   ~] = discretize((High(ft_indexes) - Open(ft_indexes)) ./Open(ft_indexes), edgesFHigh);
    [ft_fracLow,    ~] = discretize((Open(ft_indexes) - Low(ft_indexes))  ./Open(ft_indexes), edgesFLow);
    ft_discreteObservations1D = zeros(length(ft_indexes), 1);
    for i = 1:length(ft_indexes)
        ft_discreteObservations1D(i) = map3DTo1D(ft_fracChange(i), ft_fracHigh(i), ft_fracLow(i), discretizationPoints(1), discretizationPoints(2), discretizationPoints(3));
    end
    ft_totalTuningSequences = length(ft_indexes) - latency + 1;
    ft_tuningSet = zeros(ft_totalTuningSequences, latency);
    for i = 1:ft_totalTuningSequences
        startWindowIdx = i;
        endWindowIdx = i+latency-1;
        ft_tuningSet(i,:) = ft_discreteObservations1D(startWindowIdx:endWindowIdx);
    end

    tic
    [ESTTR, ESTEMIT] = hmmtrain(ft_tuningSet,ESTTR,ESTREMIT,'Verbose',true,'Maxiterations',100);
    fprintf("Fine tuning took %.2f secs", toc);


    % prediction
    fprintf("%.2f%% : ", currentPrediction / predictionLength * 100);
    predictedObservation1D = hmmPredictObservation(currentWindow1D, ESTTR, ESTEMIT, 'verbose', 1, 'possibleObservations', 1:totalDiscretizationPoints);
    
    if (~isnan(predictedObservation1D))
        % 3D mapping of current valid prediction
        [predictedFracChange, predictedFracHigh, predictedFracLow] = map1DTo3D(predictedObservation1D, discretizationPoints(1), discretizationPoints(2), discretizationPoints(3));
        % currentPrediction-th row filled with current 3D valid prediction
        predictedObservations3D(currentPrediction,:) = [edgesFChange(predictedFracChange), edgesFHigh(predictedFracHigh), edgesFLow(predictedFracLow)];
        
        predictedClose(currentPrediction) = Open(currentPredictionIdx)*(1 + predictedObservations3D(currentPrediction,1));
    else 
        % invalid prediction
        predictedObservations3D(currentPrediction,:) = NaN;
        predictedClose(currentPrediction) = NaN;
    end

end

%% Plots
disp("plots")

% initialization of MAPE
MAPE = 0;
fig_candlestick = figure(Name='Candlestick');
grid on
% candlestick plot of actual values
RG_candle(timetable(Date(predictionIndexes), Open(predictionIndexes), High(predictionIndexes), Low(predictionIndexes), Close(predictionIndexes), 'VariableNames', {'Open', 'High', 'Low', 'Close'}));
hold on
% dots of predictions (green: earned money)
whichDotsAreGreen = sign(predictedClose - Open(predictionIndexes)) == sign(Close(predictionIndexes) - Open(predictionIndexes));
plot(Date(predictionIndexes(whichDotsAreGreen)), predictedClose(whichDotsAreGreen), '.',   MarkerSize=12, Color="#378333");       % green dots
plot(Date(predictionIndexes(~whichDotsAreGreen)), predictedClose(~whichDotsAreGreen), '.', MarkerSize=12, Color="#A80303");     % red dots
% legend
leg_candlde = gobjects(2,1);
leg_candlde(1) = plot(nan, nan, '.', MarkerSize=20, Color="#378333");
leg_candlde(2) = plot(nan, nan, '.', MarkerSize=20, Color="#A80303");
legend(leg_candlde, 'Close prediction (correct direction)', 'Close prediction (wrong direction)', 'Location', 'northwest')
hold off
title(sprintf("%s - Candlestick chart", extractBefore(stock_name, ".mat")))

fig_closePlot = figure(Name='Real vs predicted Close values');
realDataPlot = plot(Date(predictionIndexes), Close(predictionIndexes), "LineWidth", 0.3, "Marker", '.', "MarkerSize", 5);
grid on
hold on

predictionInfo = struct('good', 0, 'bad', 0, 'invalid', 0);

% instantiate trading simulation array
investmentSimulation = Open(startPredictionDateIdx) .* ones(1, predictionLength + 1);
% each day the dummy investor decides how to invest -> its capital is
% calculated for the day after according to the correctness of the guess

% instantiate graphic objects array
predClosePlot = gobjects(predictionLength, 1);

for currentPrediction = 1:predictionLength
    % index of the date for the current prediction
    currentPredictionDateIdx = startPredictionDateIdx - 1 + currentPrediction;
    % dummy investor
    if (isnan(predictedClose(currentPrediction)))
        investmentSimulation(currentPrediction + 1) = investmentSimulation(currentPrediction);
    else
        currentFracChange = (Close(currentPredictionDateIdx) - Open(currentPredictionDateIdx))./Open(currentPredictionDateIdx);
        % long
        if predictedClose(currentPrediction) > Open(currentPredictionDateIdx)
            investmentSimulation(currentPrediction + 1) = (1 + currentFracChange) * investmentSimulation(currentPrediction);
            fprintf("%s: buy for %.2f, sell for %.2f\n", string(Date(currentPredictionDateIdx)), Open(currentPredictionDateIdx), Close(currentPredictionDateIdx));
        % short
        elseif predictedClose(currentPrediction) < Open(currentPredictionDateIdx)
            investmentSimulation(currentPrediction + 1) = (1 - currentFracChange) * investmentSimulation(currentPrediction);
            fprintf("%s: sell for %.2f, buy for %.2f\n", string(Date(currentPredictionDateIdx)), Open(currentPredictionDateIdx), Close(currentPredictionDateIdx));
        % if = don't invest
        else
            investmentSimulation(currentPrediction + 1) = investmentSimulation(currentPrediction);
        end
    end

    % plotting results
    if (~isnan(predictedClose(currentPrediction)))   % there exists a prediction
        %yyaxis left
        if currentPrediction == 1
            predClosePlot(currentPrediction) = plot(Date(currentPredictionDateIdx), predictedClose(currentPrediction), '-');
        else
            predClosePlot(currentPrediction) = plot(Date(currentPredictionDateIdx - 1 : currentPredictionDateIdx), [Close(currentPredictionDateIdx - 1), predictedClose(currentPrediction)], '-');
        end
        
        isPredictionGood = sign(predictedClose(currentPrediction) - Open(currentPredictionDateIdx)) == sign(Close(currentPredictionDateIdx) - Open(currentPredictionDateIdx));
        if isPredictionGood
        % stock price increased/decreased as predicted
            predClosePlot(currentPrediction).Color = 'g';
            predictionInfo.good = predictionInfo.good + 1;
        else
        % the prediction was wrong :(
            predClosePlot(currentPrediction).Color = 'r';
            predictionInfo.bad = predictionInfo.bad + 1;
        end
        predClosePlot(currentPrediction).LineWidth = 0.3;
        predClosePlot(currentPrediction).Marker = '.';
        predClosePlot(currentPrediction).MarkerSize = 5;

        % valid prediction -> MAPE
        MAPE = MAPE + abs((Close(currentPredictionDateIdx) - predictedClose(currentPrediction)) / Close(currentPredictionDateIdx));
    else
    % prediction is NaN
        predictionInfo.invalid = predictionInfo.invalid + 1;
    end
end

% copying the figure without investmentSimulation
ax = gca;
fig_paperPlot = figure(Name="Close values");
copyobj(ax, fig_paperPlot);
leg_data = gobjects(3,1);
leg_data(1) = plot(nan, nan, '-b', 'Marker', '.', 'MarkerSize', 20);     % blue
leg_data(2) = plot(nan, nan, '-g', 'Marker', '.', 'MarkerSize', 20);     % green
leg_data(3) = plot(nan, nan, '-r', 'Marker', '.', 'MarkerSize', 20);     % red
legend(leg_data, 'Actual stock close', 'Close predictions (correct direction)', 'Close predictions (wrong direction)', 'Location', 'northwest')
ylim([min(Close(predictionIndexes)) * 0.95, max(Close(predictionIndexes)) * 1.05]);
title(sprintf("%s - Real vs predicted Close values", extractBefore(stock_name, ".mat")))


% plotting investmentSimulation
figure(fig_closePlot)
yyaxis right
investSimPlot = plot([Date(predictionIndexes); Date(predictionIndexes(end)) + 1], investmentSimulation, '-', 'Color', 'k');

% adjust axis
yyaxis left
ylim([min(Close(predictionIndexes)) * 0.95, max(Close(predictionIndexes)) * 1.05]);
yyaxis right
ax = gca;
ax.YColor = 'k';
ylim([min(Close(predictionIndexes)) * 0.95, max(Close(predictionIndexes)) * 1.05]);
ticks = yticks;
if max(investmentSimulation)<2*max(Close(predictionIndexes))
    ticks = [ticks(ticks<Open(startPredictionDateIdx)), Open(startPredictionDateIdx), ticks(ticks>Open(startPredictionDateIdx))];
    yticks(ticks)
    ticks = (ticks ./ Open(startPredictionDateIdx) - 1) * 100;
    yticklabels(cellstr(strcat(num2str(round(ticks')), "%")))
else
    ticks = linspace(investmentSimulation(1),max(investmentSimulation),10);
    yticks(ticks)
    ticks = (ticks ./ Open(startPredictionDateIdx) - 1) * 100;
    yticklabels(cellstr(strcat(num2str(round(ticks')), "%")))
end
yline(Open(startPredictionDateIdx), '--', "LineWidth", 0.1, "Color", [0.2 0.2 0.2])

% legend
leg_data = gobjects(4,1);
leg_data(1) = plot(nan, nan, '-b', 'Marker', '.', 'MarkerSize', 20);     % blue
leg_data(2) = plot(nan, nan, '-g', 'Marker', '.', 'MarkerSize', 20);     % green
leg_data(3) = plot(nan, nan, '-r', 'Marker', '.', 'MarkerSize', 20);     % red
leg_data(4) = plot(nan, nan, '-k');      % black
legend(leg_data, 'Actual stock close', 'Close predictions (correct direction)', 'Close predictions (wrong direction)', 'Dummy investor', 'Location', 'northwest')

hold off
title(sprintf("%s - Real vs predicted Close values", extractBefore(stock_name, ".mat")))

% recap
disp("------------------------------")
totalNumberOfPredictions = (predictionInfo.bad + predictionInfo.good);
predictionRatio = 100 * totalNumberOfPredictions / predictionLength;
correctPredictionRatio = 100 * predictionInfo.good / totalNumberOfPredictions;
fprintf("Total predictions: %d (%.2f%%)\nCorrect derivative: %d (%.2f%%)\nWrong derivative: %d (%.2f%%)\n", ...
    totalNumberOfPredictions, predictionRatio, ...
    predictionInfo.good, ...
    correctPredictionRatio, ...
    predictionInfo.bad, 100 * predictionInfo.bad / totalNumberOfPredictions);

% Calcolo MAPE
MAPE = MAPE / totalNumberOfPredictions;
fprintf("Mean Absolute Percentage Error (MAPE): %.2f%%\n", MAPE*100);

% print md instruction for appending the train to the table
trainname = extractAfter(extractAfter(filename, "train"), 1);
fprintf("||%s", trainname) 
fprintf("|%s|%s|%s|%d|%d|%d|%d|%d|%s|%d|%.2f%%|%.2f%%|%.2f%%|your notes here\n", extractBefore(stock_name, ".mat"), startTrainDate, endTrainDate, underlyingStates, mixturesNumber, latency,shiftWindowByOne, useDynamicEdges, startPredictionDate, predictionLength, predictionRatio, correctPredictionRatio, MAPE*100);












