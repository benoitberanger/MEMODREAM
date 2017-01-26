function [ Parameters ] = GetParameters( S )
% GETPARAMETERS Prepare common parameters

fprintf('\n')
fprintf('Response buttuns (fORRP 932) : \n')
fprintf('USB \n')
fprintf('HHSC - 2x4 - CYL \n')
fprintf('HID NAR BYGRT \n')
fprintf('\n')

%% Echo in command window

EchoStart(mfilename)


%% Paths

% Parameters.Path.wav = ['wav' filesep];
% Parameters.Path.img = ['img' filesep];


%% Set parameters

%%%%%%%%%%%%%%
%   Screen   %
%%%%%%%%%%%%%%
Parameters.Video.ScreenWidthPx   = 1024;  % Number of horizontal pixel in MRI video system @ CENIR
Parameters.Video.ScreenHeightPx  = 768;   % Number of vertical pixel in MRI video system @ CENIR
Parameters.Video.ScreenFrequency = 60;    % Refresh rate (in Hertz)
Parameters.Video.SubjectDistance = 0.120; % m
Parameters.Video.ScreenWidthM    = 0.040; % m
Parameters.Video.ScreenHeightM   = 0.030; % m

switch S.Task
    
    case 'Learning5432'
        Parameters.Video.ScreenBackgroundColor = [128 128 128]; % [R G B] ( from 0 to 255 )
        
    case 'Task2'
        Parameters.Video.ScreenBackgroundColor = [0 0 0]; % [R G B] ( from 0 to 255 )
        
    case 'Task3'
        Parameters.Video.ScreenBackgroundColor = [0 0 0]; % [R G B] ( from 0 to 255 )
        
    case 'EyelinkCalibration'
        Parameters.Video.ScreenBackgroundColor = [128 128 128]; % [R G B] ( from 0 to 255 )
        
end


%%%%%%%%%%%%
%   Text   %
%%%%%%%%%%%%
switch S.Task
    case 'Learning5432'
        Parameters.Text.Size  = 30;
    case 'Task2'
        Parameters.Text.Size  = 30;
    case 'Task3'
        Parameters.Text.Size  = 60;
    case 'EyelinkCalibration'
        Parameters.Text.Size  = 30;
end
Parameters.Text.Font  = 'Courier New';
Parameters.Text.Color = [255 255 255]; % [R G B] ( from 0 to 255 )


%%%%%%%%%%%
%  Audio  %
%%%%%%%%%%%

% Parameters.Audio.SamplingRate            = 44100; % Hz
% 
% Parameters.Audio.Playback_Mode           = 1; % 1 = playback, 2 = record
% Parameters.Audio.Playback_LowLatencyMode = 1; % {0,1,2,3,4}
% Parameters.Audio.Playback_freq           = Parameters.Audio.SamplingRate ;
% Parameters.Audio.Playback_Channels       = 2; % 1 = mono, 2 = stereo

% Parameters.Audio.Record_Mode             = 2; % 1 = playback, 2 = record
% Parameters.Audio.Record_LowLatencyMode   = 0; % {0,1,2,3,4}
% Parameters.Audio.Record_freq             = SamplingRate;
% Parameters.Audio.Record_Channels         = 1; % 1 = mono, 2 = stereo


%%%%%%%%%%%%%%
%  Keybinds  %
%%%%%%%%%%%%%%

KbName('UnifyKeyNames');


Parameters.Keybinds.TTL_t_ASCII          = KbName('t'); % MRI trigger has to be the first defined key
Parameters.Keybinds.emulTTL_s_ASCII      = KbName('s');
Parameters.Keybinds.Stop_Escape_ASCII    = KbName('ESCAPE');

switch S.OperationMode
    
    case 'Acquisition'
        
        Parameters.Fingers.Right(1) = 1;           % Thumb, not on the response buttons, arbitrary number
        Parameters.Fingers.Right(2) = KbName('b'); % Index finger
        Parameters.Fingers.Right(3) = KbName('y'); % Middle finger
        Parameters.Fingers.Right(4) = KbName('g'); % Ring finger
        Parameters.Fingers.Right(5) = KbName('r'); % Little finger
        
        Parameters.Fingers.Left (1) = 2;           % Thumb, not on the response buttons, arbitrary number
        Parameters.Fingers.Left (2) = KbName('e'); % Index finger
        Parameters.Fingers.Left (3) = KbName('z'); % Middle finger
        Parameters.Fingers.Left (4) = KbName('n'); % Ring finger
        Parameters.Fingers.Left (5) = KbName('d'); % Little finger
        
        Parameters.Fingers.All = [Parameters.Fingers.Right Parameters.Fingers.Left];
        
    otherwise
        
        Parameters.Fingers.Right(1) = 1;           % Thumb, not on the response buttons, arbitrary number
        Parameters.Fingers.Right(2) = KbName('h'); % Index finger
        Parameters.Fingers.Right(3) = KbName('j'); % Middle finger
        Parameters.Fingers.Right(4) = KbName('k'); % Ring finger
        Parameters.Fingers.Right(5) = KbName('l'); % Little finger
        
        Parameters.Fingers.Left (1) = 2;           % Thumb, not on the response buttons, arbitrary number
        Parameters.Fingers.Left (2) = KbName('f'); % Index finger
        Parameters.Fingers.Left (3) = KbName('d'); % Middle finger
        Parameters.Fingers.Left (4) = KbName('s'); % Ring finger
        Parameters.Fingers.Left (5) = KbName('q'); % Little finger
        
        Parameters.Fingers.All = [Parameters.Fingers.Right Parameters.Fingers.Left];
        
end

%% Echo in command window

EchoStop(mfilename)


end