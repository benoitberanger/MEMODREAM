function [ LowBip, HighBip ] = PrepareBips
global S

%% Parameters

LowFreq  = 440;       % Hz
HighFreq = 2*LowFreq; % Hz

BipDuration = 0.5; % second

InOutFadeRation = 0.25;


%% Create objects

LowBip  = Bip( S.Parameters.Audio.SamplingRate , LowFreq  ,  BipDuration , InOutFadeRation );
LowBip. LinkToPAhandle( S.PTB.Playback_pahandle );
LowBip.AssertReadyForPlayback; % just to check

HighBip = Bip( S.Parameters.Audio.SamplingRate , HighFreq ,  BipDuration , InOutFadeRation );
HighBip.LinkToPAhandle( S.PTB.Playback_pahandle );
HighBip.AssertReadyForPlayback; % just to check


end % function
