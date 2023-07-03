function n = map3DTo1D(x, y, z, maxX, maxY)
% map3DTo1D: Mappa le coordinate di uno spazio tridimensionale su una singola dimensione.
%
% Uso:
%   n = map3DTo1D(x, y, z, maxX, maxY)
%
% Input:
%   - x: La coordinata x della tripla (x, y, z) nello spazio tridimensionale.
%   - y: La coordinata y della tripla (x, y, z) nello spazio tridimensionale.
%   - z: La coordinata z della tripla (x, y, z) nello spazio tridimensionale.
%   - maxX: Il valore massimo di x nello spazio tridimensionale.
%   - maxY: Il valore massimo di y nello spazio tridimensionale.
%
% Output:
%   - n: L'intero assegnato alla tripla (x, y, z) nello spazio tridimensionale mappato su una singola dimensione.
%
% Calcola l'indice 1D corrispondente alla tripla (x, y, z)
    n = (z-1)*(maxX*maxY) + (y-1)*maxX + x;
end