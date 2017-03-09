function [ EP , Speed ] = Planning( S )

%% Paradigme

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    
    S.Environement = 'MRI';
    
end

switch S.Environement
    
    case 'Training'
        Paradigme = {
            
        'Rest' 1
        'Free' 5 % arbitrary number
        'Rest' 1
        
        };
    
    case 'MRI'
        Paradigme = {
            
        'Rest'  10
        'Left'  20
        'Rest'  10
        'Right' 20
        'Rest'  10
        'Left'  20
        'Rest'  10
        'Right' 20
        'Rest'  10
        
        };
    
end


%% Define a planning <--- paradigme


% Create and prepare
header = { 'event_name' , 'onset(s)' , 'duration(s)' 'SequenceFingers(vect)' };
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


% --- Start ---------------------------------------------------------------

EP.AddPlanning({ 'StartTime' 0  0 [] });

% --- Stim ----------------------------------------------------------------

for p = 1 : size(Paradigme,1)
    
    EP.AddPlanning({ Paradigme{p,1} NextOnset(EP) Paradigme{p,2} '5432' });
    
end

% --- Stop ----------------------------------------------------------------

EP.AddPlanning({ 'StopTime' NextOnset(EP) 0 [] });


%% Acceleration

if nargout > 0
    
    switch S.OperationMode
        
        case 'Acquisition'
            
            Speed = 1;
            
        case 'FastDebug'
            
            Speed = 5;
            
            new_onsets = cellfun( @(x) {x/Speed} , EP.Data(:,2) );
            EP.Data(:,2) = new_onsets;
            
            new_durations = cellfun( @(x) {x/Speed} , EP.Data(:,3) );
            EP.Data(:,3) = new_durations;
            
        case 'RealisticDebug'
            
            Speed = 1;
            
        otherwise
            error( 'S.OperationMode = %s' , S.OperationMode )
            
    end
    
end


%% Display

% To prepare the planning and visualize it, we can execute the function
% without output argument

if nargout < 1
    
    fprintf( '\n' )
    fprintf(' \n Total stim duration : %g seconds \n' , NextOnset(EP) )
    fprintf( '\n' )
    
    EP.Plot
    
end
