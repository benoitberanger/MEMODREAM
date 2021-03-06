function [ EP ] = Planning
global S

%% Paradigme

numberConsecutiveGoogSequences = 5;
RestDuration                   = 3; % secondes


%% Backend setup

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    S.ComplexSequence = '';
end

Paradigme = { 'Rest' RestDuration [] }; % initilaise the container

for n = 1:1
    
    Paradigme  = [ Paradigme ; { 'Free' numberConsecutiveGoogSequences S.ComplexSequence } ; { 'Rest' RestDuration [] } ]; %#ok<AGROW>
    
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
