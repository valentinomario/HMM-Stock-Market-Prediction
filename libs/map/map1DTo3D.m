function [x, y, z] = map1DTo3D(n, maxX, maxY, maxZ)
% map1DTo3D: Effettua la mappatura inversa, convertendo un intero n nella tripla (x, y, z) corrispondente nello spazio tridimensionale.
%
% Uso:
%   [x, y, z] = map1DTo3D(n, maxX, maxY)
%
% Input:
%   - n: L'intero assegnato alla tripla (x, y, z) nello spazio tridimensionale mappato su una singola dimensione.
%   - maxX: Il valore massimo di x nello spazio tridimensionale.
%   - maxY: Il valore massimo di y nello spazio tridimensionale.
%
% Output:
%   - x: La coordinata x corrispondente all'indice 1D nello spazio tridimensionale.
%   - y: La coordinata y corrispondente all'indice 1D nello spazio tridimensionale.
%   - z: La coordinata z corrispondente all'indice 1D nello spazio tridimensionale.
%
    % Calcola le coordinate (x, y, z) corrispondenti all'indice 1D n
    if  n>(maxZ-1)*(maxX*maxY) + (maxY-1)*maxX + maxX
         error("numero da convertire non valido n=%1$.4f",n);
    else 
        z = floor((n-1) / (maxX*maxY)) + 1;
        y = floor(((n-1) - (z-1)*(maxX*maxY)) / maxX) + 1;
        x = mod((n-1), maxX) + 1;
    end 
end