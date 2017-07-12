function [ GoGo, StopStop ] = PrepareGoStop
global S

GoGo = Wav( ['wav' filesep 'GoGo.wav'] );
GoGo.Resample(S.Parameters.Audio.SamplingRate)
GoGo.LinkToPAhandle( S.PTB.Playback_pahandle );
GoGo.AssertReadyForPlayback; % just to check

StopStop = Wav( ['wav' filesep 'StopStop.wav'] );
StopStop.Resample(S.Parameters.Audio.SamplingRate)
StopStop.LinkToPAhandle( S.PTB.Playback_pahandle );
StopStop.AssertReadyForPlayback; % just to check

end % function
