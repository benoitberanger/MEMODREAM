function MEMODREAM_main(hObject, ~)

if nargin == 0
    
    MEMODREAM_GUI;
    
    %     fprintf('\n')
    %     fprintf('Use %s to start the GUI.','MEMODREAM_GUI.m');
    %     fprintf('\n')
    
    return
    
end

handles = guidata(hObject); % retrieve GUI data

clc
sca

% Initialize the main structure
S               = struct; % S is the main structure, containing everything usefull, and used everywhere
S.TimeStamp     = datestr(now, 'yyyy-mm-dd HH:MM'); % readable
S.TimeStampFile = datestr(now, 30); % to sort automatically by time of creation


%% Task selection

switch get(hObject,'Tag')
    
    case 'pushbutton_EyelinkCalibration'
        Task = 'EyelinkCalibration';
        
    case 'pushbutton_Learning5432'
        Task = 'Learning5432';
        
    case 'pushbutton_DualTask_Complex'
        Task = 'DualTask_Complex';
        
    case 'pushbutton_DualTask_Simple'
        Task = 'DualTask_Simple';
        
    otherwise
        error('MEMODREAM:TaskSelection','Error in Task selection')
end

S.Task = Task;


%% Environement selection

switch get(get(handles.uipanel_Environement,'SelectedObject'),'Tag')
    case 'radiobutton_MRI'
        Environement = 'MRI';
    case 'radiobutton_Training'
        Environement = 'Training';
    otherwise
        warning('MEMODREAM:ModeSelection','Error in Environement selection')
end

S.Environement = Environement;


%% Save mode selection

switch get(get(handles.uipanel_SaveMode,'SelectedObject'),'Tag')
    case 'radiobutton_SaveData'
        SaveMode = 'SaveData';
    case 'radiobutton_NoSave'
        SaveMode = 'NoSave';
    otherwise
        warning('MEMODREAM:SaveSelection','Error in SaveMode selection')
end

S.SaveMode = SaveMode;


%% Mode selection

switch get(get(handles.uipanel_OperationMode,'SelectedObject'),'Tag')
    case 'radiobutton_Acquisition'
        OperationMode = 'Acquisition';
    case 'radiobutton_FastDebug'
        OperationMode = 'FastDebug';
    case 'radiobutton_RealisticDebug'
        OperationMode = 'RealisticDebug';
    otherwise
        warning('MEMODREAM:ModeSelection','Error in Mode selection')
end

S.OperationMode = OperationMode;


%% Record video ?
% Disabled in the GUI for the moment

% switch get(get(handles.uipanel_RecordVideo,'SelectedObject'),'Tag')
%     case 'radiobutton_RecordOn'
%         RecordVideo          = 'On';
%         VideoName            = [ get(handles.edit_RecordName,'String') '.mov'];
%         S.VideoName = VideoName;
%     case 'radiobutton_RecordOff'
RecordVideo          = 'Off';
%     otherwise
%         warning('MEMODREAM:RecordVideo','Error in Record Video')
% end

S.RecordVideo = RecordVideo;


%% Subject ID & Run number

SubjectID = get(handles.edit_SubjectID,'String');

if isempty(SubjectID)
    error('MEMODREAM:SubjectIDLength','\n SubjectID is required \n')
end

% Prepare path
DataPath = [fileparts(pwd) filesep 'data' filesep SubjectID filesep];
DataPathNoRun = sprintf('%s_%s_%s_', SubjectID, Task, Environement);

% Fetch content of the directory
dirContent = dir(DataPath);

% Is there file of the previous run ?
previousRun = nan(length(dirContent),1);
for f = 1 : length(dirContent)
    split = regexp(dirContent(f).name,DataPathNoRun,'split');
    if length(split) == 2 && str2double(split{2}(1)) % yes there is a file
        previousRun(f) = str2double(split{2}(1)); % save the previous run numbers
    else % no file found
        previousRun(f) = 0; % affect zero
    end
end

LastRunNumber = max(previousRun);
% If no previous run, LastRunNumber is 0
if isempty(LastRunNumber)
    LastRunNumber = 0;
end
RunNumber = num2str(LastRunNumber + 1);

DataFile = sprintf('%s%s_%s_%s_%s_%s', DataPath, S.TimeStampFile, SubjectID, Task, Environement, RunNumber );

S.SubjectID = SubjectID;
S.RunNumber = RunNumber;
S.DataPath  = DataPath;
S.DataFile  = DataFile;


%% Controls for SubjectID depending on the Mode selected

switch OperationMode
    
    case 'Acquisition'
        
        % Empty subject ID
        if isempty(SubjectID)
            error('MEMODREAM:MissingSubjectID','\n For acquisition, SubjectID is required \n')
        end
        
        % Acquisition => save data
        if ~get(handles.radiobutton_SaveData,'Value')
            warning('MEMODREAM:DataShouldBeSaved','\n\n\n In acquisition mode, data should be saved \n\n\n')
        end
        
end


%% Parallel port ?

switch get( handles.checkbox_ParPort , 'Value' )
    
    case 1
        ParPort = 'On';
        
    case 0
        ParPort = 'Off';
end

handles.ParPort    = ParPort;
S.ParPort = ParPort;


%% Check if Eyelink toolbox is available

switch get(get(handles.uipanel_EyelinkMode,'SelectedObject'),'Tag')
    
    case 'radiobutton_EyelinkOff'
        
        EyelinkMode = 'Off';
        
    case 'radiobutton_EyelinkOn'
        
        EyelinkMode = 'On';
        
        % 'Eyelink.m' exists ?
        status = which('Eyelink.m');
        if isempty(status)
            error('MEMODREAM:EyelinkToolbox','no ''Eyelink.m'' detected in the path')
        end
        
        % Save mode ?
        if strcmp(S.SaveMode,'NoSave')
            error('MEMODREAM:SaveModeForEyelink',' \n ---> Save mode should be turned on when using Eyelink <--- \n ')
        end
        
        % Eyelink connected ?
        Eyelink.IsConnected
        
        % File name for the eyelink : 8 char maximum
        switch Task
            case 'EyelinkCalibration'
                task = 'EC';
            case 'Learning5432'
                task = 'LE';
            case 'DualTask_Complex'
                task = 'D1';
            case 'DualTask_Simple'
                task = 'D2';
            otherwise
                error('MEMODREAM:Task','Task ?')
        end
        EyelinkFile = [ SubjectID task sprintf('%.2d',str2double(RunNumber)) ];
        
        S.EyelinkFile = EyelinkFile;
        
    otherwise
        
        warning('MEMODREAM:EyelinkMode','Error in Eyelink mode')
        
end

S.EyelinkMode = EyelinkMode;


%% Security : NEVER overwrite a file
% If erasing a file is needed, we need to do it manually

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if exist([DataFile '.mat'], 'file')
        error('MATLAB:FileAlreadyExists',' \n ---> \n The file %s.mat already exists .  <--- \n \n',DataFile);
    end
    
end


%% Get stimulation parameters

S.Parameters = GetParameters( S );

% Screen mode selection
AvalableDisplays = get(handles.listbox_Screens,'String');
SelectedDisplay = get(handles.listbox_Screens,'Value');
S.Parameters.Video.ScreenMode = str2double( AvalableDisplays(SelectedDisplay) );


%% Windowed screen ?

switch get(handles.checkbox_WindowedScreen,'Value')
    
    case 1
        WindowedMode = 'On';
    case 0
        WindowedMode = 'Off';
    otherwise
        warning('MEMODREAM:WindowedScreen','Error in WindowedScreen')
        
end

S.WindowedMode = WindowedMode;


%% Open PTB window & sound

S.PTB = StartPTB( S );


%% Task run

EchoStart(Task)

switch Task
    
    case 'EyelinkCalibration'
        Eyelink.Calibration( S.PTB.wPtr );
        TaskData.ER.Data = {};
        TaskData.IsEyelinkRreadyToRecord = 1;
        
    case 'Learning5432'
        TaskData = Learning5432.Task( S );
        
    case 'DualTask_Complex'
        TaskData = DualTask.Task( S );
        
    case 'DualTask_Simple'
        TaskData = DualTask.Task( S );
        
    otherwise
        error('MEMODREAM:Task','Task ?')
end

EchoStop(Task)

S.TaskData = TaskData;


%% Save files on the fly : just a security in case of crash of the end the script

save([fileparts(pwd) filesep 'data' filesep 'LastDataStruct'],'S');


%% Close PTB

sca;
Priority( 0 );


%% SPM data organization

[ names , onsets , durations ] = SPMnod( S );


%% Saving data strucure

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if ~exist(DataPath, 'dir')
        mkdir(DataPath);
    end
    
    save(DataFile, 'S', 'names', 'onsets', 'durations');
    save([DataFile '_SPM'], 'names', 'onsets', 'durations');
    
    % BrainVoyager data organization
    % spm2bv( names , onsets , durations , S.DataFile )
    
end


%% Send S and SPM nod to workspace

assignin('base', 'S', S);
assignin('base', 'names', names);
assignin('base', 'onsets', onsets);
assignin('base', 'durations', durations);


%% End recording of Eyelink

% Eyelink mode 'On' ?
if strcmp(S.EyelinkMode,'On')
    
    % Stop recording and retrieve the file
    Eyelink.StopRecording( S.EyelinkFile , S.DataPath )
    
    if ~strcmp(S.Task,'EyelinkCalibration')
        
        % Rename the file
        movefile([S.DataPath filesep EyelinkFile '.edf'], [S.DataFile '.edf'])
        
    end
    
end


%% Plot a summpup of everything that happened

% Do a normal plotStim
plotStim(S.TaskData.EP,S.TaskData.ER,S.TaskData.KL)

% Plot the audio recordings
switch Task
    
    case {'DualTask_Complex','DualTask_Simple'}
        
        fullAudioSamples = [];
        for evt = 1:length(S.TaskData.ER.Data)
            fullAudioSamples = [fullAudioSamples S.TaskData.ER.Data{evt,5}]; %#ok<AGROW>
        end
        fullAudioSamples = fullAudioSamples/max(abs(fullAudioSamples)) + 0.5; % normalize
        timeAudioSamples = (1:1:(length(fullAudioSamples)))/S.Parameters.Audio.SamplingRate;
        
        plot(timeAudioSamples,fullAudioSamples);
        
end


% % Do a normal plotStim
% plotStim(S.TaskData.EP,S.TaskData.ER,S.TaskData.KL)
% 
% % Copy plotStim figure into another subplot, then close the original
% stim_fig = gcf;
% figure; % new figure
% stim_ax = subplot(2,1,1);
% copyobj(allchild(get(stim_fig,'CurrentAxes')), stim_ax)
% close(stim_fig);
% ScaleAxisLimits(stim_ax)
% 
% 
% % Plot the audio recordings
% specific_ax = subplot(2,1,2);
% switch Task
%     
%     case {'DualTask_Complex','DualTask_Simple'}
%         
%         fullAudioSamples = [];
%         for evt = 1:length(S.TaskData.ER.Data)
%             fullAudioSamples = [fullAudioSamples S.TaskData.ER.Data{evt,5}]; %#ok<AGROW>
%         end
%         timeAudioSamples = (1:1:(length(fullAudioSamples)))/S.Parameters.Audio.SamplingRate;
%         
%         plot(specific_ax,...
%             timeAudioSamples,fullAudioSamples);
%         
% end
% 
% linkaxes([stim_ax specific_ax],'x')


%% Ready for another run

set(handles.text_LastFileNameAnnouncer,'Visible','on')
set(handles.text_LastFileName,'Visible','on')
set(handles.text_LastFileName,'String',DataFile(length(DataPath)+1:end))

printResults(S.TaskData.ER)

WaitSecs(0.100);
pause(0.100);
fprintf('\n')
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n')
fprintf('  Ready for another session   \n')
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n')


end % function
