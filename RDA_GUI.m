function varargout = RDA_GUI
% Run this function start a GUI that will handle the whole stimulation
% process and parameters

% global handles

%% Open a singleton figure

% Is the GUI already open ?
figPtr = findall(0,'Tag',mfilename);

if isempty(figPtr) % Create the figure
    
    clc
    rng('default')
    rng('shuffle')
    
    % Create a figure
    figHandle = figure( ...
        'HandleVisibility', 'off',... % close all does not close the figure
        'MenuBar'         , 'none'                   , ...
        'Toolbar'         , 'none'                   , ...
        'Name'            , mfilename                , ...
        'NumberTitle'     , 'off'                    , ...
        'Units'           , 'Normalized'             , ...
        'Position'        , [0.01, 0.01, 0.98, 0.95] , ...
        'Tag'             , mfilename                );
    
    % Create GUI handles : pointers to access the graphic objects
    handles = guihandles(figHandle);
    
    handles.figureBGcolor = [0.9 0.9 0.9]; set(figHandle,'Color',handles.figureBGcolor);
    handles.buttonBGcolor = handles.figureBGcolor - 0.1;
    handles.editBGcolor   = [1.0 1.0 1.0];
    
    
    %% Graphic objects
    
    % Graph
    a_osci.x = 0.05;
    a_osci.w = 0.90;
    a_osci.y = 0.05 ;
    a_osci.h = 0.80;
    a_osci.tag = 'axes_Oscillo';
    handles.(a_osci.tag) = axes('Parent',figHandle,...
        'Tag',a_osci.tag,...
        'Units','Normalized',...
        'Position',[ a_osci.x a_osci.y a_osci.w a_osci.h ]);
    
    % IP adress
    e_adr.x = a_osci.x;
    e_adr.w = 0.20;
    e_adr.y = a_osci.y + a_osci.h + a_osci.y/2;
    e_adr.h = (1 - e_adr.y)*0.80;
    e_adr.tag = 'edit_Adress';
    handles.(e_adr.tag) = uicontrol(figHandle,...
        'Style','edit',...
        'Tag',e_adr.tag,...
        'Units', 'Normalized',...
        'Position',[e_adr.x e_adr.y e_adr.w e_adr.h],...
        'BackgroundColor',handles.editBGcolor,...
        'String','134.157.205.98',...
        'Tooltip','IP adress',...
        'Callback',@edit_Adress_Callback);
    
    % On/Off
    t_onoff.x = e_adr.x + e_adr.w + 0.05;
    t_onoff.w = e_adr.w;
    t_onoff.y = e_adr.y;
    t_onoff.h = e_adr.h;
    t_onoff.tag = 'toggle_OnOff';
    handles.(t_onoff.tag) = uicontrol(figHandle,...
        'Style','toggle',...
        'Tag',t_onoff.tag,...
        'Units', 'Normalized',...
        'Position',[t_onoff.x t_onoff.y t_onoff.w t_onoff.h],...
        'BackgroundColor',handles.buttonBGcolor,...
        'String','Stream Off',...
        'Tooltip','Switch On/Off the stream',...
        'Callback',@toggle_OnOff_Callback);
    
    
    %% End of opening
    
    % IMPORTANT
    guidata(figHandle,handles)
    % After creating the figure, dont forget the line
    % guidata(figHandle,handles) . It allows smart retrive like
    % handles=guidata(hObject)
    
    assignin('base','handles',handles)
    disp(handles)
    
    figPtr = figHandle;
    
    
    %% Default values
    
    
else % Figure exists so brings it to the focus
    
    figure(figPtr);
    
    close(figPtr);
    RDA_GUI;
    
end

if nargout > 0
    
    varargout{1} = guidata(figPtr);
    
end


end % function


%% GUI Functions

% *************************************************************************
function toggle_OnOff_Callback(hObject, eventdata)

handles = guidata(hObject);

switch get(hObject,'Value')
    
    case 1
        
        recorderip = get(handles.edit_Adress,'String');
        
        fprintf('Trying to connect to : %s ... \n',recorderip)
        
        % Establish connection to BrainVision Recorder Software 32Bit RDA-Port
        % (use 51234 to connect with 16Bit Port)
        con = pnet('tcpconnect', recorderip, 51244);
        
        % Check established connection and display a message
        status = pnet(con,'status');
        if status > 0
            disp('connection established');
        elseif status == -1
            set(hObject,'Value',0)
            error('connection FAILED')
        end
        
        set(hObject,'String','Steam ON')
        set(hObject,'BackgroundColor',[0.5 0.5 1])
        
    case 0
        
        % Close all open socket connections
        pnet('closeall');
        
        % Display a message
        disp('connection closed');
        
        set(hObject,'String','Steam off')
        set(hObject,'BackgroundColor',handles.buttonBGcolor)
        
end

end % function


% *************************************************************************
function edit_Adress_Callback(hObject, eventdata)

errormsg = 'invalid IP adress : x.x.x.x with x in {0;...;255}';

adress = get(hObject,'String');

paternIP = '^([0-9]+\.){3}[0-9]+$';
status = regexp(adress,paternIP,'once');
if isempty(status)
    set(hObject,'String','134.157.205.98')
    error(errormsg)
end

ip = sscanf(adress,'%d.%d.%d.%d');
if any(ip > 255)
    set(hObject,'String','134.157.205.98')
    error(errormsg)
end

end % function

% *************************************************************************


