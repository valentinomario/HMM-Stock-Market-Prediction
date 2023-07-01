% La funzione convertToCellArray converte un vettore di dati in un cell array con un numero specificato di osservazioni per cella.
%
% Parametri di input:
%   - dataVector: Il vettore di dati da convertire.
%   - observationsPerCell: Il numero di osservazioni desiderate per ogni cella.
%
% Parametri di output:
%   - cellArray: Il cell array contenente le osservazioni suddivise nelle celle.
%
function cellArray = convertVectorToCellArray(dataVector, observationsPerCell)
    % Calcola il numero totale di osservazioni
    numObservations = numel(dataVector);
    
    % Calcola il numero totale di celle
    numCells = ceil(numObservations / observationsPerCell);
    
    % Inizializza il cell array
    cellArray = cell(numCells, 1);
    
    % Riempie il cell array con le osservazioni
    for i = 1:numCells
        startIndex = (i - 1) * observationsPerCell + 1;
        endIndex = min(startIndex + observationsPerCell - 1, numObservations);
        cellArray{i} = dataVector(startIndex:endIndex);
    end
end