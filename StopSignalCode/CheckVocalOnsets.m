function CheckVocalOnsets(inputfile,subject_code,block)
base_directory = '~/Documents/MATLAB/SpeechAndBrainLab/StopSignalCode/';
if nargin < 3
    subject_code = input('Subject code','s');
    block = input('Scan number:');
    cd(strcat(base_directory,'results/fMRI/sub',num2str(subject_code),'/'));
    ls -1;
    inputfile = input('File name','s');
end

load(inputfile);
cd(strcat(base_directory,'voicefiles/sub',num2str(subject_code),'/'))
files = dir(strcat('session',num2str(block),'*'));

InitializePsychSound(1); %low latency setting
samp = 44100;
pahandle1 = PsychPortAudio('Open', [],[],[],samp,2);

VocalOrNot = 0;
for i = 1:size(files)
    try
        y = strsplit(files(i).name, '_');
        x = strsplit(y{1,3},'.');
        Pos = str2double(x{1});
        [aud_stim, samp] = audioread(files(i).name);% read in name of file
        fprintf('Playing file %s \n',files(i).name);
        PsychPortAudio('FillBuffer', pahandle1, aud_stim');
        PsychPortAudio('Start', pahandle1,1);
        PsychPortAudio('Stop', pahandle1, 1);
        fprintf('Initially coded as %s \n',num2str(Seeker(Pos,7)));
        VocalOrNot = input('Type 1 if there was a response, 0 if not:');
        Seeker(Pos,7) = VocalOrNot;
    catch
        sprintf('error playing file %s', files(i).name);
    end
end

PsychPortAudio('Close', pahandle1);

cd(strcat(base_directory,'voicefiles/sub',num2str(subject_code),'/'))
save(inputfile, 'Seeker');
end