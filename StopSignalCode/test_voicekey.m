% activewire(1,'OpenDevice')
%
% for t=1:10,
%     fprintf('Speak!\n');
%     starttime = GetSecs;
%     voice=0;
%     portvalue=ones(1,16);
%     while voice==0,
%         portvalue = activewire(1,'GetPort');
%         if isempty(find(portvalue==0)), voice=1; end;
%     end;
%     time = GetSecs-starttime
%     WaitSecs(2);
% end
% activewire(1,'CloseDevice')
voicetrigger = 0.05;
maxsecs = 3;
wavfilename = 'test.wav';
InitializePsychSound(1);

freq = 44100;
pahandle = PsychPortAudio('Open', [], 2, 0, freq, 2);
PsychPortAudio('GetAudioData', pahandle, 10);


for t=1:5
    fprintf('Speak!\n');
    voice=0;
    PsychPortAudio('Start', pahandle, 0, 0, 1);
    
    if voicetrigger > 0 % Yes. Fetch audio data and check against threshold:
        level = 0;
        while level < voicetrigger % Repeat as long as below trigger-threshold:
            [audiodata offset overflow tCaptureStart] = PsychPortAudio('GetAudioData', pahandle);
            if ~isempty(audiodata)
                level = max(abs(audiodata(1,:))); % Compute maximum signal amplitude in this chunk of data:
            else
                level = 0;
            end
            
            if level < voicetrigger             % Below trigger-threshold?
                WaitSecs(0.0001); % Wait for a millisecond before next scan:
            end
        end
        idx = min(find(abs(audiodata(1,:)) >= voicetrigger)); %#ok<MXFND> % Ok, last fetched chunk was above threshold!
        % Find exact location of first above threshold sample.
        recordedaudio = audiodata(:, idx:end);         % Initialize our recordedaudio vector with captured data starting from
        % triggersample:
        tOnset = tCaptureStart + ((offset + idx - 1) / freq);
        fprintf('Estimated signal onset time is %f secs, this is %f msecs after start of capture.\n', tOnset, (tOnset - tCaptureStart)*1000);
        
        % We retrieve status once to get access to SampleRate:
        s = PsychPortAudio('GetStatus', pahandle);
        
        while (length(recordedaudio) / s.SampleRate) < maxsecs
            audiodata = PsychPortAudio('GetAudioData', pahandle);
            nrsamples = size(audiodata, 2);
            recordedaudio = [recordedaudio audiodata]; %#ok
        end
        
        PsychPortAudio('Stop', pahandle, 1);
        
        % Perform a last fetch operation to get all remaining data from the capture engine:
        audiodata = PsychPortAudio('GetAudioData', pahandle);
        
        % Attach it to our full sound vector:
        recordedaudio = [recordedaudio audiodata];
        
        if ~isempty(wavfilename)
            psychwavwrite(transpose(recordedaudio), 44100, 16, wavfilename)
        end
    else
        recordedaudio = [];         % Start with empty sound vector:    
    end
end

% Close the audio device:
PsychPortAudio('Close', pahandle);

