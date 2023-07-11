function varargout = yytick(varargin)

% YYTICK align ticks on both y-axes of a yyaxis plot with nice values
%
% Syntax:
% 
% YYTICK
%
% adjusts the axes limits of both y-axes of a yyaxis plot to allow 'nice'
% tick values appearing at the same canvas height, so the major y-axis grid
% lines on both sides coincide.
% 
% For that purpose, it also sets the tick values mode on one side (the
% "dependent" side) to 'manual' and computes the tick values on this side
% at equal heights as the ticks on the other side (the "primary" side)
% where the tick values mode is 'auto'.
%
% Use yyzoom to keep the (dependent) tick values updated when zooming.
%
%
% [ax, yyLim, pInd] = YYTICK;
%
% returns the axes object ax, the computed y-limits in a 4-element vector
% yyLim = [y1Lower, y1Upper, y2Lower, y2Upper], and the linear index of the
% primary y-axis ruler pInd.
%
%
% ___ = YYTICK(ax)
% 
% acts on the axes object ax (default: current axes, gca). 
%
%
% The default behaviour of yytick should be adequate for most use cases.
% Use the optional parameter/value-pairs for more detailed control:
%
% ___ = YYTICK(___, 'parameter', value)
% ___ = YYTICK(___, parameter=value)
%
% · 'primaryside': 'left', 'right', 'current', or 'auto' (default)
%       Specify the primary side. 'current' selects the current value of
%       the YAxisLocation property of the axes. 'auto' selects the side
%       with less added canvas space penalty.
%
% · 'limits': 4-element vector, [y1Lower, y1Upper, y2Lower, y2Upper]
%       Specify limit values of the left and right y-axes that must be
%       covered by the values computed with yytick.
%       If not specified or empty (default), the covered limits are derived
%       from the existing axes (see 'limitmethod').
%
% · 'limitmethod': 'tickaligned', 'tight' (default), 'padded', or 'none'
%       Specify the method to determine the covered limit values of both
%       axes. 'none' selects the current axes limits.
%
% · 'applylimits': true (default) or false
%       Specify whether yytick applies the computed limits and ticks to the
%       axes or only returns the limit values.
% 
% · 'tickratio': vector, increasing values within [1,10) (upper-exclusive)
%       Specify the allowed multipliers, except for their powers of ten
%       (computed by yytick), between the primary and the dependent side.
%       The default is [1, 1.5, 2, 3, 4, 5, 8].
%
% · 'ratioweight': vector of the same size as the tickratio value, or zero
%       To have a penalty value for the different multipliers, the added
%       white canvas space when adjusting the limits is divided by the
%       corresponding value in ratioweight. yytick selects a multiplier
%       with a minimum penalty value.
%       If not specified or zero (default), it is set to be all ones for
%       each multiplier, unless 'tickratio' is set to default values, in
%       which case it is [15, 5, 12, 6, 9, 10, 7], preferring multiplier 1
%       the most.
%
% · 'fixside': 'left', 'right', 'primary', 'dependent', or 'none' (default)
%       Specify a side where the axes limits (but not necessarily the tick
%       values) remain unchanged.
%
%
% Note that
%
% >> yyaxtoolbar
%
% provides axes toolbar support for yytick.
%
% -------------------------------------------------------------------------
%
% EXAMPLE:
%
% % --- sample data
% x = -5:0.1:5;
% y1 = 4+5*sin(0.5*x+pi/6) + sin(x-pi/8);
% y2 = 2e3+3.1*(1000 + 333*sin(1.25*x+pi/6) + 250*sin(2*x-pi/8));
% % --- plot data with yyaxis
% figure
% yyaxis left
% plot(x,y1,'o-')
% ylabel('y_1')
% grid on
% yyaxis right
% plot(x,y2,'o-')
% ylabel('y_2')
%
% % --- align ticks
% YYTICK
% title('yyaxis chart with aligned ticks')
% % --- add yy-axtoolbar (optional)
% yyaxtoolbar
% 
% 
% -------------------------------------------------------------------------
%
% Background:
% yytick restricts the ratio of the new y-axes lengths (upper limit minus
% lower limit = yAxLength) to certain multipliers m, so that when Matlab
% determines the tick values of the primary y-axes, the tick values of
% the dependent y-axis at the same canvas height are easily readable 
% (yAxLength_Dependent = m * yAxLength_Primary).
% 
% Limitations:
% · yytick is designed for linear axis scaling.
% · Matlab may recompute the y-axes ticks after axes size or plotted data
%   changes. Call yytick after such changes.
% 
%
% See also: yyzoom, yyaxtoolbar
% 

% --- Author: -------------------------------------------------------------
%   Copyright 2022 Andres
%   $Revision: 1.01 $  $Date: 2022/04/13 14:20:00 $
% --- E-Mail: -------------------------------------------------------------
% x=-2:3;
% disp(char(round([polyval([-0.32,0.43,1.75,-5.90,-0.95,116],x),...
%                  polyval([-4.44,9.12,29.8,-33.6,-52.9, 98],x)])))
% you may also contact me via the author page
% http://www.mathworks.com/matlabcentral/fileexchange/authors/30255

% --- History: ------------------------------------------------------------
%  1.00     · first release
%  1.01     · now refers to yyaxtoolbar and shares private functions with
%             yyzoom
% -------------------------------------------------------------------------

% possible future enhancements
% - allow further y limits methods and direct limits
% - nice ticks for logarithmic axis scaling


% ~~~ input checks & defaults

nargoutchk(0,3);

[ax,hasAx,opts] = getInputs(varargin{:});

hasLimits = ~isempty(opts.limits);

% ~~~ prepare axes

% make sure we have an axes object with two y axes
% (unless applylimits=false) 
if hasAx
    ax = varargin{1};
    if numel(ax.YAxis) < 2
        yyaxis left
    end
elseif opts.applylimits
    if isempty(findobj('Type','Axes'))
        yyaxis left
    end
    ax = gca;
    hasAx = true;
end

if ~hasAx && ~hasLimits     % nothing to do
    if nargout > 0
        varargout{1} = ax;
        varargout{2} = NaN(1,4);
        varargout{3} = 0;
    end
    return;
end

% ~~~ collect axes data
if hasAx
    axLoc = ax.YAxisLocation;
    if strcmpi(opts.primaryside,'current')
        opts.primaryside = axLoc;
    end
end

% set axes limits according to limitmethod
[axLim, axLimPre, opts] = applyLimMthd(ax, axLoc, hasAx, hasLimits, opts);


% ~~~ calculate and set the new limits

% calculate the optimum limits and the linear index of the primary and the
% dependent axis
[optLim, pInd, dInd] = calcOptLimits(axLim, axLimPre, opts);

if nargout > 0
    varargout{1} = ax;
    varargout{2} = [optLim(1,:), optLim(2,:)];
    varargout{3} = pInd;
end

if opts.applylimits
    % apply the calculated limits and set the dependent tick values

    ax.YAxis(1).Limits   = optLim(1,:);
    ax.YAxis(2).Limits   = optLim(2,:);

    ax.YAxis(pInd).TickValuesMode = 'auto';
    pTicks = ax.YAxis(pInd).TickValues;
    dTicks = dependentTicks(pTicks,optLim(pInd,:),optLim(dInd,:),...
        opts.islogscale(pInd),opts.islogscale(dInd));
       
    ax.YAxis(dInd).TickValues = dTicks;
    % Specifying the calculated TickValues here will set the tick values
    % mode to 'manual', so yyzoom will keep the ticks updated.
end


end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% local functions


function [ax,hasAx,options] = getInputs(ax,options)

% Get inputs using the arguments block and perform further checks.
% Syntax: argName1 (dimensions) dataType {validators} = defaultValue

arguments 
    ax matlab.graphics.axis.Axes {mustBeScalarOrEmpty} ...
        = matlab.graphics.axis.Axes.empty;
    options.limitmethod char {mustStrcmpi(options.limitmethod,...
        {'tickaligned', 'tight', 'padded', 'none'})} = 'tight'
    options.primaryside char {mustStrcmpi(options.primaryside,...
        {'left','right','current','auto'})} = 'auto'
    options.limits double {mustBeTwoLimits} = []
    options.applylimits (1,1) logical = true
    options.fixside char {mustStrcmpi(options.fixside,...
        {'left','right','primary','dependent','none'})} = 'none'
    options.islogscale logical = []
    options.tickratio (1,:) double {mustBeNonempty,mustBeVector,...
        mustBeInRange(options.tickratio,1,10,'exclude-upper')} ...
        = [1, 1.5, 2, 3, 4, 5, 8].';
    options.ratioweight double {mustBeVector, mustBeNonnegative} = 0;
    options.epsrulerpad (1,1) double = 2;
end 

if isempty(ax)
    hasAx = false;
else
    if ~isvalid(ax)
        error('Axes object is deleted.')
    end
    hasAx = true;
end

options.tickratio   = options.tickratio(:);
options.ratioweight = options.ratioweight(:);
options.limitmethod = lower(options.limitmethod);
options.primaryside = lower(options.primaryside);

% Set acceptable tick length ratios and tick ratio weights:
if isscalar(options.ratioweight) && options.ratioweight == 0
    if isequal(options.tickratio, [ 1, 1.5,  2, 3, 4,  5, 8].')
        % set specific weights for default ratio values
        options.ratioweight =     [15,   5, 12, 6, 9, 10, 7].';
    else
        % set all weights to 1 for non-default ratio values
        options.ratioweight = ones(size(options.tickratio));
    end
end

if any(numel(options.tickratio)~=numel(options.ratioweight))
    error('tickratio and ratioweight values must have the same size.')
end

if any(diff(options.tickratio) <= 0)
    [options.tickratio,iu]  = unique(options.tickratio);
    options.ratioweight     = options.ratioweight(iu);
    warning(['tickratio values must be increasing. Using unique values',...
            newline, '[' num2str(options.tickratio,' %g') ']' ]);
end


end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function [pNew,dNew,p] = limsForAlignedTicks(pLim,dLim,ispLog,isdLog,opts)

% axes limits that allow both 'nice' and aligned ticks
% - inputs
%   pLim:  original limits of the primary axis
%   dLim:  original limits of the dependent axis, i.e. the axis whose ticks
%          are calculated depending on the tick values of the primary axis
%          (tick values mode set to 'manual')
%   opts.tickratio:   allowed tick length ratios scaled to [1,10) ...
%   opts.ratioweight: the corresponding weight factors
% - outputs
%   pNew, dNew: the new limits for both axes
%   p: penalty figure for adding new canvas space by rearranging the limits

% for logScale axes, transform limit values to canvas units
if ispLog
    pLim = log10(pLim);
end
if isdLog
    dLim = log10(dLim);
end

% lengths of both y rulers
pLen = diff(pLim);
dLen = diff(dLim);

% use next smaller power of 10 as unit for each y axis
pUnit = 10^(floor(log10(pLen)));
dUnit = 10^(floor(log10(dLen)));

% pLen/pUnit and dLen/dUnit are both within [1,10) (upper-exclusive);
% so their ratio is limited to (0.1,10).

% The ratio options, covering the range 0.1...10, whatever allowed
% tickratio values are given:
tr = [opts.tickratio/100; opts.tickratio/10; ...
      opts.tickratio    ; opts.tickratio*10];
% ... and the corresponding weight factors:
rw = repmat(opts.ratioweight,4,1);


dUnitOpts = tr.*dUnit;    % the new dUnit options

% The new dependent limits per unit will equal the primary limits per unit
pLimPerUnit = pLim / pUnit;
% (except for an integer offset) to have nice ticks on the dependent side,
% assuming nice values in options.tickratio and nice ticks on the primary
% side => dependent limits per unit (before adding the integer offset)
dLimOpts = pLimPerUnit .* dUnitOpts;

% Now shift the dLimOpts by an integer multiple (m) of the dUnitOpts to 
% cover the center of the original dependent limits:
m = round( (mean(dLim) - mean(dLimOpts,2)) ./ dUnitOpts );
dLimOpts = dLimOpts + m .* dUnitOpts;

% Finally, if allowed, expand the limits so that the new dependent limits
% cover the old ones.

% Lower dependent limit:
% lowerDiff = difference between preliminary options and old value
% <= 0: ok, old limit is within preliminary limits
%  > 0: not ok, must expand lower preliminary limit to contain old value
lowerDiff = (dLimOpts(:,1) - dLim(1));
% Upper dependent limit:
% upperDiff = difference between preliminary options and old value
% >= 0: ok, old limit is within preliminary limits
%  < 0: not ok, must expand lower preliminary limit to contain old value
upperDiff = (dLimOpts(:,2) - dLim(2));

if strcmpi(opts.fixside,'primary')
    pLimOpts = repmat(pLim,numel(tr),1);
    isok = (lowerDiff<=0) & (upperDiff>=0);
    yExcess =   max( 0, -lowerDiff./diff(dLimOpts,1,2) ) + ...
                max( 0,  upperDiff./diff(dLimOpts,1,2) );
    yExcess(~isok) = inf;
else
    % Expand:
    dLimOpts = [dLimOpts(:,1)-max(0,lowerDiff(:)), ...
                dLimOpts(:,2)-min(0,upperDiff(:))];
    % Co-expand the primary limits:
    pLimOpts = [pLim(1)-max(0,lowerDiff(:)).*pUnit./dUnitOpts, ...
                pLim(2)-min(0,upperDiff(:)).*pUnit./dUnitOpts];
    
    % Calculate the excess canvas space w.r.t. the limits
    % (sum of maximum values of each side)
    yExcess = max( ( pLim(1) - pLimOpts(:,1))./diff(pLimOpts,1,2),    ...
                   ( dLim(1) - dLimOpts(:,1))./diff(dLimOpts,1,2) ) + ...
              max( (-pLim(2) + pLimOpts(:,2))./diff(pLimOpts,1,2),    ...
                   (-dLim(2) + dLimOpts(:,2))./diff(dLimOpts,1,2) );
    
    if strcmpi(opts.fixside,'dependent')
        % exclude solutions where dependent limits exceed previous limits
        yExcess((lowerDiff<0) | (upperDiff>0)) = inf;
    end
end

% The preferred option has minimal excess space per ratio weight.
[p, io] = min(yExcess ./ rw);

% debug:
% r = dUnitOpts(io)/pUnit;     % preferred ratio
% disp("new tick step ratio is "+r+" (index "+io+")")
% disp('lowerDiff (ok <= 0), upperDiff (ok >= 0)')
% disp([(1:numel(lowerDiff)).',lowerDiff,upperDiff])
% disp('yExcess_')
% disp([(1:numel(lowerDiff)).',yExcess])
% disp('~~~')

% Sometimes, presumably due to round-off errors, ticks that are very close
% to the axis limit edges do not appear.
% Counteraction: slightly expand the ruler lengths at both ends. 
rulerpad = eps*[-1,1].*opts.epsrulerpad;
pNew = pLimOpts(io,:) + diff(pLimOpts(io,:)).*rulerpad;
dNew = dLimOpts(io,:) + diff(dLimOpts(io,:)).*rulerpad;

% back transformation for logScale axes
if ispLog
    pNew = 10.^pNew;
end
if isdLog
    dNew = 10.^dNew;
end

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function dTicks = dependentTicks(pTicks,pLim,dLim,ispLog,isdLog)

% dependentTicks ticks at equal canvas position as primary ticks
% 
% dTicks = dependentTicks(pTicks,pLim,dLim,ispLogScale,isdLogScale)
%
% dTicks        n-el. vector    dependent tick values
% pTicks        n-el. vector    primary tick values
% pLim          1×2             limits of the primary axis
% dLim          1×2             limits of the dependent axis
% ispLogScale   1×1 logical     true if primary axis has log scale
% isdLogScale   1×1 logical     true if dependent axis has log scale


if ispLog
    pLen    = log10(pLim(2)) - log10(pLim(1));
    relpLim = log10(pTicks) - log10(pLim(2));
else
    pLen    = diff(pLim);
    relpLim = pTicks - pLim(2);
end

if isdLog
    dLen   = log10(dLim(2)) - log10(dLim(1));
    dTicks = 10.^(relpLim * dLen/pLen + log10(dLim(2)));
else
    dLen   = diff(dLim);
    dTicks = relpLim * dLen/pLen + dLim(2);
end

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function mustBeTwoLimits(a)
% argument validation function for the limits
if ~isempty(a) && ( ~(numel(a)==4) || ~all(isfinite(a)) || ...
        a(1)>=a(2) || a(3)>=a(4) )
    eidType = 'mustBeTwoLimits:invalidLimits';
    msgType = ['limits must be empty or a numeric 4-element vector',...
        newline,'with two consecutive pairs of increasing values'];
    throwAsCaller(MException(eidType,msgType))
end

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function mustStrcmpi(a,allowed)
% argument validation function for string values
if ~any(strcmpi(a,allowed))
    eidType = 'mustStrcmpi:invalidString';
    msgType = ['Allowed strings are (case-insensitive)',...
        newline,sprintf(' ''%s''',allowed{:})];
    throwAsCaller(MException(eidType,msgType))
end

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function [lim, limPre, opts] = applyLimMthd(ax, axLoc, hasAx, hasLim, opts)

% apply the y-axis limits method before calculating the limits for aligned
% ticks

if numel(opts.islogscale)~=2
    opts.islogscale = [false, false];
    if hasAx
        opts.islogscale(1) = strcmpi(ax.YAxis(1).Scale,'log');
        opts.islogscale(2) = strcmpi(ax.YAxis(2).Scale,'log');
    end
end

% Store axes limits (axLimPre: limits before applying limitmethod)
% 1st row: left axis, 2nd: right
[limPre,lim] = deal(zeros(2));

if hasLim
    [limPre(1,:),lim(1,:)] = deal(opts.limits([1 2]));
    [limPre(2,:),lim(2,:)] = deal(opts.limits([3 4]));
else

    yyaxis(ax,'right');
    [limPre(2,:),lim(2,:)] = deal(ylim(ax));
    if ~strcmpi(opts.limitmethod,'none')
        % 'tight' sometimes has no effect without 'padded' before:
        ylim(ax,'padded');
        ylim(ax,opts.limitmethod);
        lim(2,:) = ylim(ax);
    end

    yyaxis(ax,'left');
    [limPre(1,:),lim(1,:)] = deal(ylim(ax));
    if ~strcmpi(opts.limitmethod,'none')
        % 'tight' sometimes has no effect without 'padded' before:
        ylim(ax,'padded');
        ylim(ax,opts.limitmethod);
        lim(1,:) = ylim(ax);
    end

    yyaxis(ax,axLoc);
end

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function [optLim, pInd, dInd] = calcOptLimits(axLim, axLimPre, opts)

% Depending on the value in opts.primaryside, try both sides or use one
% side as primary axis. If both sides are tried, select the one with the
% minimum penalty value.

% Store new limits and penalty values:
% k1: left, right axis; k2: lower, upper limit; k3: primary left, right
nLim = zeros(2,2,2); 
p = Inf(2,1);

origFixSide = opts.fixside;

if any(strcmpi(opts.primaryside,{'left','auto'}))
    % choose left axis as primary
    if any(strcmpi(origFixSide,{'left','primary'}))
        opts.fixside = 'primary';
        pLim = axLimPre(1,:);
    else
        pLim = axLim(1,:);
    end
    if any(strcmpi(origFixSide,{'right','dependent'}))
        opts.fixside = 'dependent';
        dLim = axLimPre(2,:);
    else
        dLim = axLim(2,:);
    end
    
    [nLim(1,:,1), nLim(2,:,1), p(1)] = limsForAlignedTicks(pLim,dLim,...
        opts.islogscale(1),opts.islogscale(2),opts);
end

if any(strcmpi(opts.primaryside,{'right','auto'}))
    % choose right axis as primary
    if any(strcmpi(origFixSide,{'right','primary'}))
        opts.fixside = 'primary';
        pLim = axLimPre(2,:);
    else
        pLim = axLim(2,:);
    end
    if any(strcmpi(origFixSide,{'left','dependent'}))
        opts.fixside = 'dependent';
        dLim = axLimPre(1,:);
    else
        dLim = axLim(1,:);
    end

    [nLim(2,:,2), nLim(1,:,2), p(2)] = limsForAlignedTicks(pLim,dLim,...
        opts.islogscale(1),opts.islogscale(2),opts);
end

[~,pInd] = min(p);      % the index of the primary side
dInd = 3-pInd;          % the index of the dependent side

optLim = nLim(:,:,pInd);

end