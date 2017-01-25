switch S.OperationMode
    case 'Acquisition'
        HideCursor;
    case 'FastDebug'
    case 'RealisticDebug'
    otherwise
end

Common.DrawFixation;

% Flip video
Screen( 'Flip' , S.PTB.wPtr );

% Synchronization
StartTime = WaitForTTL( S );
