%%% get ready by deleting all variables and all feedback figures
clear all;
script_name='Stop_behav, demo version';
script_version='1';
revision_date='06-10-17';

% read in subject initials
type = input('Enter manual (1), vocal (2) or word (3): ');
if type==1, tasktype='sm'; elseif type==2, tasktype='sv'; elseif type==3, tasktype='sw'; end
JitterType=1;
wordlistchoice = 2;


%get screen ready
Screen('Preference', 'SkipSyncTests', 1);
pixelSize=32;
[w, screenRect]=Screen(0, 'OpenWindow', 0, [], pixelSize);
HideCursor;
black=BlackIndex(w);
white=WhiteIndex(w);
blank_screen=Screen(w, 'OpenOffscreenWindow', 0, screenRect);
scr=Screen(w, 'OpenOffscreenWindow', 0, screenRect);
xcenter=screenRect(3)/2;
ycenter=screenRect(4)/2;
theFont='Courier';
%get positions ready
ArrowSize=80;
ArrowPosX=xcenter-ArrowSize/2;
ArrowPosY=ycenter-ArrowSize/2;
TextColor=255;

%%%%************** DEFINE PARAMS HERE *************
WAITTIME=1;
Step=50;
OCI=0.5;
arrow_duration=1;
NBLOCKS=1;

meanrt=zeros(1,NBLOCKS);
dimerrors=zeros(1,NBLOCKS);
LEFT=KbName('n'); % key 1
RIGHT=KbName('m'); % key 2


%%%% Setting up the sound stuff - SK - changed to new PsychPortAudio
%%%% settings for MATLAB R2015b
InitializePsychSound(1); %low latency setting
samp = 22255;
aud_stim = sin(1:0.25:1000);
aud_delay = [];
aud_padding = zeros(1, round(0.005*samp));	%%% Padding lasts for 5ms
aud_vec = [aud_delay  aud_padding  aud_stim  0];	% Vector fed into SND
pahandle1 = PsychPortAudio('Open', [],[],[],samp,1);
PsychPortAudio('FillBuffer', pahandle1, aud_vec);
PsychPortAudio('Start', pahandle1,1);
PsychPortAudio('Stop', pahandle1, 1);

if type==2 || type==3
    voicetrigger = 0.05;
    maxsecs = 1;
    freq = 44100;
    pahandle2 = PsychPortAudio('Open', [], 2, 0, freq, 2);
    PsychPortAudio('GetAudioData', pahandle2, 10);
    recordedaudio = [];
end

totalcnt=1;  % this is the overall counter

for block=1:NBLOCKS % change number of blocks
    NUMCHUNKS=1;
    for  tc=1:NUMCHUNKS
        for qblock=1:4
            LadderOrder=[randperm(2) randperm(2)];
            arrows = [1 1 0 0];
            [p  rand_idx]=sort(rand(1,4));
            arrows=arrows(rand_idx);
            for st=1:4
                %there are 4 in each, one stop, three go
                mini = [1 arrows(1) LadderOrder(st); 0 arrows(2) 0; 0 arrows(3) 0; 0 arrows(4) 0;];
                [p  rand_idx]=sort(rand(1,4));
                mini=mini(rand_idx,:);
                start=(tc-1)*64+(qblock-1)*16+(st-1)*4+1;
                endof=(tc-1)*64+(qblock-1)*16+(st)*4;
                trialcode(start:endof,:)=mini;
            end
        end
    end
    
    
    
    Ladder1=100;
    Ladder2=250;
    
    Ladder(1,1)=Ladder1;
    Ladder(2,1)=Ladder2;
    
    for  trlcnt=1:64                                                                     %go/nogo        arrow              staircase        staircase value
        if trialcode(trlcnt,3)>0, Seeker((block-1)*64+trlcnt,:) = [trlcnt block  trialcode(trlcnt,1) trialcode(trlcnt,2) trialcode(trlcnt,3) Ladder(trialcode(trlcnt,3)) 0 0 0 0];
        else Seeker((block-1)*64+trlcnt,:) =                      [trlcnt block  trialcode(trlcnt,1) trialcode(trlcnt,2) trialcode(trlcnt,3) 0 0 0 0 0];
        end
    end
    
    % The first column is  trial number;
    % The second column is block
    % The third column is 0 = Go, 1 = NoGo; 2 is null, 3 is notrial (kluge, see opt_stop.m)
    % The fourth column is 0=left, 1=right arrow; 2 is null
    % The fifth column is ladder number (1-2);
    % The sixth column is the value currently in "LadderX", corresponding to this...
    % The seventh column is subject response (no response is 0);
    % The eighth column is their reaction time
    % The ninth column is time since beginning of trial
    % The tenth column is ladder movement (-1 for down, +1 for up, 0 for N/A)
    
    %%%% load prescan_wordlist 1 or 2, 3 4, 5, 6, 10;
    stopwords = {}; gowords = {};
    if type==3,
        if wordlistchoice==1
            eval(sprintf('load wordlist/prescan_wordlist%d', block));
        else
            eval(sprintf('load wordlist/prescan_wordlist%d', +block+4));
        end
        for i = 1:16
            stopwords{i} = wordlist{i};
        end
        for i = 17:64
            gowords{i-16} = wordlist{i};
        end
        stopwords=stopwords(randperm(length(stopwords)));
        gowords=gowords(randperm(length(gowords)));
        
        stop_go_words=cell(64,1);
        stop_go_words(find(Seeker(totalcnt:totalcnt+63,3)==1))=stopwords;
        stop_go_words(find(Seeker(totalcnt:totalcnt+63,3)==0))=gowords;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Screen(w, 'TextFont', theFont);
    Screen(w,'TextSize', 20);
    startstring = sprintf('Get ready for block number %d', block);
    Screen(w,'DrawText',startstring,100,100,TextColor);
    
    if type==1,
        inst={{'This is the STOP MANUAL experiment'} ...
            {''}...
            {'Remember, as FAST as you can press the'}...
            {'left button if you see "T" and the right button if you see "D". '}...
            {'Remember, if you hear a beep, your task'}...
            {'is to STOP yourself from pressing.'}...
            {''}...
            {'Responding fast and stopping are equally important.'}};
    elseif type==2,
        inst={{'This is the STOP VOCAL experiment'} ...
            {''}...
            {'Remember, say as FAST as you can the'}...
            {'letter "T" (say "tee") or "D" (say "dee") once you see it. '}...
            {'Remember, if you hear a beep, your task'}...
            {'is to STOP yourself from speaking.'}...
            {''}...
            {'Responding fast and stopping speech are equally important.'}};
    elseif type==3
        inst={{'This is the STOP WORD experiment'} ...
            {''}...
            {'Remember, say as FAST as you can the'}...
            {'word once you see it. '}...
            {'Remember, if you hear a beep, your task'}...
            {'is to STOP yourself from speaking.'}...
            {''}...
            {'Responding fast and stopping speech are equally important.'}};
    end
    for x=1:size(inst,2),
        Screen(w,'DrawText',inst{x}{:},100,200+x*30,TextColor);
    end;
    Screen('Flip',w);
    
    %     % mock recording to remove delay from first response recording
    if type==2 || type==3
        PsychPortAudio('Start', pahandle2, 0, 0, 1);
        mock=PsychPortAudio('GetAudioData', pahandle2);
    end
    
    
    %%% wait for key press to begin
    % while GetChar~='space'; end	%-use so can press any key to begin
    GetChar;
    Screen('CopyWindow',blank_screen, w);
    Screen('Flip',w);
    
    anchor=GetSecs;
    
    for a=1:3 %4 miniblocks
        for b=1:8 % within each miniblock
            
            Screen(w, 'TextSize', ArrowSize);
            Screen(w, 'TextFont', 'Arial');
            DrawFormattedText(w, '+', 'center', 'center', 255);
            Screen(w, 'TextSize', ArrowSize);
            Screen(w, 'TextFont', 'Arial');
            Screen('Flip',w);
            fixtime=GetSecs;
            WaitSecs(0.5);
            if type==1 || type==2
                if (Seeker(totalcnt,4)==0),
                    DrawFormattedText(w, 'T', 'center', 'center', 255);
                else
                    DrawFormattedText(w, 'D', 'center', 'center', 255);
                end;
            elseif type==3,  %(i.e. type==3, word)
                Pos=totalcnt-(block-1)*64;
                DrawFormattedText(w, stop_go_words{Pos}, 'center', 'center', 255);
            end
            
            notone=1;
            noresp=1;
            novoice=1;
            disp(totalcnt);
            level = 0;
            
            Screen('Flip',w);
            start_time = GetSecs; %measure RT from when arrows are shown
            
            
            if type==1 %i.e. manual
                
                while (GetSecs-start_time < arrow_duration) && noresp==1 %check that response is within 1 second of arrow
                    
                    [keyIsDown,secs,keyCode] = KbCheck;
                    if keyIsDown && noresp
                        if find(keyCode)==LEFT || find(keyCode)==RIGHT
                            Seeker(totalcnt,7)=find(keyCode);
                            Seeker(totalcnt,8)=GetSecs-start_time;
                            noresp=0;
                        end
                    end
                    
                    % stop trialSSD
                    if Seeker(totalcnt,3)==1 &&  notone==1 &&(GetSecs - start_time >= Seeker(totalcnt,6)/1000)
                        PsychPortAudio('FillBuffer', pahandle1, aud_stim);
                        PsychPortAudio('Start', pahandle1,1);
                        PsychPortAudio('Stop', pahandle1, 1);
                        notone=0;
                        
                        while GetSecs-start_time < arrow_duration + 1 && noresp==1
                            [keyIsDown,secs,keyCode] = KbCheck;
                            if keyIsDown && noresp
                                if find(keyCode)==LEFT || find(keyCode)==RIGHT
                                    Seeker(totalcnt,7)=find(keyCode);
                                    Seeker(totalcnt,8)=GetSecs-start_time;
                                    noresp=0;
                                end
                            end
                        end
                        disp(Seeker(totalcnt,8));
                    end
                end
                
                %%% punish subject for making an error
                if Seeker(totalcnt,3)==0 && ( (Seeker(totalcnt,4)==0 && Seeker(totalcnt,7)==RIGHT) || ( Seeker(totalcnt,4)==1 && Seeker(totalcnt,7)==LEFT ) )
                    Screen('CopyWindow',blank_screen, w);
                    Screen(w, 'TextSize', 50);
                    %Screen(w, 'DrawText', 'Wrong!', xcenter-100, ycenter+50,255);
                    DrawFormattedText(w,'Wrong!','center','center',255);
                    Screen('Flip',w);
                    WaitSecs(2);
                end
                
                if totalcnt < 9 %give some feedback
                    Screen(w,'TextSize', 30);
                    if Seeker(totalcnt, 3) == 0 && Seeker(totalcnt,7) ~= 0
                        DrawFormattedText(w, sprintf('RT for this trial: %.1f (ms)', Seeker(totalcnt,8)*1000), 'center', 'center', 255);
                        DrawFormattedText(w, 'Try and respond as quickly as possible', 'center', 800, 255);
                    elseif Seeker(totalcnt, 3) == 0 && Seeker(totalcnt,7) == 0
                        DrawFormattedText(w, 'You must respond when you do not hear a beep', 'center', 'center', 255);
                    elseif Seeker(totalcnt, 3) == 1 && Seeker(totalcnt,7) == 0
                        DrawFormattedText(w, 'Good, you did not respond when you heard the beep', 'center', 'center', 255);
                    elseif Seeker(totalcnt, 3) == 1 && Seeker(totalcnt,7) ~= 0
                        DrawFormattedText(w, 'Try to stop responding when you hear the beep', 'center', 'center', 255);
                    end
                    Screen('Flip',w);
                    WaitSecs(1.5);
                    
                end
                
                % The first column is  trial number;
                % The second column is block
                % The third column is 0 = Go, 1 = NoGo; 2 is null, 3 is notrial (kluge, see opt_stop.m)
                % The fourth column is 0=left, 1=right arrow; 2 is null
                % The fifth column is ladder number (1-2);
                % The sixth column is the value currently in "LadderX", corresponding to this...
                % The seventh column is subject response (no response is 0);
                % The eighth column is their reaction time
                % The ninth column is time since beginning of trial
                % The tenth column is ladder movement (-1 for down, +1 for up, 0 for N/A)
                
                
            elseif (type==2 || type==3)
                PsychPortAudio('Start', pahandle2, 0, 0, 1); % start recording
                level = 0;
                while (level < voicetrigger) && (GetSecs-start_time < arrow_duration) && noresp==1
                    
                    [audiodata offset overflow tCaptureStart] = PsychPortAudio('GetAudioData', pahandle2); %get current audiodata
                    
                    if ~isempty(audiodata)
                        level = max(abs(audiodata(1,:))); % Compute maximum signal amplitude in this chunk of data:
                    else
                        level = 0;
                    end
                    
                    if level > voicetrigger
                        Seeker(totalcnt,8)=GetSecs-start_time;
                        Seeker(totalcnt,7)=1;
                        disp(Seeker(totalcnt,8));
                        noresp=0;
                        PsychPortAudio('Stop', pahandle2);
                    else
                        WaitSecs(0.005);
                    end
                    
                    % stop trialSSD
                    if Seeker(totalcnt,3)==1 &&  notone==1 &&(GetSecs - start_time >= Seeker(totalcnt,6)/1000)
                        disp('STOP trial');
                        PsychPortAudio('FillBuffer', pahandle1, aud_stim);
                        PsychPortAudio('Start', pahandle1,1);
                        PsychPortAudio('Stop', pahandle1, 1);
                        notone=0;
                        SSD_time = GetSecs;
                        
                        while (GetSecs-SSD_time) < 1 && noresp==1
                            [audiodata offset overflow tCaptureStart] = PsychPortAudio('GetAudioData', pahandle2);
                            
                            if ~isempty(audiodata)
                                level = max(abs(audiodata(1,:))); % Compute maximum signal amplitude in this chunk of data:
                            else
                                level = 0;
                            end
                            
                            if level > voicetrigger
                                Seeker(totalcnt,8)=GetSecs-start_time;
                                Seeker(totalcnt,7)=1;
                                disp(Seeker(totalcnt,8));
                                PsychPortAudio('Stop', pahandle2);
                                noresp=0;
                            else
                                level=0;
                                noresp=1;
                            end;
                        end
                    end
                    
                end % end while
                
                if noresp
                    PsychPortAudio('Stop', pahandle2);
                    disp('No response detected');
                end
                
                if totalcnt < 9 %give some feedback
                    Screen(w,'TextSize', 30);
                    if Seeker(totalcnt, 3) == 0 && Seeker(totalcnt,7) ~= 0
                        DrawFormattedText(w, sprintf('RT for this trial: %.1f (ms)', Seeker(totalcnt,8)*1000), 'center', 'center', 255);
                        DrawFormattedText(w, 'Try and respond as quickly as possible', 'center', 800, 255);
                    elseif Seeker(totalcnt, 3) == 0 && Seeker(totalcnt,7) == 0
                        DrawFormattedText(w, 'You must respond when you do not hear a beep', 'center', 'center', 255);
                    elseif Seeker(totalcnt, 3) == 1 && Seeker(totalcnt,7) == 0
                        DrawFormattedText(w, 'Good, you did not respond when you heard the beep', 'center', 'center', 255);
                    elseif Seeker(totalcnt, 3) == 1 && Seeker(totalcnt,7) ~= 0
                        DrawFormattedText(w, 'Try to stop responding when you hear the beep', 'center', 'center', 255);
                    end
                    Screen('Flip',w);
                    WaitSecs(1.5);
                    
                end
                
            end    %end if
            

            tmpsecs=GetSecs;
            
            Screen('CopyWindow',blank_screen, w);
            Screen('Flip',w);
            WaitSecs(WAITTIME);
            if JitterType==2
                WaitSecs(null_events(64-mod(totalcnt,64)));
            end
            
            Seeker(totalcnt,9)=GetSecs-anchor; %absolute time since beginning of block
            
            totalcnt = totalcnt +1; %%% this update the overall counter
            
        end;
        
        % after each 8 trials this code does the updating of staircases
        %These three loops update each of the ladders
        for c=(totalcnt-8):totalcnt-1  %this looks at the last 8 trials
            %This runs from one to two, one for each of the ladders
            for d=1:2
                
                if (Seeker(c,7)~=0 && Seeker(c,5)==d),	%col 7 is sub response
                    if Ladder(d,1)>=Step, %this doesnt allow the ladder value to go below 0
                        Ladder(d,1)=Ladder(d,1)-Step;
                        Ladder(d,2)=-1;
                    elseif Ladder(d,1)>0 && Ladder(d,1)<Step
                        Ladder(d,1)=0;
                        Ladder(d,2)=-1;
                    else
                        Ladder(d,1)=Ladder(d,1);
                        Ladder(d,2)=0;
                    end
                    disp('Decreasing SSD to:')
                    disp(Ladder(d,1))
                    if (d==1),
                        [x y]=size(Ladder1);
                        Ladder1(x+1,1)=Ladder(d,1);
                    elseif (d==2),
                        [x y]=size(Ladder2);
                        Ladder2(x+1,1)=Ladder(d,1);
                    end;
                elseif Seeker(c,7)==0 && Seeker(c,5)==d
                    Ladder(d,1)=Ladder(d,1)+Step;
                    Ladder(d,2)=1;
                    disp('Increasing SSD to:')
                    disp(Ladder(d,1))
                    if (d==1),
                        [x y]=size(Ladder1);
                        Ladder1(x+1,1)=Ladder(d,1);
                    elseif (d==2),
                        [x y]=size(Ladder2);
                        Ladder2(x+1,1)=Ladder(d,1);
                    end;
                end; % end elseif
            end; % end for d=1:4
        end; % end for c=...
        
        %Updates the time in each of the subsequent stop trials
        for c=totalcnt:(block-1)*64+64
            if (Seeker(c,5)~=0) %i.e. staircase trial
                Seeker(c,6)=Ladder(Seeker(c,5),1);
            end;
        end;
        %Updates each of the old trials with a +1 or a -1 (in col 10)
        for c=(totalcnt-8):totalcnt-1
            if (Seeker(c,5)~=0)
                Seeker(c,10)=Ladder(Seeker(c,5),2);
            end;
        end;
        
        if type==1
            meanrt(block) = 1000*median(Seeker(find( Seeker(:,2)==block & Seeker(:,3)==0 & Seeker(:,7)~=0  & ( (Seeker(:,4)==1 & Seeker(:,7)==RIGHT) | ( Seeker(:,4)==0 & Seeker(:,7)==LEFT ) )),8));
            dimerrors(block)=sum((Seeker(:,2)==block & Seeker(:,3)==0 & ( (Seeker(:,4)==0 & Seeker(:,7)==RIGHT) | ( Seeker(:,4)==1 & Seeker(:,7)==LEFT ) )));
        else
            meanrt(block) = 1000*median(Seeker(find( Seeker(:,2)==block & Seeker(:,3)==0 & Seeker(:,8)>0),8));
        end
        
        
        if type==1
            Screen(w,'TextSize', 30);
            DrawFormattedText(w, sprintf('Correct average RT on Go trials: %.1f (ms)', meanrt(block)), 'center', 'center', 255);
            DrawFormattedText(w, sprintf('Mistakes with arrow direction on Go trials: %d', dimerrors(block)), 'center', 800, 255);            
        else
            Screen(w,'TextSize', 20);
            DrawFormattedText(w, sprintf('Correct average RT on Go trials: %.1f (ms)', meanrt(block)), 'center', 'center', 255);       
        end
        Screen('Flip',w);
        %%% wait for key press to begin
        while ~KbCheck; end % wait for a key press
        
        if totalcnt == 9
            Screen(w,'TextSize', 30);
            DrawFormattedText(w, 'Now lets practice without immediate feedback', 'center', 'center', 255);
            Screen('Flip',w);
            WaitSecs(2);
        end
        
    end; %end of miniblock
    
    
    %%Feedback
    

end


Screen('TextSize',w,36);
Screen('TextFont',w,'Ariel');
DrawFormattedText(w, 'Great Job. Thank you!', 'center', 'center', 255);
Screen('Flip',w);

Screen('CloseAll');
PsychPortAudio('Close', pahandle1);
if type == 2 || type == 3
PsychPortAudio('Close', pahandle2);
end


