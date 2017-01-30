function [ TaskData ] = Task( S )

try
    %% Shortcuts
    
    wPtr = S.PTB.wPtr;
    
    
    %% Parallel port
    
    Common.PrepareParPort;
    
    
    %% Tunning of the task
    
    [ EP , Speed ] = Learning5432.Planning( S );
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    Common.PrepareRecorders;
    
    
    %% Record movie
    
    Common.Movie.CreateMovie;
    
    
    %% Start recording eye motions
    
    Common.StartRecordingEyelink;
    
    
    %% Load and prepare sprites for the hands
    
    img_path = 'img';
    img_file = [ img_path filesep 'left_hand.png' ];
    
    hand_color = [0 128 255 255]; % [R G B a] from 0 to 255
    
    LeftHand  = Hand(img_file, hand_color, false);
    LeftHand. MakeTexture(wPtr);
    
    RightHand = Hand(img_file, hand_color, true );
    RightHand.MakeTexture(wPtr);
    
    
    %% Scale and shift the Hands
    
    sizeOfSprite = 0.9* S.PTB.Width / 2;
    
    LeftHand. ReScale( sizeOfSprite / LeftHand. wPx );
    RightHand.ReScale( sizeOfSprite / RightHand.wPx );
    
    LeftHand.MoveCenter ( [ (1/4)*S.PTB.Width ; S.PTB.CenterV ] );
    RightHand.MoveCenter( [ (3/4)*S.PTB.Width ; S.PTB.CenterV ] );
    
    
    %% Prepare display of the fingers
    
    FingersLeftpos = [
        726 404 % 1
        454 74  % 2
        324 44  % 3
        180 132 % 4
        32 294  % 5
        ];
    
    fingers_color = [255 0 0 255];
    
    LeftFingers = Fingers(FingersLeftpos, fingers_color);
    RightFingers = Fingers(FingersLeftpos, fingers_color);
    
    LeftFingers.LinkToHand(LeftHand);
    RightFingers.LinkToHand(RightHand);
    
    RightFingers.FlipLR;
    
    LeftFingers.UpdatePos;
    RightFingers.UpdatePos;
    
    
    %% Go
    
    % Initialize some varibles
    pp = 0;
    keyCode = zeros(1,256);
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay;
        
        switch EP.Data{evt,1}
            
            case 'StartTime'
                
                Common.StartTimeEvent;
                
            case 'StopTime'
                
                Common.StopTimeEvent;
                
            case 'FixationCross'
                
                Common.DrawFixation
                
                Screen('DrawingFinished',wPtr);
                vbl = Screen('Flip',wPtr, StartTime + EP.Data{evt,2} - S.PTB.slack);
                ER.AddEvent({EP.Data{evt,1} vbl-StartTime})
                
            case 'Free'
                
                LeftHand.Draw;
                RightHand.Draw;
                
                Screen('DrawingFinished',wPtr);
                vbl = Screen('Flip',wPtr, StartTime + EP.Data{evt,2} - S.PTB.slack);
                ER.AddEvent({EP.Data{evt,1} vbl-StartTime})
                
                needFlip = 0;
                
                while ~keyCode(S.Parameters.Keybinds.Stop_Escape_ASCII)
                    
                    [keyIsDown, secs, keyCode] = KbCheck;
                    
                    if keyIsDown
                        
                        if any(keyCode(S.Parameters.Fingers.All))
                            
                            LeftHand.Draw;
                            RightHand.Draw;
                            
                            needFlip = 2;
                            
                            r = find(keyCode(S.Parameters.Fingers.Right));
                            l = find(keyCode(S.Parameters.Fingers.Left));
                            
                            if ~isempty(r)
                                RightFingers.Draw(r);
                            end
                            
                            if ~isempty(l)
                                LeftFingers. Draw(l);
                            end
                            
                        end
                        
                    end
                    
                    if needFlip == 2
                        
                        Screen('DrawingFinished',wPtr);
                        Screen('Flip',wPtr);
                        
                        needFlip = needFlip - 1;
                        
                    elseif needFlip == 1
                        
                        LeftHand.Draw;
                        RightHand.Draw;
                        
                        Screen('DrawingFinished',wPtr);
                        Screen('Flip',wPtr);
                        
                        needFlip = needFlip - 1;
                        
                    end
                    
                end
                
                
        end % switch
        
        
        
    end % for
    
    
    %% End of stimulation
    
    
    Common.EndOfStimulationScript;
    
    Common.Movie.FinalizeMovie;
    
    
catch err %#ok<*NASGU>
    
    Common.Catch;
    
end

end
