close all
clear
clc

init();

% sequences of observations of three different parameters
fracChange = (Open(trainIndexes) - Close(trainIndexes))./Open(trainIndexes);
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
        edgesFChange = linspace(-0.1,0.1,numberOfPoints(1)+1);
        edgesFHigh = linspace(0,0.1,numberOfPoints(2)+1);
        edgesFLow = linspace(0,0.1,numberOfPoints(3)+1);
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








