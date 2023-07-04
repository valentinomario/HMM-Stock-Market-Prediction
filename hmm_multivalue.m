close all
clear
clc
load AAPL.mat;  % Date Open Close High Low

% TUTTE LE DATE SONO NEL FORMATO MM/DD/YYYY
% selezioniamo un periodo di osservazione
llim = indexOfDate(Date,'2003-02-10');
ulim = indexOfDate(Date,'2004-09-10');
%train_size = 365;
Date_l = Date(llim:ulim);
fracChange = (Open(llim:ulim) - Close(llim:ulim))./Open(llim:ulim);
fracHigh = (High(llim:ulim) - Close(llim:ulim))./Open(llim:ulim);
fracLow = (Open(llim:ulim) - Low(llim:ulim))./Open(llim:ulim);

continuos_observations3D = [fracChange, fracHigh, fracLow];

numberOfPoints = [50 10 10];
[fracChange, edgesFChange] = discretize(fracChange, numberOfPoints(1)-1);
[fracHigh, edgesFHigh] = discretize(fracHigh, numberOfPoints(2)-1);
[fracLow, edgesFLow] = discretize(fracLow, numberOfPoints(3)-1);

observations3D = [fracChange, fracHigh, fracLow];

observations = zeros(length(Date_l), 1);
for i = 1:length(Date_l)
    observations(i) = map3DTo1D(fracChange(i), fracHigh(i), fracLow(i), numberOfPoints(1), numberOfPoints(2));
end

underlyingStates = 4;
mixturesNumber = 5; % Number of mixture components for each state
latency = 10; % days aka vectors in sequence

% Markov Chain guesses
initialProb = 1/underlyingStates.*ones(1, underlyingStates); % initial probabilities of the states
transitionMatrix = 1/underlyingStates.*ones(underlyingStates, underlyingStates); % transition matrix

gm3D = fitgmdist(continuos_observations3D, mixturesNumber*underlyingStates, 'CovarianceType', 'diagonal', 'RegularizationValue', 1e-10, 'Replicates', 10);
%gm1D = fitgmdist(observations, mixturesNumber*underlyingStates, 'CovarianceType', 'diagonal', 'RegularizationValue', 1e-10, 'Replicates', 10);

emissionProbabilities = zeros(underlyingStates,5000);

for i = 1:underlyingStates
    gm_s{i}= gmdistribution(gm3D.mu((1+(i-1)*mixturesNumber):(i*mixturesNumber),:), ...
        gm3D.Sigma(1,:,(1+(i-1)*mixturesNumber):(i*mixturesNumber)));
    for x=edgesFChange
        for y=edgesFHigh
            for z=edgesFLow
                p = pdf(gm_s{i},[x' y' z']);
                   
                x_d = find(edgesFChange==x);
                y_d = find(edgesFHigh==y);
                z_d = find(edgesFLow==z);
                n = map3DTo1D(x_d,y_d,z_d,numberOfPoints(1),numberOfPoints(2));

                emissionProbabilities(i,n) = p;
            end
        end
    end
    emissionProbabilities(i,:) = emissionProbabilities(i,:)./sum(emissionProbabilities(i,:));
end

%observations_train = convertVectorToCellArray(observations', latency);

observations_train = zeros(length(Date_l)-latency,latency);

for i=1:(length(Date_l)-latency)
    observations_train(i,:) = observations(i:(i+latency-1));
end

[ESTTR,ESTEMIT] = hmmtrain(observations(startIndex:endIndex), transitionMatrix, emissionProbabilities,'Verbose',true);



