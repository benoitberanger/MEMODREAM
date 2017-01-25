% Eyelink mode 'On' ?
switch S.EyelinkMode
    case 'On'
        
        % Acquisition ?
        switch S.OperationMode
            
            case 'Acquisition'
                Eyelink.StartRecording( S.EyelinkFile );
                
            otherwise
                error('Task:EyelinkWithourAcquisition','\n Eyelink mode should be ''Off'' if not in Acquisition mode \n')
                
        end
        
    case 'Off'
    otherwise
end
