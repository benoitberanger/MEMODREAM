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
        'HandleVisibility', 'off'                    ,... % close all does not close the figure
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
    
    
    % Connecion
    t_con.x = e_adr.x + e_adr.w + 0.05;
    t_con.w = e_adr.w;
    t_con.y = e_adr.y;
    t_con.h = e_adr.h;
    t_con.tag = 'toggle_Connection';
    handles.(t_con.tag) = uicontrol(figHandle,...
        'Style','toggle',...
        'Tag',t_con.tag,...
        'Units', 'Normalized',...
        'Position',[t_con.x t_con.y t_con.w t_con.h],...
        'BackgroundColor',handles.buttonBGcolor,...
        'String','Connect',...
        'Tooltip','Switch On/Off TCPIP connection',...
        'Callback',@toggle_Connection_Callback);
    
    
    % Stream
    t_stream.x = t_con.x + t_con.w + 0.05;
    t_stream.w = e_adr.w;
    t_stream.y = e_adr.y;
    t_stream.h = e_adr.h;
    t_stream.tag = 'toggle_Stream';
    handles.(t_stream.tag) = uicontrol(figHandle,...
        'Style','toggle',...
        'Tag',t_stream.tag,...
        'Units', 'Normalized',...
        'Position',[t_stream.x t_stream.y t_stream.w t_stream.h],...
        'BackgroundColor',handles.buttonBGcolor,...
        'String','Stream',...
        'Tooltip','Switch On/Off the data streaming',...
        'Callback',@toggle_Stream_Callback,....
        'Visible','Off');
    
    
    %% End of opening
    
    % IMPORTANT
    guidata(figHandle,handles)
    % After creating the figure, dont forget the line
    % guidata(figHandle,handles) . It allows smart retrive like
    % handles=guidata(hObject)
    
    % assignin('base','handles',handles)
    % disp(handles)
    
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
function edit_Adress_Callback(hObject, eventdata) %#ok<*INUSD>

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
function toggle_Connection_Callback(hObject, eventdata)

handles = guidata(hObject);

switch get(hObject,'Value')
    
    case 1
        
        recorderip = get(handles.edit_Adress,'String');
        
        fprintf('Trying to connect to : %s ... ',recorderip)
        
        % Establish connection to BrainVision Recorder Software 32Bit RDA-Port
        % (use 51234 to connect with 16Bit Port)
        handles.con = pnet('tcpconnect', recorderip, 51244);
        
        % Check established connection and display a message
        status = pnet(handles.con,'status');
        if status > 0
            fprintf('connection established \n');
        elseif status == -1
            set(hObject,'Value',0)
            error('connection FAILED')
        end
        
        set(hObject,'BackgroundColor',[0.5 0.5 1])
        set(handles.toggle_Stream,'Visible','On')
        
    case 0
        
        % Switch off streaming if needed
        set(handles.toggle_Stream,'Value',0);
        toggle_Stream_Callback(handles.toggle_Stream, eventdata)
        
        % Close all open socket connections
        pnet('closeall');
        
        % Display a message
        fprintf('connection closed \n\n\n');
        
        set(hObject,'BackgroundColor',handles.buttonBGcolor)
        set(handles.toggle_Stream,'Visible','Off')
        
end

guidata(hObject, handles);

end % function


% *************************************************************************
function toggle_Stream_Callback(hObject, eventdata)

handles = guidata(hObject);

switch get(hObject,'Value')
    
    case 1
        
        % Clear axes and ADC data
        cla(handles.axes_Oscillo)
        if isfield( handles , 'Scope' )
            handles = rmfield( handles ,'Scope' );
        end
        
        handles.RefreshPeriod = 0.020; % secondes
        
        handles.TimerHandle = timer(...
            'StartDelay',0 ,...
            'Period', handles.RefreshPeriod ,...
            'TimerFcn', {@DoStream,handles.(mfilename)} ,...
            'BusyMode', 'drop',...  %'queue'
            'TasksToExecute', Inf,...
            'ExecutionMode', 'fixedRate');
        
        guidata(hObject, handles);
        start(handles.TimerHandle)
        
        set(hObject,'BackgroundColor',[0.5 0.5 1])
        fprintf('Streaming ON ... \n')
        
    case 0
        
        try
            stop( handles.TimerHandle );
            delete( handles.TimerHandle );
        catch err %#ok<*NASGU>
            warning('GUI:Timer','Cannot delete the timer object. delete(timerfind) can clean all timers in the memory')
        end
        
        fprintf('Streaming off \n')
        
        
        set(hObject,'BackgroundColor',handles.buttonBGcolor)
        
        
end

guidata(hObject, handles);

end % function


% *************************************************************************
function DoStream(hObject,eventdata,hFigure) %#ok<*INUSL>

global props
global lastBlock
global data1s

try
    
    handles = guidata(hFigure);
    
    header_size = 24;
    
    % check for existing data in socket buffer
    tryheader = pnet(handles.con, 'read', header_size, 'byte', 'network', 'view', 'noblock');
    
    while ~isempty(tryheader)
        
        % Read header of RDA message
        hdr = RDA.ReadHeader(handles.con);
        
        % Perform some action depending of the type of the data package
        switch hdr.type
            case 1       % Start, Setup information like EEG properties
                disp('Start');
                % Read and display EEG properties
                props = RDA.ReadStartMessage(handles.con, hdr);
                disp(props);
                
                % Reset block counter to check overflows
                lastBlock = -1;
                
                % Fill data buffer with zeros and plot first time to
                % get handles
                data1s = nan(props.channelCount,1000000 / props.samplingInterval);
                
            case 4       % 32Bit Data block
                % Read data and markers from message
                [datahdr, data, markers] = RDA.ReadDataMessage(handles.con, hdr, props);
                
                % check tcpip buffer overflow
                if lastBlock ~= -1 && datahdr.block > lastBlock + 1
                    disp(['******* Overflow with ' int2str(datahdr.block - lastBlock) ' blocks ******']);
                end
                lastBlock = datahdr.block;
                
                %                 % print marker info to MATLAB console
                %                 if datahdr.markerCount > 0
                %                     for m = 1:datahdr.markerCount
                %                         disp(markers(m));
                %                     end
                %                 end
                
                % Process EEG data,
                % in this case extract last recorded second,
                
                EEGData = reshape(data, props.channelCount, length(data) / props.channelCount);
                
                for k = 1:props.channelCount
                    
                    EEGData (k,:) = EEGData (k,:) * props.resolutions (k);
                    
                end
                
                data1s = [data1s EEGData];
                dims = size(data1s);
                if dims(2) > 1000000 / props.samplingInterval
                    data1s = data1s(:, dims(2) - 1000000 / props.samplingInterval : dims(2));
                end
                
                time = (1:length(data1s(1,:)))*props.samplingInterval/1000000;
                plot(handles.axes_Oscillo,time,data1s(1,:),'blue',time,data1s(2,:),'red')
                xlim(handles.axes_Oscillo,[0 1])
                
            case 3       % Stop message
                disp('Stop');
                data = pnet(handles.con, 'read', hdr.size - header_size);
                finish = true;
                
            otherwise    % ignore all unknown types, but read the package from buffer
                data = pnet(handles.con, 'read', hdr.size - header_size);
        end
        
        tryheader = pnet(handles.con, 'read', header_size, 'byte', 'network', 'view', 'noblock');
    end
    
catch err
    
    err.getReport
    
end

end % function
