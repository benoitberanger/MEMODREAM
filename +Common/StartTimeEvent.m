function StartTime = StartTimeEvent(  WhiteCross )

global S  reverseStr
reverseStr = '';

switch S.OperationMode
    case 'Acquisition'
        HideCursor;
    case 'FastDebug'
    case 'RealisticDebug'
    otherwise
end

% ### Video ### %
if S.Parameters.Type.Video
    
    switch S.Task
        
        case 'Learning5432'
            WhiteCross.Draw;
            
        case 'DualTask'
            Common.FillBackGround
            
    end
    
    % Flip video
    Screen( 'Flip' , S.PTB.wPtr );
    
end

% Synchronization
StartTime = WaitForTTL;

end % function
