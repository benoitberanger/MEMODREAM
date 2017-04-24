clc
close all
clear all

%% Init

Subject = input('Subject (filename): ', 's');
if isempty(Subject)
    error('Subject')
end

Run = input('Run (filename): ', 's');
if isempty(Run)
    error('Run')
end

DataPath = [ fileparts(fileparts(pwd)) filesep 'data' filesep Subject filesep];


%% Initialization : do it before start of the scanner

KbName('UnifyKeyNames');

keys = {'space' 'escape' 't' 'b' 'y' 'g' 'r'};
esc = KbName('escape');

KL = KbLogger(KbName(keys) , keys);

KL.Start;


%% Scanner running, do nothing...

fprintf('\n')
fprintf('Scanner can run, recording keys... Waiting for ESCAPE to end. \n')

[keyIsDown, secs, keyCode] = KbCheck;

while 1
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(esc)
            break
        end
    end
end


%% Scanner stopped : Stop logger and display results

KL.GetQueue;

KL.Stop;

KL.ScaleTime;

KL.ComputeDurations;

KL.BuildGraph;

KL.Plot;

KL.ComputePulseSpacing(1);

disp(KL)
disp(KL.Data)
disp(KL.KbEvents)


%% Save datas

timestamp = datestr(now,30);

if ~exist(DataPath,'dir')
    mkdir(DataPath)
end

save([DataPath timestamp '_' Run])

fprintf('\n')
fprintf('File saved : %s \n', [DataPath timestamp '_' Run])
fprintf('Ready for another run \n')
