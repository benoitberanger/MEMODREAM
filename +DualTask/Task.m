function [ TaskData ] = Task( S )

try
    %% Shortcuts
    
    % ### Video ### %
    if S.Parameters.Type.Video
        wPtr    = S.PTB.wPtr;              % window pointer
    end
    playPAh = S.PTB.Playback_pahandle; % playback audio pointer
    recPAh  = S.PTB.Record_pahandle;   % record   audio pointer
    
    
    %% Parallel port
    
    Common.PrepareParPort;
    
    
    %% Tunning of the task
    
    [ EP ] = DualTask.Planning( S );
    
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
    
    %% Prepare High bip and Low bip
    
    Common.PrepareBips
    Common.PrepareGoStop
    
    
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
                
                % Start audio capture immediately and wait for the capture to start.
                % We set the number of 'repetitions' to zero,
                % i.e. record until recording is manually stopped.
                PsychPortAudio('Start', recPAh, 0, 0, 1);
                WaitSecs(0.100);
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
                
            case 'Sequence'
                
                bipseq = EP.Data{evt,5};
                v = linspace(0, EP.Data{evt,3},length(bipseq)+1)+0.5;
                v_onset = v(1:end-1);
                
                needFlip = 0;
                revreset = 1;
                
                % ### Video ### %
                if S.Parameters.Type.Video
                    
                    Common.DrawHand
                    
                    Screen('DrawingFinished',wPtr);
                    vbl = Screen('Flip',wPtr, StartTime + EP.Data{evt,2} - S.PTB.slack);
                    
                else
                    vbl = WaitSecs('UntilTime',StartTime + EP.Data{evt,2} - S.PTB.anticipation);
                end
                
                ER.AddEvent({EP.Data{evt,1} vbl-StartTime [] [] []})
                
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
                    Common.DisplayInputsInCommandWindow
                    
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
