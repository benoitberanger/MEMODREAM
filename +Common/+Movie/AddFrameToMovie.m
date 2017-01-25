switch S.RecordVideo
    case 'On'
        Screen('AddFrameToMovie',S.PTB.wPtr,[],'frontBuffer',moviePtr,1);
    case 'Off'
    otherwise
        error('S.RecordVideo ?')
end
