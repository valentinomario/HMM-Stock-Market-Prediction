function tensor = prepareSequenceTensor(dataMatrix, d)
% prepareSequenceTensor: Prepara un tensore di dimensione o per d per (t - d + 1)
% a partire da una matrice di dimensione t per o, in cui ogni riga
% rappresenta un'osservazione composta da o valori.
% Il tensore rappresenta le sequenze di osservazioni
% ottenute da una finestratura continua di dimensione d delle t
% osservazioni.
%
% Uso:
%   tensor = prepareSequenceTensor(dataMatrix, d)
%
% Input:
%   - dataMatrix: Una matrice di dimensione t per o contenente le osservazioni originali.
%   - d: Il numero di osservazioni desiderate per ogni sequenza.
%
% Output:
%   - tensor: Un tensore di dimensione o per d per (t/d) contenente le sequenze di osservazioni.
%
% Esempio:  TODO

    % Ottiene le dimensioni della matrice di dati
    [t, o] = size(dataMatrix);
    
    % Calcola il numero di sequenze
    numSequences = t-d+1;
    
    % Inizializza il tensore delle sequenze
    tensor = zeros(o, d, numSequences);
    
    % Riorganizza le osservazioni nel tensore delle sequenze
    for i = 1:numSequences
        startIndex = i;
        endIndex = i + d - 1;
        tensor(:,:,i) = dataMatrix(startIndex:endIndex,:)';
    end
end

