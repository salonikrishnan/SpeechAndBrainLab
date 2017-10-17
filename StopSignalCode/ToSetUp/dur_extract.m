%extract durations from the files Xue sent

durations = [];

for s = 1:12
    for f=1:3
        filename = strcat('s',num2str(s),'_f',num2str(f),'.mat');
        load(filename)
        for i =1:length(trialcode)
            if trialcode(i,1)==2
                durations = [durations trialcode(i,2)];
            end
        end
    end
end


[p  rand_idx]=sort(rand(1,length(durations)));
durations=durations(rand_idx);
durations_concat = durations(1:192);

while sum(durations_concat) < 253 || sum(durations_concat) > 255 || mean(durations_concat) < 1.3 || mean(durations_concat) > 1.35  
    [p  rand_idx]=sort(rand(1,length(durations)));
    durations=durations(rand_idx);
    durations_concat = durations(1:192);
end;

hist(durations_concat)

duration4 = durations_concat; %this was changed from 1, 2 ,3 4
savefile = 'durations.mat';
save(savefile,'duration1','duration2','duration3','duration4')
