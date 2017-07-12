function [ TaskData ] = Task
global S

try
    %% Shortcuts
    
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
    
    [ GoGo, StopStop ] = Common.PrepareGoStop;
    
    
    %% Go
    
    % Initialize some varibles
    Exit_flag = 0;
    from = 1;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay( EP, evt ) ;
        
        switch EP.Data{evt,1}
            
            case 'StartTime' % --------------------------------------------
                
                StartTime = Common.StartTimeEvent;
                
                
            case 'StopTime' % ---------------------------------------------
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
            case 'Rest' % -------------------------------------------------
                
                % Wrapper for the control condition. It's a script itself,
                % used across several tasks
                [ ER, from, Exit_flag, StopTime ] = Common.ControlCondition( EP, ER, RR, KL, StartTime, from, GoGo, StopStop, evt );
                
                
            otherwise % ---------------------------------------------------
                
                if strcmp(EP.Data{evt,1},'Free')
                    timeLimit = Inf;
                else
                    timeLimit = EP.Data{evt,3};
                end
                
                vbl = WaitSecs('UntilTime',StartTime + EP.Data{evt,2} - S.PTB.anticipation);
                
                ER.AddEvent({EP.Data{evt,1} vbl-StartTime [] [] []})
                
                revreset = 1;
                
                PTBtimeLimit = StartTime + EP.Data{evt,2} + timeLimit - S.PTB.anticipation*16;
                
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
