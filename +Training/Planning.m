function [ EP ] = Planning
global S

%% Paradigme

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    S.Environement  = 'MRI';
    S.OperationMode = 'Acquisition';
    S.Sequence      = '';
end

switch S.Environement
    case 'Training'
        NrBlocksSimple  = 2;
        NrBlocksComplex = 2;
        NrTaps          = 60;
    case 'MRI'
        NrBlocksSimple  = 14;
        NrBlocksComplex = 14;
        NrTaps          = 60;
end

BLockDuration = NrTaps; % in Taps, no secondes
RestDuration  = 10    ; % in seconds

switch S.OperationMode
    case 'Acquisition'
    case 'FastDebug'
        NrBlocksSimple  = 1;
        NrBlocksComplex = 1;
        BLockDuration   = 5;  % in Taps, no secondes
        RestDuration    = 3;  % in seconds
    case 'RealisticDebug'
        NrBlocksSimple  = 2;
        NrBlocksComplex = 2;
        BLockDuration   = 10;  % in Taps, no secondes
        RestDuration    = 5;  % in seconds
end

Paradigme = { 'Rest' RestDuration [] }; % initilaise the container

blocksOrder = Common.Randomize01( NrBlocksSimple, NrBlocksComplex );

for b = 1:length(blocksOrder)
    
    switch blocksOrder(b)
        
        case 0
            Paradigme  = [ Paradigme ; { 'Simple'  BLockDuration '5432'     } ; { 'Rest' RestDuration [] } ]; %#ok<AGROW>
        case 1
            Paradigme  = [ Paradigme ; { 'Complex' BLockDuration S.Sequence } ; { 'Rest' RestDuration [] } ]; %#ok<AGROW>
    end
    
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
