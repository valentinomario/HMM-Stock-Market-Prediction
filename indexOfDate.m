function y = indexOfDate(dates,elem)

    y = find(dates ==datetime(elem,'InputFormat','MM/dd/uuuu'));
    if(isempty(y)) 
        error('Data '+string(elem)+' non trovata');
    end
end

