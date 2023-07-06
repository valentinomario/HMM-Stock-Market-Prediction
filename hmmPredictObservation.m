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
    % Se non sono specificate possibili osservazioni, esegui la predizione
    % utilizzando l'approccio standard: cerco di tradurre la sequenza di
    % osservazioni in una sequenza di stati, valuto la probabilità per
    % ognuno dei possibili prossimi stati, prendo l'emissione con massima
    % probabilità

    [states, logPSeq] = hmmdecode(obsSeq, transMatrix, emissMatrix);
    
    lastStateP = states(:,end);
    % Calcolo delle probabilità per ogni possibile prossimo stato
    nextStateP = transMatrix' * lastStateP; % è una colonna 
    % Calcolo delle probabilità per ogni possibile emissione
    nextObsP = emissMatrix' * nextStateP;   % ancora una colonna
    % Scelgo l'emissione con massima probabilità
    [pObs, predictedObservation] = max(nextObsP);
    if (verbose)
        fprintf("Logaritmo probabilita' sequenza: %1$.4f\nProbabilita' osservazione: %2$.4f", logPSeq, pObs);
    end
else
    % avendo a disposizione il (sub)set delle possibili osservazioni,
    % calcolo la likelihood della sequenza [sequenzaData osservazione].
    % alla fine scelgo l'osservazione la cui sequenza ha la max likelihood

    maxLogPSeq = -Inf;
    mostLikelyObs = NaN;
    converged = 0;
    while converged==0
        for possibleObs = possibleObservations      % per ogni possibile osservazione
            [~, logPSeq] = hmmdecode([obsSeq, possibleObs], transMatrix, emissMatrix);  % come alternativa possiamo mettere obsSeq(2:end), così che la sequenza sia lunga 10
            if (maxLogPSeq < logPSeq)
                maxLogPSeq = logPSeq;
                mostLikelyObs = possibleObs;
            end
        end

        if maxLogPSeq == -inf
            if length(obsSeq)>3
                obsSeq = obsSeq(2:end);
            else
                converged = 1;
            end
        else
            converged = 1;
        end

    end
    predictedObservation = mostLikelyObs;
    if (verbose)
        fprintf("Logaritmo probabilita' sequenza: %1$.4f\n", maxLogPSeq);
    end
end








