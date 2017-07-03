function [ TaskData ] = Task
global S

try
    %% Parallel port
    
    TaskData.ParPortMessages = Common.PrepareParPort;
    
    
    %% Tunning of the task
    
    [ EP ] = SpeedTest.Planning;
    
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
    
    % Just in case, for leagcy purpose
    WhiteCross = [];
    
    
    %% Prepare High bip and Low bip
    
    [ GoGo  , StopStop ] = Common.PrepareGoStop;
    
    
    %% Go
    
    % Initialize some varibles
    Exit_flag = 0;
    from      = 1;
    
    Left = S.Parameters.Fingers.Left; % shortcut
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay( EP, evt );
        
        switch EP.Data{evt,1}
            
            case 'StartTime'
                
                StartTime = Common.StartTimeEvent( WhiteCross );
                
            case 'StopTime'
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
            case 'Rest'
                
                stopOnset = StopStop.Playback();
                
                ER.AddEvent({EP.Data{evt,1} stopOnset-StartTime [] [] []})
                
                if ~strcmp(EP.Data{evt-1,1},'StartTime')
                    KL.GetQueue;
                    
                    results = Common.SequenceAnalyzer(EP.Data{evt-1,4}, 'L', EP.Data{evt-1,3}, from, KL.EventCount, KL);
                    from = KL.EventCount;
                    ER.Data{evt-1,4} = results;
                    disp(results)
                end
                
                PTBtimeLimit = stopOnset + EP.Data{evt,3} - GoGo.duration - S.PTB.anticipation;
                
                % The WHILELOOP below is a trick so we can use ESCAPE key to quit
                % earlier.
                keyCode = zeros(1,256);
                secs = stopOnset;
                while ~( keyCode(S.Parameters.Keybinds.Stop_Escape_ASCII) || ( secs > PTBtimeLimit ) )
                    [~, secs, keyCode] = KbCheck;
                end
                
                [ Exit_flag, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                if Exit_flag
                    return
                end
                
                if ~strcmp(EP.Data{evt+1,1},'StopTime')
                    GoGo.Playback(PTBtimeLimit);
                end
                
                
            case 'Sequence'
                
                ER.AddEvent({EP.Data{evt,1} GetSecs-StartTime [] [] []})
                
                % 1 : display like "0 1 0 0 0 | 0 0 0 0 0 ", single ligne refreshed
                % 2 : (multiline display)
                %
                % 5
                % 4
                % 3
                % 2
                % 2 <-
                % 3 <-
                % 4 <-
                % 5
                
                dislpayKind = 2;
                
                switch dislpayKind
                    
                    case 2
                        
                        seq_num = EP.Data{evt,4}; % sequence
                        
                        next_input = seq_num(1); % initilization
                        
                        KbVect_prev = zeros(size(Left));
                        % KbVect_curr = zeros(size(Left));
                        % KbVect_diff = zeros(size(Left));
                        
                end
                
                tap = 0;
                while tap < EP.Data{evt,3}
                    
                    [keyIsDown, ~, keyCode] = KbCheck;
                    
                    switch dislpayKind
                        
                        case 2
                            
                            KbVect_curr = keyCode(Left);
                            KbVect_diff = KbVect_curr - KbVect_prev;
                            KbVect_prev = KbVect_curr;
                            
                            new_input = find(KbVect_diff==1);
                            
                            if ~isempty(new_input) && isscalar(new_input)
                                
                                if new_input == str2double(next_input)
                                    fprintf('%d\n',new_input)
                                    seq_num = circshift(seq_num,[0 -1]);
                                    next_input = seq_num(1);
                                else
                                    fprintf('%d <-\n',new_input)
                                end
                                tap = tap+1;
                                
                            end
                            
                        case 1
                            
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
                            
                    end
                    
                    if keyIsDown
                        
                        [ Exit_flag, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if Exit_flag
                            return
                        end
                        
                    end
                    
                end % while
                
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
    
    Common.Movie.FinalizeMovie( moviePtr );
    
    
catch err
    
    Common.Catch( err );
    
end

end % function
