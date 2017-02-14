Screen('DrawingFinished',wPtr);
vbl = Screen('Flip',wPtr, StartTime + EP.Data{evt,2} - S.PTB.slack);
ER.AddEvent({EP.Data{evt,1} vbl-StartTime [] []})

if ~strcmp(EP.Data{evt-1,1},'StartTime')
    KL.GetQueue;
    results = Common.SequenceAnalyzer(EP.Data{evt-1,4}, EP.Data{evt-1,1}, EP.Data{evt-1,3}, from, KL.EventCount, KL);
    from = KL.EventCount;
    ER.Data{evt-1,4} = results;
end

% The WHILELOOP below a trick so we can use ESCAPE key to quit
% earlier.
while ~( keyCode(S.Parameters.Keybinds.Stop_Escape_ASCII) || ( secs > StartTime + EP.Data{evt,2} + EP.Data{evt,3} - S.PTB.slack ) )
    [~, secs, keyCode] = KbCheck;
end

Common.Interrupt
