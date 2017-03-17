close all
clear all
clc



%% keys

KbName('UnifyKeyNames');

esc    = KbName('ESCAPE');

Left (1) = KbName('v'); % Thumb, not on the response buttons, arbitrary number
Left (2) = KbName('f'); % Index finger
Left (3) = KbName('d'); % Middle finger
Left (4) = KbName('s'); % Ring finger
Left (5) = KbName('q'); % Little finger

Right(1) = KbName('b'); % Thumb, not on the response buttons, arbitrary number
Right(2) = KbName('h'); % Index finger
Right(3) = KbName('j'); % Middle finger
Right(4) = KbName('k'); % Ring finger
Right(5) = KbName('l'); % Little finger

All      = [fliplr(Left) Right];
Names    = {'L5' 'L4' 'L3' 'L2' 'L1' 'R1' 'R2' 'R3' 'R4' 'R5'};


%% Init loop
[keyIsDown, secs, keyCode] = KbCheck;
revreset = 1;

% seq = '5432';
seq = '2345';
for s = 1 : length(seq)
    if s == 1
        seq_spaced = seq(1);
    else
        seq_spaced = [seq_spaced ' ' seq(s)]; %#ok<AGROW>
    end
end
seq_num = str2num(seq_spaced); %#ok<ST2NM>

next_input = seq_num(1);

KbVect_prev = zeros(size(Left));
KbVect_curr = zeros(size(Left));
KbVect_diff = zeros(size(Left));


%% Loop

fprintf('Sequence to perform : %s \n',seq_spaced)

while ~keyCode(esc)
    
    [keyIsDown, secs, keyCode] = KbCheck;
    
    KbVect_curr = keyCode(Left);
    KbVect_diff = KbVect_curr - KbVect_prev;
    KbVect_prev = KbVect_curr;
    
    new_input = find(KbVect_diff==1);
    
    if ~isempty(new_input) && isscalar(new_input)
        
        if new_input == next_input
            fprintf('%d\n',new_input)
            seq_num = circshift(seq_num,[0 -1]);
            next_input = seq_num(1);
        else
            fprintf('%d <-\n',new_input)
        end
        
        %         msg = sprintf([repmat('%d ',[1 4]) '\n'],...
        %             keyCode(Left (5)),...
        %             keyCode(Left (4)),...
        %             keyCode(Left (3)),...
        %             keyCode(Left (2)) ...
        %             );
        %         fprintf(msg);
        
    end
    
    %     WaitSecs(0.050);
    
    %     msg = sprintf([repmat('%d ',[1 5]) '| ' repmat('%d ',[1 5]) '\n'],...
    %         keyCode(Left (5)),...
    %         keyCode(Left (4)),...
    %         keyCode(Left (3)),...
    %         keyCode(Left (2)),...
    %         keyCode(Left (1)),...
    %         keyCode(Right(1)),...
    %         keyCode(Right(2)),...
    %         keyCode(Right(3)),...
    %         keyCode(Right(4)),...
    %         keyCode(Right(5)) ...
    %         );
    %     revfprintf(msg,revreset)
    %     revreset = 0;
    
    
    
end % while

fprintf('\n')
