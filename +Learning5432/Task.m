function [ TaskData ] = Task( S )

try
    %% Shortcuts
    wPtr = S.PTB.wPtr;
    
    
    %% Parallel port
    
    Common.PrepareParPort;
    
    
    %% Load and prepare all stimuli
    
%     Session.LoadStimuli;
%     Session.PrepareStimuli;
    
    
    %% Tunning of the task
    
%     [ EP , Stimuli , Speed ] = Session.Planning( S , Stimuli ); %#ok<NODEF>
%     
%     % End of preparations
%     EP.BuildGraph;
%     TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
%     Common.PrepareRecorders;
    
    
    %% Record movie
    
    Common.Movie.CreateMovie;
    
    
    %% Start recording eye motions
    
    Common.StartRecordingEyelink;
    
    
    %% Load and prepare sprites
    
    img_path = 'img';
    
    % MakeTexture_specialFlags = bin2dec('0 0 0 1 1 1'); % See Screen('MakeTexture?')
    % DrawTexture_specialFlags = 4                     ; % See Screen('DrawTexture?')
    MakeTexture_specialFlags = []; % See Screen('MakeTexture?')
    DrawTexture_specialFlags = []; % See Screen('DrawTexture?')
    
    % glsl = MakeTextureDrawShader(DataStruct.PTB.Window, 'SeparateAlphaChannel' );
    glsl = [];
    
%     if exist('LeftHand.texture','var')
%         Screen('Close',LeftHand.texture)
%     end
%     if exist('RightHand.texture','var')
%         Screen('Close',RightHand.texture)
%     end
%     
%     [~,~,LeftHand.alpha] = imread( [ img_path filesep 'left_hand.png' ] );
%     LeftHand.wPx         = size(LeftHand.alpha,1);
%     LeftHand.hPx         = size(LeftHand.alpha,2);
%     LeftHand.color       = [0 0 255];
%     LeftHand.foreground  = LeftHand.alpha > 10;
%     LeftHand.alpah_image = uint8( cat( 3, LeftHand.foreground*LeftHand.color(1) , LeftHand.foreground*LeftHand.color(2) , LeftHand.foreground*LeftHand.color(3) , LeftHand.foreground*255 ) );
%     LeftHand.texture     = Screen( 'MakeTexture' , wPtr , LeftHand.alpah_image ,[] , MakeTexture_specialFlags , [] , [] , glsl );
    

    LeftHand  = Hand([ img_path filesep 'left_hand.png' ], false);
    LeftHand. MakeTexture(wPtr);

    RightHand = Hand([ img_path filesep 'left_hand.png' ], true );
    RightHand.MakeTexture(wPtr);

    
    %%
    
    FingersLeft = [
        726 404 % 1
        454 74  % 2
        324 44  % 3
        180 132 % 4
        32 294  % 5
        ];
    
    FingersRight = [LeftHand.wPx - FingersLeft(:,1) , FingersLeft(:,2) ];
    
    scalefactor = 0.8;

    LeftHand.ReScale(scalefactor);
    RightHand.ReScale(scalefactor);
    
    %%
    
    res = [1024 768];
    
    LeftHand.MoveCenter(rand(1,2).*res);
    RightHand.MoveCenter(rand(1,2).*res);
    
    FingerLeftRects = CenterRectOnPoint([0 0 100 100] , FingersLeft(:,1) , FingersLeft(:,2) )';
    FingerRightRects = CenterRectOnPoint([0 0 100 100] , FingersRight(:,1) , FingersRight(:,2) )';
    RingerColors = repmat([255 0 0 180], [5 1] )';
    
    ScaledFingerLeftRects = ScaleRect(FingerLeftRects',scalefactor,scalefactor)';
    ScaledFingerRightRects = ScaleRect(FingerRightRects',scalefactor,scalefactor)';
    
    
    Screen('DrawTexture',wPtr,LeftHand.texture,[],LeftHand.rect);
    Screen('FillOval', wPtr , RingerColors , ScaledFingerLeftRects );
    
    Screen('DrawTexture',wPtr,RightHand.texture,[],RightHand.rect);
    Screen('FillOval', wPtr , RingerColors , ScaledFingerRightRects );
    
    
    Screen('Flip',wPtr);
    
   
    
    0
    
    
    %% Go
    
    
%     event_onset = 0;
%     Exit_flag = 0;
%     pp = 0;
%     
%     % Loop over the EventPlanning
%     for evt = 1 : size( EP.Data , 1 )
%         
%         switch EP.Data{evt,1}
%             
%             case 'StartTime'
%                 
%                 Common.StartTimeEvent;
%                 
%             case 'StopTime'
%                 
%                 Common.StopTimeEvent;
%                 
%             otherwise
%                 
%                 frame_counter = 0;
%                 
%                 % In the planning we have events with duration=0. So, they
%                 % don't get go inside the whileloop. But we still need to
%                 % record their occurence with a fake onset : we modify it
%                 % latter
%                 if ~(event_onset < StartTime + EP.Data{evt+1,2} - S.PTB.slack * 1)
%                     ER.AddEvent({ EP.Data{evt,1} [] })
%                     Common.CommandWindowDisplay
%                 end
%                 
%                 while event_onset < StartTime + EP.Data{evt+1,2} - S.PTB.slack * 1
%                     
%                     frame_counter = frame_counter + 1;
%                     
%                     % ESCAPE key pressed ?
%                     Common.Interrupt;
%                     
%                     switch EP.Data{evt,1}
%                         
%                         case 'cross'
%                             Common.DrawFixation;
%                             event_onset = Screen('Flip',wPtr);
%                             
%                         case 'blackscreen'
%                             event_onset = Screen('Flip',wPtr);
%                             
%                         case 'word'
%                             DrawFormattedText(wPtr,EP.Data{evt,4},'center','center');
%                             event_onset = Screen('Flip',wPtr);
%                             
%                         case 'img'
%                             Screen('DrawTexture',wPtr,EP.Data{evt,4});
%                             event_onset = Screen('Flip',wPtr);
%                             
%                         case 'wav'
%                             if frame_counter == 1
%                                 PsychPortAudio('FillBuffer',S.PTB.Playback_pahandle,[EP.Data{evt,4} EP.Data{evt,4}]');
%                                 event_onset = PsychPortAudio('Start',S.PTB.Playback_pahandle,[],StartTime + EP.Data{evt,2},1);
%                             else
%                                 event_onset = GetSecs;
%                             end
%                             
%                         otherwise
%                             event_onset = GetSecs;
%                             % error('Unrecognzed condition : %s',EP.Data{evt,1})
%                             
%                     end
%                     
%                     Common.Movie.AddFrameToMovie;
%                     
%                     if frame_counter == 1
%                         
%                         if evt > 2
%                             Common.SendParPortMessage
%                         end
%                         
%                         % Modification of the onset of the events with
%                         % duration=0. We force them to have the same real
%                         % onset, and still a duration of 0.
%                         if EP.Data{evt-1,3} == 0
%                             ER.Data{evt-1,2} = event_onset-StartTime;
%                         end
%                         % Save onset
%                         ER.AddEvent({ EP.Data{evt,1} event_onset-StartTime })
%                     end
%                     
%                 end % while
%                 
%                 PsychPortAudio('Stop',S.PTB.Playback_pahandle);
%                 
%         end % switch
%         
%         if Exit_flag
%             break %#ok<*UNRCH>
%         end
%         
%         
%     end % for
    
    
    %% End of stimulation
    
    
%     Common.EndOfStimulationScript;
    
    Common.Movie.FinalizeMovie;
    
    
catch err %#ok<*NASGU>
    
    Common.Catch;
    
end

end
