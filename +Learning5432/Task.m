function [ TaskData ] = Task( S )

try
    %% Shortcuts
    
    wPtr = S.PTB.wPtr;
    
    
    %% Parallel port
    
    Common.PrepareParPort;
    
    
    %% Tunning of the task
    
    [ EP , Speed ] = Learning5432.Planning( S );
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    Common.PrepareRecorders;
    
    
    %% Record movie
    
    Common.Movie.CreateMovie;
    
    
    %% Start recording eye motions
    
    Common.StartRecordingEyelink;
    
    
    %% Load and prepare sprites for the hands
    
    img_path = 'img';
    img_file = [ img_path filesep 'left_hand.png' ];
    
    hand_color = [0 128 255 255]; % [R G B a] from 0 to 255
    
    LeftHand  = Hand(img_file, hand_color, false);
    LeftHand. MakeTexture(wPtr);
    
    RightHand = Hand(img_file, hand_color, true );
    RightHand.MakeTexture(wPtr);
    
    
    %% Scale and shift the Hands
    
    sizeOfSprite = 0.9* S.PTB.Width / 2;
    
    LeftHand. ReScale( sizeOfSprite / LeftHand. wPx );
    RightHand.ReScale( sizeOfSprite / RightHand.wPx );
    
    LeftHand.MoveCenter ( [ (1/4)*S.PTB.Width ; S.PTB.CenterV ] );
    RightHand.MoveCenter( [ (3/4)*S.PTB.Width ; S.PTB.CenterV ] );
    
    
    %% Prepare display of the fingers
    
    FingersLeftpos = [
        726 404 % 1
        454 74  % 2
        324 44  % 3
        180 132 % 4
        32 294  % 5
        ];
    
    fingers_color = [255 0 0 255];
    
    LeftFingers = Fingers(FingersLeftpos, fingers_color);
    RightFingers = Fingers(FingersLeftpos, fingers_color);
    
    LeftFingers.LinkToHand(LeftHand);
    RightFingers.LinkToHand(RightHand);
    
    RightFingers.FlipLR;
    
    LeftFingers.UpdatePos;
    RightFingers.UpdatePos;
    
    
    %% Go
    
    % Initialize some varibles
    pp = 0;
    keyCode = zeros(1,256);
    secs = GetSecs;
    reverseStr = '';
    Exit_flag = 0;
    from = 1;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay;
        
        switch EP.Data{evt,1}
            
            case 'StartTime'
                
                Common.StartTimeEvent;
                
            case 'StopTime'
                
                Common.StopTimeEvent;
                
            case 'FixationCross'
                
                Common.DrawFixation
                
                Screen('DrawingFinished',wPtr);
                vbl = Screen('Flip',wPtr, StartTime + EP.Data{evt,2} - S.PTB.slack);
                ER.AddEvent({EP.Data{evt,1} vbl-StartTime [] []})
                
                if ~strcmp(EP.Data{evt-1,1},'StartTime')
                    KL.GetQueue;
                    results = Common.SequenceAnalyzer('5432', EP.Data{evt-1,1}, EP.Data{evt-1,3}, from, KL.EventCount, KL);
                    from = KL.EventCount;
                    ER.Data{evt-1,4} = results;
                end
                
                % The WHILELOOP below a trick so we can use ESCAPE key to quit
                % earlier.
                while ~( keyCode(S.Parameters.Keybinds.Stop_Escape_ASCII) || ( secs > StartTime + EP.Data{evt,2} + EP.Data{evt,3} - S.PTB.slack ) )
                    [~, secs, keyCode] = KbCheck;
                end
                
                Common.Interrupt
                
                
            otherwise
                
                if strcmp(EP.Data{evt,1},'Free')
                    timeLimit = Inf;
                else
                    timeLimit = EP.Data{evt,3};
                end
                
                Common.DrawHand
                
                Screen('DrawingFinished',wPtr);
                vbl = Screen('Flip',wPtr, StartTime + EP.Data{evt,2} - S.PTB.slack);
                ER.AddEvent({EP.Data{evt,1} vbl-StartTime [] []})
                
                needFlip = 0;
                
                % Here we stop 3 frames before the expected next onset
                % because the while loop will make 2 flips, wich will
                % introduce a delay
                while ~( keyCode(S.Parameters.Keybinds.Stop_Escape_ASCII) || ( secs > StartTime + EP.Data{evt,2} + timeLimit - S.PTB.ifi*3 ) )
                    
                    
                    [keyIsDown, secs, keyCode, deltasecs] = KbCheck;
                    
                    
                    msg = sprintf([repmat('%d ',[1 10]) '\n'],...
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
                    fprintf([reverseStr, msg]);
                    reverseStr = repmat(sprintf('\b'), 1, length(msg));
                    
                    
                    if keyIsDown
                        
                        if any(keyCode(S.Parameters.Fingers.All))
                            
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
                        
                        Common.Interrupt
                        
                    end
                    
                    
                    if needFlip == 1 % && ( secs < StartTime + EP.Data{evt,2} + timeLimit - S.PTB.slack*2 )
                        
                        Common.DrawHand
                        
                        Screen('DrawingFinished',wPtr);
                        Screen('Flip',wPtr);
                        
                    end
                    
                    needFlip = needFlip - 1;
                    
                end % while
                
        end % switch
        
        if Exit_flag
            break %#ok<*UNRCH>
        end
        
    end % for
    
    
    %% End of stimulation
    
    
    Common.EndOfStimulationScript;
    
    Common.Movie.FinalizeMovie;
    
    
catch err %#ok<*NASGU>
    
    Common.Catch;
    
end

end
