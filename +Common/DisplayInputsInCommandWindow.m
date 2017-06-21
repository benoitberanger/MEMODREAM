% 1 : display like "0 1 0 0 0 | 0 0 0 0 0 ", single ligne refreshed
% 2 : (multiline display)
%
% 5
% 4
% 3
% 2
% 2 <-
% 3 <-
% 4 <-
% 5

dislpayKind = 2;

switch dislpayKind
    
    case 2
        
        seq_num = EP.Data{evt,4}; % sequence
        
        next_input = seq_num(1); % initilization
        
        Left = S.Parameters.Fingers.Left; % shortcut
        
        KbVect_prev = zeros(size(Left));
        KbVect_curr = zeros(size(Left));
        KbVect_diff = zeros(size(Left));
        
end

while secs < PTBtimeLimit
    
    [keyIsDown, secs, keyCode] = KbCheck;
    
    switch dislpayKind
        
        case 2
            
            KbVect_curr = keyCode(Left);
            KbVect_diff = KbVect_curr - KbVect_prev;
            KbVect_prev = KbVect_curr;
            
            new_input = find(KbVect_diff==1);
            
            if ~isempty(new_input) && isscalar(new_input)
                
                if new_input == str2double(next_input)
                    fprintf('%d\n',new_input)
                    seq_num = circshift(seq_num,[0 -1]);
                    next_input = seq_num(1);
                else
                    fprintf('%d <-\n',new_input)
                end
                
            end
            
        case 1
            
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
            
    end
    
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
