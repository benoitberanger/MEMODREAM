global reverseStr
reverseStr = '';

switch S.OperationMode
    case 'Acquisition'
        HideCursor;
    case 'FastDebug'
    case 'RealisticDebug'
    otherwise
end

switch S.Task
    
    case 'Learning5432'
        WhiteCross.Draw;
        
    case 'DualTask'
        Common.FillBackGround
        
end


% Flip video
Screen( 'Flip' , S.PTB.wPtr );

% Synchronization
StartTime = WaitForTTL( S );
