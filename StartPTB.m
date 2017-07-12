function [ PTB ] = StartPTB
% STARTPTB starts audio and video systems of PTB
global S

%% Echo in command window

EchoStart(mfilename)


%% Audio

% Shortcut
Audio = S.Parameters.Audio;

% Perform basic initialization of the sound driver:
InitializePsychSound(1);

% Close the audio device:
PsychPortAudio('Close')

% Playback device initialization
PTB.Playback_pahandle = PsychPortAudio('Open', [],...
    Audio.Playback_Mode,...
    Audio.Playback_LowLatencyMode,...
    Audio.Playback_freq,...
    Audio.Playback_Channels);

% Record device initialization
PTB.Record_pahandle = PsychPortAudio('Open', [],...
    Audio.Record_Mode,...
    Audio.Record_LowLatencyMode,...
    Audio.Record_freq,...
    Audio.Record_Channels);

% Preallocate an internal audio recording  buffer with a capacity of 60 seconds:
PsychPortAudio('GetAudioData', PTB.Record_pahandle, 60);


PTB.anticipation = 0.001; % in secondes


%% Priority

% Set max priority
PTB.oldLevel         = Priority();
PTB.maxPriorityLevel = MaxPriority( [] );
PTB.newLevel         = Priority( PTB.maxPriorityLevel );


%% Warm up

PsychPortAudio('FillBuffer',PTB.Playback_pahandle,zeros(2,1e3));
PsychPortAudio('Start',PTB.Playback_pahandle,[],[],1);

WaitSecs(0.100);
GetSecs;
KbCheck;


%% Echo in command window

EchoStop(mfilename)


end
