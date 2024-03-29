% MAin plot of time series, allowing to reject bad segments manually (from
% eegplot). 


function plot_data(data, varargin)

% DEFAULT_PLOT_COLOR = { [0 0 1], [0.7 0.7 0.7]}; % EEG line color
DEFAULT_FIG_COLOR = [0.93 0.96 1];
BUTTON_COLOR =[0.66 0.76 1];
DEFAULT_AXIS_COLOR = 'k';         % X-axis, Y-axis Color, text Color
% DEFAULT_GRID_SPACING = 1;         % Grid lines every n seconds
DEFAULT_GRID_STYLE = '-';         % Grid line style
% YAXIS_NEG = 'off';                % 'off' = positive up
% DEFAULT_NOUI_PLOT_COLOR = 'k';    % EEG line color for noui option
SPACING_EYE = 'on';               % g.spacingI on/off
% SPACING_UNITS_STRING = '';        % '\muV' for microvolt optional units for g.spacingI Ex. uV
ORIGINAL_POSITION = [50 50 800 500];

% matVers = version;
% matVers = str2double(matVers(1:3));

% Push button: create/remove window
defdowncom   = 'plot_data2(''defdowncom'',   gcbf);'; % push button: create/remove window
defmotioncom = 'plot_data2(''defmotioncom'', gcbf);'; % motion button: move windows or display current position
defupcom     = 'plot_data2(''defupcom'',     gcbf);';
defctrldowncom = 'plot_data2(''topoplot'',   gcbf);'; % CTRL press and motion -> do nothing by default
defctrlmotioncom = ''; % CTRL press and motion -> do nothing by default
defctrlupcom = ''; % CTRL press and up -> do nothing by default

% Inputs
options = varargin;
if ~isempty( varargin )
    for i = 1:2:numel(options)
        g.(options{i}) = options{i+1};
    end
else
    g = [];
end

% try g.spacing;          catch, g.spacing    = 100; end
try g.eloc_file;        catch, g.eloc_file  = 0; end % 0 mean numbered
% try g.winlength; 		catch, g.winlength	= 15; end % Number of seconds of EEG displayed
try g.position; 	    catch, g.position	= ORIGINAL_POSITION; 	end
try g.title; 		    catch, g.title		= 'Scroll and select artifacts to reject'; 	end
% try g.plottitle; 		catch, g.plottitle	= ''; 	end
try g.trialstag; 		catch, g.trialstag	= -1; 	end
try g.winrej; 			catch, g.winrej		= []; 	end
try g.command; 			catch, g.command	= ''; 	end
try g.tag; 				catch, g.tag		= 'plot_data'; end
try g.xgrid;		    catch, g.xgrid		= 'off'; end
try g.ygrid;		    catch, g.ygrid		= 'off'; end
try g.color;		    catch, g.color		= 'off'; end
try g.submean;			catch, g.submean	= 'off'; end % substract mean (detrending)
try g.children;			catch, g.children	= 0; end
% try g.limits;		    catch, g.limits	    = [0 1000*(size(data,2)-1)/g.srate]; end
% try g.freqs;            catch, g.freqs	    = []; end  
% try g.freqlimits;	    catch, g.freqlimits	= []; end
try g.dispchans; 		catch, g.dispchans  = size(data,1); end
try g.wincolor; 		catch, g.wincolor   = [ 0.7 1 0.9]; end
% try g.butlabel; 		catch, g.butlabel   = 'REJECT'; end
try g.colmodif; 		catch, g.colmodif   = { g.wincolor }; end
try g.scale; 		    catch, g.scale      = 'on'; end
try g.events; 		    catch, g.events      = []; end
% try g.ploteventdur;     catch, g.ploteventdur = 'off'; end
try g.data2;            catch, g.data2      = []; end
try g.plotdata2;        catch, g.plotdata2 = 'off'; end
try g.mocap;		    catch, g.mocap		= 'off'; end % nima
try g.selectcommand;    catch, g.selectcommand     = { defdowncom defmotioncom defupcom }; end
try g.ctrlselectcommand; catch, g.ctrlselectcommand = { defctrldowncom defctrlmotioncom defctrlupcom }; end
% try g.datastd;          catch, g.datastd = []; end 
% try g.normed;           catch, g.normed = 0; end 
try g.envelope;         catch, g.envelope = 0; end
try g.maxeventstring;   catch, g.maxeventstring = 10; end
% try g.isfreq;           catch, g.isfreq = 0;    end
try g.noui;             catch, g.noui = 'off'; end
try g.time;             catch, g.time = []; end
% if strcmpi(g.ploteventdur, 'on'), g.ploteventdur = 1; else g.ploteventdur = 0; end
% if ndims(data) > 2
%     g.trialstag = size(	data, 2);
% end
g.command = '[outEEG, com] = eeg_eegrej(data,eegplot2event(TMPREJ,-1));';
gfields = fieldnames(g);
for index = 1:length(gfields)
    switch gfields{index}
        case {'spacing', 'srate' 'eloc_file' 'winlength' 'position' 'title' 'plottitle' ...
                'trialstag'  'winrej' 'command' 'tag' 'xgrid' 'ygrid' 'color' 'colmodif'...
                'freqs' 'freqlimits' 'submean' 'children' 'limits' 'dispchans' 'wincolor' ...
                'maxeventstring' 'ploteventdur' 'butlabel' 'scale' 'events' 'data2' 'plotdata2' ...
                'mocap' 'selectcommand' 'ctrlselectcommand' 'datastd' 'normed' 'envelope' 'isfreq' 'noui' 'time' }
        otherwise
            error(['plot_data2: unrecognized option: ''' gfields{index} '''' ]);
    end
end


% Convert color to modify into array of float
for index = 1:length(g.colmodif)
    if iscell(g.colmodif{index})
        tmpcolmodif{index} = g.colmodif{index}{1} ...
            + g.colmodif{index}{2}*10 ...
            + g.colmodif{index}{3}*100;
    else
        tmpcolmodif{index} = g.colmodif{index}(1) + g.colmodif{index}(2)*10 + g.colmodif{index}(3)*100;
    end
end
% g.colmodif = 100.7;

[g.chans,g.frames, tmpnb] = size(data);
g.frames = g.frames*tmpnb;

if g.spacing == 0
    maxindex = min(1000, g.frames);
    stds = std(data(:,1:maxindex),[],2);
    g.datastd = stds;
    stds = sort(stds);
    if length(stds) > 2
        stds = mean(stds(2:end-1));
    else
        stds = mean(stds);
    end
    g.spacing = stds*3;
    if g.spacing > 10
        g.spacing = round(g.spacing);
    end
    if g.spacing  == 0 || isnan(g.spacing)
        g.spacing = 1; % default
    end
end

% Set defaults
g.incallback = 0;
g.winstatus = 1;
g.setelectrode  = 0;
[g.chans,g.frames,tmpnb] = size(data);
g.frames = g.frames*tmpnb;
g.nbdat = 1; % deprecated
g.elecoffset = 0;

switch lower(g.color)
    case 'on', g.color = { 'k', 'm', 'c', 'b', 'g' };
    case 'off', g.color = { [ 0 0 0.4] };
end

% %%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare figure and axes
% %%%%%%%%%%%%%%%%%%%%%%%%%
figh = figure('UserData', g,... % store the settings here
    'Color',DEFAULT_FIG_COLOR, 'name', g.title,...
    'MenuBar','none','tag', g.tag','Position', g.position, ...
    'numbertitle', 'off', 'visible', 'off', 'Units', 'Normalized');
pos = get(figh,'position'); % plot relative to current axes
q = [pos(1) pos(2) 0 0];
s = [pos(3) pos(4) pos(3) pos(4)]./100;
clf;

% Plot title if provided
if ~isempty(g.title)
    h = textsc(g.title, 'title');
    set(h, 'tag', 'plottitle');
end

% Max event string
DEFAULT_AXES_POSITION = [0.0964286 0.15 0.842 0.75-(g.maxeventstring-5)/100];

% Background axis
ax0 = axes('tag','backeeg','parent',figh,...
    'Position',DEFAULT_AXES_POSITION,...
    'Box','off','xgrid','off', 'xaxislocation', 'top', 'Units', 'Normalized');

% Drawing axis
YLabels = num2str((1:g.chans)');  % Use numbers as default
YLabels = flipud(char(YLabels,' '));
ax1 = axes('Position',DEFAULT_AXES_POSITION,...
    'userdata', data, ...% store the data here
    'tag','eegaxis','parent',figh,...%(when in g, slow down display)
    'Box','on','xgrid', g.xgrid,'ygrid', g.ygrid,...
    'gridlinestyle',DEFAULT_GRID_STYLE,...
    'Ylim',[0 (g.chans+1)*g.spacing],...
    'YTick',0:g.spacing:g.chans*g.spacing,...
    'YTickLabel', YLabels,...
    'TickLength',[.005 .005],...
    'Color','none',...
    'XColor',DEFAULT_AXIS_COLOR,...
    'YColor',DEFAULT_AXIS_COLOR);
set(ax1, 'TickLabelInterpreter', 'none');

% if ischar(g.eloc_file) || isstruct(g.eloc_file)  % Read in electrode name
%     if isstruct(g.eloc_file) && length(g.eloc_file) > size(data,1)
%         g.eloc_file(end) = []; % common reference channel location
%     end
%     plot_data2('setelect', g.eloc_file, ax1);
% end

% %%%%%%%%%%%%%%%%%%%%%%%%%
% Set up uicontrols
% %%%%%%%%%%%%%%%%%%%%%%%%%

% positions of buttons
posbut(1,:) = [ 0.0464    0.0254    0.0385    0.0339 ]; % <<
posbut(2,:) = [ 0.0924    0.0254    0.0288    0.0339 ]; % <
posbut(3,:) = [ 0.1924    0.0254    0.0299    0.0339 ]; % >
posbut(4,:) = [ 0.2297    0.0254    0.0385    0.0339 ]; % >>
posbut(5,:) = [ 0.1287    0.0203    0.0561    0.0390 ]; % Eposition
posbut(6,:) = [ 0.4744    0.0236    0.0582    0.0390 ]; % Espacing
posbut(7,:) = [ 0.2762    0.01    0.0582    0.0390 ]; % elec
posbut(8,:) = [ 0.3256    0.01    0.0707    0.0390 ]; % g.time
posbut(9,:) = [ 0.4006    0.01    0.0582    0.0390 ]; % value
posbut(14,:) = [ 0.2762    0.05    0.0582    0.0390 ]; % elec tag
posbut(15,:) = [ 0.3256    0.05    0.0707    0.0390 ]; % g.time tag
posbut(16,:) = [ 0.4006    0.05    0.0582    0.0390 ]; % value tag
posbut(10,:) = [ 0.5437    0.0458    0.0275    0.0270 ]; % +
posbut(11,:) = [ 0.5437    0.0134    0.0275    0.0270 ]; % -
posbut(12,:) = [ 0.6    0.02    0.14    0.05 ]; % cancel
posbut(13,:) = [-0.15   0.02    0.07    0.05 ]; % cancel
posbut(17,:) = [-0.06    0.02    0.09    0.05 ]; % events types
posbut(20,:) = [-0.17   0.15     0.015    0.8 ]; % slider
posbut(21,:) = [0.738    0.87    0.06      0.048];%normalize
posbut(22,:) = [0.738    0.93    0.06      0.048];%stack channels(same offset)
posbut(:,1) = posbut(:,1)+0.2;

% 5 buttons to move
u(1) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'Position', posbut(1,:), ...
    'Tag','Pushbutton1',...
    'string','<<',...
    'Callback',['global in_callback;', ...
    'if isempty(in_callback);in_callback=1;', ...
    '    try plot_data(''drawp'',1);', ...
    '        clear global in_callback;', ...
    '    catch error_struct;', ...
    '        clear global in_callback;', ...
    '        throw(error_struct);', ...
    '    end;', ...
    'else;return;end;']);
u(2) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'Position', posbut(2,:), ...
    'Tag','Pushbutton2',...
    'string','<',...
    'Callback',['global in_callback;', ...
    'if isempty(in_callback);in_callback=1;', ...
    '    try plot_data(''drawp'',2);', ...
    '        clear global in_callback;', ...
    '    catch error_struct;', ...
    '        clear global in_callback;', ...
    '        throw(error_struct);', ...
    '    end;', ...
    'else;return;end;']);
u(3) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'Position',posbut(3,:), ...
    'Tag','Pushbutton3',...
    'string','>',...
    'Callback',['global in_callback;', ...
    'if isempty(in_callback);in_callback=1;', ...
    '    try plot_data(''drawp'',3);', ...
    '        clear global in_callback;', ...
    '    catch error_struct;', ...
    '        clear global in_callback;', ...
    '        throw(error_struct);', ...
    '    end;', ...
    'else;return;end;']);
u(4) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'Position',posbut(4,:), ...
    'Tag','Pushbutton4',...
    'string','>>',...
    'Callback',['global in_callback;', ...
    'if isempty(in_callback);in_callback=1;', ...
    '    try plot_data(''drawp'',4);', ...
    '        clear global in_callback;', ...
    '    catch error_struct;', ...
    '        clear global in_callback;', ...
    '        error(error_struct);', ...
    '    end;', ...
    'else;return;end;']);
u(5) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'BackgroundColor',[1 1 1], ...
    'Position', posbut(5,:), ...
    'Style','edit', ...
    'Tag','EPosition',...
    'string', num2str(g.time),...
    'Callback', 'plot_data(''drawp'',0);' );

% Text edit fields
u(6) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'BackgroundColor',[1 1 1], ...
    'Position', posbut(6,:), ...
    'Style','edit', ...
    'Tag','ESpacing',...
    'string',num2str(g.spacing),...
    'Callback', 'plot_data(''draws'',0);' );

% Slider for vertical motion
u(20) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'Position', posbut(20,:), ...
    'Style','slider', ...
    'visible', 'off', ...
    'sliderstep', [0.9 1], ...
    'Tag','eegslider', ...
    'callback', [ 'tmpg = get(gcbf, ''userdata'');' ...
    'tmpg.elecoffset = get(gcbo, ''value'')*(tmpg.chans-tmpg.dispchans);' ...
    'set(gcbf, ''userdata'', tmpg);' ...
    'plot_data(''drawp'',0);' ...
    'clear tmpg;' ], ...
    'value', 0);

% Channels, position, value and tag
u(9) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'BackgroundColor',DEFAULT_FIG_COLOR, ...
    'Position', posbut(7,:), ...
    'Style','text', ...
    'Tag','Eelec',...
    'string',' ');
u(10) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'BackgroundColor',DEFAULT_FIG_COLOR, ...
    'Position', posbut(8,:), ...
    'Style','text', ...
    'Tag','Etime',...
    'string','0.00');
u(11) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'BackgroundColor',DEFAULT_FIG_COLOR, ...
    'Position',posbut(9,:), ...
    'Style','text', ...
    'Tag','Evalue',...
    'string','0.00');
u(14)= uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'BackgroundColor',DEFAULT_FIG_COLOR, ...
    'Position', posbut(14,:), ...
    'Style','text', ...
    'Tag','Eelecname',...
    'string','Chan.');

% Values of time/value and freq/power in GUI
% if g.isfreq
%     u15_string =  'Freq';
%     u16_string  = 'Power';
% else
u15_string =  'Time';
u16_string  = 'Value';
% end

u(15) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'BackgroundColor',DEFAULT_FIG_COLOR, ...
    'Position', posbut(15,:), ...
    'Style','text', ...
    'Tag','Etimename',...
    'string',u15_string);

u(16) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'BackgroundColor',DEFAULT_FIG_COLOR, ...
    'Position',posbut(16,:), ...
    'Style','text', ...
    'Tag','Evaluename',...
    'string',u16_string);

% ESpacing buttons: + -
u(7) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'Position',posbut(10,:), ...
    'Tag','Pushbutton5',...
    'string','+',...
    'FontSize',8,...
    'Callback','plot_data(''draws'',1)');
u(8) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'Position',posbut(11,:), ...
    'Tag','Pushbutton6',...
    'string','-',...
    'FontSize',8,...
    'Callback','plot_data(''draws'',2)');

cb_normalize = ['g = get(gcbf,''userdata'');if g.normed, disp(''Denormalizing...''); else, disp(''Normalizing...''); end;'...
    'hmenu = findobj(gcf, ''Tag'', ''Normalize_menu'');' ...
    'ax1 = findobj(''tag'',''eegaxis'',''parent'',gcbf);' ...
    'data = get(ax1,''UserData'');' ...
    'if isempty(g.datastd), g.datastd = std(data(:,1:min(1000,g.frames),[],2)); end;'...
    'if g.normed, '...
    'for i = 1:size(data,1), '...
    'data(i,:,:) = data(i,:,:)*g.datastd(i);'...
    'if ~isempty(g.data2), g.data2(i,:,:) = g.data2(i,:,:)*g.datastd(i);end;'...
    'end;'...
    'set(gcbo,''string'', ''Norm'');set(findobj(''tag'',''ESpacing'',''parent'',gcbf),''string'',num2str(g.oldspacing));' ...
    'else, for i = 1:size(data,1),'...
    'data(i,:,:) = data(i,:,:)/g.datastd(i);'...
    'if ~isempty(g.data2), g.data2(i,:,:) = g.data2(i,:,:)/g.datastd(i);end;'...
    'end;'...
    'set(gcbo,''string'', ''Denorm'');g.oldspacing = g.spacing;set(findobj(''tag'',''ESpacing'',''parent'',gcbf),''string'',''5'');end;' ...
    'g.normed = 1 - g.normed;' ...
    'plot_data(''draws'',0);'...
    'set(hmenu, ''Label'', fastif(g.normed,''Denormalize channels'',''Normalize channels''));' ...
    'set(gcbf,''userdata'',g);set(ax1,''UserData'',data);clear ax1 g data;' ...
    'plot_data(''drawp'',0);' ...
    'disp(''Done.'')'];

% Button for Normalizing data
u(21) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'Position',posbut(21,:), ...
    'Tag','Norm',...
    'string','Norm', 'callback', cb_normalize);

cb_envelope = ['g = get(gcbf,''userdata'');'...
    'hmenu = findobj(gcf, ''Tag'', ''Envelope_menu'');' ...
    'g.envelope = ~g.envelope;' ...
    'set(gcbf,''userdata'',g);'...
    'set(gcbo,''string'',fastif(g.envelope,''Spread'',''Stack''));' ...
    'set(hmenu, ''Label'', fastif(g.envelope,''Spread channels'',''Stack channels''));' ...
    'plot_data(''drawp'',0);clear g;'];

% Button to plot envelope of data
u(22) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'Position',posbut(22,:), ...
    'Tag','Envelope',...
    'string','Stack', 'callback', cb_envelope);


% if isempty(g.command) tmpcom = 'fprintf(''Rejections saved in variable TMPREJ\n'');';
% else
tmpcom = g.command;
% end
acceptcommand = [ 'g = get(gcbf, ''userdata'');' ...
    'TMPREJ = g.winrej;' ...
    'if g.children, delete(g.children); end;' ...
    'delete(gcbf);' ...
    tmpcom ...
    '; clear g;']; % quitting expression

% Reject button
if ~isempty(g.command)
    u(12) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'Position',posbut(12,:), ...
        'Tag','Accept',...
        'string','Reject', 'callback', acceptcommand);
end

u(13) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'Position',posbut(13,:), ...
    'string',fastif(isempty(g.command),'CLOSE', 'CANCEL'), 'callback', ...
    [	'g = get(gcbf, ''userdata'');' ...
    'if g.children, delete(g.children); end;' ...
    'close(gcbf);'] );

if ~isempty(g.events)
    u(17) = uicontrol('Parent',figh, ...
        'Units', 'normalized', ...
        'Position',posbut(17,:), ...
        'string', 'Event types', 'callback', 'plot_data(''drawlegend'', gcbf)');
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up uimenus
% %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Figure Menu
m(7) = uimenu('Parent',figh,'Label','Figure');
m(8) = uimenu('Parent',m(7),'Label','Print');
uimenu('Parent',m(7),'Label','Edit figure', 'Callback', 'plot_data(''noui'');');
uimenu('Parent',m(7),'Label','Accept and close', 'Callback', acceptcommand );
uimenu('Parent',m(7),'Label','Cancel and close', 'Callback','delete(gcbf)')

% Portrait
timestring = ['[OBJ1,FIG1] = gcbo;',...
    'PANT1 = get(OBJ1,''parent'');',...
    'OBJ2 = findobj(''tag'',''orient'',''parent'',PANT1);',...
    'set(OBJ2,''checked'',''off'');',...
    'set(OBJ1,''checked'',''on'');',...
    'set(FIG1,''PaperOrientation'',''portrait'');',...
    'clear OBJ1 FIG1 OBJ2 PANT1;'];

uimenu('Parent',m(8),'Label','Portrait','checked',...
    'on','tag','orient','callback',timestring)

% Landscape
timestring = ['[OBJ1,FIG1] = gcbo;',...
    'PANT1 = get(OBJ1,''parent'');',...
    'OBJ2 = findobj(''tag'',''orient'',''parent'',PANT1);',...
    'set(OBJ2,''checked'',''off'');',...
    'set(OBJ1,''checked'',''on'');',...
    'set(FIG1,''PaperOrientation'',''landscape'');',...
    'clear OBJ1 FIG1 OBJ2 PANT1;'];

uimenu('Parent',m(8),'Label','Landscape','checked',...
    'off','tag','orient','callback',timestring)

% Print command
uimenu('Parent',m(8),'Label','Print','tag','printcommand','callback',...
    ['RESULT = inputdlg2( { ''Command:'' }, ''Print'', 1,  { ''print -r72'' });' ...
    'if size( RESULT,1 ) ~= 0' ...
    '  eval ( RESULT{1} );' ...
    'end;' ...
    'clear RESULT;' ]);

% Display Menu
m(1) = uimenu('Parent',figh,...
    'Label','Display', 'tag', 'displaymenu');

% window grid
m(11) = uimenu('Parent',m(1),'Label','Data select/mark', 'tag', 'displaywin', ...
    'userdata', { 1, [0.8 1 0.8], 0, fastif( g.trialstag(1) == -1, 0, 1)});

uimenu('Parent',m(11),'Label','Hide marks','Callback', ...
    ['g = get(gcbf, ''userdata'');' ...
    'if ~g.winstatus' ...
    '  set(gcbo, ''label'', ''Hide marks'');' ...
    'else' ...
    '  set(gcbo, ''label'', ''Show marks'');' ...
    'end;' ...
    'g.winstatus = ~g.winstatus;' ...
    'set(gcbf, ''userdata'', g);' ...
    'plot_data(''drawb''); clear g;'] )

% plot durations
% if g.ploteventdur && isfield(g.events, 'duration')
%     disp(['Use menu "Display > Hide event duration" to hide colored regions ' ...
%         'representing event duration']);
% end
% if isfield(g.events, 'duration')
%     uimenu('Parent',m(1),'Label',fastif(g.ploteventdur, 'Hide event duration', 'Plot event duration'),'Callback', ...
%         ['g = get(gcbf, ''userdata'');' ...
%         'if ~g.ploteventdur' ...
%         '  set(gcbo, ''label'', ''Hide event duration'');' ...
%         'else' ...
%         '  set(gcbo, ''label'', ''Show event duration'');' ...
%         'end;' ...
%         'g.ploteventdur = ~g.ploteventdur;' ...
%         'set(gcbf, ''userdata'', g);' ...
%         'plot_data(''drawb''); clear g;'] )
% end

% X grid
m(3) = uimenu('Parent',m(1),'Label','Grid');
timestring = ['FIGH = gcbf;',...
    'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
    'if size(get(AXESH,''xgrid''),2) == 2' ... %on
    '  set(AXESH,''xgrid'',''off'');',...
    '  set(gcbo,''label'',''X grid on'');',...
    'else' ...
    '  set(AXESH,''xgrid'',''on'');',...
    '  set(gcbo,''label'',''X grid off'');',...
    'end;' ...
    'clear FIGH AXESH;' ];
uimenu('Parent',m(3),'Label',fastif(strcmp(g.xgrid, 'off'), ...
    'X grid on','X grid off'), 'Callback',timestring)

% Y grid 
timestring = ['FIGH = gcbf;',...
    'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
    'if size(get(AXESH,''ygrid''),2) == 2' ... %on
    '  set(AXESH,''ygrid'',''off'');',...
    '  set(gcbo,''label'',''Y grid on'');',...
    'else' ...
    '  set(AXESH,''ygrid'',''on'');',...
    '  set(gcbo,''label'',''Y grid off'');',...
    'end;' ...
    'clear FIGH AXESH;' ];
uimenu('Parent',m(3),'Label',fastif(strcmp(g.ygrid, 'off'), ...
    'Y grid on','Y grid off'), 'Callback',timestring)

% Grid Style
m(5) = uimenu('Parent',m(3),'Label','Grid Style');
timestring = ['FIGH = gcbf;',...
    'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
    'set(AXESH,''gridlinestyle'',''--'');',...
    'clear FIGH AXESH;'];
uimenu('Parent',m(5),'Label','- -','Callback',timestring)
timestring = ['FIGH = gcbf;',...
    'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
    'set(AXESH,''gridlinestyle'',''-.'');',...
    'clear FIGH AXESH;'];
uimenu('Parent',m(5),'Label','_ .','Callback',timestring)
timestring = ['FIGH = gcbf;',...
    'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
    'set(AXESH,''gridlinestyle'','':'');',...
    'clear FIGH AXESH;'];
uimenu('Parent',m(5),'Label','. .','Callback',timestring)
timestring = ['FIGH = gcbf;',...
    'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
    'set(AXESH,''gridlinestyle'',''-'');',...
    'clear FIGH AXESH;'];
uimenu('Parent',m(5),'Label','__','Callback',timestring)

% % Submean menu %%%%%%%%%%%%%
% g.submean = 'off';
% cb =       ['g = get(gcbf, ''userdata'');' ...
%     'if strcmpi(g.submean, ''on''),' ...
%     '  set(gcbo, ''label'', ''Remove DC offset'');' ...
%     '  g.submean =''off'';' ...
%     'else' ...
%     '  set(gcbo, ''label'', ''Do not remove DC offset'');' ...
%     '  g.submean =''on'';' ...
%     'end;' ...
%     'set(gcbf, ''userdata'', g);' ...
%     'plot_data(''drawp'', 0); clear g;'];
% uimenu('Parent',m(1),'Label',fastif(strcmp(g.submean, 'on'), ...
%     'Do not remove DC offset','Remove DC offset'), 'Callback',cb)

% Scale Eye 
timestring = ['[OBJ1,FIG1] = gcbo;',...
    'plot_data(''scaleeye'',OBJ1,FIG1);',...
    'clear OBJ1 FIG1;'];
m(7) = uimenu('Parent',m(1),'Label','Show scale','Callback',timestring);

% Title
uimenu('Parent',m(1),'Label','Title','Callback','plot_data(''title'')')

% Stack/Spread 
cb =       ['g = get(gcbf, ''userdata'');' ...
    'hbutton = findobj(gcf, ''Tag'', ''Envelope'');' ...  % find button
    'if g.envelope == 0,' ...
    '  set(gcbo, ''label'', ''Spread channels'');' ...
    '  g.envelope = 1;' ...
    '  set(hbutton, ''String'', ''Spread'');' ...
    'else' ...
    '  set(gcbo, ''label'', ''Stack channels'');' ...
    '  g.envelope = 0;' ...
    '  set(hbutton, ''String'', ''Stack'');' ...
    'end;' ...
    'set(gcbf, ''userdata'', g);' ...
    'plot_data(''drawp'', 0); clear g;'];
uimenu('Parent',m(1),'Label',fastif(g.envelope == 0, ...
    'Stack channels','Spread channels'), 'Callback',cb, 'Tag', 'Envelope_menu')

% Normalize/denormalize 
cb_normalize = ['g = get(gcbf,''userdata'');if g.normed, disp(''Denormalizing...''); else, disp(''Normalizing...''); end;'...
    'hbutton = findobj(gcf, ''Tag'', ''Norm'');' ...  % find button
    'ax1 = findobj(''tag'',''eegaxis'',''parent'',gcbf);' ...
    'data = get(ax1,''UserData'');' ...
    'if isempty(g.datastd), g.datastd = std(data(:,1:min(1000,g.frames),[],2)); end;'...
    'if g.normed, '...
    '  for i = 1:size(data,1), '...
    '    data(i,:,:) = data(i,:,:)*g.datastd(i);'...
    '    if ~isempty(g.data2), g.data2(i,:,:) = g.data2(i,:,:)*g.datastd(i);end;'...
    '  end;'...
    '  set(hbutton,''string'', ''Norm'');set(findobj(''tag'',''ESpacing'',''parent'',gcbf),''string'',num2str(g.oldspacing));' ...
    '  set(gcbo, ''label'', ''Normalize channels'');' ...
    'else, for i = 1:size(data,1),'...
    '    data(i,:,:) = data(i,:,:)/g.datastd(i);'...
    '    if ~isempty(g.data2), g.data2(i,:,:) = g.data2(i,:,:)/g.datastd(i);end;'...
    '  end;'...
    '  set(hbutton,''string'', ''Denorm'');'...
    '  set(gcbo, ''label'', ''Denormalize channels'');' ...
    '  g.oldspacing = g.spacing;set(findobj(''tag'',''ESpacing'',''parent'',gcbf),''string'',''5'');end;' ...
    'g.normed = 1 - g.normed;' ...
    'plot_data(''draws'',0);'...
    'set(gcbf,''userdata'',g);set(ax1,''UserData'',data);clear ax1 g data;' ...
    'plot_data(''drawp'',0);' ...
    'disp(''Done.'')'];
uimenu('Parent',m(1),'Label',fastif(g.envelope == 0, ...
    'Normalize channels','Denormalize channels'), 'Callback',cb_normalize, 'Tag', 'Normalize_menu')

% Settings Menu 
m(2) = uimenu('Parent',figh,...
    'Label','Settings');

% Window 
uimenu('Parent',m(2),'Label','Time range to display',...
    'Callback','plot_data(''window'')')

% Electrode window 
uimenu('Parent',m(2),'Label','Number of channels to display',...
    'Callback','plot_data(''winelec'')')

% Electrodes 
m(6) = uimenu('Parent',m(2),'Label','Channel labels');

timestring = ['FIGH = gcbf;',...
    'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
    'YTICK = get(AXESH,''YTick'');',...
    'YTICK = length(YTICK);',...
    'set(AXESH,''YTickLabel'',flipud(char(num2str((1:YTICK-1)''),'' '')));',...
    'clear FIGH AXESH YTICK;'];
uimenu('Parent',m(6),'Label','Show number','Callback',timestring)
showlab = ['g = get(gcbf, ''userdata'');'...
    'ax1 = findobj(''tag'',''eegaxis'',''parent'',gcbf);'...
    'data = get(ax1,''UserData'');'...
    'if ischar(g.eloc_file) || isstruct(g.eloc_file)'...
    'if isstruct(g.eloc_file) && length(g.eloc_file) > size(data,1)'...
    'g.eloc_file(end) = []; end;'...
    'plot_data(''setelect'', g.eloc_file, ax1); end;'];
uimenu('Parent',m(6),'Label','Show label','Callback',showlab)
uimenu('Parent',m(6),'Label','Load .loc(s) file',...
    'Callback','plot_data(''loadelect'');')

% Zooms 
zm = uimenu('Parent',m(2),'Label','Zoom off/on');
% Temporary fix to avoid warning when setting a callback and the  mode is active
% This is failing for us http://undocumentedmatlab.com/blog/enabling-user-callbacks-during-zoom-pan
commandzoom = [ 'wtemp = warning; warning off;set(gcbf, ''WindowButtonDownFcn'', [ ''zoom(gcbf); plot_data(''''zoom'''', gcbf, 1);'' ]);' ...
    'tmpg = get(gcbf, ''userdata'');' ...
    'warning(wtemp);'...
    'clear wtemp tmpg tmpstr; '];

uimenu('Parent',zm,'Label','Zoom on', 'callback', commandzoom);
uimenu('Parent',zm,'Label','Zoom off', 'separator', 'on', 'callback', ...
    ['zoom(gcbf, ''off''); tmpg = get(gcbf, ''userdata'');' ...
    'set(gcbf, ''windowbuttondownfcn'', tmpg.commandselect{1});' ...
    'set(gcbf, ''windowbuttonupfcn'', tmpg.commandselect{3});' ...
    'clear tmpg;' ]);

uimenu('Parent',figh,'Label', 'Help', 'callback', 'pophelp(''plot_data'');');

% Events
zm = uimenu('Parent',m(2),'Label','Events');
complotevent = [ 'tmpg = get(gcbf, ''userdata'');' ...
    'tmpg.plotevent = ''on'';' ...
    'set(gcbf, ''userdata'', tmpg); clear tmpg; plot_data(''drawp'', 0);'];
comnoevent   = [ 'tmpg = get(gcbf, ''userdata'');' ...
    'tmpg.plotevent = ''off'';' ...
    'set(gcbf, ''userdata'', tmpg); clear tmpg; plot_data(''drawp'', 0);'];
comeventmaxstring   = [ 'tmpg = get(gcbf, ''userdata'');' ...
    'tmpg.plotevent = ''on'';' ...
    'set(gcbf, ''userdata'', tmpg); clear tmpg; plot_data(''emaxstring'');']; % JavierLC
comeventleg  = [ 'plot_data(''drawlegend'', gcbf);'];

uimenu('Parent',zm,'Label','Events on'    , 'callback', complotevent, 'enable', fastif(isempty(g.events), 'off', 'on'));
uimenu('Parent',zm,'Label','Events off'   , 'callback', comnoevent  , 'enable', fastif(isempty(g.events), 'off', 'on'));
uimenu('Parent',zm,'Label','Events'' string length'   , 'callback', comeventmaxstring, 'enable', fastif(isempty(g.events), 'off', 'on')); % JavierLC
uimenu('Parent',zm,'Label','Events'' legend', 'callback', comeventleg , 'enable', fastif(isempty(g.events), 'off', 'on'));


% %%%%%%%%%%%%%%%%%
% Set up autoselect
% NOTE: commandselect{2} option has been moved to a
%       subfunction to improve speed
%%%%%%%%%%%%%%%%%%%
g.commandselect{1} = [ 'if strcmp(get(gcbf, ''SelectionType''),''alt''),' g.ctrlselectcommand{1} ...
    'else '                                            g.selectcommand{1} 'end;' ];
g.commandselect{3} = [ 'if strcmp(get(gcbf, ''SelectionType''),''alt''),' g.ctrlselectcommand{3} ...
    'else '                                            g.selectcommand{3} 'end;' ];

set(figh, 'windowbuttondownfcn',   g.commandselect{1});
set(figh, 'windowbuttonmotionfcn', {@defmotion,figh,ax0,ax1,u(10),u(11),u(9)});
set(figh, 'windowbuttonupfcn',     g.commandselect{3});
set(figh, 'WindowKeyPressFcn',     @plot_data_readkey);
set(figh, 'interruptible', 'off');
set(figh, 'busyaction', 'cancel');

% prepare event array if any
if ~isempty(g.events)
    if ~isfield(g.events, 'type') || ~isfield(g.events, 'latency'), g.events = []; end
end

if ~isempty(g.events)
    if ischar(g.events(1).type)
        [g.eventtypes, tmpind, indexcolor] = unique_bc({g.events.type}); % indexcolor countinas the event type
    else [g.eventtypes, tmpind, indexcolor] = unique_bc([ g.events.type ]);
    end
    g.eventcolors     = { 'r', [0 0.8 0], 'm', 'c', 'k', 'b', [0 0.8 0] };
    g.eventstyle      = { '-' '-' '-'  '-'  '-' '-' '-' '--' '--' '--'  '--' '--' '--' '--'};
    g.eventwidths     = [ 2.5 1 ];
    g.eventtypecolors = g.eventcolors(mod((1:length(g.eventtypes))-1 ,length(g.eventcolors))+1);
    g.eventcolors     = g.eventcolors(mod(indexcolor-1               ,length(g.eventcolors))+1);
    g.eventtypestyle  = g.eventstyle (mod((1:length(g.eventtypes))-1 ,length(g.eventstyle))+1);
    g.eventstyle      = g.eventstyle (mod(indexcolor-1               ,length(g.eventstyle))+1);

    % for width, only boundary events have width 2 (for the line)
    indexwidth = ones(1,length(g.eventtypes))*2;
    if iscell(g.eventtypes)
        for index = 1:length(g.eventtypes)
            if strcmpi(g.eventtypes{index}, 'boundary'), indexwidth(index) = 1; end
        end
    else
        eeglab_options;
        if option_boundary99
            indexwidth = g.eventtypes == -99;
        end
    end
    g.eventtypewidths = g.eventwidths (mod(indexwidth(1:length(g.eventtypes))-1 ,length(g.eventwidths))+1);
    g.eventwidths     = g.eventwidths (mod(indexwidth(indexcolor)-1               ,length(g.eventwidths))+1);

    % latency and duration of events
    g.eventlatencies  = [ g.events.latency ]+1;
    if isfield(g.events, 'duration')
        durations = { g.events.duration };
        durations(cellfun(@isempty, durations)) = { NaN };
        g.eventlatencyend   = g.eventlatencies + [durations{:}]+1;
    else g.eventlatencyend   = [];
    end
    g.plotevent       = 'on';
end
if isempty(g.events)
    g.plotevent      = 'off';
end

set(figh, 'userdata', g);

% %%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot EEG Data
% %%%%%%%%%%%%%%%%%%%%%%%%%%
axes(ax1)
hold on

% %%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Spacing I
% %%%%%%%%%%%%%%%%%%%%%%%%%%
YLim = get(ax1,'Ylim');
A = DEFAULT_AXES_POSITION;
axes('Position',[A(1)+A(3) A(2) 1-A(1)-A(3) A(4)],'Visible','off','Ylim',YLim,'tag','eyeaxes')
axis manual
if strcmp(SPACING_EYE,'on') 
    set(m(7),'checked','on')
else 
    set(m(7),'checked','off');
end
plot_data2('scaleeye', [], gcf);
if strcmpi(g.scale, 'off')
    plot_data2('scaleeye', 'off', gcf);
end
plot_data2('drawp', 0);
if g.dispchans ~= g.chans
    plot_data2('zoom', gcf);
end
plot_data2('scaleeye', [], gcf);
h = findobj(gcf, 'style', 'pushbutton');
set(h, 'backgroundcolor', BUTTON_COLOR);
h = findobj(gcf, 'tag', 'eegslider');
set(h, 'backgroundcolor', BUTTON_COLOR);
set(figh, 'visible', 'on');
if strcmpi(g.noui, 'on')
    plot_data2('noui');
end

%% SUBFUNCTIONS

% Shows the value and electrode at mouse position
function defmotion(varargin)
fig = varargin{3};
ax1 = varargin{5};
tmppos = get(ax1, 'currentpoint');

if  all([tmppos(1,1) >= 0,tmppos(1,2)>= 0])
    g = get(fig,'UserData');
    if g.trialstag ~= -1
        lowlim = round(g.time*g.trialstag+1);
    else, lowlim = round(g.time*g.srate+1);
    end
    if g.incallback
        g.winrej = [g.winrej(1:end-1,:)' [g.winrej(end,1) tmppos(1)+lowlim g.winrej(end,3:end)]']';
        set(fig,'UserData', g);
        if exist('OCTAVE_VERSION', 'builtin') == 0
            plot_data2('drawb');
        end
    else
        hh = varargin{6}; % h = findobj('tag','Etime','parent',fig);
        if g.trialstag ~= -1
            tmpval = mod(tmppos(1)+lowlim-1,g.trialstag)/g.trialstag*(g.limits(2)-g.limits(1)+1000/g.srate) + g.limits(1);
%             if g.isfreq, tmpval = tmpval/1000 + g.freqs(1); end
            set(hh, 'string', num2str(tmpval));
        else
            tmpval = (tmppos(1)+lowlim-1)/g.srate;
%             if g.isfreq, tmpval = tmpval+g.freqs(1); end
            set(hh, 'string', num2str(tmpval)); % put g.time in the box
        end
        ax1 = varargin{5};% ax1 = findobj('tag','eegaxis','parent',fig);
        tmppos = get(ax1, 'currentpoint');
        tmpelec = round(tmppos(1,2) / g.spacing);
        tmpelec = min(max(double(tmpelec), 1),g.chans);
        labls = get(ax1, 'YtickLabel');
        hh = varargin{8}; % hh = findobj('tag','Eelec','parent',fig);  % put electrode in the box
        if ~g.envelope
            set(hh, 'string', labls(tmpelec+1,:));
        else
            set(hh, 'string', ' ');
        end
        hh = varargin{7}; % hh = findobj('tag','Evalue','parent',fig);
        if ~g.envelope
            eegplotdata = get(ax1, 'userdata');
            set(hh, 'string', num2str(eegplotdata(g.chans+1-tmpelec, min(g.frames,max(1,double(round(tmppos(1)+lowlim)))))));  % put value in the box
        else
            set(hh,'string',' ');
        end
    end
end

% % function not supported under Mac
% function [reshist, allbin] = myhistc(vals, intervals)
% 
% reshist = zeros(1, length(intervals));
% allbin = zeros(1, length(vals));
% 
% for index=1:length(vals)
%     minvals = vals(index)-intervals;
%     bintmp  = find(minvals >= 0);
%     [mintmp, indextmp] = min(minvals(bintmp));
%     bintmp = bintmp(indextmp);
% 
%     allbin(index) = bintmp;
%     reshist(bintmp) = reshist(bintmp)+1;
% end

