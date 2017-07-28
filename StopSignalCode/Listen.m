function resptime = Listen(maxsecs)

if nargin <1
    maxsecs = 1;
end

voicetrigger = 0.05;

freq = 44100;
pahandle = PsychPortAudio('Open', [], 2, 0, freq, 2);
PsychPortAudio('GetAudioData', pahandle, 1);
recordedaudio = [];

PsychPortAudio('Start', pahandle, 0, 0, 1); % start recording

start_time = GetSecs;
level = 0;
while level < voicetrigger

    [audiodata offset overflow tCaptureStart] = PsychPortAudio('GetAudioData', pahandle); %get current audiodata
    
    if ~isempty(audiodata)
        level = max(abs(audiodata(1,:))); % Compute maximum signal amplitude in this chunk of data:
    else
        level = 0;
        disp('nothing detected');
    end
    
    if level > voicetrigger
        resptime=GetSecs-start_time;
        PsychPortAudio('Stop', pahandle);
    else
        WaitSecs(0.005);
        disp('rescan');
    end


end

end
