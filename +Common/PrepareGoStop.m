GoGo = Wav( ['wav' filesep 'GoGo.wav'] );
GoGo.Resample(S.Parameters.Audio.SamplingRate)
GoGo.LinkToPAhandle(playPAh);
GoGo.AssertReadyForPlayback; % just to check

StopStop = Wav( ['wav' filesep 'StopStop.wav'] );
StopStop.Resample(S.Parameters.Audio.SamplingRate)
StopStop.LinkToPAhandle(playPAh);
StopStop.AssertReadyForPlayback; % just to check
