function n = map3DTo1D(x, y, z, maxX, maxY, maxZ)
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
    if z > maxZ || y > maxY || x > maxX
       error("Terna da convertire non valida: x = %1$.4f \n y= %2$.4f z= %3$.4f", x, y, z);
    else
        n = (z-1)*(maxX*maxY) + (y-1)*maxX + x;
        if isnan(n) 
            error("Mapped to NaN. x = %.2f; y = %.2f; z = %.2f\n", x, y, z);
        end
    end 
  
end