function [ TaskData ] = Task
global S

try
    %% Shortcuts
    
    % ### Video ### %
    if S.Parameters.Type.Video
        wPtr = S.PTB.wPtr;              % window pointer
    else
        wPtr = [];
    end
    playPAh = S.PTB.Playback_pahandle; % playback audio pointer
    recPAh  = S.PTB.Record_pahandle;   % record   audio pointer
    
    
    %% Parallel port
    
    TaskData.ParPortMessages = Common.PrepareParPort;
    
    
    %% Tunning of the task
    
    [ EP ] = Learning5432.Planning;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    [ ER, RR, KL ] = Common.PrepareRecorders( EP );
    
    
    %% Hands sprites and fingers patchs, fixation cross
    
    % ### Video ### %
    if S.Parameters.Type.Video
        [ LeftHand, RightHand ] = Common.PrepareHandsFingers ;
        [ WhiteCross          ] = Common.PrepareFixationCross;
    else
        LeftHand   = [];
        RightHand  = [];
        WhiteCross = [];
    end
    
    [ GoGo, StopStop ] = Common.PrepareGoStop;
    
    
    %% Go
    
    % Initialize some varibles
    Exit_flag = 0;
    from = 1;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay( EP, evt ) ;
        
        switch EP.Data{evt,1}
            
            case 'StartTime'
                
                StartTime = Common.StartTimeEvent( WhiteCross );
                
            case 'StopTime'
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
            case 'Rest'
                
                % ### Video ### %
                if S.Parameters.Type.Video
                    WhiteCross.Draw
                end
                
                % Wrapper for the control condition. It's a script itself,
                % used across several tasks
                [ ER, from, Exit_flag, StopTime ] = Common.ControlCondition( EP, ER, RR, KL, StartTime, from, GoGo, StopStop, evt );
                
                
            otherwise
                
                if strcmp(EP.Data{evt,1},'Free')
                    timeLimit = Inf;
                else
                    timeLimit = EP.Data{evt,3};
                end
                
                % ### Video ### %
                if S.Parameters.Type.Video
                    
                    Common.DrawHand( EP, LeftHand, RightHand )
                    
                    Screen('DrawingFinished',wPtr);
                    vbl = Screen('Flip',wPtr, StartTime + EP.Data{evt,2} - S.PTB.slack);
                    
                else
                    vbl = WaitSecs('UntilTime',StartTime + EP.Data{evt,2} - S.PTB.anticipation);
                end
                
                ER.AddEvent({EP.Data{evt,1} vbl-StartTime [] [] []})
                
                needFlip = 0;
                
                revreset = 1;
                
                % ### Video ### %
                if S.Parameters.Type.Video
                    % Here we stop 3 frames before the expected next onset
                    % because the while loop will make 2 flips, wich will
                    % introduce a delay
                    PTBtimeLimit = StartTime + EP.Data{evt,2} + timeLimit - S.PTB.ifi*3;
                else
                    PTBtimeLimit = StartTime + EP.Data{evt,2} + timeLimit - S.PTB.anticipation*16;
                end
                [ Exit_flag, StopTime ] = Common.DisplayInputsInCommandWindow( EP, ER, RR, PTBtimeLimit, evt, StartTime );
                if Exit_flag
                    break
                end
                
        end % switch
        
        % This flag comes from Common.Interrupt, if ESCAPE is pressed
        if Exit_flag
            break
        end
        
    end % for
    
    
    %% End of stimulation
    
    TaskData = Common.EndOfStimulation( TaskData, EP, ER, RR, KL, StartTime, StopTime );
    
    
catch err %#ok<*NASGU>
    
    Common.Catch( err );
    
end

end % function
