function [ names , onsets , durations ] = SPMnod( S )
%SPMNOD Build 'names', 'onsets', 'durations' for SPM

EchoStart(mfilename)

try
    %% Preparation
    
    % 'names' for SPM
    switch S.Task
        
        case 'EyelinkCalibration'
            names = {'EyelinkCalibration'};
            
        case 'Task1'
            names = {
                '';
                };
            
        case 'Task2'
            names = {
                '';
                };
            
        case 'Task3'
            names = {
                ''
                };
            
    end
    
    % 'onsets' & 'durations' for SPM
    onsets    = cell(size(names));
    durations = cell(size(names));
    
    % Shortcut
    EventData = S.TaskData.ER.Data;
    
    
    %% Onsets building
    
    for event = 1:size(EventData,1)
        
        switch EventData{event,1}
            
            case 'Horizontal_Checkerboard'
                onsets{1} = [onsets{1} ; EventData{event,2}];
            case 'Vertical_Checkerboard'
                onsets{2} = [onsets{2} ; EventData{event,2}];
        end
        
    end
    
    
    %% Durations building
    
    % +1 because Event_Like_This is one line but with duration=0
    % +1 if we incorporate the cross~=rest time a the end of each trial
    offcet = 1 ;
    
    for event = 1:size(EventData,1)
        
        switch EventData{event,1}
            
            case 'Horizontal_Checkerboard'
                durations{1} = [ durations{1} ; EventData{event+8+offcet,2}-EventData{event,2}] ;
            case 'Vertical_Checkerboard'
                durations{2} = [ durations{2} ; EventData{event+8+offcet,2}-EventData{event,2}] ;
        end
        
    end
    
    
    %% Add Catch trials and Clicks
    
    if ~strcmp(S.Task,'EyelinkCalibration')
        
        N = length(names);
        
        % CLICK
        
        clic_spot.R = regexp(S.TaskData.KL.KbEvents(:,1),KbName(S.Parameters.Keybinds.Right_Blue_b_ASCII));
        clic_spot.R = ~cellfun(@isempty,clic_spot.R);
        clic_spot.R = find(clic_spot.R);
        
        clic_spot.L = regexp(S.TaskData.KL.KbEvents(:,1),KbName(S.Parameters.Keybinds.Left_Yellow_y_ASCII));
        clic_spot.L = ~cellfun(@isempty,clic_spot.L);
        clic_spot.L = find(clic_spot.L);
        
        count = 0 ;
        Sides = {'R' ; 'L'};
        for side = 1:length(Sides)
            
            count = count + 1 ;
            
            switch side
                case 1
                    names{N+count} = 'CLICK_right';
                case 2
                    names{N+count} = 'CLICK_left';
            end
            
            if ~isempty(S.TaskData.KL.KbEvents{clic_spot.(Sides{side}),2})
                clic_idx = cell2mat(S.TaskData.KL.KbEvents{clic_spot.(Sides{side}),2}(:,2)) == 1;
                clic_idx = find(clic_idx);
                % the last click can be be unfinished : button down + end of stim = no button up
                if isempty(S.TaskData.KL.KbEvents{clic_spot.(Sides{side}),2}{clic_idx(end),3})
                    S.TaskData.KL.KbEvents{clic_spot.(Sides{side}),2}{clic_idx(end),3} =  S.TaskData.ER.Data{end,2} - S.TaskData.KL.KbEvents{clic_spot.(Sides{side}),2}{clic_idx(end),1};
                end
                onsets{N+count}    = cell2mat(S.TaskData.KL.KbEvents{clic_spot.(Sides{side}),2}(clic_idx,1));
                durations{N+count} = cell2mat(S.TaskData.KL.KbEvents{clic_spot.(Sides{side}),2}(clic_idx,3));
            else
                onsets{N+count}    = [];
                durations{N+count} = [];
            end
            
        end
        
    end
    
    
catch err
    
    sca
    rethrow(err)
    
end

EchoStop(mfilename)

end
