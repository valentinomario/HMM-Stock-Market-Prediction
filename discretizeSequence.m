% La funzione discretizeSequence discretizza una sequenza di valori reali su n punti compresi tra il massimo e il minimo.
%
% Parametri di input:
%   - values: la sequenza di valori reali da discretizzare.
%   - n: il numero di punti desiderati per la discretizzazione.
%
% Parametri di output:
%   - discretizedSequence: la sequenza discretizzata sui punti desiderati.
%
% Esempio di utilizzo:
%   values = [1.2, 2.5, 3.7, 4.9, 5.1, 6.3]; % Sequenza di valori reali
%   n = 5; % 5 punti per la discretizzazione
%   discretizedSequence = discretizeSequence(values, n);
%
function discretizedSequence = discretizeSequence(values, n)
    % Trova il massimo e il minimo della sequenza di valori
    minValue = min(values);
    maxValue = max(values);
    
    % Calcola l'intervallo tra i punti discretizzati
    interval = (maxValue - minValue) / (n - 1);
    
    % Discretizza la sequenza di valori sui punti desiderati
    discretizedSequence = round((values - minValue) / interval) * interval + minValue;
end
