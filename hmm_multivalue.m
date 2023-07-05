close all
clear
clc

TRAIN = 0;

load AAPL.mat;  % Date Open Close High Low

% TUTTE LE DATE SONO NEL FORMATO MM/DD/YYYY
% selezioniamo un periodo di osservazione
llim = indexOfDate(Date,'2003-02-10');
ulim = indexOfDate(Date,'2004-09-10');
%train_size = 365;
Date_l = Date(llim:ulim);
fracChange = (Open(llim:ulim) - Close(llim:ulim))./Open(llim:ulim);
fracHigh   = (High(llim:ulim) - Close(llim:ulim))./Open(llim:ulim);
fracLow    = (Open(llim:ulim) - Low(llim:ulim))  ./Open(llim:ulim);

continuos_observations3D = [fracChange, fracHigh, fracLow];

numberOfPoints = [50 10 10];
[fracChange, edgesFChange] = discretize(fracChange, numberOfPoints(1)-1);
[fracHigh, edgesFHigh]     = discretize(fracHigh, numberOfPoints(2)-1);
[fracLow, edgesFLow]       = discretize(fracLow, numberOfPoints(3)-1);

observations3D = [fracChange, fracHigh, fracLow];

observations = zeros(length(Date_l), 1);
for i = 1:length(Date_l)
    observations(i) = map3DTo1D(fracChange(i), fracHigh(i), fracLow(i), numberOfPoints(1), numberOfPoints(2));
end

underlyingStates = 4;
mixturesNumber = 5; % Number of mixture components for each state
latency = 10; % days aka vectors in sequence

%% Markov Chain guesses
initialProb = 1/underlyingStates.*ones(1, underlyingStates); % initial probabilities of the states
transitionMatrix = 1/underlyingStates.*ones(underlyingStates, underlyingStates); % transition matrix

gm3D = fitgmdist(continuos_observations3D, mixturesNumber*underlyingStates, 'CovarianceType', 'diagonal', 'RegularizationValue', 1e-10, 'Replicates', 10);

% mu sorting
mu_sorted = zeros(mixturesNumber*underlyingStates,3);
[mu_sorted(:,1), mu_index] = sort(gm3D.mu(:,1), 1);
mu_sorted(:,2:3) = gm3D.mu(mu_index,2:3);

% sigma sorting
sigma_sorted = gm3D.Sigma(1, 1:3, mu_index);

emissionProbabilities = zeros(underlyingStates,5000);
for i = 1:underlyingStates
    gm_s{i} = gmdistribution(mu_sorted((1+(i-1)*mixturesNumber):(i*mixturesNumber),:), ...
                             sigma_sorted(1,:,(1+(i-1)*mixturesNumber):(i*mixturesNumber)));
    % TODO delta edges
    for x=edgesFChange
        for y=edgesFHigh
            for z=edgesFLow
                p = pdf(gm_s{i},[x y z]);
                   
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

%% finestra
%observations_train = convertVectorToCellArray(observations', latency);

% finestra traslata di 1

observations_train = zeros(length(Date_l)-latency,latency);
for i=1:(length(Date_l)-latency)
    observations_train(i,:) = observations(i:(i+latency-1));
end

% finestra traslata di 10

% observations_train = zeros(ceil(length(Date_l) / latency),latency);
% for i=1:ceil(length(Date_l) / latency)
%    startIndex = (i - 1) * latency + 1;
%    endIndex = min(startIndex + latency - 1, length(Date_l));
%    observations_train(i,:) = observations(startIndex:endIndex);
% end

%% train

if (TRAIN)
    maxIter = 500;      %#ok<UNRCH> 
    trainInfo = struct('maxIter', maxIter, 'converged', 0, 'trainingTime', -1);
    lastwarn('', '');
    tic     % start cronometro
    [ESTTR,ESTEMIT] = hmmtrain(observations_train, transitionMatrix, emissionProbabilities,'Verbose',true,'Maxiterations', maxIter);
    trainInfo.trainingTime = toc;   % fine cronometro
    [warnMsg, warnId] = lastwarn();
    if(isempty(warnId))
        trainInfo.converged = 1;
    else
        %error(warnMsg, warnId);
        trinInfo.converged = 0;
    end
    save(strcat("hmmtrain-", string(datetime('now', 'format', 'yyyy-MM-dd-HH-mm-ss')), ".mat"), "ESTTR", "ESTEMIT","trainInfo");
else
    load("hmmtrain converged.mat");
end

% ESTTR   = transitionMatrix;
% ESTEMIT = emissionProbabilities;
% for i=1:(length(Date_l)-latency)
%     [ESTTR,ESTEMIT] = hmmtrain(observations(i:(i+latency)), ESTTR, ESTEMIT,'Verbose',true);
% end


%% simulazione hmmgenerate

[sequence, states] = hmmgenerate(length(Date_l), ESTTR, ESTEMIT);

prices = zeros(1,length(sequence));
prices(1) = Close(llim);

for i = 1:length(sequence)
    [fCtemp, fHtemp, fLtemp] = map1DTo3D(sequence(i), numberOfPoints(1), numberOfPoints(2));
    fC(i) = edgesFChange(fCtemp);
    fH(i) = edgesFHigh(fHtemp);
    fL(i) = edgesFLow(fLtemp);
end

for i = 2:length(sequence)
    prices(i) = prices(i-1)*(1 - fC(i)); 
end

figure
subplot(2,1,1)
plot(Date_l,Close(llim:ulim));
grid on
title('andamento prezzi dati reali')
subplot(2,1,2)
plot(Date_l,prices);
grid on
title('andamento prezzi simulazione')

figure
subplot(3,1,1)
bar(Date_l,continuos_observations3D(:,1))
title('Frac Change')
subplot(3,1,2)
bar(Date_l,continuos_observations3D(:,2))
title('Frac High')
subplot(3,1,3)
bar(Date_l,continuos_observations3D(:,3))
title('Frac Low')

figure
subplot(3,1,1)
bar(Date_l,fC)
title('Frac C')
subplot(3,1,2)
bar(Date_l,fH)
title('Frac H')
subplot(3,1,3)
bar(Date_l,fL)
title('Frac L')

%% predizione

predictionLength = 360;
predObservations3D = zeros(predictionLength, 3);
predictedClose = zeros(predictionLength,1);

for t = 1:predictionLength
    disp("Predizione " + t);
%vecchi estremi del 04/07
%     llimPred = (ulim - latency + 1 + t);
%     ulimPred = (ulim + t);

    llimPred = (ulim - latency + t);    
    ulimPred = (ulim + t -1);           

    predictionFracChange = (Open(llimPred:ulimPred) - Close(llimPred:ulimPred))./Open(llimPred:ulimPred);
    predictionFracHigh   = (High(llimPred:ulimPred) - Close(llimPred:ulimPred))./Open(llimPred:ulimPred);
    predictionFracLow    = (Open(llimPred:ulimPred) - Low(llimPred:ulimPred))  ./Open(llimPred:ulimPred);
        
    predictionFracChange = discretize(predictionFracChange, edgesFChange);
    predictionFracHigh   = discretize(predictionFracHigh, edgesFHigh);
    predictionFracLow    = discretize(predictionFracLow, edgesFLow);
        
    predictionObservations = zeros(1, latency);
    for i = 1:latency
        predictionObservations(i) = map3DTo1D(predictionFracChange(i), predictionFracHigh(i), predictionFracLow(i), numberOfPoints(1), numberOfPoints(2));
    end

    predictedObs = hmmPredictObservation(predictionObservations, ESTTR, ESTEMIT, 'verbose', 1, 'possibleObservations', 1:5000);
    if(~isnan(predictedObs))
        [predictedFC, predictedFH, predictedFL] = map1DTo3D(predictedObs, numberOfPoints(1), numberOfPoints(2));
        predObservations3D(t,:) = [edgesFChange(predictedFC), edgesFHigh(predictedFH), edgesFLow(predictedFL)];
    else
        predObservations3D(t,:) = NaN;
    end
    % !!! prima era Open(ulimPred+t), lucy e ludo credono fosse sbagliato
    if(isnan(predictedObs))
        predictedClose(t)=0;
    else
        predictedClose(t) = Open(ulimPred+1) * (1 - predObservations3D(t,1));
    end
end

%% grafici

lastPredDate = (ulim  + predictionLength);

figure(Name='Real vs predicted data')
p1 = plot(Date(llim : lastPredDate), Close(llim:lastPredDate));
grid on
hold on
p1.LineWidth = 0.3;
p1.Marker = '.';
p1.MarkerSize = 5;

%p2 = plot(Date(ulim +1 : lastPredDate), predictedClose);
for i=1:predictionLength -1
    p2 = plot(Date(ulim + i -1 :ulim+i),[ Close(ulim + i -1) predictedClose(i)]);
    p2.Color='r';
    p2.LineWidth = 0.3;
    p2.Marker = '.';
    p2.MarkerSize = 5;
end
% p2.Color='r';
% p2.LineWidth = 0.3;
% p2.Marker = '.';
% p2.MarkerSize = 5;
title('andamento prezzi dati reali vs predizione')








