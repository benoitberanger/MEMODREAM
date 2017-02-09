close all
clear all
clc

PsychPortAudio('close')

Fs = 44100; % Hz

F_low  = 440; % Hz
F_high = F_low*2; % Hz


%% Create bip

SamplingRate = Fs; % Hz

Length = 300; % milliseconds

t = (0:1:(Length/1000*SamplingRate))'/SamplingRate  ;

phase = 0; % radian

window = tukeywin(length(t),0.25);
% window = hann(length(t));
% window = hamming(length(t));
% window = ones(length(t),1);

signal_low = sin( 2*pi*F_low*t + phase );
signal_high = sin( 2*pi*F_high*t + phase );

bip_low = signal_low.*window;
bip_high = signal_high.*window;

figure
subplot(2,1,1)
plot(t,bip_low)
subplot(2,1,2)
plot(t,bip_high)


bip_low = [ zeros(Fs,1) ; bip_low ; zeros(Fs,1) ];
bip_high = [ zeros(Fs,1) ; bip_high ; zeros(Fs,1) ];
t = (1:1:length(bip_low))/SamplingRate;


%% Play

% InitializePsychSound(1)
% playAudioPTB(bip_low',Fs)
% WaitSecs(0.1);
% playAudioPTB(bip_high',Fs)

playAudio(bip_low',Fs)
pause(0.1)
playAudio(bip_high',Fs)
