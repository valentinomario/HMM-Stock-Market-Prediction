function y = indexOfDate(dates, elem)
% y = indexOfDate(dates, elem)
% Trova l'indice nell'array dates della data elem.
    y = find(dates == datetime(elem, 'InputFormat', 'uuuu-MM-dd'));
    if (isempty(y)) 
        error('Data ' + string(elem) + ' non trovata');
    end
end

