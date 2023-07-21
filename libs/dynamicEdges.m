function edges = dynamicEdges(sequence, numberOfPoints)
% dynamicEdges: Calcola gli intervalli dinamici per la discretizzazione di una sequenza.
%
% Uso:
%   edges = dynamicEdges(sequence, numberOfPoints)
%
% Input:
%   - sequence: La sequenza di valori reali da discretizzare.
%   - numberOfPoints: Il numero desiderato di punti per la discretizzazione.
%
% Output:
%   - edges: I bordi degli intervalli calcolati per la discretizzazione.
%

if ~isvector(sequence)
    error('sequence deve essere un vettore');
end

if ~isscalar(numberOfPoints)
    error('numberOfPoints deve essere uno scalare');
end

minSeq = min(sequence);
maxSeq = max(sequence);
if minSeq < -0.9 || maxSeq > 0.9
    warning("Weird min/max value(s)")
end

edges = linspace(minSeq, maxSeq, numberOfPoints + 1);

