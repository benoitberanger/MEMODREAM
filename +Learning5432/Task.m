function [ TaskData ] = Task( S )

try
    %% Shortcuts
    
    % ### Video ### %
    if S.Parameters.Type.Video
        wPtr = S.PTB.wPtr;
    end
    
    
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
    
    
    %% Hands sprites and fingers patchs, fixation cross
    
    % ### Video ### %
    if S.Parameters.Type.Video
        Common.PrepareHandsFingers
        Common.PrepareFixationCross
    end
    
    
    %% Go
    
    % Initialize some varibles
    pp = 0;
    keyCode = zeros(1,256);
    secs = GetSecs;
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
                
            case 'Rest'
                
                % ### Video ### %
                if S.Parameters.Type.Video
                    WhiteCross.Draw
                end
                
                % Wrapper for the control condition. It's a script itself,
                % used across several tasks
                Common.ControlConditionScript
                
                
            otherwise
                
                if strcmp(EP.Data{evt,1},'Free')
                    timeLimit = Inf;
                else
                    timeLimit = EP.Data{evt,3};
                end
                
                % ### Video ### %
                if S.Parameters.Type.Video
                    
                    Learning5432.DrawHand
                    
                    Screen('DrawingFinished',wPtr);
                    vbl = Screen('Flip',wPtr, StartTime + EP.Data{evt,2} - S.PTB.slack);
                    
                else
                    vbl = WaitSecs('UntilTime',StartTime + EP.Data{evt,2} - S.PTB.anticipation);
                end
                
                ER.AddEvent({EP.Data{evt,1} vbl-StartTime [] []})
                
                needFlip = 0;
                
                revreset = 1;
                
                % ### Video ### %
                if S.Parameters.Type.Video
                    % Here we stop 3 frames before the expected next onset
                    % because the while loop will make 2 flips, wich will
                    % introduce a delay
                    PTBtimeLimit = StartTime + EP.Data{evt,2} + timeLimit - S.PTB.ifi*3;
                else
                    PTBtimeLimit = StartTime + EP.Data{evt,2} + timeLimit - S.PTB.anticipation;
                end
                
                while ~( keyCode(S.Parameters.Keybinds.Stop_Escape_ASCII) || ( secs > PTBtimeLimit ) )
                    
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
                                
                                Learning5432.DrawHand
                                
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
                            
                            Learning5432.DrawHand
                            
                            Screen('DrawingFinished',wPtr);
                            Screen('Flip',wPtr);
                            
                        end
                        
                        needFlip = needFlip - 1;
                        
                    end
                    
                end % while
                
        end % switch
        
        % This flag comes from Common.Interrupt, if ESCAPE is pressed
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
