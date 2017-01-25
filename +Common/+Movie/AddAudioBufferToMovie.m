switch S.RecordVideo
    case 'On'
        Screen('AddAudioBufferToMovie', moviePtr, [EP.Data{evt,4} EP.Data{evt,4}]');
    case 'Off'
    otherwise
        error('S.RecordVideo ?')
end
