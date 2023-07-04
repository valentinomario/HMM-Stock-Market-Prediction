function predictedObservation = hmmPredictObservation(obsSeq, transMatrix, emissMatrix, varargin)
% hmmPredictObservation: Predice l'osservazione successiva in un modello di Markov a stati nascosti (HMM).
%
% Uso:
%   predictedObservation = hmmPredictObservation(obsSeq, transMatrix, emissMatrix, varargin)
%
% Input:
%   - obsSeq: La sequenza di osservazioni per cui si vuole predire l'osservazione successiva.
%   - transMatrix: La matrice di transizione che rappresenta le probabilità di transizione tra gli stati del modello HMM.
%   - emissMatrix: La matrice di emissione che rappresenta le probabilità di emissione delle diverse osservazioni per ogni stato del modello HMM.
%   - varargin: Coppie di parametri opzionali (nome, valore) per configurare il comportamento della funzione.
%       - 'verbose': Un flag opzionale per abilitare la stampa di informazioni dettagliate. Valore predefinito: 0 (disabilitato).
%       - 'possibleObservations': Un vettore delle possibili osservazioni per la predizione dell'osservazione successiva.
%
% Output:
%   - predictedObservation: L'osservazione predetta come successiva nella sequenza.
%
p = inputParser;
addParameter(p, 'verbose', 0)
addParameter(p, 'possibleObservations', [])
parse(p, varargin{:})
verbose = p.Results.verbose;
possibleObservations = p.Results.possibleObservations;

if isempty(possibleObservations)
    [states, logPSeq] = hmmdecode(obsSeq, transMatrix, emissMatrix);
    
    lastStateP = states(:,end);
    nextStateP = transMatrix' * lastStateP; % è una colonna 
    nextObsP = emissMatrix' * nextStateP;   % ancora una colonna
    
    [pObs, predictedObservation] = max(nextObsP);
    if (verbose)
        fprintf("Logaritmo probabilita' sequenza: %1$.4f\nProbabilita' osservazione: %2$.4f", logPSeq, pObs);
    end
else
    maxLogPSeq = -Inf;
    mostLikelyObs = NaN;
    for possibleObs = possibleObservations
        [~, logPSeq] = hmmdecode([obsSeq, possibleObs], transMatrix, emissMatrix);
        if (maxLogPSeq < logPSeq)
            maxLogPSeq = logPSeq;
            mostLikelyObs = possibleObs;
        end
    end
    predictedObservation = mostLikelyObs;
    if (verbose)
        fprintf("Logaritmo probabilita' sequenza: %1$.4f\n", maxLogPSeq);
    end
end








