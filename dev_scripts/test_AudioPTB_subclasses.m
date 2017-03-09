close all
clear all
clc
% try
%     PsychPortAudio('close')
% catch err
% end
clear classes

fs = 44100;


%%

bip = Bip( fs , 440 ,  1000 , 0.25 );
bip.Plot
% bip.PlayInMatlab


%%

gogo = Wav(['wav' filesep 'GoGo.wav']);
gogo
gogo.Resample(fs);
gogo
gogo.Plot
% gogo.PlayInMatlab
