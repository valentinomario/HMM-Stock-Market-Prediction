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

% Parameters
cofficientPerVector = size(observations_train, 2);
underlyingStates = 4;
mixturesNumber = 5; % Number of mixture components for each state
latency = 10; % days aka vectors in sequence

% Markov Chain guesses
P = 1/underlyingStates.*ones(1, underlyingStates); % initial probabilities of the states
A = 1/underlyingStates.*ones(underlyingStates, underlyingStates); % transition matrix

observations_train(:,1) = discretize(observations_train(:,1),500);
observations_train(:,2) = discretize(observations_train(:,2),100);
observations_train(:,3) = discretize(observations_train(:,3),100);
obs_tr_t = prepareSequenceTensor(observations_train, latency);
[mu0, Sigma0, weights] = mixgauss_init(underlyingStates*mixturesNumber, obs_tr_t, 'full');
mu0 = reshape(mu0, [cofficientPerVector underlyingStates mixturesNumber]);
Sigma0 = reshape(Sigma0, [cofficientPerVector cofficientPerVector underlyingStates mixturesNumber]);
%mixmat0 = mk_stochastic(rand(underlyingStates, mixturesNumber));
mixmat0 = reshape(weights,[underlyingStates mixturesNumber]);

[LL, prior1, transmat1, mu1, Sigma1, mixmat1] = mhmm_em(obs_tr_t, P, A, mu0, Sigma0, mixmat0, 'max_iter', 15);

figure
plot(Date_l,Close(llim:ulim)), grid;
figure
subplot(3,1,1)
bar(Date_l,fracChange), grid
title('Frac Change')
subplot(3,1,2)
bar(Date_l,fracHigh), grid
title('Frac High')
subplot(3,1,3)
bar(Date_l,fracLow), grid
title('Frac Low')


