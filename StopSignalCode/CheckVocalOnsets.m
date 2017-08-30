function CheckVocalOnsets(inputfile,subject_code,block)

if nargin < 3
    inputfile = input('File name','s');
    subject_code = input('Subject code','s');
    block = input('Scan number:');
end

load(inputfile);
cd(voicefiles);
cd(subject_code);
files = dir(strcat('block',num2str(block),'*'))

for i = 1:length(Seeker); 
    
    if Seeker(i,9)~=0; Seeker(i,7) = 1; end; 

end

save(outfile, 'Seeker');
end
