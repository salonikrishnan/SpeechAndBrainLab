function SentReading(ppid, subjectOrder)
%the purpose of this script is to present the participant with a set of
%sentences to read, and record onsets and durations of each sentence
%a back up log is also created in case any errors happen

%% get input about participant and run
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 2 %if you didnt initialise these at the start
    ppid = input('Type Participant ID:','s');
    subjectOrder = input('What run is this [1,2,3..]:');
end

clock_id=clock; % adding the current time to your participant ID will ensure your files don't get overwritten
clock_id=['Date_',num2str(clock_id(1)),'_',num2str(clock_id(2)),'_',num2str(clock_id(3)),'_Time_',num2str(clock_id(4)),'_',num2str(clock_id(5)),'_',num2str(clock_id(6))];
ppid=[ppid,'_Localiser_participant_',num2str(subjectOrder),'_',clock_id]; % make participant information include clock and session and run
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Point the script to your working directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
basedir = pwd; %change as neccessary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% create a log file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lognm = strcat(pwd,'/Logs/',ppid,'.log'); %if you get an error the first time you run this script, make sure you have created a directory called 'Logs'
logfid = fopen(lognm,'a');
if logfid<1,
    error('could not open logfile!');
end;
fprintf(logfid,'%s',ppid);

%label regressors
names = {
    'Silence'
    'Sentences'
    };

for x=1:2 % to create a matrix of onsets and durations for future use
    onsets{x}=[];
    durations{x}=[];
    buttonpress{x}=[];
end
c1 = 0; c2 = 0; c3 = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set up experimental parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trials=20; % how many trials
randomiser=randperm(trials);
load('sentences.mat');
init=0;
trialMarker = repmat([0:1],1,20); % a random order to present sentence & silence trials, 20 sets in all
trialMarker = trialMarker(randperm(length(trialMarker)));

jitter=[repmat([0:0.5:1],1,20)]; %make long vector of jitter values
jitter=jitter(randperm(length(jitter)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% check if this is a dummy run and set up input devices accordingly
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TA = 2; %set the acquisition time per volume
dummyrun= input('Is this a dry run or the real thing? Press 1 if dry run, 0 if real thing');
if dummyrun == 0
    % waitcmd = ('PulseChecker_new(1)');
    MRI=1;
    % set up input devices
    numDevices=PsychHID('NumDevices');
    devices=PsychHID('Devices');
    for n=1:numDevices,
        if (findstr(devices(n).transport,'USB') & findstr(devices(n).usageName,'Keyboard') & (devices(n).productID==16385 | devices(n).vendorID==6171 | devices(n).totalElements==274)),
            inputDevice=n;
        else
            inputDevice=2; % my keyboard
        end;
    end;
    fprintf('Using Device #%d (%s)\n',inputDevice,devices(inputDevice).product);
    KbName('UnifyKeyNames');
    trigger1 = KbName('5%');
    waitcmd = ('KbTriggerWait(trigger1)'); %replace 34 with correct code, this is 5 on my keyboard; add device number if appropriate
else
    waitcmd = ('WaitSecs(TA)');
    MRI = 0;
    % set up input devices
    numDevices=PsychHID('NumDevices');
    devices=PsychHID('Devices');
    for n=1:numDevices,
        if (findstr(devices(n).transport,'USB') & findstr(devices(n).usageName,'Keyboard')),
            inputDevice=n;
            break,
        elseif (findstr(devices(n).transport,'Bluetooth') & findstr(devices(n).usageName,'Keyboard')),
            inputDevice=n;
            break,
        elseif findstr(devices(n).transport,'ADB') & findstr(devices(n).usageName,'Keyboard'),
            inputDevice=n;
        elseif findstr(devices(n).transport,'SPI') & findstr(devices(n).usageName,'Keyboard'),
            inputDevice=n;
        end;
    end;
    fprintf('Using Device #%d (%s)\n',inputDevice,devices(n).product);
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% ready to go
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
StartExperiment=input('Press ENTER to start the experiment','s'); %here ths script will wait for a keyboard press from the user
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set up screens
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
screens=Screen('Screens');
screenNumber=max(screens);

w = Screen('OpenWindow',screenNumber,0,[],32,2);
[wWidth, wHeight]=Screen('WindowSize', w);
grayLevel=120;
Screen('FillRect', w, grayLevel); % it's a bit nicer to see a gray screen in the scanner
black=BlackIndex(w); % Should equal 0.
white=WhiteIndex(w);
Screen('TextFont',w, 'Arial');
Screen('TextSize',w, 40);
Screen('TextColor',w,black);
HideCursor;
DrawFormattedText(w,'Experimenter press SPACE to start','center','center',0);
Screen('Flip',w);
KbWait;

DrawFormattedText(w,'Read the sentences or wait if a + is displayed','center','center',0);
Screen('Flip',w);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% dummy scans & timing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dummyscans = 3; %set number of dummies
if dummyscans>0
    for i = 1:dummyscans
        eval(waitcmd); %waits for the trigger, if this is a dummy run it will wait for the set TA
        dum(i)= GetSecs;
        %Write out information about the timing of dummies into the log file
        fprintf(logfid,'\n%s\t%d\t%d', ...
            'dummy',i,dum(i))
    end
    eval(waitcmd);
    dum(i+1)= GetSecs; %this is the volume at the end of the dummies
    refVol = dum(i+1); %all future times are referenced to this volume
    %Write out information about the ref volume
    fprintf(logfid,'\n%s\t%d\t%d', ...
        'RefVol',i+1,refVol)
    %Write out information about the next volumes
    fprintf(logfid,'\n%s\t%s\t%s\t%s\t%s\t%s', ...
        'trialNo','condition','adjustTime','duration','rawOnset','rawOffset');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% start experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

s=1; %counter for the sentence set

for t = 1:length(trialMarker)
    
    sprintf('start of trial %d',t); %useful to have on second screen to monitor experiment progress
    if trialMarker(t) == 0
        textInstruction = '+';
        trialName{t}='Silence';
        Screen('TextColor', w, [0 0 0]);
    elseif trialMarker(t)==1
        textInstruction = Sentences{randomiser(s)}; %20 random sentences from the Sentences set
        s = s+1;
        trialName{t}='Sentences';
        Screen('TextColor', w, [0 0 0]);
    end
    
    Screen('FillRect', w,[128,128,128]);
    DrawFormattedText(w,textInstruction,'center','center')
    Screen('Flip',w);
    
    rawOnset(t)=GetSecs;
    CorrectedOnset(t)=rawOnset(t)-refVol;
    
    if trialMarker(t) == 0
        WaitSecs((TA)+jitter(t));
    elseif t == length(trialMarker)
        WaitSecs((TA-1)+jitter(t));
        textInstruction = 'All done,thank you';
        DrawFormattedText(w,textInstruction,'center','center',[1 0 0])
        Screen('Flip',w);
        WaitSecs(1);
    elseif trialMarker(t)==1
        % WaitSecs((TA)+jitter(t)); % at the moment it waits for 2 seconds but jitter, but this can be changed to any value by changing TA
        % Kb Response  - comment these lines out if you prefer to just set a
        % time
        if MRI ==1
            DisableKeysForKbCheck(KbName('5%')); % So trigger is no longer detected
        end
        noresp=1;
        timetowait = 2;
        start_time = GetSecs;
        while (GetSecs-start_time < timetowait && noresp),
            [keyIsDown,secs,keyCode] = KbCheck();
            if keyIsDown & noresp,
                c3=c3+1;
                tmp=KbName(keyCode)
                buttonpress{1}(c3)=KbName(tmp(1));
                buttonpress{2}(c3)=GetSecs-start_time;
                noresp=0;
            end;
        end
    end
    rawOffset(t)=GetSecs;
    duration(t)=rawOffset(t)-rawOnset(t);
    
    if trialMarker(t) == 0 % silent trial
        c1=c1+1;
        onsets{1}(c1)=CorrectedOnset(t);
        durations{1}(c1)=duration(t) ;
    elseif trialMarker(t) == 1 % sentence trial
        c2=c2+1;
        onsets{2}(c2)=CorrectedOnset(t);
        durations{2}(c2)=duration(t);
    else
        error('oh')
    end
    
    fprintf(logfid,'\n%d\t%s\t%d\t%d\t%d\t%d', ...
        t,trialName{t},CorrectedOnset(t),duration(t),rawOnset(t),rawOffset(t));
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%end of all trials
if MRI ==1
    DisableKeysForKbCheck([]); % So trigger is no longer detected
end
eval(waitcmd);
FinalVol= GetSecs; %record raw timing for final volume

%record final volume time in log file after all the other stuff
fprintf(logfid, '\n%s\t%d\t', ...
    'final_volume',FinalVol)
%close it - if you don't do this the file stays open and can't be
%deleted until Matlab is closed
fclose(logfid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% finish up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
savename= [pwd,'/Onsets/',ppid,'.mat']; %make sure you have created an Onset directory
save([pwd,'/Onsets/',ppid,'_Localiser.mat'],'names','onsets','durations');
sca;
clear all;
disp('Experiment done and dusted! Yay!');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end


