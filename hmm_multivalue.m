close all
clear
clc

disp("Init");
load AAPL.mat;  % Date Open Close High Low

TRAIN = 1;      % see train section: if 0 a specified .mat file is loaded
                %                    if 1 a new training is done

shiftByOne = 1; % see sequences train section: if 0 a new sequence is grouped every #days = latency
                %                              if 1 a new sequence is grouped every day

% select period of observation, date format MM/DD/YYYY
llim = indexOfDate(Date,'2017-01-03');
ulim = indexOfDate(Date,'2018-01-02');

startPred = indexOfDate(Date,'2022-01-03'); % first day of prediction
lastDate  = indexOfDate(Date, Date(end));   % last avaiable date
predictionLength = 350;                     % how many days of prediction starting from startPred
                                            % must not exceed (lastDate-startPred)                                           
if ((startPred+predictionLength)>lastDate) 
        error('Wrong interval');
end

Date_l = Date(llim:ulim);      % indexes to easily access loaded data

% sequences of observations of three different parameters
fracChange = (Open(llim:ulim) - Close(llim:ulim))./Open(llim:ulim);
fracHigh   = (High(llim:ulim) - Open(llim:ulim)) ./Open(llim:ulim);
fracLow    = (Open(llim:ulim) - Low(llim:ulim))  ./Open(llim:ulim);
% sequences of observations grouped in a three columns matrix
continuous_observations3D = [fracChange, fracHigh, fracLow];

% uniform intervals to discretize observed parameters
numberOfPoints = [50 10 10];
edgesFChange = linspace(-0.1,0.1,numberOfPoints(1)+1);
edgesFHigh = linspace(0,0.1,numberOfPoints(2)+1);
edgesFLow = linspace(0,0.1,numberOfPoints(3)+1);
% discretization of each parameter sequence (overscribed)
[fracChange, ~] = discretize(fracChange, edgesFChange,'IncludedEdge','right');
[fracHigh,   ~] = discretize(fracHigh, edgesFHigh,'IncludedEdge','right');
[fracLow,    ~] = discretize(fracLow, edgesFLow,'IncludedEdge','right');

% discretized sequences of observations grouped in a three columns matrix
% observations3D = [fracChange, fracHigh, fracLow];

% discretized sequences mapped into a monodimensional array
observations = zeros(length(Date_l), 1);
for i = 1:length(Date_l)
    observations(i) = map3DTo1D(fracChange(i), fracHigh(i), fracLow(i), numberOfPoints(1), numberOfPoints(2),numberOfPoints(3));
end

underlyingStates = 4; % number of hidden states
mixturesNumber = 4;   % number of mixture components for each state
latency = 10;         % days aka vectors in sequence

%% Markov Chain guesses
disp("Markov Chain guesses")
% initialProb = 1/underlyingStates.*ones(1, underlyingStates); % initial probabilities of the states

% transition matrix initialized assuming uniform distribution of probabilities 
transitionMatrix = 1/underlyingStates.*ones(underlyingStates, underlyingStates);
% Gaussian Mixture Models fitting
gm3D = fitgmdist(continuous_observations3D, mixturesNumber*underlyingStates, 'CovarianceType', 'diagonal', 'RegularizationValue', 1e-10, 'Replicates', 10);

% mu sorting
mu_sorted = zeros(mixturesNumber*underlyingStates,3);
[mu_sorted(:,1), mu_index] = sort(gm3D.mu(:,1), 1);
mu_sorted(:,2:3) = gm3D.mu(mu_index,2:3);
% sigma sorting
sigma_sorted = gm3D.Sigma(1, 1:3, mu_index);

% emission probabilities initialized to zeros
totalPoints = numberOfPoints(1)*numberOfPoints(2)*numberOfPoints(3);
emissionProbabilities = zeros(underlyingStates,totalPoints);

% Gaussian Mixture Model for each hidden state
gm_s = cell(underlyingStates, 1); % _s as state
for i = 1:underlyingStates
    gm_s{i} = gmdistribution(mu_sorted((1+(i-1)*mixturesNumber):(i*mixturesNumber),:), ...
                             sigma_sorted(1,:,(1+(i-1)*mixturesNumber):(i*mixturesNumber)));
    
    for x=edgesFChange(1:end-1)
        for y=edgesFHigh(1:end-1)
            for z=edgesFLow(1:end-1)

                % probability of state i emitting observation [x,y,z]
                p = pdf(gm_s{i},[x y z]);
                % 3D indexes for observation [x,y,z]
                x_d = find(edgesFChange==x);
                y_d = find(edgesFHigh==y);
                z_d = find(edgesFLow==z);
                % mapping 3D indexes into 1D indexcontinuous_observations3D n
                n = map3DTo1D(x_d,y_d,z_d,numberOfPoints(1),numberOfPoints(2),numberOfPoints(3));
                % (i,n) element filled: i = state i, n = 1D emission index 
                emissionProbabilities(i,n) = p;
            end
        end
    end
    % scaled probabilities of state i emitting each of total #observations = totalPoints
    emissionProbabilities(i,:) = emissionProbabilities(i,:)./sum(emissionProbabilities(i,:));
end

%% train sequences
% construction of matrix observations_train containing train sequences of
% discretized monodimensional values

if (shiftByOne) % interval shifted by #days = 1
    observations_train = zeros(length(Date_l)-latency,latency);
    for i=1:(length(Date_l)-latency)
        observations_train(i,:) = observations(i:(i+latency-1));
    end
else            % interval shifted by #days = latency
    observations_train = zeros(ceil(length(Date_l) / latency)-1,latency); %#ok<UNRCH>
    for i=1:ceil(length(Date_l) / latency)-1
       startIndex = (i - 1) * latency + 1;
       endIndex = startIndex + latency - 1;
       observations_train(i,:) = observations(startIndex:endIndex);
    end
end

%% train
disp("Train")
if (TRAIN)
    maxIter = 500;      %#ok<UNRCH>
    trainInfo = struct('maxIter', maxIter, 'converged', 0, 'trainingTime', -1);
    lastwarn('', '');

    % construction of transition and emission matrixes
    tic                             % start stopwatch
    [ESTTR,ESTEMIT] = hmmtrain(observations_train, transitionMatrix, emissionProbabilities,'Verbose',true,'Maxiterations', maxIter);
    trainInfo.trainingTime = toc;   % stop

    [warnMsg, warnId] = lastwarn();
    if(isempty(warnId))
        trainInfo.converged = 1;
    else
        %error(warnMsg, warnId);
        trinInfo.converged = 0;
    end
    save(strcat("hmmtrain-", string(datetime('now', 'format', 'yyyy-MM-dd-HH-mm-ss')), ".mat"), "ESTTR", "ESTEMIT","trainInfo");
else
    load("hmmtrain-2023-07-06-13-18-13.mat");
end

% play sound when training is finished
load handel
sound(y,Fs)
%% predizione
disp("Prediction")
% initialization of 3D predicted observations
predObservations3D = zeros(predictionLength, 3);
% initialization of Close values based on predicted data 
predictedClose     = zeros(predictionLength, 1);

for t = 1:predictionLength
    %disp("Predizione " + t);
    llimPred = (startPred - latency + t);    
    ulimPred = (startPred + t -1);           

    predictionFracChange = (Open(llimPred:ulimPred) - Close(llimPred:ulimPred))./Open(llimPred:ulimPred);
    predictionFracHigh   = (High(llimPred:ulimPred) - Open(llimPred:ulimPred))./Open(llimPred:ulimPred);
    predictionFracLow    = (Open(llimPred:ulimPred) - Low(llimPred:ulimPred))  ./Open(llimPred:ulimPred);
    %discretization of data during current observation interval    
    predictionFracChange = discretize(predictionFracChange, edgesFChange);
    predictionFracHigh   = discretize(predictionFracHigh, edgesFHigh);
    predictionFracLow    = discretize(predictionFracLow, edgesFLow);
    % initialization of 1D mapped discretized data
    predictionObservations = zeros(1, latency);
    for i = 1:latency
        predictionObservations(i) = map3DTo1D(predictionFracChange(i), predictionFracHigh(i), predictionFracLow(i), numberOfPoints(1), numberOfPoints(2), numberOfPoints(3));
    end
    %prediction
    predictedObs = hmmPredictObservation(predictionObservations, ESTTR, ESTEMIT, 'verbose', 1, 'possibleObservations', 1:totalPoints);
    
    if (~isnan(predictedObs))
        % 3D mapping of current valid prediction
        [predictedFC, predictedFH, predictedFL] = map1DTo3D(predictedObs, numberOfPoints(1), numberOfPoints(2), numberOfPoints(3));
        % t-th row filled with current 3D valid prediction
        predObservations3D(t,:) = [edgesFChange(predictedFC), edgesFHigh(predictedFH), edgesFLow(predictedFL)];
    else 
        predObservations3D(t,:) = NaN;  % invalid prediction
    end
    
    if (isnan(predictedObs))    % invalide prediction corresponds to invalid value for Close
        predictedClose(t) = NaN;    
    else                        % t-th element filled with Close value based on predicted fractional change
        predictedClose(t) = Open(ulimPred+1) * (1 - predObservations3D(t,1));
    end
end

%% grafici
disp("Plots")
lastPredDate = (startPred  + predictionLength);

% initialization of MAPE 
MAPE = 0;

figure(Name='Real vs predicted data')
p1 = plot(Date(llim : lastPredDate), Close(llim:lastPredDate));
grid on
hold on
p1.LineWidth = 0.3;
p1.Marker = '.';
p1.MarkerSize = 5;

prediction = struct('good', 0, 'bad', 0, 'invalid', 0);
p2 = gobjects(predictionLength - 1, 1);
%p2 = plot(Date(ulim +1 : lastPredDate), predictedClose);
for i=1:predictionLength %- 1   % ho tolto il -1 perchè non mi trovavo -L
    if (~isnan(predictedClose(i)))     % se è riuscito a fare una previsione
        p2(i) = plot(Date(startPred + i - 1 : startPred + i), [Close(startPred + i -1), predictedClose(i)]);
        if (sign(predictedClose(i) - Close(startPred + i - 1)) == sign(Close(startPred + i) - Close(startPred + i - 1)))
            % se il segno della derivata è corretto
            p2(i).Color = 'g';
            prediction.good = prediction.good + 1;
        else    % il segno della derivata è sbagliato :(
            p2(i).Color='r';
            prediction.bad = prediction.bad + 1;
        end
        p2(i).LineWidth = 0.3;
        p2(i).Marker = '.';
        p2(i).MarkerSize = 5;

        % la predizione è corretta -> MAPE
        MAPE = MAPE + abs((Close(startPred + i) - predictedClose(i))/Close(startPred + i));
    else
        % incremento il conteggio di predizioni non valide
        prediction.invalid = prediction.invalid + 1;
    end
end

title('andamento prezzi dati reali vs predizione')

% Stampo riepilogo
disp("------------------------------")
fprintf("Total predictions: %d (%.2f%%)\nCorrect derivative: %d (%.2f%%)\nWrong derivative: %d (%.2f%%)\n", ...
    prediction.bad + prediction.good, 100*(prediction.bad + prediction.good)/predictionLength, ...
    prediction.good, 100 * prediction.good / (prediction.bad + prediction.good), ...
    prediction.bad, 100 * prediction.bad / (prediction.bad + prediction.good));

% Calcolo MAPE
MAPE = MAPE / (prediction.bad + prediction.good);
% quando tutte le predictedClose saranno diverse da zero, posso calcolare
% il MAPE fuori dal loop così:
% MAPE = 1/(predictionLength - 1) * sum(abs(Close(ulim+1:ulim+predictionLength) - predictedClose(1:predictionLength)) ./ abs(Close(ulim+1:ulim+predictionLength)), 'all');
fprintf("Mean Absolute Percentage Error (MAPE): %.2f%%\n", MAPE*100);


figure(Name="Grafico marketing")
plot(Date(startPred+1:startPred+predictionLength),Close(startPred+1:startPred+predictionLength),'Marker','.');
hold on
plot(Date(startPred+1:startPred+predictionLength),predictedClose,'Color','red','Marker','.')
grid
