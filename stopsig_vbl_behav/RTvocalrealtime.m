clear all
arrow_duration = 1;
triggerlevel = 0.1;
Pos = 10;
Seeker = zeros(10,15);
Seeker(Pos,3)=1;
b=1;


%%sound
wave=sin(1:0.25:1000);
freq1=22254;
nrchannels = size(wave,1);
deviceid = -1;
reqlatencyclass = 2; 
InitializePsychSound(1);
pahandle1 = PsychPortAudio('Open', deviceid, [], reqlatencyclass, freq1, nrchannels);


%set up listening
freq2 = 44100;
pahandle2 = PsychPortAudio('Open', [], 2, reqlatencyclass, freq2, 2, [], 0.02);
PsychPortAudio('GetAudioData', pahandle2, 2);

noresp=1;
notone=1;
level = 0;


%flip screen
%Screen('Flip',w);
%start time
arrow_start_time = GetSecs;
PsychPortAudio('Start', pahandle2, 0, 0, 1);

% Repeat as long as below trigger-threshold & not beyond arrow_duration
while noresp && (GetSecs-arrow_start_time < arrow_duration)
    % Fetch current audiodata:
    [audiodata offset overflow tCaptureStart]= PsychPortAudio('GetAudioData', pahandle2);
    % Compute maximum signal amplitude in this chunk of data:
    if ~isempty(audiodata)
        level = max(abs(audiodata(1,:)));
    else
        level = 0;
    end
    
    % Below trigger-threshold?
    if level < triggerlevel && noresp
        % Wait for five milliseconds before next scan:
        WaitSecs(0.005);
        fprintf('---> Looking.\n');
    elseif notone
        Seeker(Pos,7) = 1; %value detected
        % Find exact location of first above threshold sample.
        idx = min(find(abs(audiodata(1,:)) >= triggerlevel)); %#ok<MXFND>
        % Compute absolute event time:
        tOnset = tCaptureStart + ((offset + idx - 1) / freq2);
        % Stop sound capture:
        PsychPortAudio('Stop', pahandle2);
        % Fetch all remaining audio data out of the buffer - Needs to be empty
        % before next trial:
        PsychPortAudio('GetAudioData', pahandle2);
        %write output
        if b==1 && GetSecs-arrow_start_time<0,
            Seeker(Pos,9)=0;
            Seeker(Pos,13)=0;
        else
            Seeker(Pos,9)=tOnset-arrow_start_time; % RT
            fprintf('---> Reaction time 1 is %f milliseconds.\n', (tOnset - arrow_start_time)*1000);
            Seeker(Pos,13)=1;
        end;
        noresp=0;
    end

WaitSecs(0.001);

if Seeker(Pos,3)==1 && GetSecs - arrow_start_time >=Seeker(Pos,6)/1000 && notone,
    %% Psychportaudio
    PsychPortAudio('FillBuffer', pahandle1, wave);
    PsychPortAudio('Start', pahandle1, 1, 0, 0);
    PsychPortAudio('Stop', pahandle1, 1);
    Seeker(Pos,14)=GetSecs-arrow_start_time;
    notone=0;
    
    
    PsychPortAudio('Start', pahandle2, 0, 0, 1);
    
    while GetSecs<Seeker(Pos,14)+1 && noresp
        %set up listening
        [audiodata offset overflow tCaptureStart]= PsychPortAudio('GetAudioData', pahandle2);
        % Compute maximum signal amplitude in this chunk of data:
        if ~isempty(audiodata)
            level = max(abs(audiodata(1,:)));
        end
        
        % Below trigger-threshold?
        if level < triggerlevel && noresp
            % Wait for five milliseconds before next scan:
            WaitSecs(0.005);
            fprintf('---> Looking 2.\n');
        else
            Seeker(Pos,7) = 1; %value detected
            % Find exact location of first above threshold sample.
            idx = min(find(abs(audiodata(1,:)) >= triggerlevel)); %#ok<MXFND>
            % Compute absolute event time:
            tOnset = tCaptureStart + ((offset + idx - 1) / freq);
            % Stop sound capture:
            PsychPortAudio('Stop', pahandle2);
            % Fetch all remaining audio data out of the buffer - Needs to be empty
            % before next trial:
            PsychPortAudio('GetAudioData', pahandle2);
            % Print RT:
            fprintf('---> Reaction time 2 is %f milliseconds.\n', (tOnset - arrow_start_time)*1000);
            if b==1 && GetSecs-arrow_start_time<0,
                Seeker(Pos,9)=0;
                Seeker(Pos,13)=0;
            else
                Seeker(Pos,9)=tOnset-arrow_start_time; % RT
            end;
            noresp=0;
        end;
    end
    end;
end; %end while
PsychPortAudio('Stop', pahandle2); % If do this,
% response doesn't end loop
