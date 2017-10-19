function [ EP ] = Planning
global S

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    S.Environement  = 'MRI';
    S.OperationMode = 'Acquisition';
    S.ComplexSequence      = '';
end


%% Paradigme

switch S.Environement
    case 'Practice'
        NrBlocks = 4;
        NrTaps   = 60;
    case 'MRI'
        NrBlocks = 4;
        NrTaps   = 60;
end

RestDuration  = 10 ; % in seconds

switch S.OperationMode
    case 'Acquisition'
    case 'FastDebug'
        NrBlocks      = 2;
        NrTaps        = 5;
        RestDuration  = 3;  % in seconds
    case 'RealisticDebug'
        NrBlocks      = 2 ;
        NrTaps        = 10;
        RestDuration  = 5 ; % in seconds
end

Paradigme = { 'Rest' RestDuration [] }; % initilaise the container

for n = 1:NrBlocks
    
    Paradigme  = [ Paradigme ; { 'Complex' NrTaps S.ComplexSequence } ; { 'Rest' RestDuration [] } ]; %#ok<AGROW>
    
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
    
    EP.AddPlanning({ Paradigme{p,1} NextOnset(EP) Paradigme{p,2} Paradigme{p,3} });
    
end

% --- Stop ----------------------------------------------------------------

EP.AddPlanning({ 'StopTime' NextOnset(EP) 0 [] });


%% Display

% To prepare the planning and visualize it, we can execute the function
% without output argument

if nargout < 1
    
    fprintf( '\n' )
    fprintf(' \n Total stim duration : %g seconds \n' , NextOnset(EP) )
    fprintf( '\n' )
    
    EP.Plot
    
end

end % function
