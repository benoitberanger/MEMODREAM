function [ PTB ] = StartPTB( S )
% STARTPTB starts audio and video systems of PTB


%% Echo in command window

EchoStart(mfilename)


%% Audio

if S.Parameters.Type.Audio
    
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
    
end


%% Video

if S.Parameters.Type.Video
    
    % Shortcut
    Video = S.Parameters.Video;
    
    % Use GStreamer : for videos
    Screen('Preference', 'OverrideMultimediaEngine', 1);
    
    % PTB opening screen will be empty = black screen
    Screen('Preference', 'VisualDebugLevel', 1);
    
    % Open PTB display window
    switch S.WindowedMode
        case 'Off'
            WindowRect = [];
        case 'On'
            factor = 0.5;
            [ScreenWidth, ScreenHeight]=Screen('WindowSize', Video.ScreenMode);
            SmallWindow = ScaleRect( [0 0 ScreenWidth ScreenHeight] , factor , factor );
            WindowRect = CenterRectOnPoint( SmallWindow , ScreenWidth/2 , ScreenHeight/2 );
        otherwise
    end
    
    color_depth = []; % bit, only assigna specific value for backward compatibility
    multisample = 8; % samples for anti-aliasing
    
    try
        Screen('Preference', 'SkipSyncTests', 0);
        [PTB.wPtr,PTB.wRect] = Screen('OpenWindow',Video.ScreenMode,Video.ScreenBackgroundColor,WindowRect,color_depth,[],[],multisample);
    catch err
        disp(err)
        Screen('Preference', 'SkipSyncTests', 1);
        [PTB.wPtr,PTB.wRect] = Screen('OpenWindow',Video.ScreenMode,Video.ScreenBackgroundColor,WindowRect,color_depth,[],[],multisample);
    end
    
    
    
    % Refresh time of the monitor
    PTB.slack = Screen('GetFlipInterval', PTB.wPtr)/2;
    PTB.ifi   = Screen('GetFlipInterval', PTB.wPtr)  ;
    PTB.fps   = Screen('FrameRate'      , PTB.wPtr)  ;
    
    % Set up alpha-blending for smooth (anti-aliased) lines and alpha-blending
    % (transparent background textures)
    Screen('BlendFunction', PTB.wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % Center
    [ PTB.CenterH , PTB.CenterV ] = RectCenter( PTB.wRect );
    
    % Size
    [ PTB.Width , PTB.Height ] = RectSize( PTB.wRect );
    
    % B&W colors
    PTB.Black = BlackIndex( PTB.wPtr );
    PTB.White = WhiteIndex( PTB.wPtr );
    
    % Text
    Screen('TextSize' , PTB.wPtr, S.Parameters.Text.Size);
    Screen('TextFont' , PTB.wPtr, S.Parameters.Text.Font);
    Screen('TextColor', PTB.wPtr, S.Parameters.Text.Color);
    
else
    
    PTB.anticipation = 0.001; % in secondes
    
end


%% Priority

% Set max priority
PTB.oldLevel         = Priority();
PTB.maxPriorityLevel = MaxPriority( [] );
PTB.newLevel         = Priority( PTB.maxPriorityLevel );


%% Warm up

if S.Parameters.Type.Audio
    
    PsychPortAudio('FillBuffer',PTB.Playback_pahandle,zeros(2,1e3));
    PsychPortAudio('Start',PTB.Playback_pahandle,[],[],1);
    
end

if S.Parameters.Type.Video
    
    Screen('Flip',PTB.wPtr);
    
end

WaitSecs(0.100);
GetSecs;
KbCheck;


%% Echo in command window

EchoStop(mfilename)


end
