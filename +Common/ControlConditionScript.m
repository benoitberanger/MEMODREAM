vbl = StopStop.Playback(StartTime + EP.Data{evt,2} - S.PTB.anticipation);

% ### Video ### %
if S.Parameters.Type.Video
    Screen('DrawingFinished',wPtr);
    Screen('Flip',wPtr,  StartTime + EP.Data{evt,2} - S.PTB.slack);
end
% vbl = WaitSecs('UntilTime',StartTime + EP.Data{evt,2} - S.PTB.anticipation);

ER.AddEvent({EP.Data{evt,1} vbl-StartTime [] [] []})

if ~strcmp(EP.Data{evt-1,1},'StartTime')
    KL.GetQueue;
    switch S.Task
        case 'DualTask_Complex'
            Side = 'L';
        case 'DualTask_Simple'
            Side = 'L';
        case 'Learning5432'
            Side = EP.Data{evt-1,1};
    end
    results = Common.SequenceAnalyzer(EP.Data{evt-1,4}, Side, EP.Data{evt-1,3}, from, KL.EventCount, KL);
    from = KL.EventCount;
    ER.Data{evt-1,4} = results;
    disp(results)
end


% ### Video ### %
if S.Parameters.Type.Video
    PTBtimeLimit = StartTime + EP.Data{evt,2} + EP.Data{evt,3} - StopStop.duration - S.PTB.slack;
else
    PTBtimeLimit = StartTime + EP.Data{evt,2} + EP.Data{evt,3} - StopStop.duration - S.PTB.anticipation;
end

% The WHILELOOP below is a trick so we can use ESCAPE key to quit
% earlier.
while ~( keyCode(S.Parameters.Keybinds.Stop_Escape_ASCII) || ( secs > PTBtimeLimit ) )
    [~, secs, keyCode] = KbCheck;
end

Common.Interrupt

if ~strcmp(EP.Data{evt+1,1},'StopTime')
    GoGo.Playback(StartTime + EP.Data{evt+1,2} - GoGo.duration - S.PTB.anticipation);
end
