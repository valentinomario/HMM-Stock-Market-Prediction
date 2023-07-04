close all
clear
clc
load('AAPL.mat')
% TUTTE LE DATE SONO NEL FORMATO MM/DD/YYYY
% selezioniamo un periodo di osservazione
llim = indexOfDate(Date,'2003-02-10');
ulim = indexOfDate(Date,'2004-09-10');
train_size = 365;
Date_l = Date(llim:ulim);
fracChange = (Open(llim:ulim) - Close(llim:ulim))./Open(llim:ulim);
% fracHigh = (High(llim:ulim) - Close(llim:ulim))./Open(llim:ulim);
% fracLow = (Open(llim:ulim) - Low(llim:ulim))./Open(llim:ulim);

observations = fracChange; % [fracChange, fracHigh, fracLow];
% preleviamo solo i primi campioni per il training del modello
observations_train = observations(1:train_size);

% le osservazioni devono essere campionate: vedere tabella II del paper
%number_of_points = [50, 10, 10];
number_of_points = 5000;
%observations_train_discr = [discretizeSequence(observations_train, number_of_points(1))];

% Parameters
underlyingStates = 4;
m = 5; % Number of mixture components for each state
latency = 10; % days

% Markov Chain guesses
P = 1/underlyingStates.*ones(1, underlyingStates); % initial probabilities of the states
A = 1/underlyingStates.*ones(underlyingStates, underlyingStates); % transition matrix

%[m,v] = kmeansMeanVariance(observations_train,m);
%gm = gmdistribution(m,v);

% calcoliamo la gaussian mixture distribution
% TODO: garantire convergenza fitgmdist
gm = fitgmdist(observations_train,m*underlyingStates,'CovarianceType','diagonal','RegularizationValue',0);
% la covarianza del gruppo i-esimo è data da gm.Sigma(:,:,i)

% la funzione hmmtrain richiede:
% - un cell array contenente, in ogni cella, una sequenza di osservazioni
% - una guess iniziale per la matrice delle transizioni
% - una guess iniziale per la matrice delle emissioni (valutata dalla
%    gaussian mixture) (di dimensione n_stati x n_uscite, vedi riga 20)
% TODO: ricavare guess iniziale matrice delle emissioni
%emguess = ones(underlyingStates,number_of_points) ./ (underlyingStates*number_of_points);
pdf_step = 0.2/number_of_points;
pdf_samples = [-0.1+pdf_step:pdf_step:0.1]';
%TODO: una emguess per ogni gaussiana
emguess = pdf(gm,pdf_samples)';
plot(pdf_samples,emguess);
[obs_seq, edges] = discretize(observations_train,number_of_points);
observations_train_cell = convertVectorToCellArray(obs_seq', latency);
[ESTTR,ESTEMIT] = hmmtrain(observations_train_cell, A, emguess);
