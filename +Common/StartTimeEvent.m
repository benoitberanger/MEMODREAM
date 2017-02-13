switch S.OperationMode
    case 'Acquisition'
        HideCursor;
    case 'FastDebug'
    case 'RealisticDebug'
    otherwise
end

WhiteCross.Draw;

% Flip video
Screen( 'Flip' , S.PTB.wPtr );

% Synchronization
StartTime = WaitForTTL( S );
