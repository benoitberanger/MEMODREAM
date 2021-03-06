function [ TaskData ] = Task
global S

try
    %% Tunning of the task
    
    switch S.Task
        
        case 'Training'
            [ EP ] = Training.Planning;
            
        case 'SpeedTest'
            [ EP ] = SpeedTest.Planning;
            
        otherwise
            error('MEMODREAM:SpeedTest','Task error...')
    end
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    [ ER, RR, KL ] = Common.PrepareRecorders( EP );
    
    
    %% Prepare audio objects
    
    [ audioObj ] = Common.Audio.PrepareAudioFiles;
    
    
    %% Go
    
    % Initialize some varibles
    Exit_flag = 0;
    from      = 1;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay( EP, evt );
        
        switch EP.Data{evt,1}
            
            case 'StartTime' % --------------------------------------------
                
                switch S.OperationMode
                    
                    case 'Acquisition'
                        
                        switch S.Task
                            case 'Training'
                                audioObj.instructions_training.Playback();
                                WaitSecs(audioObj.instructions_training.duration);
                            case 'SpeedTest'
                                audioObj.instructions_speedtest.Playback();
                                WaitSecs(audioObj.instructions_speedtest.duration);
                        end
                        
                end
                
                StartTime = Common.StartTimeEvent;
                
            case 'StopTime' % ---------------------------------------------
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
            case 'Rest' % -------------------------------------------------
                
                % Wrapper for the control condition. It's a script itself,
                % used across several tasks
                [ ER, from, Exit_flag, StopTime ] = Common.ControlCondition( EP, ER, RR, KL, StartTime, from, audioObj, evt, 'tap' );
                
            otherwise % ---------------------------------------------------
                
                vbl = WaitSecs('UntilTime',StartTime + ER.Data{evt-1,2} + EP.Data{evt-1,3} - S.PTB.anticipation);
                
                ER.AddEvent({EP.Data{evt,1} vbl-StartTime [] [] []})
                
                [ Exit_flag, StopTime ] = Common.DisplayInputsInCommandWindow( EP, ER, RR, evt, StartTime, audioObj, 'tap', EP.Data{evt,3} );
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
    
    
catch err
    
    Common.Catch( err );
    
end

end % function
