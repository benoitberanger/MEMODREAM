function [ ER, from, Exit_flag, StopTime ] = ControlCondition( EP, ER, RR, KL, StartTime, from, audioObj, evt, limitType )
global S

switch limitType
    case 'tap'
        stopOnset = audioObj.StopStop.Playback();
    case 'time'
        stopOnset = audioObj.StopStop.Playback(StartTime + EP.Data{evt,2} - S.PTB.anticipation);
end

% vbl = WaitSecs('UntilTime',StartTime + EP.Data{evt,2} - S.PTB.anticipation);

ER.AddEvent({EP.Data{evt,1} stopOnset-StartTime [] [] []})

if ~strcmp(EP.Data{evt-1,1},'StartTime')
    KL.GetQueue;
    %     switch S.Task
    %         case 'DualTask_Complex'
    %             Side = 'L';
    %         case 'DualTask_Simple'
    %             Side = 'L';
    %         case 'Learning5432'
    %             Side = EP.Data{evt-1,1};
    %         case 'SpeedTest'
    %             Side = 'L';
    %     end
    results = Common.SequenceAnalyzer(EP.Data{evt-1,4}, 'L', EP.Data{evt-1,3}, from, KL.EventCount, KL);
    from = KL.EventCount;
    ER.Data{evt-1,4} = results;
    disp(results)
end

PTBtimeLimit = stopOnset + EP.Data{evt,3} - audioObj.GoGo.duration - S.PTB.anticipation;

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
    
    switch EP.Data{evt+1,1}
        case 'Simple'
            audioObj.SimpleSimple.Playback(PTBtimeLimit);
        case 'Complex'
            audioObj.ComplexComplex.Playback(PTBtimeLimit);
        otherwise
            error('')
    end
    
end

end % function
