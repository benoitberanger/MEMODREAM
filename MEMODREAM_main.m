function MEMODREAM_main(hObject, ~)
% MEMODREAM_main is the main program, calling the different tasks and
% routines, accoding to the paramterts defined in the GUI


%% GUI : open a new one or retrive data from the current one

if nargin == 0
    
    MEMODREAM_GUI;
    
    return
    
end

handles = guidata(hObject); % retrieve GUI data


%% Clean the environment

clc
sca
rng('default')
rng('shuffle')


%% Initialize the main structure

global S
S               = struct; % S is the main structure, containing everything usefull, and used everywhere
S.TimeStamp     = datestr(now, 'yyyy-mm-dd HH:MM'); % readable
S.TimeStampFile = datestr(now, 30                ); % to sort automatically by time of creation


%% Task selection

switch get(hObject,'Tag')
    
    case 'pushbutton_Familiarization'
        Task = 'Familiarization';
        TaskNameFile = Task;
        
    case 'pushbutton_Training'
        Task = 'Training';
        TaskNameFile = Task;
        
    case 'pushbutton_SpeedTest'
        Task = 'SpeedTest';
        TaskNameFile = Task;
        
    case 'pushbutton_DualTask_Complex'
        Task = 'DualTask_Complex';
        TaskNameFile = 'DT_Cplexe';
        
    case 'pushbutton_DualTask_Simple'
        Task = 'DualTask_Simple';
        TaskNameFile = 'DT_Simple';
        
    case 'pushbutton_DreamDebrief'
        Task = 'DreamDebrief';
        TaskNameFile = Task;
        
    otherwise
        error('MEMODREAM:TaskSelection','Error in Task selection')
end

S.Task = Task;


%% Environement selection

switch get(get(handles.uipanel_Environement,'SelectedObject'),'Tag')
    case 'radiobutton_MRI'
        Environement = 'MRI';
    case 'radiobutton_Practice'
        Environement = 'Practice';
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


%% Name modulation selection

NameModulation = get(get(handles.uipanel_NameModulation,'SelectedObject'),'Tag');
NameModulation = NameModulation(13:end); % remove 'radiobutton_'
S.NameModulation = NameModulation;


%% Session name

SessionNumber = get(get(handles.uipanel_SessionNumber,'SelectedObject'),'Tag');
SessionNumber = SessionNumber(14:end); % remove 'radiobutton_s'
S.SessionNumber = SessionNumber;


%% ComplexSequence

ComplexSequence = get(handles.edit_Sequence,'String');
if isempty(ComplexSequence)
    error('ComplexSequence is empty')
end
S.ComplexSequence = ComplexSequence;


%% Subject ID & Run number

SubjectID = get(handles.edit_SubjectID,'String');

if isempty(SubjectID)
    error('MEMODREAM:SubjectIDLength','\n SubjectID is required \n')
end

% Prepare path
DataPath = [fileparts(pwd) filesep 'data' filesep SubjectID filesep];

DataFile = sprintf('%s%s_%s_%s_%s_%s_%s', DataPath, S.TimeStampFile, SubjectID, Environement, TaskNameFile, NameModulation, SessionNumber );
if isempty(SessionNumber)
    DataFile(end) = []; % remove the last '_'
end

S.SubjectID = SubjectID;
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

S.ParPort         = ParPort;
S.ParPortMessages = Common.PrepareParPort; % wrapper



%% Left or right handed ?

switch get(get(handles.uipanel_ParallelPortLeftRight,'SelectedObject'),'Tag')
    case 'radiobutton_LeftButtons'
        Side = 'Left';
    case 'radiobutton_RightButtons'
        Side = 'Right';
    otherwise
        warning('MEMODREAM:LeftRight','Error in LeftRight')
end

S.Side = Side;


%% Security : NEVER overwrite a file
% If erasing a file is needed, we need to do it manually

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if exist([DataFile '.mat'], 'file')
        error('MATLAB:FileAlreadyExists',' \n ---> \n The file %s.mat already exists .  <--- \n \n',DataFile);
    end
    
end


%% Get stimulation parameters

S.Parameters = GetParameters;


%% Open PTB window & sound

S.PTB = StartPTB;


%% Task run

EchoStart(Task)

switch Task
    
    case 'Familiarization'
        TaskData = Familiarization.Task;
        
    case 'Training'
        TaskData = SpeedTest.Task;
        
    case 'SpeedTest'
        TaskData = SpeedTest.Task;
        
    case 'DualTask_Complex'
        TaskData = DualTask.Task;
        
    case 'DualTask_Simple'
        TaskData = DualTask.Task;
        
    case 'DreamDebrief'
        TaskData = DreamDebrief.Task;
        
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

[ names , onsets , durations ] = SPMnod;


%% Saving data strucure

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if ~exist(DataPath, 'dir')
        mkdir(DataPath);
    end
    
    save(DataFile, 'S', 'names', 'onsets', 'durations');
    save([DataFile '_SPM'], 'names', 'onsets', 'durations');
    
end


%% Send S and SPM nod to workspace

assignin('base', 'S', S);
assignin('base', 'names', names);
assignin('base', 'onsets', onsets);
assignin('base', 'durations', durations);


%% Plot a summpup of everything that happened

% Do a normal plotStim
plotStim(S.TaskData.EP,S.TaskData.ER,S.TaskData.KL)

% Plot the audio recordings
switch Task
    
    case {'DualTask_Complex','DualTask_Simple'}
        
        fullAudioSamples = [];
        for evt = 1:size(S.TaskData.ER.Data,1)
            fullAudioSamples = [fullAudioSamples S.TaskData.ER.Data{evt,5}]; %#ok<AGROW>
        end
        fullAudioSamples = fullAudioSamples/max(abs(fullAudioSamples)) + 0.5; % normalize + shift : for display
        timeAudioSamples = (1:1:(length(fullAudioSamples)))/S.Parameters.Audio.SamplingRate;
        
        plot(timeAudioSamples,fullAudioSamples);
        
end


%% Ready for another run

set(handles.text_LastFileNameAnnouncer,'Visible','on')
set(handles.text_LastFileName,         'Visible','on')
set(handles.text_LastFileName,'String' ,DataFile(length(DataPath)+1:end))

printResults(S.TaskData.ER)

WaitSecs(0.100);
pause(0.100);
fprintf('\n')
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n')
fprintf('  Ready for another session   \n')
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n')


end % function
