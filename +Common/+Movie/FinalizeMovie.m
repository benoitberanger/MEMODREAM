function FinalizeMovie( moviePtr )
global S

switch S.RecordVideo
    case 'On'
        Screen('FinalizeMovie', moviePtr);
    case 'Off'
    otherwise
        error('S.RecordVideo ?')
end

end % function
