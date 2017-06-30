function [ TriggerTime ] = WaitForTTL
global S

if strcmp(S.OperationMode,'Acquisition')
    
    if ~isfield(S,'StartTime') % It means wait for 1st TTL @ Begining of stimulation
        
        disp('----------------------------------')
        disp('      Waiting for trigger "t"     ')
        disp('                OR                ')
        disp('   Press "s" to emulate trigger   ')
        disp('      Press "Escape" to abort     ')
        disp('----------------------------------')
        disp(' ')
        
    else % All other cases
        
        disp('Waiting for TTL')
        
    end
    
    for d = 1:S.Parameters.Sync.DiscardVolume
        
        fprintf('Discard volume %d/%d \n',d,S.Parameters.Sync.DiscardVolume)
        
        % Just to be sure the user is not pushing a button before
        WaitSecs(0.200); % secondes
        
        % Waiting for TTL signal
        while 1
            
            [ keyIsDown , TriggerTime, keyCode ] = KbCheck;
            
            if keyIsDown
                
                switch S.Environement
                    
                    case 'MRI'
                        
                        if keyCode(S.Parameters.Keybinds.TTL_t_ASCII) || keyCode(S.Parameters.Keybinds.emulTTL_s_ASCII)
                            break
                            
                        elseif keyCode(S.Parameters.Keybinds.Stop_Escape_ASCII)
                            
                            % Eyelink mode 'On' ?
                            if strcmp(S.EyelinkMode,'On')
                                Eyelink.STOP % Stop wrapper
                            end
                            
                            sca
                            stack = dbstack;
                            error('WaitingForTTL:Abort','\n ESCAPE key : %s aborted \n',stack.file)
                            
                        end
                        
                    case 'Training'
                        
                        if keyCode(S.Parameters.Keybinds.Right_Blue_b_ASCII) || keyCode(S.Parameters.Keybinds.TTL_t_ASCII) || keyCode(S.Parameters.Keybinds.emulTTL_s_ASCII)
                            break
                            
                        elseif keyCode(S.Parameters.Keybinds.Stop_Escape_ASCII)
                            
                            % Eyelink mode 'On' ?
                            if strcmp(S.EyelinkMode,'On')
                                Eyelink.STOP % Stop wrapper
                            end
                            
                            sca
                            stack = dbstack;
                            error('WitingForTTL:Abort','\n ESCAPE key : %s aborted \n',stack.file)
                            
                        end
                        
                end % switch
                
            end
            
        end % while
        
    end % for
    
    
else % in DebugMod
    
    disp('Waiting for TTL : DebugMode')
    
    TriggerTime = GetSecs;
    
end

end
