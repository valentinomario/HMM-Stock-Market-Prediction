close all
clear
clc
load Data.mat;  % Date Open Close High Low

% TUTTE LE DATE SONO NEL FORMATO MM/DD/YYYY
% selezioniamo un periodo di osservazione
llim = indexOfDate(Date,'01/03/2008');
ulim = indexOfDate(Date,'01/02/2020');
train_size = 3000;
Date_l = Date(llim:ulim);
fracChange = (Open(llim:ulim) - Close(llim:ulim))./Open(llim:ulim);
fracHigh = (High(llim:ulim) - Close(llim:ulim))./Open(llim:ulim);
fracLow = (Open(llim:ulim) - Low(llim:ulim))./Open(llim:ulim);

observations = [fracChange, fracHigh, fracLow];
% preleviamo solo i primi campioni per il training del modello
observations_train = observations(1:train_size, :);

% le osservazioni devono essere campionate: vedere tabella II del paper
number_of_points = [50, 10, 10];
observations_train = [discretizeSequence(observations_train(:,1), number_of_points(1)),...
    discretizeSequence(observations_train(:,2), number_of_points(2)),...
    discretizeSequence(observations_train(:,3), number_of_points(3))];

% Parameters
underlyingStates = 4;
m = 4; % Number of mixture components for each state
latency = 10; % days

% Clustering observations
% figure
% subplot(3,3,1);
% plot(observations_train(:,1), observations_train(:,1),'o')
% subplot(3,3,2);
% plot(observations_train(:,1), observations_train(:,2),'o')
% subplot(3,3,3);
% plot(observations_train(:,1), observations_train(:,3),'o')
% 
% subplot(3,3,4);
% plot(observations_train(:,2), observations_train(:,1),'o')
% subplot(3,3,5);
% plot(observations_train(:,2), observations_train(:,2),'o')
% subplot(3,3,6);
% plot(observations_train(:,2), observations_train(:,3),'o')
% 
% subplot(3,3,7);
% plot(observations_train(:,3), observations_train(:,1),'o')
% subplot(3,3,8);
% plot(observations_train(:,3), observations_train(:,2),'o')
% subplot(3,3,9);
% plot(observations_train(:,3), observations_train(:,3),'o')

% Markov Chain guesses
P = 1/underlyingStates.*ones(1, underlyingStates); % initial probabilities of the states
A = 1/underlyingStates.*ones(underlyingStates, underlyingStates); % transition matrix

%[m,v] = kmeansMeanVariance(observations_train,m);
%gm = gmdistribution(m,v);

% calcoliamo la gaussian mixture distribution
% TODO: garantire convergenza fitgmdist
gm = fitgmdist(observations_train,m);
% la covarianza del gruppo i-esimo è data da gm.Sigma(:,:,i)

% la funzione hmmtrain richiede:
% - un cell array contenente, in ogni cella, una sequenza di osservazioni
% - una guess iniziale per la matrice delle transizioni
% - una guess iniziale per la matrice delle emissioni (valutata dalla
%    gaussian mixture) (di dimensione n_stati x n_uscite, vedi riga 20)
% TODO: ricavare guess iniziale matrice delle emissioni
observations_train_cell = convertToCellArray(observations_train, latency);
[ESTTR,ESTEMIT] = hmmtrain(observations_train_cell, A, gm);

figure
plot(Date_l,Close(llim:ulim));
figure
subplot(3,1,1)
bar(Date_l,fracChange)
title('Frac Change')
subplot(3,1,2)
bar(Date_l,fracHigh)
title('Frac High')
subplot(3,1,3)
bar(Date_l,fracLow)
title('Frac Low')