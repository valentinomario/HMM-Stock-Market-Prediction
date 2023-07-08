function predictedObservation = hmmPredictObservation(obsSeq, transMatrix, emissMatrix, varargin)
% hmmPredictObservation: Predicts the next observation in a Hidden Markov Model (HMM).

% Usage:
%   predictedObservation = hmmPredictObservation(obsSeq, transMatrix, emissMatrix, varargin)

% Input:
% - obsSeq: The sequence of observations for which the next observation is to be predicted.
% - transMatrix: The transition matrix representing the transition probabilities between the states of the HMM model.
% - emissMatrix: The emission matrix representing the probabilities of emitting different observations for each state of the HMM model.
% - varargin: Optional parameter-value pairs to configure the behavior of the function.
%   - 'verbose': An optional flag to enable verbose information printing. Default: 0 (disabled).
%   - 'possibleObservations': A vector of possible observations for predicting the next observation.
%   - 'dynamicWindow': An optional flag to enable dynamic windowing for convergence. Default: 1 (enabled).

% Output:
% - predictedObservation: The predicted observation as the next one in the sequence.

p = inputParser;
addParameter(p, 'verbose', 0)
addParameter(p, 'possibleObservations', [])
addParameter(p, 'dynamicWindow',1)

parse(p, varargin{:})
verbose = p.Results.verbose;
possibleObservations = p.Results.possibleObservations;
dynamicWindow = p.Results.dynamicWindow;

if isempty(possibleObservations)
    % If no possible observations are specified, predict using the standard approach:
    %  - Estimate a sequence of states from observation sequence
    %  - Evaluate the probabilities for each of possible next state
    %  - Evaluate the probabilities for each of possible emissions, given each
    %    possible transition (given nextStateP)
    %  - Choose the emission with the highest probability.

    [states, logPSeq] = hmmdecode(obsSeq, transMatrix, emissMatrix);
    lastStateP = states(:,end);
    nextStateP = transMatrix' * lastStateP;   % column
    nextObsP   = emissMatrix' * nextStateP;   % column
    [pObs, predictedObservation] = max(nextObsP);

    if (verbose)
        fprintf("Log probability of sequence: %1$.4f\nProbabilita' osservazione: %2$.4f", logPSeq, pObs);
    end
else

    % If a (sub)set of possible observations is available:
    %  - Calculate the likelihood of the sequence logPSeq using hmmdecode.
    %  - Finally, choose the observation whose sequence has the maximum likelihood.

    maxLogPSeq = -Inf;
    mostLikelyObs = NaN;
    
    if dynamicWindow
        converged = 0;
    else
        % if dynamicWindow is set to 0, skip the while loop for convergence
        converged = 1;
    end
    
    while converged == 0
        for possibleObs = possibleObservations     % For each possible observation
            [~, logPSeq] = hmmdecode([obsSeq, possibleObs], transMatrix, emissMatrix); 
            % come alternativa possiamo mettere obsSeq(2:end), così che la sequenza sia lunga 10
            if (maxLogPSeq < logPSeq)
                % update maximum likelihood and most likely observation
                maxLogPSeq = logPSeq;
                mostLikelyObs = possibleObs;
            end
        end

        if ((maxLogPSeq == -inf) && (length(obsSeq) > 3))
            % If convergence is not reached, 
            % Remove the first value from the sequence and try hmmdecode
            % again
            obsSeq = obsSeq(2:end);
        else
            converged = 1;
        end

    end

    predictedObservation = mostLikelyObs;
    if (verbose)
        fprintf("Log probability of sequence: %1$.4f\n", maxLogPSeq);
    end

end
