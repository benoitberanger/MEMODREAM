close all
clear all
clc
try
    PsychPortAudio('close')
catch err
end

fs = 44100;


%%

obj = Bip( fs , 440 ,  1 , 0.25 );


%%

InitializePsychSound(1);

pahandle = PsychPortAudio('Open', [], [], 0, fs, 1 );

%%

obj.LinkToPAhandle(pahandle)


%%

obj.Plot
obj.Playback(0);


%%

