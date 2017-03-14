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
        %     Common.PrepareFixationCross
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
                
                Common.StartTimeEvent;
                
            case 'StopTime'
                
                Common.StopTimeEvent;
                
            case 'Rest'
                
                % ### Video ### %
                if S.Parameters.Type.Video
                    Common.FillBackGround
                end
                
                % Wrapper for the control condition. It's a script itself,
                % used across several tasks
                Common.ControlConditionScript
                
            case 'Sequence'
                
                bipseq = EP.Data{evt,5};
                v = linspace(0, EP.Data{evt,3},length(bipseq)+1);
                v_onset = v(1:end-1);
                
                for b = 1 : length(bipseq)
                    
                    switch bipseq(b)
                        case 1 % high bip
                            last_onset = HighBip.Playback(StartTime + EP.Data{evt,2} + v_onset(b));
                        case 0 % low bip
                            last_onset = LowBip. Playback(StartTime + EP.Data{evt,2} + v_onset(b));
                    end
                    
                    if b == 1
                        ER.AddEvent({EP.Data{evt,1} last_onset-StartTime [] []})
                    end
                    
                end
                
                
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
