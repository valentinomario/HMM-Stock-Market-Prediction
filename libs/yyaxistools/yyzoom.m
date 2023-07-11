function varargout = yyzoom(varargin)

% YYZOOM allow zooming both y-axes of a yyaxis plot simultaneously
%
% Syntax:
% 
% YYZOOM
%
% makes both y-axes of a yyaxis plot zoom and pan simultaneously with
% linearly linked axes limits. The yyaxis chart must be the current axes,
% otherwise a new yyaxis chart is created. The current axes limits are
% taken as base values for the linear zoom link that yyzoom creates by
% means of a listener to the 'YLim' property of the axes.
%
%
% YYZOOM(h)
% 
% where h is an axes of a yyaxis chart or an yyzoom proplistener, acts on
% the corresponding object h (default: current axes, gca). 
%
%
% YYZOOM option
%
% YYZOOM(option)
%
% YYZOOM(h, option)
%
% specify a yyzoom option. Allowed options are
%
% - "new"   (default) Link the axes zoom linearly based on the current
%           limits of the left and right y-axes or, if given, on the limits
%           provided by the Limits argument (see below). Previous yyzoom
%           links are overwritten.
%
% - "on"    (Re-)enable the yyaxes zoom link. Same as "new" if no yyzoom
%           proplistener exists. 
%
% - "off"   Disable the yyzoom link. A recently disabled zoom link can be
%           re-enabled with the "on" option. 
%
% - "base"  Zoom (back) both y-axes to their respective yyzoom base limits. 
%           Same as "new" if the Limits argument (see below) is given.
%
% - "del"   Delete the yyzoom link proplistener. A deleted link cannot be
%           re-enabled.
%
% - "update" Update the axes limits according to the base limits of the
%           current (enabled) yyzoom link. The update may be useful after
%           limit changes that the listener did not capture (see below) or
%           that occurred before re-enabling the listener.
%
%
% YYZOOM(___, Limits);
%
% with a four-element vector Limits = [yL(1), yL(2), yR(1), yR(2)], sets
% the limits of the left y-axis to [yL(1),yL(2)] and the limits of the
% right axis to [yR(1),yR(2)]. NaN elements in Limits are replaced with the
% current axes limit values.
%
%
% [ax,pl] = YYZOOM(___);
%
% returns the axes object of the yyaxis chart (ax) and the
% event.proplistener of the yyzoom link (pl). yyzoom creates such a 
% listener to the YLim property of the axes to react on limit updates.
%
%
% "Linear zoom link" means that the lower and upper axes limits of the left
% y-axis, [yL(1),yL(2)], and of the right y-axis, [yR(1),yR(2)], are linked
% by a linear dependency represented by the straight line passing through
% the base points [yLb(1),yRb(1)] and [yLb(2),yRb(2)].
% These base points for the linear interpolation are defined by the y-axes
% limits at the time when a new link is created.
%
% If a y-axis scale is logarithmic, the above will apply to the decadic
% logarithm of the limits.
%
%
% EXAMPLE:
%
% fyy = figure;
% x = linspace(0,10);
% y = sin(3*x);
% z = sin(3*x).*exp(0.5*x);
% yyaxis left
% plot(x,y)
% ylim([-1.5 1.5])
% yyaxis right
% plot(x,z)
% ylim([-150 150])
% grid on
% yyaxis left
% 
% yyzoom
%
%
%
% Remarks:
%
% - >> yyaxtoolbar
%
%   sets up a customized axes toolbar ('yy-axtoolbar') for yyaxis plots.
%   You can access most of yyzoom's features interactively with this
%   toolbar.
%
% - If the TickValuesMode property of only one y-axis side is 'auto', the 
%   listener's callback function also calculates the other side's tick
%   values at the same canvas height. This is useful to keep the ticks of
%   both y-axes aligned at nice values if the axes limits are chosen
%   properly (as with yytick).
%
% · +-inf y-axis limits are replaced by the values used when YLimMode is
%   'auto'.
%
%
%
% Limitations:
%
% · The "Restore view" button may produce a wrong result with yyaxis charts
%   (tested in release R2021b). Workarounds / alternatives:
%   · activate the other y-axis before using "Restore view" again, or
%   · click on "Zoom to Y1+Y2 Base" in the yy-axtoolbar, or enter
%     >> yyzoom base
%     to zoom to the base limits, or
%   · click on "Limits & Ticks Auto" in the yy-axtoolbar dropdown menu.
%
% · The event.proplistener does not capture some direct programmatic
%   changes of the Limits property of one of the NumericRulers, like 
%   >> ax.YAxis(1).Limits = [0 10]
%   and thus it does not trigger an update of the other ruler's limit,
%   in contrast to mouse zooming actions and e.g.
%   >> ax.YLim = [0 10]
%   >> ylim([0 10])
%  
% 
% See also: yytick, yyaxtoolbar
% 

% --- Author: -------------------------------------------------------------
%   Copyright 2022 Andres
%   $Revision: 3.00 $  $Date: 2022/04/13 14:21:00 $
% --- E-Mail: -------------------------------------------------------------
% x=-2:3;
% disp(char(round([polyval([-0.32,0.43,1.75,-5.90,-0.95,116],x),...
%                  polyval([-4.44,9.12,29.8,-33.6,-52.9, 98],x)])))
% you may also contact me via the author page
% http://www.mathworks.com/matlabcentral/fileexchange/authors/30255

% --- History: ------------------------------------------------------------
%  1.00     · first release
%  1.0.1    · improved handling of negative limits with logarithmic scale
%  2.00     · improved axes toolbar with support for yytick
%  3.00     · removed "toolbar" option (use yyaxtoolbar instead)
%           · added "update" option
% -------------------------------------------------------------------------

% ~~~ input checks

narginchk(0,3);
nargoutchk(0,2);

% get option, proplistener, axes, and limits arguments from varargin (or
% defaults), and an indicator if the Limits argument is given
[op, pl, ax, li, hasLiArg] = getArgs(varargin);


% ~~~ main code

% By default, a newly created proplistener will be enabled
if op == "off"
    enableNewPl = false;
else
    enableNewPl = true;
end

% If pl is an empty event.proplistener, we'll have to create a new listener
% (set op="new" unless op=="del"). If there is a Limits argument, we apply
% these new limits. 
if isempty(pl)  
    if hasLiArg
        setYyLimits(ax,li);
    end
    if op == "del"
        if nargout > 0
            varargout{1} = ax;
            varargout{2} = pl;
        end
        return
    else
        op = "new";
    end
else
    if hasLiArg
        pl.Enabled = false;
        setYyLimits(ax,li);
        setDependentYTicks(ax,[]);
        % if we have a limits argument, replace option "base" with "new"
        if op == "base"
            op = "new";
        end
    end
end


switch op
    case "new"
        % Set the base limits on the first page of a 2x2x2 array,
        % [ylimLeft; ylimRight],
        % and pre-calculate logarithmic base limits on the second page.
        blLin = [li(1:2); li(3:4)];
        blLog = [logLim(li(1:2)); logLim(li(3:4))];
        bl = cat(3,blLin,blLog);

        % Set up the scaling function scaleFun.
        % yli = scaleFun(lim) returns scaled limits yli
        % yli(1,:) : .. of *left* axis, with new limits lim of *right* axis
        % yli(2,:) : vice versa
        scaleFun = @(lim,srcSideI,srcYScaleI,tarYScaleI) ...
                   scaleLimit(lim,srcSideI,srcYScaleI,tarYScaleI,bl);

        % If not present, add a new listener for events changing the y axes
        % limits.
        if isempty(pl)
            % note: when looking for an existing yyzoom listener, it is
            % identified by its function string
            pl = addlistener(ax,'YLim','PostSet',...
                @(src,evnt)yLimScaleFun(evnt.AffectedObject,scaleFun));
        else
            % just update the existing listener function
            pl.Callback = ...
                @(src,evnt)yLimScaleFun(evnt.AffectedObject,scaleFun);
        end

        pl.Enabled  = enableNewPl;

        setToolbarYyzoomState(ax,'on');
       
        setDependentYTicks(ax,scaleFun);

    case "on"
        pl.Enabled = true;
        setToolbarYyzoomState(ax,'on');

    case "off"
        pl.Enabled = false;
        setToolbarYyzoomState(ax,'off');

    case "del"
        delete(pl)
        pl = event.proplistener.empty;
        setToolbarYyzoomState(ax,'off');

    case "base"
        bl = getBaseLimits(pl);
        setYyLimits(ax,bl(:,:,1).');
        setDependentYTicks(ax,[]);

    case "update"
        yLimScaleFun(ax,[]);
end

if nargout > 0
    varargout{1} = ax;
    varargout{2} = pl;
end


end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% local functions


function [op, pl, ax, li, hasLiArg] = getArgs(inArgs)

% Get the option, proplistener, axes, and limits arguments (op, pl, ax, li)
% from the argument list inArgs (or set defaults), and the indicator
% hasLiArg to tell if the Limits argument is in the list or not. 

isPlArg = cellfun(@(x) isscalar(x) && isa(x,'event.proplistener'), inArgs);
isAxArg = cellfun(@(x) isscalar(x) && ...
                       isa(x,'matlab.graphics.axis.Axes'), inArgs);
isOpArg = cellfun(@(x) isStringScalar(x) || ischar(x), inArgs);
isLiArg = cellfun(@(x) isnumeric(x), inArgs);

isArg = [isPlArg|isAxArg; isOpArg; isLiArg];

if numel(inArgs) > 0 && ...
        (sum(isArg(:)) ~= numel(inArgs) || max(sum(isArg,2)) > 1)
    error("yyzoom: invalid arguments; accepts only scalar handle"+ ...
        " (proplistener" +newline+...
        "or axes), option, and limits arguments (zero or one each)")
end


% ~~~ get option

if any(isOpArg)
    op = inArgs{isOpArg};
    knownOp = ["on","off","new","del","base","update"];
    tf = strcmpi(op,knownOp);
    if any(tf)
        op = knownOp(tf);
    else
        error("yyzoom: known options are 'on', 'off', 'new'," + ...
            newline+"'del', 'base', and 'update', but not '%s'", op)
    end
else 
    op = "new";
end


% ~~~ get proplistener

if any(isPlArg)
    pl = inArgs{isPlArg};
else
    pl = event.proplistener.empty;
end


% ~~~ get axes

if any(isAxArg)
    ax = inArgs{isAxArg};
else
    ax = matlab.graphics.axis.Axes.empty;
end

% further checks on the handles argument
[ax,pl] = checkHandles(ax,pl);


% ~~~ get limits

hasLiArg = any(isLiArg);

if hasLiArg
    li = inArgs{isLiArg};
    if ~isvector(li) || numel(li) ~= 4
        error("yyzoom: y-limits argument must be a 4-element vector")
    end
else
    li = NaN(1,4);
end

% further checks on the limits argument
li = checkLimits(li, ax, pl);

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function [ax,pl] = checkHandles(ax,pl)

% Check axes argument and return valid axes handle and proplistener.

if isempty(pl)
    % If no axes is given, choose the current axes.
    % If there is no current axes, create a yyaxis one instead of throwing
    % an error, as that is more inline with zoom, gca, ylim ...
    if isempty(ax)
        if isempty(findobj('Type','Axes'))
            yyaxis left
        end
        ax = gca;
    end

    if ~isvalid(ax)
        error('yyzoom: invalid or deleted axes object')
    end
    
    % check if two y-axes exist in the axes object
    if numel(ax.YAxis) == 1
        % Do NOT error,
        % error('yyzoom: axes contains only one y-axis')
        % but create a second y-axis
        yyaxis(ax,"left")    
        % as this is more inline with Matlab's behaviour.
        % The existing y-axis always becomes the left y-axis (with
        % NumericRuler ax.YAxis(1)), a right axis is added, and the
        % property ax.YAxisLocation becomes read-only. 
    end

    pl = getYyzoomListener(ax);

else
    % check the given propertylistener pl
    % the listener's identifying callback function string
    if isYyzoomListener(pl)
        ax = pl.Object{1};
        if ~isvalid(ax)
            error("yyzoom: proplistener belongs to a deleted axes")
        end
    else
        error("yyzoom: proplistener is not a valid yyzoom proplistener")
    end
end

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function li = checkLimits(li, ax, pl)

% Check left and right limits pairs in 4-element vector li for axes ax.
% Replace NaN values in li with current axes limits.

isnanli = isnan(li);

if any(isnanli)
    axLim = getFiniteYLimits(ax,pl); 
    li(isnanli) = axLim(isnanli);
end

if (li(1) >= li(2)) || (li(3) >= li(4))
    error("yyzoom: y-limits vector must contain consecutive pairs of " +...
          "increasing values.")
end

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function isvpl = isYyzoomListener(pl)

% Determine if pl is a valid proplistener for yyzoom.

zoomLinkLstnCbStr = ...
        '@(src,evnt)yLimScaleFun(evnt.AffectedObject,scaleFun)';

isvpl = isValidProplistener(pl,zoomLinkLstnCbStr);

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function setYyLimits(ax,li)

% Apply the limits li to y-axes in ax.

ax.YAxis(1).Limits = li(1:2);
ax.YAxis(2).Limits = li(3:4);

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function yLimScaleFun(ax, scaleFun)

% Scale the limits of the inactive y-axis according to the change of limits
% of the active y-axis. 
% Writing to ax.YAxis(tarSideI).Limits does not trigger a new event, but as
% 'recursive' is off, this would not happen with ax.YLim=... either.

srcSide     = ax.YAxisLocation;
srcSideI    = xor([false, true], strcmp(srcSide,'left'));
tarSideI    = ~srcSideI;
srcYScaleI  = 1 + strcmp(ax.YScale,'log');  % 1: linear, 2: log
tarYScaleI  = 1 + strcmp(ax.YAxis(tarSideI).Scale,'log');
lim         = ax.YAxis(srcSideI).Limits;

if isempty(scaleFun)
    pl = getYyzoomListener(ax);
    if ~isempty(pl) && pl.Enabled
        bl = getBaseLimits(pl);
        ax.YAxis(tarSideI).Limits = scaleLimit(lim,srcSideI,srcYScaleI,...
            tarYScaleI,bl);
        setDependentYTicks(ax,[]);
    end
else
    % calculate and set target side limits
    ax.YAxis(tarSideI).Limits = scaleFun(lim,srcSideI,srcYScaleI,...
        tarYScaleI);
    % update dependent ticks
    setDependentYTicks(ax,scaleFun);
end

% debug:
%disp("yyzoom: invoked yLimScaleFun @"+ datestr(now,'HH:MM:SS:FFF'))

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function tarLim = scaleLimit(srcLim,srcSideI,srcYScaleI,tarYScaleI,baseLim)

% Calculate target axis limits tarLim from source axis limits srcLim.
% srcSideI:    index of source y-axis
% srcYScaleI:  source axis YScale: 1 if 'linear', 2 if 'log'
% tarYScaleI:  target axis YScale: 1 if 'linear', 2 if 'log'
% baseLimits:  2x2x2 array, k1: left,right, k2: ymin,ymax, k3: lin,log

tarSideI = ~srcSideI;    % target y-axis side

% care for logarithmic scaling of the source y-axis
if srcYScaleI > 1
    srcLim = logLim(srcLim);
end

% (linear interpolation with interp1 would work here as well)

% slope of the linear function linking the y-axis limits of both sides
slope = (baseLim(tarSideI,2,tarYScaleI)-baseLim(tarSideI,1,tarYScaleI)) ...
      ./(baseLim(srcSideI,2,srcYScaleI)-baseLim(srcSideI,1,srcYScaleI));

% calculate the target limits using the slope and the upper base limit
tarLim = baseLim(tarSideI,2,tarYScaleI) + slope .* ...
         ( srcLim - baseLim(srcSideI,2,srcYScaleI) );

% care for logarithmic scaling of the target y-axis
if tarYScaleI > 1
    tarLim = 10.^tarLim;
end

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function pl = getYyzoomListener(ax)

% Return the handle of an already existing yyzoom proplistener of axes ax.

% the listener's identifying callback function string
zoomLinkLstnCbStr = ...
    '@(src,evnt)yLimScaleFun(evnt.AffectedObject,scaleFun)';

pl = findValidProplistener(ax,zoomLinkLstnCbStr);

if isempty(pl)
    pl = event.proplistener.empty;
else
    pl = pl{end};
end

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function [bl,sFun] = getBaseLimits(pl)

% Extract the 4-element vector base limits bl and the scale function sFun
% from an existing event.proplistener pl. 

if ~isYyzoomListener(pl)
    bl = [0,1,0,1];         % default
    return
end

cfs = functions(pl.Callback);

sfs = functions(cfs.workspace{1}.scaleFun);

sFun = sfs.function;

bl  = sfs.workspace{1}.bl;

% bl  = bl(:).';

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 

function yl = getFiniteYLimits(ax,pl)

% Get the finite values of both y-axes limits into 4-element vector yl,
% from axes object ax with proplistener pl.

% +/-inf are allowed axis limits, but obviously they are not suited as base
% values for the linear scaling. So if +/-inf occur, temporarily switch
% ax.YLimMode to 'auto' to retrieve the true axis limits.

    
yl = [ax.YAxis(1).Limits, ax.YAxis(2).Limits];

if any(isinf(yl))

    if isYyzoomListener(pl)
        isEnabled = pl.Enabled;
        pl.Enabled = false;
    end

    currLoc = ax.YAxisLocation;

    yyaxis(ax,'left')
    currLim     = ylim(ax);
    isInfLim    = isinf(currLim);
    if any(isInfLim)
        ax.YLimMode = 'auto';
        finYLim = ylim(ax);
        currLim(isInfLim) = finYLim(isInfLim);
        ylim(ax,currLim);
        yl([1,2]) = currLim;
    end

    yyaxis(ax,'right')
    currLim     = ylim(ax);
    isInfLim    = isinf(currLim);
    if any(isInfLim)
        ax.YLimMode = 'auto';
        finYLim = ylim(ax);
        currLim(isInfLim) = finYLim(isInfLim);
        ylim(ax,currLim);
        yl([3,4]) = currLim;
    end

    yyaxis(ax,currLoc);

    if isYyzoomListener(pl)
        pl.Enabled = isEnabled;
    end

end

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function setToolbarYyzoomState(ax,value)

% If the current axes has the yyaxtoolbar, set state of the 'Zoom Y1+Y2'
% button to the value 'on' or 'off'

if isprop(ax,'Toolbar') && strcmp(ax.Toolbar.Tag,'yyzoom')
    % find state buttons
    tsb = findobj(ax.Toolbar.Children,'Type','ToolbarStateButton');
    % find yyzoom state button 
    isYyzoomButton = strcmp('Zoom Y1+Y2',{tsb.Tooltip});
    if any(isYyzoomButton)
        tsb(isYyzoomButton).Value = value;
    end
end


end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function llim = logLim(lim)

% decadic logarithm of axes limits, with defaults for non-positive values

llim = [-1,0];              % default if both limit values <= 0

if lim(1) > 0
    llim = log10(lim);
elseif lim(2) > 0
    llim = [-1,0]+log10(lim(2));
end


end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function setDependentYTicks(ax,scaleFun)

% If only one side has TickValuesMode set to 'auto', calculate the other
% side's TickValues at the same canvas height. This is useful to keep the
% ticks aligned at nice values if the axes limits are properly chosen (as
% with yytick).

isTickModeAuto = strcmp('auto',{ax.YAxis.TickValuesMode});
if sum(isTickModeAuto) == 1

    % determine scaling; 1: linear, 2: log
    srcYScaleI  = 1 + strcmp(ax.YAxis(isTickModeAuto),'log');
    tarYScaleI  = 1 + strcmp(ax.YAxis(~isTickModeAuto).Scale,'log');

    srcTicks = ax.YAxis(isTickModeAuto).TickValues;

    if isempty(scaleFun)
        pl = getYyzoomListener(ax);
        bl = getBaseLimits(pl);
        tarTicks = scaleLimit(srcTicks,isTickModeAuto,srcYScaleI,...
                              tarYScaleI,bl);
    else
        tarTicks = scaleFun(srcTicks,isTickModeAuto,srcYScaleI,tarYScaleI);
    end

    ax.YAxis(~isTickModeAuto).TickValues = tarTicks;
end

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~