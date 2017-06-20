%% testing changes

InitializePsychSound(0);

samp = 22255;
aud_stim = sin(1:0.25:1000);

pahandle = PsychPortAudio('Open', [],[],[],samp,1);
PsychPortAudio('FillBuffer', pahandle, aud_stim);
PsychPortAudio('Start', pahandle,1);
PsychPortAudio('Stop', pahandle, 1);