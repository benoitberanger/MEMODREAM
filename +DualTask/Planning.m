function [ EP ] = Planning
global S

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    S.Task          = 'DualTask_Complex';
    S.Environement  = 'MRI';
    S.OperationMode = 'Acquisition';
    S.Sequence      = '';
end


%% Paradigme

switch S.Environement
    case 'Training'
        NrBlocks      = 1;
        RestDuration  = 5; % seconds
    case 'MRI'
        NrBlocks      = 4;
        RestDuration  = 15; % seconds
end

BLockDuration = 30; % seconds
NrHighLow     = 10;

switch S.OperationMode
    case 'Acquisition'
    case 'FastDebug'
        NrBlocks      = 2;
        BLockDuration = 5; % seconds
        NrHighLow     = 1;
        RestDuration  = 3; % seconds
    case 'RealisticDebug'
end

switch S.Task
    case 'DualTask_Complex'
        Difficulty      = 'Complex';
        SequenceFingers = S.Sequence;
    case 'DualTask_Simple'
        Difficulty      = 'Simple';
        SequenceFingers = '5432';
end


%% Backend setup

Paradigme = { 'Rest' RestDuration [] [] }; % initilaise the container

for n = 1:NrBlocks
    
    SequenceHighLow = Common.Randomize01(NrHighLow, NrHighLow);
    
    Paradigme  = [ Paradigme ; { Difficulty BLockDuration SequenceFingers SequenceHighLow } ; { 'Rest' RestDuration [] [] } ]; %#ok<AGROW>
    
end


%% Define a planning <--- paradigme


% Create and prepare
header = { 'event_name' , 'onset(s)' , 'duration(s)' 'SequenceFingers(vect)' 'SequenceHighLow(vect)'};
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


% --- Start ---------------------------------------------------------------

EP.AddPlanning({ 'StartTime' 0  0 [] [] });

% --- Stim ----------------------------------------------------------------

for p = 1 : size(Paradigme,1)
    
    EP.AddPlanning({ Paradigme{p,1} NextOnset(EP) Paradigme{p,2} Paradigme{p,3} Paradigme{p,4}});
    
end

% --- Stop ----------------------------------------------------------------

EP.AddPlanning({ 'StopTime' NextOnset(EP) 0 [] [] });


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
