%% Prepare event record

% Create
ER = EventRecorder( { 'event_name' , 'onset(s)' , 'durations(s)' , 'results' } , size(EP.Data,1) );

% Prepare
ER.AddStartTime( 'StartTime' , 0 );


%% Response recorder

% Create
RR = EventRecorder( { 'event_name' , 'onset(s)' , 'duration(s)' , 'content' } , 50000 ); % high arbitrary value : preallocation of memory

% Prepare
RR.AddEvent( { 'StartTime' , 0 , 0 , [] } );


%% Prepare the logger of MRI triggers

KbName('UnifyKeyNames');

KL = KbLogger( ...
    [ struct2array(S.Parameters.Keybinds) S.Parameters.Fingers.All ] ,...
    [ KbName(struct2array(S.Parameters.Keybinds)) S.Parameters.Fingers.Names ] );

% Start recording events
KL.Start;
