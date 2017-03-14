while secs < PTBtimeLimit
    
    [keyIsDown, secs, keyCode] = KbCheck;
    
    msg = sprintf([repmat('%d ',[1 5]) '| ' repmat('%d ',[1 5]) '\n'],...
        keyCode(S.Parameters.Fingers.Left (5)),...
        keyCode(S.Parameters.Fingers.Left (4)),...
        keyCode(S.Parameters.Fingers.Left (3)),...
        keyCode(S.Parameters.Fingers.Left (2)),...
        keyCode(S.Parameters.Fingers.Left (1)),...
        keyCode(S.Parameters.Fingers.Right(1)),...
        keyCode(S.Parameters.Fingers.Right(2)),...
        keyCode(S.Parameters.Fingers.Right(3)),...
        keyCode(S.Parameters.Fingers.Right(4)),...
        keyCode(S.Parameters.Fingers.Right(5)) ...
        );
    revfprintf(msg,revreset)
    revreset = 0;
    
    if keyIsDown
        
        if any(keyCode(S.Parameters.Fingers.All))
            
            % ### Video ### %
            if S.Parameters.Type.Video
                
                Common.DrawHand
                
                needFlip = 2;
                
                r = find(keyCode(S.Parameters.Fingers.Right));
                l = find(keyCode(S.Parameters.Fingers.Left));
                
                if ~isempty(r)
                    RightFingers.Draw(r);
                end
                
                if ~isempty(l)
                    LeftFingers. Draw(l);
                end
                
                Screen('DrawingFinished',wPtr);
                Screen('Flip',wPtr);
                
            end
            
        end
        
        Common.Interrupt
        
    end
    
    % ### Video ### %
    if S.Parameters.Type.Video
        
        if needFlip == 1 % && ( secs < StartTime + EP.Data{evt,2} + timeLimit - S.PTB.slack*2 )
            
            Common.DrawHand
            
            Screen('DrawingFinished',wPtr);
            Screen('Flip',wPtr);
            
        end
        
        needFlip = needFlip - 1;
        
    end
    
end % while
