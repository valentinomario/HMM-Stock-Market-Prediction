function isvpl = isValidProplistener(pl,CallbackStr)

% isValidProplistener check if proplistener has callback function string
%
% isvpl = isValidProplistener(pl,CallbackStr)
% 
% returns true if pl is a scalar valid event.proplistener attached to an
% axes object whose callback function string matches the string
% CallbackStr, and false otherwise. 
% The callback function string is the result of func2str applied to the
% Callback property of the listener.

isvpl = (numel(pl) == 1) && ...
    isa(pl,'event.proplistener') && ... 
    isvalid(pl) && ...
    isa(pl.Object{1},'matlab.graphics.axis.Axes') && ...
    strcmp(func2str(pl.Callback),CallbackStr);
