function pl = findValidProplistener(ax,CallbackStr)

% findValidProplistener find proplistener by callback function string
%
% pl = findValidProplistener(ax,CallbackStr)
% 
% returns a cell array pl containing the valid proplistener(s) of axes ax
% that have the callback function string CallbackStr.
% The callback function string is the result of func2str applied to the
% Callback property of the listener.

if ~isvalid(ax)
    error("findValidProplistener: deleted axes")
end

pl = {};

if isprop(ax,'AutoListeners__')
    nListener = numel(ax.AutoListeners__);
    isvp = false(nListener,1);
    for k = 1:nListener
        isvp(k) = isValidProplistener(ax.AutoListeners__{k},CallbackStr);
    end
    pl = ax.AutoListeners__(isvp);
end

