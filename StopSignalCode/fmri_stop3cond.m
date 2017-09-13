%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% stop3condfmri %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Adam Aron and Gui Xue%%% adapted by Saloni Krishnan, June 2017 for newer MATLAB version%%% uses voice recording from Psychtoolboxclear all;% output versionscript_name='stop3condfmri: fMRI manual, vocal and word version with fixed delays';script_version='2';revision_date='06-18-17'; %american date% read in subject initialsfprintf('%s %s (revised %s)\n',script_name,script_version, revision_date);type = input('Enter manual (1), vocal (2) or word (3): ');if type==1, tasktype='sm'; elseif type==2, tasktype='sv'; elseif type==3, tasktype='sw'; endsubject_code=input('Enter subject number: ');scannum=input('Enter scan number: ');SSDc = input('Enter SSDc value: ');base_directory = '~/Documents/MATLAB/SpeechAndBrainLab/StopSignalCode/';%load relevant input file for this scan  (there MUST be s1_f1.mat, etc. in%the directory)inputfile=sprintf('design/s%d_f%d.mat',subject_code,type);load(inputfile); %variable is trialcodelogfiles=sprintf('logfile/log_fMRI_sub%d_%s%d_%s.txt',subject_code,tasktype,scannum,date);fid = fopen(logfiles,'w');fixtime=10; %???%Seed random number generatorrand('state',subject_code);if scannum==1  %only sets this stuff up once        mkdir(strcat(base_directory,'voicefiles/sub',num2str(subject_code)));    mkdir(strcat(base_directory,'results/fmri/sub',num2str(subject_code)));    %Ladder Starts (in ms):    Ladder1=200;    Ladder(1,1)=Ladder1;    Ladder2=250;    Ladder(2,1)=Ladder2;    Ladder3=200;    Ladder(3,1)=Ladder3;    Ladder4=250;    Ladder(4,1)=Ladder4;    end; %end of scannum==1 setup%%% here we assign SSD values to a vector and randomizeSSDvec(1:8)=SSDc-60;SSDvec(9:16)=SSDc-20;SSDvec(17:24)=SSDc+20;SSDvec(25:32)=SSDc+60;[foo,rand_idx]=sort(rand(1,32));SSDvec=SSDvec(rand_idx);%% this code looks up the last value in each staircaseif scannum>1    cd(base_directory); cd(strcat('results/fmri/sub',num2str(subject_code)));    ls;    outfile=input('Enter name of prior scan_file to open: ','s');    load(outfile);    cd(base_directory);    clear Seeker; %gets rid of this so it won't interfere with current Seeker    Ladder(1,1)=Ladder1;    Ladder(2,1)=Ladder2;    Ladder(3,1)=Ladder3;    Ladder(4,1)=Ladder4;end%PsychDebugWindowConfiguration %can be disabled laterscreens=Screen('Screens');screenNumber=max(screens);%get screen readypixelSize=32;[w, screenRect]=Screen(screenNumber, 'OpenWindow', 0, [], pixelSize);screenRect=Screen(w, 'Rect');HideCursor;TextColor = 255;BgColor = 0;blank_screen=Screen(w, 'OpenOffscreenWindow', BgColor, screenRect);xcenter=screenRect(3)/2;ycenter=screenRect(4)/2;theFont='Courier';%get positions readyCircleSize=50;CirclePosX=xcenter-CircleSize/2-10;CirclePosY=ycenter-70;ArrowSize=100;ArrowPosX=xcenter-ArrowSize/2;ArrowPosY=ycenter-50;%Adaptable Constants% "chunks", will always be size 64:NUMCHUNKS=6;  %gngscan has 6 blocks of 64%StepSize = 50 ms;Step=50;%Interstimulus interval (trial time-.OCI) = 2.5sISI=2; %set at 1.5 for preTMS%NB, see figure in GNG4manual (set at 2 for scan)%BlankScreen Interval is 1.0sBSI=1 ;  %NB, see figure in GNG4manual (set at 1 for scan)%Only Circle Interval is 0.5sOCI=0.5;arrow_duration=1; %because stim duration is 1.5 secs in opt_stopnumDevices=PsychHID('NumDevices');devices=PsychHID('Devices');for n=1:numDevices    if (findstr(devices(n).manufacturer,'Current Designs, Inc.') & findstr(devices(n).transport,'USB') & findstr(devices(n).usageName,'Keyboard'))        inputDevice=n;    else        inputDevice=11;    end;end;fprintf('Using Device #%d (%s)\n',inputDevice,devices(inputDevice).product);%%% FEEDBACK VARIABLESLEFT=KbName('1!');%97; %49; %55; %49;RIGHT=KbName('2@');%98;%50; % 56; %50;triggerkey = KbName('5%');fb=scannum;errorsmade=0;rt=0;count_rt=0;if scannum==1,    errorstring=cell(1,NUMCHUNKS/2);    rtstring=cell(1, NUMCHUNKS/2);    blockstring=cell(1, NUMCHUNKS/2);end%%%% Setting up the sound stuffInitializePsychSound(1); %low latency settingsamp = 22255;aud_stim = sin(1:0.25:1000);aud_delay = [];aud_padding = zeros(1, round(0.005*samp));	%%% Padding lasts for 5msaud_vec = [aud_delay  aud_padding  aud_stim  0];	% Vector fed into SNDpahandle1 = PsychPortAudio('Open', [],[],[],samp,1);PsychPortAudio('FillBuffer', pahandle1, aud_vec);PsychPortAudio('Start', pahandle1,1);PsychPortAudio('Stop', pahandle1, 1);if type==2 || type==3    voicetrigger = 0.01;    maxsecs = 1;    freq = 44100;    audiodevices = PsychPortAudio('GetDevices'); %% to be changed for scanner mic    for n=1:size(audiodevices,2)        if strfind(audiodevices(n).DeviceName,'USB Audio CODEC')             nochannels=audiodevices(n).NrInputChannels;            if nochannels==2                inputDevice=audiodevices(n).DeviceIndex;            end        elseif strfind(audiodevices(n).DeviceName,'Samson C01U Pro Mic')            inputDevice=audiodevices(n).DeviceIndex;            nochannels=audiodevices(n).NrInputChannels;        elseif strfind(audiodevices(n).DeviceName,'Built-in Microph')            inputDevice=audiodevices(n).DeviceIndex;            nochannels=audiodevices(n).NrInputChannels;        end;    end;    fprintf('Using Device #%d (%s)\n',inputDevice,audiodevices(inputDevice+1).DeviceName);    pahandle2 = PsychPortAudio('Open', inputDevice, 2, 0, freq, nochannels);    PsychPortAudio('GetAudioData', pahandle2, 5);    recordedaudio = [];end%%%%%%%%%%%%%% Stimuli and Response on same matrix, pre-determined% The first column is trial number;% The second column is numchunks number (1-NUMCHUNKS);% The third column is 0 = Go, 1 = NoGo; 2 is null, 3 is notrial (kluge, see opt_stop.m)% The fourth column is 0=left, 1=right arrow; 2 is null% The fifth column is ladder number (1-4);% The sixth column is the value currently in "LadderX", corresponding to this...% The seventh column is subject response (no response is 0);% The eighth column is ladder movement (-1 for down, +1 for up, 0 for N/A)% The ninth column is their reaction time% The tenth column is their actual SSD (for error-check)% The 11th column is their actual SSD plus time taken to run the command% The 12th column is the time since the start of the trial (after while loop ends)% The 13th column is the time elapsed since the beginning of the block at moment when arrows are shown% The 14th column is the time elapsed since beginning of block at the moment the beep is played% The 15th column is the duration of the trial% The 16th column is the time_course%this puts trialcode into Seeker% trialcode was generated in opt_stop and is balanced for 4 staircase types every 16 trials, and arrow direction%  see opt_stop.m in /gng/optmize/stopping/% because of interdigitated null and true trial, there will thus be four staircases per 32 trials in trialcodefor  tc=1:256                                               %go/nogo        arrow          staircase        staircase value                        duration      timecourse    if trialcode(tc,5)>0, Seeker(tc,:) = [tc scannum  trialcode(tc,1) trialcode(tc,4) trialcode(tc,5) Ladder(trialcode(tc,5)) 0 0 0 0 0 0 0 0 trialcode(tc,2) trialcode(tc,3)];    else Seeker(tc,:) = [tc scannum trialcode(tc,1) trialcode(tc,4) trialcode(tc,5) 0 0 0 0 0 0 0 0 0 trialcode(tc,2) trialcode(tc,3)];    endend%%%% kluge to replace SSD values in Seeker with values from SSDvecSeeker(find(Seeker(:,6)>0),6)=SSDvec';if type==3    %%%% load wordlist1 or wordlist2 (scan1 or scan2)    if scannum==1, load('wordlist/wordlist1.mat'), else load('wordlist/wordlist2.mat'); end        stopwords = wordlist(1:32);    gowords = wordlist(33:128);        [foo,rand_idx]=sort(rand(1,32));    stopwords=stopwords(rand_idx);        [foo,rand_idx]=sort(rand(1,96));    gowords=gowords(rand_idx);    stop_go_words=cell(256,1);    stop_go_words(find(Seeker(:,3)==1))=stopwords;    stop_go_words(find(Seeker(:,3)==0))=gowords;end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TRIAL PRESENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Screen(w, 'TextFont', theFont);Screen(w,'TextSize', 24);startstring = sprintf('Get ready for scan number %d', scannum);Screen(w,'DrawText',startstring,100,100,TextColor);if type==1,    inst={{'This it the STOP MANUAL experiment'} ...        {''}...        {'Remember, as FAST as you can press the'}...        {'left button if you see "T" and the right button if you see "D". '}...        {'Remember, if you hear a beep, your task'}...        {'is to STOP yourself from pressing.'}...        {''}...        {'Responding fast and stopping are equally important.'}};elseif type==2,    inst={{'This it the STOP VOCAL experiment'} ...        {''}...        {'Remember, say as FAST as you can the'}...        {'letter "T" (say "tee") or "D" (say "dee") once you see it. '}...        {'Remember, if you hear a beep, your task'}...        {'is to STOP yourself from speaking.'}...        {''}...        {'Responding fast and stopping speech are equally important.'}};elseif type==3    inst={{'This it the STOP WORD experiment'} ...        {''}...        {'Remember, say as FAST as you can the'}...        {'word once you see it. '}...        {'Remember, if you hear a beep, your task'}...        {'is to STOP yourself from speaking.'}...        {''}...        {'Responding fast and stopping speech are equally important.'}};endfor x=1:size(inst,2),    Screen(w,'DrawText',inst{x}{:},100,200+x*30,TextColor);end;Screen('Flip',w);%     % mock recording to remove delay from first response recordingif type==2 || type==3    PsychPortAudio('Start', pahandle2, 0, 0, 1);    mock=PsychPortAudio('GetAudioData', pahandle2);end%%%%%%%%%%This is where scanner pulse is waited for%%%%%%%%%%notrigger=1;%while notrigger    [keyIsDown,secs,keyCode] = KbCheck();    if keyIsDown && find(keyCode)==triggerkey, notrigger=0; end;end% while GetChar ~= '!',end;Screen('CopyWindow',blank_screen, w);Screen('Flip',w);anchor=GetSecs;Pos=1;for block=1:2	  %because of way it's designed, there are two blocks for every scan        for a=1:4        for b=1:32 %should update after every 16 but now we have extra 16 digitated null trials                        while GetSecs - anchor < Seeker(Pos,16), end %waits to synch beginning of trial with 'true' start                        if Seeker(Pos,3)~=2 %% ie this is not a NULL event                                Screen(w, 'TextSize', 80);                Screen(w, 'TextFont', 'Arial');                DrawFormattedText(w, '+', 'center', 'center', TextColor);                Screen('Flip',w);                                while (GetSecs - anchor) < (Seeker(Pos,16)+ 0.5), end %waits to synch beginning of trial with 'true' start            end                        if Seeker(Pos,3)~=2 %% ie this is not a NULL event                                if type==1 || type==2                    if (Seeker(Pos,4)==0)                        DrawFormattedText(w,'T', 'center', 'center', TextColor);                    else                        DrawFormattedText(w,'D', 'center', 'center', TextColor);                    end;                elseif type==3  %(i.e. type==3, word)                    DrawFormattedText(w,stop_go_words{Pos}, 'center', 'center', TextColor);                end                Screen('Flip',w);                                noresp=1;                notone=1;                                start_time = GetSecs;                level = 0;                                %%% wait minimum seconds to avoid too fast response.                %%% and to avoid the case when response is faster than beep.                WaitSecs(0.1);                if Seeker(Pos,3)~=1, notone=0; end                                if type==1                                        while (GetSecs-start_time < arrow_duration) || (Seeker(Pos,3)==1 && notone) && GetSecs-start_time < arrow_duration + 1                        [keyIsDown,secs,keyCode] = KbCheck(inputDevice);                        if keyIsDown                            if find(keyCode) == KbName('q'), Screen('closeall'); fclose(fid); return; end                            if find(keyCode)==LEFT || find(keyCode)==RIGHT                                Seeker(Pos,7)=find(keyCode);                                Seeker(Pos,9)=GetSecs-start_time;                                noresp=0;                            end                        end                                                %stop signal                        if Seeker(Pos,3)==1 && GetSecs - start_time >=Seeker(Pos,6)/1000 && notone                            disp('stop trial')                            PsychPortAudio('FillBuffer', pahandle1, aud_stim);                            PsychPortAudio('Start', pahandle1,1);                            Seeker(Pos,14)=GetSecs-start_time;                            PsychPortAudio('Stop', pahandle1, 1);                            notone=0;                        end                    end %end while                                    elseif (type==2 || type==3)                    PsychPortAudio('Start', pahandle2, 0, 0, 1); % start recording                                        recordedaudio = [];                                        while (GetSecs-start_time < arrow_duration) || (Seeker(Pos,3)==1 && notone) && GetSecs-start_time < arrow_duration + 1                                                %stop signal                        if Seeker(Pos,3)==1 && GetSecs - start_time >=Seeker(Pos,6)/1000 && notone                            disp('stop trial')                            PsychPortAudio('FillBuffer', pahandle1, aud_stim);                            PsychPortAudio('Start', pahandle1,1);                            Seeker(Pos,14)=GetSecs-start_time;                            PsychPortAudio('Stop', pahandle1, 1);                            notone=0;                        end                                                %make recording                        [audiodata] = PsychPortAudio('GetAudioData', pahandle2); %get current audiodata                        recordedaudio = [recordedaudio audiodata];                    end                                        voicetrigger = 0.01;                    if max(abs(recordedaudio(1,:))) >= voicetrigger                        Seeker(Pos,9)=(find(abs(recordedaudio(1,:)-median(recordedaudio(1,:))) > voicetrigger, 1, 'first')/freq);                        Seeker(Pos,7)=1;                    end                                        PsychPortAudio('Stop', pahandle2);                    wavfilename = strcat('voicefiles/sub',num2str(subject_code),'/scan',num2str(scannum),'_block',num2str(block),'_pos_',num2str(Pos),'_a',num2str(a),'_b',num2str(b),'.wav');                    psychwavwrite(transpose(recordedaudio), 44100, 16, wavfilename);                end            end %end non null                        Screen('CopyWindow',blank_screen, w);            Screen('Flip',w);                        while(GetSecs - anchor < Seeker(Pos,16) + Seeker(Pos,15)), end                        Seeker(Pos,12)=GetSecs-anchor; %absolute time since beginning of block                        %%%% write trial info to a new line of the logfile            fprintf(fid,'%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n',Seeker(Pos,1),Seeker(Pos,2),Seeker(Pos,3),Seeker(Pos,4),...                Seeker(Pos,5),Seeker(Pos,6),Seeker(Pos,7),Seeker(Pos,8),Seeker(Pos,9),Seeker(Pos,10),Seeker(Pos,11),Seeker(Pos,12),Seeker(Pos,13),Seeker(Pos,14),Seeker(Pos,15),Seeker(Pos,16));                        Pos=Pos+1;                    end; % end of trial loop            end; %end of miniblock    end; %end block loopfclose(fid);%%%% FEEDBACK %%%%%Screen(w, 'TextSize', 24);%remember fb is the counter for fbfor t=1:256    if Seeker(t,3)==0 && Seeker(t,4)==0 && Seeker(t,7)==RIGHT||Seeker(t,4)==1 && Seeker(t,7)==LEFT, errorsmade=errorsmade+1; end    if Seeker(t,3)==0 && Seeker(t,9)>0, rt=rt+Seeker(t,9); count_rt=count_rt+1; endendblockstring=sprintf('End of STOP VOCAL scanning block %d', fb);%   errorstring{fb} = sprintf('Mistakes with arrow direction: %d', errorsmade);%   rtstring{fb}=sprintf('Correct average RT on Go trials: %.1f (ms)', rt/count_rt*1000);Screen('CopyWindow',blank_screen, w);Screen('Flip',w);Screen(w,'DrawText',blockstring,100,100,255);Screen('Flip',w);%    screen(w,'DrawText', errorstring{1},100,140,255);%    screen(w,'DrawText',rtstring{1},100,180,255);d=clock;cdate=date;outfile=strcat(base_directory,sprintf('results/fMRI/sub%d/%s%d_%s_%02.0f-%02.0f.mat',subject_code,tasktype,scannum,cdate(1:6),d(4),d(5)));PsychPortAudio('Close', pahandle1);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SAVE DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Make parameters for output fileparams = cell (9,2);params{1,1}='NUMCHUNKS';   params{1,2}=NUMCHUNKS;params{2,1}='Ladder1 start';   params{2,2}=Ladder1(1,1);params{3,1}='Ladder2 start';   params{3,2}=Ladder2(1,1);params{4,1}='Ladder3 start';   params{4,2}=Ladder3(1,1);params{5,1}='Ladder4 start';   params{5,2}=Ladder4(1,1);params{6,1}='Step';   params{6,2}=Step;params{7,1}='ISI';   params{7,2}=ISI;params{8,1}='BSI';   params{8,2}=BSI;params{9,1}='OCI';   params{9,2}=OCI;%%% It's better to access these variables via parameters, rather than saving them...save(outfile, 'Seeker', 'params', 'Ladder1', 'Ladder2', 'Ladder3',...    'Ladder4','SSDc');%waits for 'q' end key to be pressed by experimenternotrigger=1;while notrigger    [keyIsDown,secs,keyCode] = KbCheck();    if keyIsDown && find(keyCode)==triggerkey, notrigger=0; end;endScreen('CopyWindow',blank_screen, w);clear Screen;