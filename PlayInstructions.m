function PlayInstructions(hObject, ~)

clc
EchoStart(mfilename)

%%  Which instructions ?

switch get(hObject,'Tag')
    case 'pushbutton_InstructionSleep'
        Task = 'sleep';
        
    case 'pushbutton_InstructionExecution'
        Task = 'execution';
        
    case 'pushbutton_InstructionImagination'
        Task = 'imagination';
        
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
audioObj.(Task).Playback();
WaitSecs(audioObj.(Task).duration);

% Stop engine
PsychPortAudio('close');

EchoStop(mfilename)

end % function
