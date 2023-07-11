function varargout = yyaxtoolbar(ax)

% YYAXTOOLBAR extended axes toolbar for yyaxis charts 
%
% Syntax:
% 
% YYAXTOOLBAR
%
% adds a custom axes toolbar for yyaxis plots on the current axes to
% facilitate interactive zooming and setting limits and ticks on both
% y-axes. 
%
%
% YYAXTOOLBAR(ax)
% 
% adds the toolbar to axes ax.
%
%
% YYAXTOOLBAR also creates a yyaxis chart if not yet existing.
% 
%
% YYAXTOOLBAR buttons from left to right:
%
% 1) Restore View (default toolbar button)
%
% 2) YAxis Location
%       toggle and display the active y-axis side; dashes indicate
%       tick values mode 'auto' on the respective side
%
% 3) Zoom Link
%       de-/activate linear zoom link for both y-axes (see yyzoom)
%
% 4) Align Ticks
%       align nice tick values on both y-axes sharing the same major grid
%       (see yytick)
%
% 5) Dropdown button....
%       several buttons to modify axes ticks and limits
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
% by a linear dependency represented by the straight line on a (yL,yR) plot
% passing through the points [yLb(1),yRb(1)] and [yLb(2),yRb(2)]. 
% These base points for the linear interpolation, yLb and yRb, are defined
% by the y-axes limits at the time when a new link is created.
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
% yyaxtoolbar
%
%
% Limitations:
%
% · After reloading a figure that was saved with the yy-axestoolbar, you
%   have to click on the Active Side icon and the Zoom Link icon once to
%   display the current state correctly.
%  
% 
% See also: yyzoom, yytick
% 

% --- Author: -------------------------------------------------------------
%   Copyright 2022 Andres
%   $Revision: 1.01 $  $Date: 2022/04/13 14:25:00 $
% --- E-Mail: -------------------------------------------------------------
% x=-2:3;
% disp(char(round([polyval([-0.32,0.43,1.75,-5.90,-0.95,116],x),...
%                  polyval([-4.44,9.12,29.8,-33.6,-52.9, 98],x)])))
% you may also contact me via the author page
% http://www.mathworks.com/matlabcentral/fileexchange/authors/30255

% --- History: ------------------------------------------------------------
%  1.01     · yyaxtoolbar was split off from yyzoom to replace 
%             >> yyzoom toolbar
%           · toolbar is now working after reloading a saved figure
% -------------------------------------------------------------------------

%{
figure
ax = yyaxtoolbar;
plot([0 1],[1,3])
yyaxis right
plot([1 2],[1,0])
grid on

%}

% ~~~ argument checks

arguments
    ax (1,1) matlab.graphics.axis.Axes = gca
end

nargoutchk(0,1);

% ~~~ add toolbar 

if strcmp(ax.Toolbar.Tag,'yyzoom')
    warning('yyzoom: custom toolbar is already present.')
else
    yyzoom("update")
    addyyaxtoolbar(ax);
end

if nargout > 0
    varargout{1} = ax;
end


end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% local functions
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function tf = hasListener(ax,CallbackStr)

% Determine if axis ax has a valid listener with the specified callback
% function string.

tf = false; % default

if isprop(ax,'AutoListeners__')
    nListener = numel(ax.AutoListeners__);
else
    return
end

for k = 1:nListener
    tf = tf || ( isValidProplistener(ax.AutoListeners__{k}, CallbackStr) );
end

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function addyyaxtoolbar(ax)

% add the toolbar to the axes ax

%% ~~~~~~ create the 7 default buttons

tb = axtoolbar(ax,{'export','brush','datacursor','pan','zoomin',...
    'zoomout','restoreview'},'Tag','yyzoom');

%{
% A remark on 'restoreview':
% restoreview / zoom('out') sets the axes limits back to the values that
% can be retrieved by getappdata(ax,'matlab_graphics_resetplotview') or
% getappdata(ax,'zoom_zoomOrigAxesLimits') once a >> zoom reset
% has been executed.
% Problem: the zoomOrig y-axis limits may originate from either the left or
% the right y-axis, but zoom('out') applies them to the active side, no
% matter if the sides match or not.
% I have not yet found a way to trace back the original side of the limits,
% so the user has to activate the matching side by himself.
% As a placeholder / reminder for a possible future workaround function, I
% keep the comment with a substitute function 'myzoomout' here.
tb.Children(strcmpi('restoreview',{tb.Children.Tag})).ButtonPushedFcn = ...
    @(~,event) myzoomout(event.Axes);
%}


%% ~~~~~~ button 8 in toolbar: pushbutton "Active y-axis side."

% This pushbutton's icon adapts to active side and it is altered if the
% TickValuesMode changes: dashes appear if TickValuesMode is 'auto'.
% Note that this alteration depends on the icons' original pixel
% array, so take care of it if you change the pixel array.

btnYSide = axtoolbarbtn(tb,'push');

    function updateYSideIcon(ax)
        side = ax.YAxisLocation;
        % debug:
        % disp("yyaxtoolbar: side change to "+ side+ " axis @"+ ...
        %      datestr(now,'HH:MM:SS:FFF'))
        addedText = [newline 'Click to change.' newline newline ...
                     '(Dashes indicate' newline 'Auto-TickValues.)'];
        if strcmp(side,'left')
            btnYSide.Icon = geticon('activeLeft');
            btnYSide.Tooltip = ['Left y-axis is active.' addedText];
        elseif strcmp(side,'right')
            btnYSide.Icon = geticon('activeRight');
            btnYSide.Tooltip = ['Right y-axis is active.' addedText];
        else
            btnYSide.Icon = geticon('activeNone');
            btnYSide.Tooltip = ['Active y-axis side.' addedText];
        end
        % add indicative dashes if TickValuesMode of an axis is auto
        isTVModeAuto = strcmpi('auto',{ax.YAxis.TickValuesMode});
        if isTVModeAuto(1)
            btnYSide.Icon([2,5,13,16],5:6) = btnYSide.Icon(2,2);
        end
        if isTVModeAuto(2)
            btnYSide.Icon([2,5,13,16],12:13) = btnYSide.Icon(2,16);
        end
    end

updateYSideIcon(ax);


% Add listener to the active y ruler side to update the icon of pushbutton
% "Active y-axis side" .
% - The listener function
sideListenFun = @(src,evnt)updateYSideIcon(evnt.AffectedObject);
% - The listener function as a string. The function string can be used to
%   identify the specific listener.
sideListenCbStr = func2str(sideListenFun);

addlistener(ax, 'YAxisLocation', 'PostSet', sideListenFun);

btnYSide.ButtonPushedFcn  = @(src,evnt) btnYLoc(src,evnt);

    function btnYLoc(~,event)
        % debug:
        % disp("yyaxtoolbar: side change button push @"+ ...
        %      datestr(now,'HH:MM:SS:FFF'))

        % Renew YAxisLocation listener if it is not valid/existing anymore,
        % e.g. after saving and reloading the figure.
        if ~hasListener(event.Axes,sideListenCbStr)
            addlistener(event.Axes,'YAxisLocation','PostSet',...
                @(src,evnt)updateYSideIcon(evnt.AffectedObject));
            % debug:
            % disp("yyaxtoolbar: location listener recreated @"+ ...
            %      datestr(now,'HH:MM:SS:FFF'))
        else

        end

        % Clicking this button also updates the limits and the dependent
        % ticks as if the limits of the currently active axis were changed
        % - useful after programmatic axis limits changes without notice of
        % the listener, as e.g. with >> ylim tickaligned
        yyzoom(event.Axes,"update")
        % Change the active axis after the above update.
        if strcmp(event.Axes.YAxisLocation,'left')
            yyaxis(event.Axes,"right");
        else
            yyaxis(event.Axes,"left");
        end
    end



%% ~~~~~~ button 9 in toolbar: state button "Zoom Y1+Y2"

btnYYZoom = axtoolbarbtn(tb,'state');
btnYYZoom.Icon = geticon('yyzoomState');
btnYYZoom.Tooltip = ['Zoom both Y1 & Y2.' newline '(Re-)activate to ' ...
                     newline 'renew base limits.'];
btnYYZoom.Value = 'on';

btnYYZoom.ValueChangedFcn = @(src,evnt) yyzoomState(src,evnt);

    function yyzoomState(src,event)
        switch src.Value
            case 'off'
                yyzoom(event.Axes,"off");
            case 'on'
                yyzoom(event.Axes,"new");
        end
    end


%% ~~~~~~ button 10 in toolbar: pushbutton "Align Y-axes Ticks."

btnYYAlign = axtoolbarbtn(tb,'push');
btnYYAlign.Icon = geticon('alignTicks');
btnYYAlign.Tooltip = ['Align Y1 & Y2 Ticks.' newline '(Renew base limits to' ...
                       newline 'keep them aligned.)' ];
btnYYAlign.ButtonPushedFcn  = @(~,evnt)yyaligncallback(evnt.Axes);

    function yyaligncallback(ax)
        yytick(ax,'limitmethod','none');
        updateYSideIcon(ax); % just to update the icon
    end


%% ~~~~~~ button 11 in toolbar: toolbarDropdown "More zoom actions"

DdMoreZoom = matlab.ui.controls.ToolbarDropdown;
DdMoreZoom.Icon = geticon('moreZoom');
DdMoreZoom.Tag = 'morezoomactions';
DdMoreZoom.Parent = tb;


%% ~~~ button 1 in Dropdown: pushbutton "Zoom Reset"

btnZReset = matlab.ui.controls.ToolbarPushButton;
btnZReset.Parent = DdMoreZoom;
btnZReset.Icon = geticon('zoomReset');
btnZReset.Tooltip = 'Zoom Reset';
btnZReset.ButtonPushedFcn  = @(src,evnt) zoom(evnt.Axes,'reset');
% note that the axes is passed to zoom as first argument, not the figure


%% ~~~ button 2 in Dropdown: pushbutton "Limits Auto"

btnLAuto = matlab.ui.controls.ToolbarPushButton;
btnLAuto.Parent = DdMoreZoom;
btnLAuto.Icon = geticon('limitsAuto');
btnLAuto.Tooltip = 'Limits & Ticks Auto';
btnLAuto.ButtonPushedFcn  = @(src,evnt) xylimauto(src,evnt);

    function xylimauto(~,event)
        xlim(event.Axes,'auto');
        xticks auto
        event.Axes.YAxis(1).LimitsMode = 'auto';
        event.Axes.YAxis(1).TickValuesMode = 'auto';
        event.Axes.YAxis(2).LimitsMode = 'auto';
        event.Axes.YAxis(2).TickValuesMode = 'auto';
        updateYSideIcon(event.Axes); % just to update the icon
    end


%% ~~~ button 3 in Dropdown: pushbutton "Zoom to Base"


btnYYZoomBase = matlab.ui.controls.ToolbarPushButton;
btnYYZoomBase.Parent = DdMoreZoom;
btnYYZoomBase.Icon = geticon('zoomToBase');
btnYYZoomBase.Tooltip = ['Zoom Y1+Y2 to' newline 'yyzoom base values.'];

btnYYZoomBase.ButtonPushedFcn  = @(src,evnt) yyzoombase(src,evnt);

    function yyzoombase(~,event)
        yyzoom(event.Axes,"base");
    end

%% ~~~ button 4 in Dropdown: pushbutton "tick-aligned limits"


btnTickAlign = matlab.ui.controls.ToolbarPushButton;
btnTickAlign.Parent = DdMoreZoom;
btnTickAlign.Icon = geticon('tickalignedLimits');
btnTickAlign.Tooltip = 'Tick-Aligned Limits';
btnTickAlign.ButtonPushedFcn  = @(src,evnt) ...
    setLimMethodBtnFun(evnt.Axes,'tickaligned');


%% ~~~ button 5 in Dropdown: pushbutton "pad limits"


btnPaddedLim = matlab.ui.controls.ToolbarPushButton;
btnPaddedLim.Parent = DdMoreZoom;
btnPaddedLim.Icon = geticon('paddedLimits');
btnPaddedLim.Tooltip = 'Padded Limits';
btnPaddedLim.ButtonPushedFcn  = @(src,evnt) ...
    setLimMethodBtnFun(evnt.Axes,'padded');


%% ~~~ button 6 in Dropdown: pushbutton "tight limits"


btnTightLim = matlab.ui.controls.ToolbarPushButton;
btnTightLim.Parent = DdMoreZoom;
btnTightLim.Icon = geticon('tightLimits');
btnTightLim.Tooltip = 'Tight Limits';
btnTightLim.ButtonPushedFcn  = @(src,evnt) ...
    setLimMethodBtnFun(evnt.Axes,'tight');


%% ~~~ button 7 in Dropdown: pushbutton "YTicks Auto"


btnYYTicksAuto = matlab.ui.controls.ToolbarPushButton;
btnYYTicksAuto.Parent = DdMoreZoom;
btnYYTicksAuto.Icon = geticon('ticksAuto');
btnYYTicksAuto.Tooltip = 'Y1+Y2 Ticks Auto';

btnYYTicksAuto.ButtonPushedFcn  = @(src,evnt) yyzoomticksauto(src,evnt);

    function yyzoomticksauto(~,event)
        event.Axes.YAxis(1).TickValuesMode = 'auto';
        event.Axes.YAxis(2).TickValuesMode = 'auto';
        updateYSideIcon(event.Axes); % just to update the icon
    end



%% ~~~ reorder buttons
ax.Toolbar.Children = movel(ax.Toolbar.Children,1:4,11,true);

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function setLimMethodBtnFun(ax, limMethod)

% button down function for setting the y-limit method of axes ax to
% limMethod (= "tight", "padded", or "tickaligned")

sides = {'left','right'};
yloc  = ax.YAxisLocation;
sideI = strcmpi(yloc,sides);
yytvmodes = {ax.YAxis.TickValuesMode};

% two cases:
% 1) the tick values modes of both y-axes are equal -> set the y-limit mode
%    for each y-axis individually
% 2) one tick values mode is 'auto' (=primary side, see yytick), the other
%    'manual' (=dependent side) -> special handling to keep the ticks
%    aligned

% Note 1: Some back and forth ylim calls appear as ...
% 1) ylim(ax,'tickaligned') alone sometimes has no effect at all,
%    but prepending ylim(ax,'padded') seems to help.
% 2) ylim(ax,method) and ax.YAxis(sideI).Limits = ___ are not
%    captured by the proplistener, but ylim(ax,limits) is.

% Note 2:
% For some plots, method 'tickaligned' produces the 'tight' result (R2021a)
%{
% demo:
figure('pos',[50   500   250   250])
plot([ 18.8546 82.2977])
% play around with:
ylim tight
ylim padded
ylim tickaligned
%}
%

if strcmp(yytvmodes{:})
    % work on the current y-axis side
    ylim(ax,'padded');
    ylim(ax, limMethod);

    % work on the other y-axis side
    yyaxis(ax,sides{~sideI})
    ylim(ax,'padded');
    ylim(ax, limMethod);
    
    % switch back to the previous side
    yyaxis(ax,sides{sideI})

else
    % procedure:
    % 1) set the dependent side to tight limits in a way that the
    %    proplistener notices (back and forth...) so that the limits on the
    %    primary side are adjusted, too
    % 2) store the resulting new limits of the primary side as they
    %    correspond to the tight limits of the dependent side
    % 3) add temporary data containing these limits to the plot on the
    %    primary side 
    % 4) change the primary side limits applying the desired limMethod in a
    %    way that the proplistener notices so that the limits on the
    %    dependent side are adjusted, too
    % 5) remove the temporary data

    % primary and dependent side indices
    priSideI = strcmp('auto', yytvmodes);
    depSideI = ~priSideI;

    % step 1)
    yyaxis(ax,sides{depSideI})
    ylo   = ylim(ax);               % the old limits
    ylim(ax,'padded');
    ylim(ax,'tight');
    yln = ylim(ax);                 % the tight limits
    ax.YAxis(depSideI).Limits = ylo;
    ylim(ax,yln);                   % <- noticed by the listener

    % step 2)
    yyaxis(ax,sides{priSideI})
    yls   = ylim(ax);               % the corresponding limits

    % step 3)
    isHoldOff = ~ishold(ax);
    if isHoldOff
        hold(ax,'on')
    end
    temp = plot(ax,xlim,yls,'Color','none');

    % step 4)
    ylim(ax,'padded');
    ylim(ax,limMethod);
    yln = ylim(ax);                 % the new limits
    ax.YAxis(priSideI).Limits = yls;
    ylim(ax,yln);                   % <- noticed by the listener

    % step 5)
    delete(temp)
    if isHoldOff
        hold(ax,'off')
    end

end

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


function icon = geticon(iconname)

% Get an icon for the axes toolbar from the yyzoom icon collection.
% Icons size is 16 x 16, except for the dropdown icon (14 x 14), the pixel
% values range from 0 (black) to 63 (transparent).
%
% Currently known values for iconname:
% 'activeLeft'            'activeRight'           'activeNone' 
% 'yyzoomState'           'alignTicks'            'moreZoom' (14x14)  
% 'zoomReset'             'limitsAuto'            'zoomToBase'  
% 'tickalignedLimits'     'paddedLimits'          'tightLimits'
% 'ticksAuto'  

switch iconname

    case 'activeLeft'
        icon = uint8([
            63	63	63	63	63	63	63	63	63	63	63	63	63	63	63	63
            63	0	 0	63	63	63	63	63	63	63	63	63	63	63	41	32
            63	0	36	63	63	63	63	63	63	63	63	63	63	63	59	32
            63	0	45	63	63	63	63	63	63	63	63	63	63	63	63	32
            63	0	 0	63	63	63	63	63	63	63	63	63	63	63	41	32
            63	0	36	63	63	63	63	63	63	63	63	63	63	63	59	32
            63	0	36	63	63	63	12	63	63	63	12	63	63	63	59	32
            63	0	36	63	63	12	12	63	63	63	12	12	63	63	59	32
            63	0	 0	63	12	12	12	12	12	12	12	12	12	63	41	32
            63	0	36	63	63	12	12	63	63	63	12	12	63	63	59	32
            63	0	36	63	63	63	12	63	63	63	12	63	63	63	59	32
            63	0	36	63	63	63	63	63	63	63	63	63	63	63	59	32
            63	0	 0	63	63	63	63	63	63	63	63	63	63	63	41	32
            63	0	36	63	63	63	63	63	63	63	63	63	63	63	63	32
            63	0	36	63	63	63	63	63	63	63	63	63	63	63	59	32
            63	0	 0	63	63	63	63	63	63	63	63	63	63	63	41	32 
            ]);

    case 'activeRight'
        icon = uint8([
            63	63	63	63	63	63	63	63	63	63	63	63	63	63	63	63
            63	32	41	63	63	63	63	63	63	63	63	63	63	63	 0	0
            63	32	59	63	63	63	63	63	63	63	63	63	63	63	36	0
            63	32	63	63	63	63	63	63	63	63	63	63	63	63	45	0
            63	32	41	63	63	63	63	63	63	63	63	63	63	63	 0	0
            63	32	59	63	63	63	63	63	63	63	63	63	63	63	36	0
            63	32	59	63	63	63	12	63	63	63	12	63	63	63	36	0
            63	32	59	63	63	12	12	63	63	63	12	12	63	63	36	0
            63	32	41	63	12	12	12	12	12	12	12	12	12	63	 0	0
            63	32	59	63	63	12	12	63	63	63	12	12	63	63	36	0
            63	32	59	63	63	63	12	63	63	63	12	63	63	63	36	0
            63	32	59	63	63	63	63	63	63	63	63	63	63	63	36	0
            63	32	41	63	63	63	63	63	63	63	63	63	63	63	 0	0
            63	32	59	63	63	63	63	63	63	63	63	63	63	63	36	0
            63	32	59	63	63	63	63	63	63	63	63	63	63	63	36	0
            63	32	41	63	63	63	63	63	63	63	63	63	63	63	 0	0 
            ]);

    case 'activeNone'
        icon = uint8([ ...
            63	63	63	63	63	63	63	63	63	63	63	63	63	63	63	63
            63	30	39	63	63	63	63	63	63	63	63	63	63	63	39	30
            63	30	58	63	63	63	63	63	63	63	63	63	63	63	58	30
            63	30	63	63	63	63	63	63	63	63	63	63	63	63	63	30
            63	30	39	63	63	63	63	63	63	63	63	63	63	63	39	30
            63	30	58	63	63	63	63	63	63	63	63	63	63	63	58	30
            63	30	58	63	63	63	12	63	63	63	12	63	63	63	58	30
            63	30	58	63	63	12	12	63	63	63	12	12	63	63	58	30
            63	30	39	63	12	12	12	12	12	12	12	12	12	63	39	30
            63	30	58	63	63	12	12	63	63	63	12	12	63	63	58	30
            63	30	58	63	63	63	12	63	63	63	12	63	63	63	58	30
            63	30	58	63	63	63	63	63	63	63	63	63	63	63	58	30
            63	30	39	63	63	63	63	63	63	63	63	63	63	63	39	30
            63	30	58	63	63	63	63	63	63	63	63	63	63	63	63	30
            63	30	58	63	63	63	63	63	63	63	63	63	63	63	58	30
            63	30	39	63	63	63	63	63	63	63	63	63	63	63	39	30
            ]);

    case 'yyzoomState'
        icon = uint8([
            63	63	63	63	63	63	63	63	63	63	63	63	63	63	63	63
            63	0	0	63	63	63	63	63	63	63	63	63	63	63	0	0
            63	0	36	0	63	63	63	63	63	63	63	63	63	0	36	0
            63	0	45	36	63	63	63	63	63	63	63	63	18	36	45	0
            63	0	0	45	63	33	0	0	0	4	58	63	63	45	0	0
            63	0	36	45	33	0	54	61	59	25	0	63	63	45	36	0
            63	0	36	45	0	54	63	63	63	61	0	54	63	45	36	0
            63	0	36	45	0	58	63	63	63	61	8	33	63	45	36	0
            63	0	0	45	2	54	63	63	63	61	0	54	63	45	0	0
            63	0	36	45	33	0	54	59	58	16	0	63	63	45	36	0
            63	0	36	45	63	33	0	0	0	0	0	54	63	45	36	0
            63	0	36	45	63	63	63	58	61	61	33	0	59	45	36	0
            63	0	0	45	63	18	63	63	63	63	63	33	0	45	0	0
            63	0	36	36	18	63	63	63	63	63	63	63	63	36	45	0
            63	0	36	0	63	63	63	63	63	63	63	63	63	0	36	0
            63	0	0	63	63	63	63	63	63	63	63	63	63	63	0	0 
            ]);

    case 'alignTicks'
        icon = uint8([
            63	63	63	63	63	63	63	63	63	63	63	63	63	63	63	63
            63	0	18	63	63	63	63	63	63	63	63	63	63	63	18	0
            63	0	54	63	63	63	1	63	63	63	1	63	63	63	54	0
            63	0	63	63	63	63	54	1	63	1	54	63	63	63	63	0
            63	0	18	63	63	63	63	54	1	54	63	63	63	63	18	0
            63	0	54	63	63	63	63	63	63	63	63	63	63	63	54	0
            63	0	54	63	1	1	48	1	1	1	48	1	1	63	54	0
            63	0	54	63	63	63	63	63	63	63	63	63	63	63	54	0
            63	0	18	63	63	63	63	63	63	63	63	63	63	63	18	0
            63	0	54	63	63	63	63	63	63	63	63	63	63	63	54	0
            63	0	54	63	1	1	48	1	1	1	48	1	1	63	54	0
            63	0	54	63	63	63	63	63	63	63	63	63	63	63	54	0
            63	0	18	63	63	63	63	63	1	63	63	63	63	63	18	0
            63	0	54	63	63	63	63	1	54	1	63	63	63	63	63	0
            63	0	54	63	63	63	1	54	63	54	1	63	63	63	54	0
            63	0	18	63	63	63	63	63	63	63	63	63	63	63	18	0 
            ]);

    case 'moreZoom'
        icon = uint8([ ...
            63  63  63  23   3   0   0   0   3  23  63  63  63
            63  52   6   1  23  30  22  30  23   1   6  52  63
            63   6   6  52  63  12   1  12  63  52   6   6  63
            23   1  52  63  63  36   1  36  63  63  52   1  23
            3   23  63  63  63  60  57  60  63  63  63  23   3
            0   44  63  63  60  36  12  47  63  63  63  44   0
            0   63  63  63  57   1   1  22  63  63  63  63   0
            0   44  63  63  60  36  12  47  63  63  63  44   0
            3   23  63  63  63  60  57  60  63  63  63  23   3
            28   1  49  63  63  36   1  36  63  63  49   1  31
            63   6   6  49  63  12   1  12  63  49   1   1  63
            63  52   6   1  23  27  22  27  23   1   4   1  16
            63  63  63  31   6   0   0   0   6  31  63  35   0
            ]);

    case 'zoomReset'
        icon = uint8([
            63	63	63	29	11	4	4	4	11	29	63	63	63	63	63	63
            63	53	14	7	29	46	63	46	29	7	14	53	63	63	63	63
            63	14	14	53	63	63	63	63	63	53	14	14	63	63	63	63
            29	7	53	60	4	4	4	12	33	62	53	7	29	63	63	63
            11	29	63	60	4	22	63	36	4	44	63	29	11	63	63	63
            4	46	63	60	4	22	63	48	4	38	63	46	4	63	63	63
            4	63	63	60	4	22	63	36	4	51	63	63	4	63	63	63
            4	46	63	60	4	4	4	4	31	63	63	46	4	63	63	63
            11	29	63	60	4	22	61	35	4	42	63	29	11	63	63	63
            33	7	50	60	4	22	63	62	20	7	44	7	36	63	63	63
            63	14	14	50	63	63	63	63	63	50	7	7	63	63	63	63
            63	53	14	7	29	42	63	42	29	7	12	7	23	63	63	63
            63	63	63	36	14	4	4	4	14	36	63	39	4	23	63	63
            63	63	63	63	63	63	63	63	63	63	63	63	36	4	23	63
            63	63	63	63	63	63	63	63	63	63	63	63	63	36	4	33
            63	63	63	63	63	63	63	63	63	63	63	63	63	63	36	4 
            ]);

    case 'limitsAuto'
        icon = uint8([
            63  63  63  23   3   0   0   0   3  23  63  63  63  63  63  63
            63  52   6   1  23  43  63  43  23   1   6  52  63  63  63  63
            63   6   6  52  63  63  63  63  63  52   6   6  63  63  63  63
            23   1  52  63  63  29   1  32  63  63  52   1  23  63  63  63
            3   23  63  63  61   2   1   5  62  63  63  23   3  63  63  63
            0   43  63  63  47   1  34   1  49  63  63  43   0  63  63  63
            0   63  63  63  26   4  60   2  29  63  63  63   0  63  63  63
            0   43  63  60   1  27  63  24   2  61  63  43   0  63  63  63
            3   23  63  46   1   1   1   1   1  47  63  23   3  63  63  63
            27   1  48  23   8  62  63  62   7  25  48   1  31  63  63  63
            63   6   6  48  63  63  63  63  63  48   1   1  63  63  63  63
            63  52   6   1  23  38  63  38  23   1   4   1  16  63  63  63
            63  63  63  31   6   0   0   0   6  31  63  35   0  16  63  63
            63  63  63  63  63  63  63  63  63  63  63  63  31   0  16  63
            63  63  63  63  63  63  63  63  63  63  63  63  63  31   0  27
            63  63  63  63  63  63  63  63  63  63  63  63  63  63  31   0
            ]);

    case 'zoomToBase'
        icon = uint8([
            63	63	63	63	63	63	63	63	63	63	63	63	63	63	63	63
            63	0	18	63	63	63	63	63	63	63	63	63	63	63	18	0
            63	0	54	63	63	63	63	63	63	63	63	63	63	63	54	0
            63	0	63	63	63	63	63	63	18	62	63	0	5	63	63	0
            63	0	18	63	63	63	61	19	8	19	58	26	0	63	18	0
            63	0	54	63	63	59	14	14	56	8	13	58	33	63	54	0
            63	0	54	63	59	13	13	63	63	55	13	13	55	63	54	0
            63	0	54	63	13	19	56	63	63	63	59	19	8	63	54	0
            63	0	18	63	19	12	58	63	63	63	58	12	19	63	18	0
            63	0	54	63	63	7	58	7	5	7	58	7	63	63	54	0
            63	0	54	63	63	7	58	7	59	7	58	7	63	63	54	0
            63	0	54	63	63	7	59	7	59	7	59	7	63	63	54	0
            63	0	18	63	63	6	54	6	59	6	54	6	63	63	18	0
            63	0	54	63	63	2	0	2	59	2	0	2	63	63	63	0
            63	0	54	63	63	63	63	63	63	63	63	63	63	63	54	0
            63	0	18	63	63	63	63	63	63	63	63	63	63	63	18	0
            ]);

    case 'tickalignedLimits'
        icon = uint8([ ...
            63  63  63  63  63  63  63  63  63  63  63  63  63  63  63  63
            63  63  63   0   0  63   0   0   0   0   0   0   0  63  63  63
            63  63  63   0  54  63  63   0  18  54  63  63  63  63  63  63
            63  63  63   0  63  63  63  63   0  54  63  63  63  63  63  63
            63  63  63   0  18  63  63  63  63  18  54  63  63  63  63  63
            63  63  63   0  54  63  63  63  63  63  63  63  63  63  63  63
            63  63  63   0  54  63  63  63  63  63  63  63  63  63  63  63
            63  63  63   0  54  63  63  63  63  63  63  63  63  63  63  63
            63  63  63   0  18  63  63  63  63  63  63  63  63  63  63  63
            63  63  63   0  54  63  63  63  63  63  63  63  63  63  63  63
            63  63  63   0  54  63  63  63  63  63  63  63  63  63  63  63
            63  63  63   0  54  63  63  63  63  63  63  63  63  63  63  63
            63  63  63   0  18  63  63  63  63  18  54  63  63  63  63  63
            63  63  63   0  54  63  63  63   0  54  63  63  63  63  63  63
            63  63  63   0  54  63  63   0  18  54  63  63  63  63  63  63
            63  63  63   0   0  63   0   0   0   0   0   0   0  63  63  63
            ]);

    case 'paddedLimits'
        icon = uint8([ ...
            63  63  63  63  63  63  63  63  63  63  63  63  63  63  63  63
            63  63  63   0   0  63  63  63  63  18  54  63  63  63  63  63
            63  63  63   0  54  63  63  63   0  54  63  63  63  63  63  63
            63  63  63   0  63  63  63   0  18  54  63  63  63  63  63  63
            63  63  63   0  18  63   0   0   0   0   0   0   0  63  63  63
            63  63  63   0  54  63  63   0  18  54  63  63  63  63  63  63
            63  63  63   0  54  63  63  63   0  54  63  63  63  63  63  63
            63  63  63   0  54  63  63  63  63  18  54  63  63  63  63  63
            63  63  63   0  18  63  63  63  63  63  63  63  63  63  63  63
            63  63  63   0  54  63  63  63  63  18  54  63  63  63  63  63
            63  63  63   0  54  63  63  63   0  54  63  63  63  63  63  63
            63  63  63   0  54  63  63   0  18  54  63  63  63  63  63  63
            63  63  63   0  18  63   0   0   0   0   0   0   0  63  63  63
            63  63  63   0  54  63  63   0  18  54  63  63  63  63  63  63
            63  63  63   0  54  63  63  63   0  54  63  63  63  63  63  63
            63  63  63   0   0  63  63  63  63  18  54  63  63  63  63  63
            ]);

    case 'tightLimits'
        icon = uint8([ ...
            63  63  63  63  63  63  63  63  63  63  63  63  63  63  63  63
            63  63  63   0  17  63  63   0  63  63  63   0  63  63  63  63
            63  63  63   0  54  63  63  54   0  63   0  54  63  63  63  63
            63  63  63   0  63  63  63  63  54   0  54  63  63  63  63  63
            63  63  63   0  17  63   0   0  48  48   0   0  48  63  63  63
            63  63  63   0  54  63  24  21  63  63  63  63  63  63  63  63
            63  63  63   0  54  44  15  39  29  63  63  63  63  63  63  63
            63  63  63   0  54  24  56  56  15  56  63  63  63  63  63  63
            63  63  63   0  17  56  63  63  24  21  63  63  63  63  63  63
            63  63  63   0  54  63  63  63  56  24  63  63  63  63  63  63
            63  63  63   0  54  63  63  63  63  44   8  56  44  44  63  63
            63  63  63   0  54  63  63  63  63  63  39  24   0  63  63  63
            63  63  63   0  17  63   0   0  48  48   0   0  48  63  63  63
            63  63  63   0  54  63  63  63  63   0  63  63  63  63  63  63
            63  63  63   0  54  63  63  63   0  54   0  63  63  63  63  63
            63  63  63   0  17  63  63   0  54  63  54   0  63  63  63  63
            ]);

    case 'ticksAuto'
        icon = uint8([
            63  63  63  63  63  63  63  63  63  63  63  63  63  63  63  63
            63   0  18  63  63  63  63  63  63  63  63  63  63  63  18   0
            63   0  54  63  63  63  63  63  63  63   1  54  63  63  54   0
            63   0  63  63  63  63  63  63  63  63   1  54  63  63  63   0
            63   0  18  63  63  63  63  63  63   1  54  63  63  63  18   0
            63   0  54  63  63  63  63  63  63   1  54  63  63  63  54   0
            63   0  54  63   1   1  48   1   1   1  48   1   1  63  54   0
            63   0  54  63  63  63  63  63   1  54  63  63  63  63  54   0
            63   0  18  63  63  63  63  63   1  54  63  63  63  63  18   0
            63   0  54  63  63  63  63  63   1  54  63  63  63  63  54   0
            63   0  54  63   1   1  48   1   1   1  48   1   1  63  54   0
            63   0  54  63  63  63  63   1  54  63  63  63  63  63  54   0
            63   0  18  63  63  63  63   1  54  63  63  63  63  63  18   0
            63   0  54  63  63  63   1  54  63  63  63  63  63  63  63   0
            63   0  54  63  63  63   1  54  63  63  63  63  63  63  54   0
            63   0  18  63  63  63  63  63  63  63  63  63  63  63  18   0
            ]);

    otherwise
        icon = uint8([
            63  63  63  63  63  63  63  63  63  63  63  63  63  63  63  63
            63   0  54  63  63  63  63  63  63  63  63  63  63  63   0  54
            63  63   0  54  63  63  63  63  63  63  63  63  63   0  54  63
            63  63  63   0  54  63  63  63  63  63  63  63   0  54  63  63
            63  63  63  63   0  54  63  63  63  63  63   0  54  63  63  63
            63  63  63  63  63   0  54  63  63  63   0  54  63  63  63  63
            63  63  63  63  63  63   0  54  63   0  54  63  63  63  63  63
            63  63  63  63  63  63  63   0   0  54  63  63  63  63  63  63
            63  63  63  63  63  63  63   0   0  54  63  63  63  63  63  63
            63  63  63  63  63  63   0  54  63   0  54  63  63  63  63  63
            63  63  63  63  63   0  54  63  63  63   0  54  63  63  63  63
            63  63  63  63   0  54  63  63  63  63  63   0  54  63  63  63
            63  63  63   0  54  63  63  63  63  63  63  63   0  54  63  63
            63  63   0  54  63  63  63  63  63  63  63  63  63   0  54  63
            63   0  54  63  63  63  63  63  63  63  63  63  63  63   0  54
            63  63  63  63  63  63  63  63  63  63  63  63  63  63  63  63 
            ]);

end

end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function x = movel(x,s,t,beforeFlag)

% MOVEL move (reorder) elements in vector or array
%
% y = MOVEL(x,s,t,beforeFlag)
%
% moves the elements in array x with linear indices s (source) to the
% position right before (*) or right after (**) the element with scalar
% linear index t (target).
% (*)  beforeFlag is true
% (**) beforeFlag is false
% 
% Example:
%
% x = 10:10:100
% s = [2,9,3];
% 
% t = 6;
% b = true;
% y = movel(x,s,t,b);   % -> place [20, 90, 30] before element @ index 6:
% 
% % x = [ 10    20    30    40    50    60    70    80    90   100 ]
% %             ^^    ^^                **                ^^      
% % y = [ 10    40    50    20    90    30    60    70    80   100 ]
% %                         ^^    ^^    ^^    **                  
% 
% t = 10;
% b = false;
% y = movel(x,s,t,b);   % -> place [20, 90, 30] after element @ index 10:
% 
% % x = [ 10    20    30    40    50    60    70    80    90   100 ]
% %             ^^    ^^                                  ^^   ***
% % y = [ 10    40    50    60    70    80   100    20    90    30 ]
% %                                          ***    ^^    ^^    ^^

s = s(:).';

% affected indices
k = min([s,t]):max([s,t]);

% the affected indices without the elements of s
ks = setdiff(k,s);

if beforeFlag
    x(k) = x([ks(ks< t), s, ks(ks>=t)]);
else
    x(k) = x([ks(ks<=t), s, ks(ks> t)]);
end

end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~