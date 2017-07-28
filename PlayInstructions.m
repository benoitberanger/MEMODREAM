function PlayInstructions(hObject, ~)

clc
EchoStart(mfilename)

%%  Which instructions ?

switch get(hObject,'Tag')
    case 'pushbutton_InstructionTraining'
        Task = 'training';
        
    case 'pushbutton_InstructionSpeedTest'
        Task = 'speedtest';
        
    case 'pushbutton_InstructionDualTask'
        Task = 'dualtask';
        
    otherwise
        error('MEMODREAM:Instructions','Error in Task selection')
        
end


%% Start PTB audio playback engine

global S
S = struct; % S is the main structure, containing everything usefull, and used everywhere
S.OperationMode = '';
S.Parameters = GetParameters;
S.PTB = StartPTB;

% Load audio objects
audioObj = Common.Audio.PrepareAudioFiles;

% Play
audioObj.(['instructions_' Task]).Playback();
WaitSecs(audioObj.(['instructions_' Task]).duration);

% Stop engine
PsychPortAudio('close');

EchoStop(mfilename)

end % function
