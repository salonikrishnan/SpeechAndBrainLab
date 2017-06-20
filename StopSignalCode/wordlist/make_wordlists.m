fileID = fopen('fmri_wordlist_pure.txt')
formatSpec = '%s'
C = textscan(fileID,formatSpec);
fclose(fileID);

mkdir wordlist
cd wordlist
wordlist = {}; 

for i=1:128
    wordlist(i,:)=C{1}{i};
end

save('wordlist1','wordlist')
clear wordlist

for i=129:256
    wordlist{i-128}=C{1}{i}
end
save('wordlist2','wordlist')

clear all

cd ../

fileID = fopen('behav_wordlist_pure.txt')
formatSpec = '%s'
C = textscan(fileID,formatSpec);
fclose(fileID);
cd wordlist
for i = 1:10
    k(i) = 64*i
end
wordlist = {}; counter = 1;
for i = 1:640
    j=mod(i,64);
    if j == 0; j = 64; end
    wordlist{j}=C{1}{i};  
    if ismember(i,k)
    save(strcat('prescan_wordlist',num2str(counter)),'wordlist');
    counter = counter + 1;
    end
end
