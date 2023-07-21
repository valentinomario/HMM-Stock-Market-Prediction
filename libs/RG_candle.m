function varargout = RG_candle(varargin)
%CANDLE Candlestick chart.
%
% Modified by Luigi Catello 2023/07/12
%
% Syntax:
%
%   candle(Data)
%   candle(Data,Color)
%   candle(ax,___)
%
% Description:
%
%   CANDLE plots a candlestick chart from a series of opening, high, low,
%   and closing prices of a security. If the closing price is greater than the
%   opening price, the body (the region between the open and close price)
%   is unfilled; otherwise the body is filled.
%
% Input Argument:
%
%   Data    - A matrix, table, or timetable. For matrix input, Data is an
%             M-by-4 matrix of opening, high, low, and closing prices.
%             Timetables and tables with M rows contain variables named
%             'Open', 'High', 'Low', and 'Close' (case insensitive).
%
% Optional Argument:
%
%   ax      - Valid axis object. The plot will be created in the axes specified
%             by ax instead of in the current axes (gca). The option ax can
%             precede any of the input argument combinations.
%
%   Color   - Three element color vector, [R G B], or a string specifying the
%             color name. The default color differs depending on the background
%             color of the figure window. See COLORSPEC for additional details.
%
% Output Argument:
%
%   h                    - Graphic handle of the figure.
%
%   See also HIGHLOW, KAGI, LINEBREAK, POINTFIG, PRICEANDVOL, RENKO, VOLAREA.

%	Copyright 1995-2021 The MathWorks, Inc.

%--------------------------- Parsing/Validation --------------------------%
try
    narginchk(1,Inf);
    [ax,args] = internal.finance.axesparser(varargin{:});
    if ~isempty(ax) && ~isscalar(ax)
        error(message('finance:internal:finance:axesparser:ScalarAxes'))
    end
    
    output = internal.finance.ftseriesInputParser(args, ...
        4,{'open','high','low','close'},{},{},{'Color'},{''},{@(x)1,@ischar},1);
catch ME
    throwAsCaller(ME)
end

[data,~,dates,~] = output{:};
op = data(:,1);
hi = data(:,2);
lo = data(:,3);
cl = data(:,4);

% Validation work will be left to child functions.
%color = optional.Color;

%------------------------------ Data Preparation -------------------------%

% Need to pad all inputs with NaN's to leave spaces between day data
% Vertical High/Low lines data preparation.
numObs = length(hi(:));

hiloVertical = [hi lo NaN(numObs, 1)]';
indexVertical = repmat(dates',3,1);

% Boxes data preparation
if isdatetime(dates) && length(dates) > 1
    %If using datetimes, make the box width one half of the smallest
    %distance between dates
    inc = 1/4 * min(diff(dates));
else
    inc = 0.25;
end
indexLeft = dates - inc;
indexRight = dates + inc;

%------------------------------- Plot ------------------------------------%

ax = newplot(ax);

% Store NextPlot flag (and restore on cleanup):
next = get(ax,'NextPlot');
cleanupObj = onCleanup(@()set(ax,'NextPlot',next));

%backgroundColor = get(ax,'color');
%if isempty(color)
%    cls = get(ax, 'colororder');
%    color = cls(1, :);
%end

h = gobjects(numObs+1,1); % Preallocate

% Plot vertical lines
h(1) = plot(ax,indexVertical(:),hiloVertical(:),'Color','k',...
    'LineStyle','-','Marker','none','AlignVertexCenters','on');

set(ax,'NextPlot','add')

% Plot filled boxes
colorSet = {'g','r'};

% Filled the boxes when opening price is greater than the closing price.
filledIndex = ones(numObs, 1);
filledIndex(op > cl) = 2;

try
    for i = 1 : numObs
        h(i+1) = fill(ax, ...
                [indexLeft(i); indexLeft(i); indexRight(i); indexRight(i)], ...
                [op(i); cl(i); cl(i); op(i)],colorSet{filledIndex(i)},'Edgecolor',colorSet{filledIndex(i)}, ...
                'LineStyle','-','Marker','none','AlignVertexCenters', 'on');
    end
catch ME
    throwAsCaller(ME)
end

switch next
    case {'replace','replaceall'}
        grid(ax, 'on')
    case {'replacechildren','add'}  
        % Do not modify axes properties
end

if nargout % Not equal to 0
    varargout = {h};
end

end
