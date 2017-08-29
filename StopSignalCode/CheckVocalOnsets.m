function CheckVocalOnsets(inputfile,subject_code,block)

if nargin < 3
    subject_code = input('Subject code','s');
    block = input('Scan number:');
    cd results/fMRI/subject_code/
    ls;
    inputfile = input('File name','s');
end

load(inputfile);
cd ../../../voicefiles/subject_code
files = dir(strcat('scannum',num2str(block),'*'));

InitializePsychSound(1); %low latency setting
samp = 22255;
pahandle1 = PsychPortAudio('Open', [],[],[],samp,1);

VocalOrNot = 0;
for i = 1:length(Seeker);
    
    aud_stim = 'xx';% read in name of file
    disp('Playing file');
    PsychPortAudio('FillBuffer', pahandle1, aud_stim);
    PsychPortAudio('Start', pahandle1,1);
    PsychPortAudio('Stop', pahandle1, 1);
    VocalOrNot = input('Type 1 if there was a response, 0 if not:');
    Seeker(i,7) = VocalOrNot;
    
end

PsychPortAudio('Close', pahandle1);

cd ../../results/fMRI/subject_code/
save(inputfile, 'Seeker');
end
