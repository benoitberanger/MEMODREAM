%% Parameters

LowFreq  = 440;       % Hz
HighFreq = 2*LowFreq; % Hz

BipDuration = 1; % second

InOutFadeRation = 0.25;


%% Create objects

LowBip  = Bip( S.Parameters.Audio.SamplingRate , LowFreq  ,  BipDuration , InOutFadeRation );
LowBip. LinkToPAhandle(playPAh);
LowBip.AssertReadyForPlayback; % just to check

HighBip = Bip( S.Parameters.Audio.SamplingRate , HighFreq ,  BipDuration , InOutFadeRation );
HighBip.LinkToPAhandle(playPAh);
LowBip.AssertReadyForPlayback; % just to check
