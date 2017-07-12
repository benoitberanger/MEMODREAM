function [ TaskData ] = Task
global S

try
    %% Shortcuts
    
    recPAh  = S.PTB.Record_pahandle;   % record   audio pointer
    
    
    %% Parallel port
    
    TaskData.ParPortMessages = Common.PrepareParPort;
    
    
    %% Tunning of the task
    
    [ EP ] = DualTask.Planning;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    [ ER, RR, KL ] = Common.PrepareRecorders( EP );
    
    
   
    %% Prepare audio objects
    
    [ LowBip       , HighBip        ] = Common.Audio.PrepareBips         ;
    [ GoGo         , StopStop       ] = Common.Audio.PrepareGoStop       ;
    [ SimpleSimple , ComplexComplex ] = Common.Audio.PrepareSimpleComplex;
    audioObj.LowBip         = LowBip;
    audioObj.HighBip        = HighBip;
    audioObj.GoGo           = GoGo;
    audioObj.StopStop       = StopStop;
    audioObj.SimpleSimple   = SimpleSimple;
    audioObj.ComplexComplex = ComplexComplex;
    
    %% Go
    
    % Initialize some varibles
    Exit_flag = 0;
    from      = 1;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay( EP, evt );
        
        switch EP.Data{evt,1}
            
            case 'StartTime' % --------------------------------------------
                
                % Start audio capture immediately and wait for the capture to start.
                % We set the number of 'repetitions' to zero,
                % i.e. record until recording is manually stopped.
                PsychPortAudio('Start', recPAh, 0, 0, 1);
                WaitSecs(0.100);
                StartTime = Common.StartTimeEvent;
                
            case 'StopTime' % ---------------------------------------------
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
            case 'Rest' % -------------------------------------------------
               
                % Wrapper for the control condition. It's a script itself,
                % used across several tasks
                [ ER, from, Exit_flag, StopTime ] = Common.ControlCondition( EP, ER, RR, KL, StartTime, from, audioObj, evt, 'time' );
                
            case 'Sequence' % ---------------------------------------------
                
                bipseq = EP.Data{evt,5};
                v = linspace(0, EP.Data{evt,3},length(bipseq)+1)+0.5;
                v_onset = v(1:end-1);
                
                onset = WaitSecs('UntilTime',StartTime + EP.Data{evt,2} - S.PTB.anticipation);
                
                ER.AddEvent({EP.Data{evt,1} onset-StartTime [] [] []})
                
                for b = 1 : length(bipseq)
                    
                    switch bipseq(b)
                        case 1 % high bip
                            last_onset = audioObj.HighBip.Playback(StartTime + EP.Data{evt,2} + v_onset(b));
                            RR.AddEvent({EP.Data{evt,1} last_onset-StartTime [] 'HighBip'})
                        case 0 % low bip
                            last_onset = audioObj.LowBip. Playback(StartTime + EP.Data{evt,2} + v_onset(b));
                            RR.AddEvent({EP.Data{evt,1} last_onset-StartTime [] 'LowBip'})
                    end
                    
                    
                    if b ~= length(bipseq)
                        PTBtimeLimit = StartTime + EP.Data{evt,2} + v_onset(b+1)   - S.PTB.anticipation;
                    else
                        PTBtimeLimit = StartTime + EP.Data{evt,2} + EP.Data{evt,3} - S.PTB.anticipation*16;
                    end
                    
                    [ Exit_flag, StopTime ] = Common.DisplayInputsInCommandWindow( EP, ER, RR, PTBtimeLimit, evt, StartTime );
                    if Exit_flag
                        break
                    end
                    
                end % for
                
        end % switch
        
        % Perform a fetch operation to get all data from the capture engine:
        audiodata = PsychPortAudio('GetAudioData', recPAh);
        % Sore audio data
        if evt > 1
            ER.Data{evt,5} = audiodata;
        end
        
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
