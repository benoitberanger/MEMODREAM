function [ TaskData ] = Task
global S

try
    %% Shortcuts
    
    % ### Video ### %
    if S.Parameters.Type.Video
        wPtr    = S.PTB.wPtr;              % window pointer
    else
        wPtr = [];
    end
    playPAh = S.PTB.Playback_pahandle; % playback audio pointer
    recPAh  = S.PTB.Record_pahandle;   % record   audio pointer
    
    
    %% Parallel port
    
    ParPortMessages = Common.PrepareParPort;
    
    
    %% Tunning of the task
    
    [ EP ] = DualTask.Planning;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    [ ER, RR, KL ] = Common.PrepareRecorders( EP );
    
    
    %% Record movie
    
    moviePtr = Common.Movie.CreateMovie;
    
    
    %% Start recording eye motions
    
    Common.StartRecordingEyelink;
    
    
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
    
    
    %% Prepare High bip and Low bip
    
    [ LowBip, HighBip  ] = Common.PrepareBips  ;
    [ GoGo  , StopStop ] = Common.PrepareGoStop;
    
    
    %% Go
    
    % Initialize some varibles
    Exit_flag = 0;
    from      = 1;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay( EP, evt );
        
        switch EP.Data{evt,1}
            
            case 'StartTime'
                
                % Start audio capture immediately and wait for the capture to start.
                % We set the number of 'repetitions' to zero,
                % i.e. record until recording is manually stopped.
                PsychPortAudio('Start', recPAh, 0, 0, 1);
                WaitSecs(0.100);
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
                
            case 'Sequence'
                
                bipseq = EP.Data{evt,5};
                v = linspace(0, EP.Data{evt,3},length(bipseq)+1)+0.5;
                v_onset = v(1:end-1);
                
                needFlip = 0;
                revreset = 1;
                
                % ### Video ### %
                if S.Parameters.Type.Video
                    
                    Common.DrawHand( EP, LeftHand, RightHand );
                    
                    Screen('DrawingFinished',wPtr);
                    onset = Screen('Flip',wPtr, StartTime + EP.Data{evt,2} - S.PTB.slack);
                    
                else
                    onset = WaitSecs('UntilTime',StartTime + EP.Data{evt,2} - S.PTB.anticipation);
                end
                
                ER.AddEvent({EP.Data{evt,1} onset-StartTime [] [] []})
                
                for b = 1 : length(bipseq)
                    
                    switch bipseq(b)
                        case 1 % high bip
                            last_onset = HighBip.Playback(StartTime + EP.Data{evt,2} + v_onset(b));
                            RR.AddEvent({EP.Data{evt,1} last_onset-StartTime [] 'HighBip'})
                        case 0 % low bip
                            last_onset = LowBip. Playback(StartTime + EP.Data{evt,2} + v_onset(b));
                            RR.AddEvent({EP.Data{evt,1} last_onset-StartTime [] 'LowBip'})
                    end
                    
                    
                    % ### Video ### %
                    if S.Parameters.Type.Video
                        % Here we stop 3 frames before the expected next onset
                        % because the while loop will make 2 flips, wich will
                        % introduce a delay
                        PTBtimeLimit = StartTime + EP.Data{evt,2} + EP.Data{evt,3} - S.PTB.ifi*3;
                    else
                        if b ~= length(bipseq)
                            PTBtimeLimit = StartTime + EP.Data{evt,2} + v_onset(b+1)   - S.PTB.anticipation;
                        else
                            PTBtimeLimit = StartTime + EP.Data{evt,2} + EP.Data{evt,3} - S.PTB.anticipation*16;
                        end
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
    
    Common.Movie.FinalizeMovie( moviePtr );
    
    
catch err %#ok<*NASGU>
    
    Common.Catch( err );
    
end

end % function
