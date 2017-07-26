function [ audioObj ] = PrepareAudioFiles
global S

audioObj = struct;

list_audio_files = dir('wav');
list_audio_files = list_audio_files(3:end); % remove '.' and '..'

for file = 1 : length(list_audio_files)
    [~,name,~] = fileparts(list_audio_files(file).name);
    audioObj.(name) = Wav( ['wav' filesep name '.wav'] );
    audioObj.(name).Resample(S.Parameters.Audio.SamplingRate)
    audioObj.(name).LinkToPAhandle( S.PTB.Playback_pahandle );
    audioObj.(name).AssertReadyForPlayback; % just to check
end

end % function
