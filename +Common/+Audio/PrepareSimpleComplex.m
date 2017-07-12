function [ SimpleSimple, ComplexComplex ] = PrepareSimpleComplex
global S

SimpleSimple = Wav( ['wav' filesep 'SimpleSimple.wav'] );
SimpleSimple.Resample(S.Parameters.Audio.SamplingRate)
SimpleSimple.LinkToPAhandle( S.PTB.Playback_pahandle );
SimpleSimple.AssertReadyForPlayback; % just to check

ComplexComplex = Wav( ['wav' filesep 'ComplexComplex.wav'] );
ComplexComplex.Resample(S.Parameters.Audio.SamplingRate)
ComplexComplex.LinkToPAhandle( S.PTB.Playback_pahandle );
ComplexComplex.AssertReadyForPlayback; % just to check

end % function
