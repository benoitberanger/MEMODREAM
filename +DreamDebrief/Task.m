function [ TaskData ] = Task
global S

try
    %% Shortcuts
    
    recPAh  = S.PTB.Record_pahandle;   % record   audio pointer
    
    %% Prepare stuff
    
    % Create and prepare
    header = { 'event_name' , 'onset(s)' , 'duration(s)'};
    EP     = EventPlanning(header);
    % NextOnset = PreviousOnset + PreviousDuration
    NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};
    % --- Start ---------------------------------------------------------------
    EP.AddPlanning({ 'StartTime' 0  0 });
    % --- Stim ----------------------------------------------------------------
    % --- Stop ----------------------------------------------------------------
    EP.AddPlanning({ 'StopTime' NextOnset(EP) 0});
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    [ ER, RR, KL ] = Common.PrepareRecorders( EP );
    
    % Signal
    audiodata = [];
    
    % Plot the signal
    ax = axes;
    drawnow
    
    
    %% Start recording
    
    StartTime = Common.StartTimeEvent;
    
    % Start audio capture immediately and wait for the capture to start.
    % We set the number of 'repetitions' to zero,
    % i.e. record until recording is manually stopped.
    PsychPortAudio('Start', recPAh, 0, 0, 1);
    
    fprintf('Recording started...\n')
    fprintf('Pres ESCAPE to stop the record\n')
    
    %% Record...
    
    while 1
        WaitSecs(1.000); % seconds
        
        % Perform a fetch operation to get all data from the capture engine:
        newdata = PsychPortAudio('GetAudioData', recPAh);
        
        audiodata = [audiodata newdata]; %#ok<AGROW>
        
        plot(ax,newdata);
        drawnow
        
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown && keyCode(S.Parameters.Keybinds.Stop_Escape_ASCII)
            break
        end
        
    end
    
    [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, 2 );
    
    
    %% End
    
    TaskData.audiodata = audiodata;
    TaskData = Common.EndOfStimulation( TaskData, EP, ER, RR, KL, StartTime, StopTime );
    
    
catch err
    
    Common.Catch( err );
    
end

end % function
