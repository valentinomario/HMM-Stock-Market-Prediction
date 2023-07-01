% La funzione convertToCellArray prende una matrice di n osservazioni di 3 
% parametri e la converte in un cell array in cui ogni cella contiene un
% numero specificato di osservazioni.
% 
% Parametri di input:
%   - dataMatrix: la matrice di n osservazioni di 3 parametri.
%   - observationsPerCell: il numero di osservazioni desiderato per cella.
%
% Parametri di output:
%   - cellArray: il cell array contenente le osservazioni divise in celle.
%
% Esempio di utilizzo:
%   dataMatrix = rand(30, 3); % Matrice di 30 osservazioni di 3 parametri
%   observationsPerCell = 10; % 10 osservazioni per cella
%   cellArray = convertToCellArray(dataMatrix, observationsPerCell);
%
%   % Esempio di accesso alle celle del cell array
%   firstCell = cellArray{1};
%   secondCell = cellArray{2};
%   ...
%   lastCell = cellArray{end};
%
function cellArray = convertToCellArray(dataMatrix, observationsPerCell)
    [numObservations, ~] = size(dataMatrix);

    % Calcola il numero totale di celle
    numCells = ceil(numObservations / observationsPerCell);
    
    % Inizializza il cell array
    cellArray = cell(numCells, 1);
    
    % Riempie il cell array con le osservazioni
    for i = 1:numCells
        startIndex = (i - 1) * observationsPerCell + 1;
        endIndex = min(startIndex + observationsPerCell - 1, numObservations);
        cellArray{i} = dataMatrix(startIndex:endIndex, :);
    end
end