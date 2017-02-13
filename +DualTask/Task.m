function [ TaskData ] = Task( S )

try
    %% Shortcuts
    
    wPtr = S.PTB.wPtr;              % window pointer
    aPtr = S.PTB.Playback_pahandle; % audio pointer
    
    
    %% Parallel port
    
    Common.PrepareParPort;
    
    
    %% Tunning of the task
    
    [ EP , Speed ] = DualTask.Planning( S );
    
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
    
    Common.PrepareHandsFingers
%     Common.PrepareFixationCross
    
    
    %% Prepare High bip and Low bip
    
    Common.PrepareBips
    
    
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
                
            case 'Rest'
                
                Common.FillBackGround
                
                % Wrapper for the control condition. It's a script itself,
                % used across several tasks
                Common.ControlConditionScript
                
                
            case 'Sequence'
                
                
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
