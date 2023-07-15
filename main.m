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
        edgesFChange = dynamicEdges((Open(startTrainDateIdx:end) - Close(startTrainDateIdx:end))./Open(startTrainDateIdx:end), discretizationPoints(1));
        edgesFHigh = dynamicEdges((High(startTrainDateIdx:end) - Open(startTrainDateIdx:end))./Open(startTrainDateIdx:end), discretizationPoints(2));
        edgesFLow = dynamicEdges((Open(startTrainDateIdx:end) - Low(startTrainDateIdx:end))./Open(startTrainDateIdx:end), discretizationPoints(3));
    else
        edgesFChange = linspace(-0.1,0.1,discretizationPoints(1)+1);
        edgesFHigh = linspace(0,0.1,discretizationPoints(2)+1);
        edgesFLow = linspace(0,0.1,discretizationPoints(3)+1);
    end
end

% discretization of each parameter sequence (overscribed)
[fracChange, ~] = discretize(fracChange, edgesFChange);
[fracHigh,   ~] = discretize(fracHigh, edgesFHigh);
[fracLow,    ~] = discretize(fracLow, edgesFLow);

% discretized sequences mapped into a monodimensional array
discreteObservations1D = zeros(length(trainIndexes), 1);
for i = 1:length(trainIndexes)
    discreteObservations1D(i) = map3DTo1D(fracChange(i), fracHigh(i), fracLow(i), discretizationPoints(1), discretizationPoints(2),discretizationPoints(3));
end

%% Markov Chain guesses
 
if (TRAIN)
    disp("Markov Chain guesses")
    transitionMatrix = 1/underlyingStates.*ones(underlyingStates, underlyingStates);
    gaussianMixture = fitgmdist(continuousObservations3D, mixturesNumber*underlyingStates, 'CovarianceType', 'diagonal', 'RegularizationValue', 1e-10, 'Replicates', 10);
    
    % gaussin sorting
    sortedMu = zeros(mixturesNumber*underlyingStates,3);
    [sortedMu(:,1), sortedMuIndexes] = sort(gaussianMixture.mu(:,1), 1);
    sortedMu(:,2:3) = gaussianMixture.mu(sortedMuIndexes,2:3);    % sigma sorting 
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
% construction of matrix observations_train containing train sequences of
% discretized monodimensional values

if(TRAIN)
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
        trainingSet = zeros(totalTrainSequences, latency); %#ok<UNRCH>
        for i = 1:totalTrainSequences
           startWindowIdx = (i - 1) * latency + 1;
           endWindowIdx = startWindowIdx + latency - 1;
           trainingSet(i,:) = discreteObservations1D(startWindowIdx:endWindowIdx);
        end
    end
end

%% train
if (TRAIN)
    disp("Train")      %#ok<UNRCH>
    maxIter = 1000;
    trainInfo = struct('maxIter', maxIter, 'converged', 0, 'trainingTime', -1);
    lastwarn('', '');

    tic
    [ESTTR, ESTEMIT] = hmmtrain(trainingSet,transitionMatrix,emissionProbabilities,'Verbose',true,'Maxiterations',maxIter);
    trainInfo.trainingTime = toc;
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
    currentWindowEndIdx = startPredictionDateIdx -2 + currentPrediction;
    
    % index corresponding to current predicion in Date vector
    currentPredictionIdx = currentWindowEndIdx +1;
    currentWindowIndexes = currentWindowStartIdx:currentWindowEndIdx;
    
    % historical window observations
    currentWindowFracChange = (Close(currentWindowIndexes) - Open(currentWindowIndexes))./Open(currentWindowIndexes);
    currentWindowFracHigh   = (High(currentWindowIndexes) - Open(currentWindowIndexes)) ./Open(currentWindowIndexes);
    currentWindowFracLow    = (Open(currentWindowIndexes) - Low(currentWindowIndexes))  ./Open(currentWindowIndexes);
    
    % discretization of historical data used for prediction
    [currentWindowFracChange, ~] = discretize(currentWindowFracChange, edgesFChange);
    [currentWindowFracHigh, ~]   = discretize(currentWindowFracHigh, edgesFHigh);
    [currentWindowFracLow, ~]    = discretize(currentWindowFracLow, edgesFLow);
    
    currentWindow1D = zeros(1, latency-1);
    for i = 1:(latency-1)
        currentWindow1D(i) = map3DTo1D(currentWindowFracChange(i), currentWindowFracHigh(i), currentWindowFracLow(i), ...
            discretizationPoints(1), discretizationPoints(2), discretizationPoints(3));
    end
    %prediction
    fprintf("%.2f%% : ", currentPrediction / predictionLength * 100);
    predictedObservation1D = hmmPredictObservation(currentWindow1D, ESTTR, ESTEMIT, 'verbose', 1, 'possibleObservations', 1:totalDiscretizationPoints);
    
    if (~isnan(predictedObservation1D))
        % 3D mapping of current valid prediction
        [predictedFracChange, predictedFracHigh, predictedFracLow] = map1DTo3D(predictedObservation1D, discretizationPoints(1), discretizationPoints(2), discretizationPoints(3));
        % t-th row filled with current 3D valid prediction
        predictedObservations3D(currentPrediction,:) = [edgesFChange(predictedFracChange), edgesFHigh(predictedFracHigh), edgesFLow(predictedFracLow)];
        
        predictedClose(currentPrediction) = Open(currentPredictionIdx)*(1 + predictedObservations3D(currentPrediction,1));
    else 
        % invalid prediction
        predictedObservations3D(currentPrediction,:) = NaN;
        predictedClose(currentPrediction) = NaN;
    end

end




