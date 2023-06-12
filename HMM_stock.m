close all

ulim = indexOfDate(Date,'01/02/1998');
llim = indexOfDate(Date,'01/02/2020');
train_size = 3000;
Date_l = Date(llim:ulim);
fracChange = (Open(llim:ulim) - Close(llim:ulim))./Open(llim:ulim);
fracHigh = (High(llim:ulim) - Close(llim:ulim))./Open(llim:ulim);
fracLow = (Open(llim:ulim) - Low(llim:ulim))./Open(llim:ulim);

observations=[fracChange, fracHigh, fracLow];
observations_train = observations(1:train_size,:);
% Parameters
underlyingStates = 4;
m = 5; % Number of mixture components for each state
latency = 10; % days

% Clustering observations

figure
subplot(3,3,1);
plot(observations_train(:,1), observations_train(:,1),'o')
subplot(3,3,2);
plot(observations_train(:,1), observations_train(:,2),'o')
subplot(3,3,3);
plot(observations_train(:,1), observations_train(:,3),'o')

subplot(3,3,4);
plot(observations_train(:,2), observations_train(:,1),'o')
subplot(3,3,5);
plot(observations_train(:,2), observations_train(:,2),'o')
subplot(3,3,6);
plot(observations_train(:,2), observations_train(:,3),'o')

subplot(3,3,7);
plot(observations_train(:,3), observations_train(:,1),'o')
subplot(3,3,8);
plot(observations_train(:,3), observations_train(:,2),'o')
subplot(3,3,9);
plot(observations_train(:,3), observations_train(:,3),'o')

% Markov Chain guesses
P = 1/underlyingStates.*ones(1,underlyingStates); % initial probabilities of the states
A = 1/underlyingStates.*ones(1,underlyingStates); % transition matrix

[m,v] = kmeansMeanVariance(observations_train,m);

figure
plot(Date_l,Close(llim:ulim));
figure
subplot(3,1,1)
bar(Date_l,fracChange)
subplot(3,1,2)
bar(Date_l,fracHigh)
subplot(3,1,3)
bar(Date_l,fracLow)