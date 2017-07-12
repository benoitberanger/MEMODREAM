function [ Exit_flag, StopTime ] = DisplayInputsInCommandWindow( EP, ER, RR, evt, StartTime, limitType, limitValue )
global S


% 5
% 4
% 3
% 2
% 2 <-
% 3 <-
% 4 <-
% 5

%% Ouput var

Exit_flag = 0;
StopTime = [];


%% Initialize the count-by-difference

seq_num = EP.Data{evt,4}; % sequence

next_input = seq_num(1); % initilization

Left = S.Parameters.Fingers.Left; % shortcut

KbVect_prev = zeros(size(Left));


%% Loop

% Initialization for the whileloop
secs = GetSecs;
tap  = 0;
switch limitType
    case 'tap'
        condition = tap  < limitValue;
    case 'time'
        condition = secs < limitValue;
end

while condition
    
    [keyIsDown, secs, keyCode] = KbCheck;
    
    % Compare last input with current unpur
    KbVect_curr = keyCode(Left);
    KbVect_diff = KbVect_curr - KbVect_prev;
    KbVect_prev = KbVect_curr;
    new_input   = find(KbVect_diff==1);
    
    % New value
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
    
    % Escape ?
    if keyIsDown
        [ Exit_flag, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
        if Exit_flag
            return
        end
    end
    
    % Refresh condition
    switch limitType
        case 'tap'
            condition = tap  < limitValue;
        case 'time'
            condition = secs < limitValue;
    end
    
end % while

end % function
