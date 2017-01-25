switch S.RecordVideo
    case 'On'
    moviePtr = Screen('CreateMovie', S.PTB.wPtr, S.VideoName ,[], [], S.PTB.fps,...
        [':CodecType=theoraenc AddAudioTrack=2@' num2str(S.Parameters.Audio.SamplingRate) ' EncodingQuality=1 numChannels=1']); % doesnt work (on windows)
    
    case 'Off'
    otherwise
        error('S.RecordVideo ?')
end
