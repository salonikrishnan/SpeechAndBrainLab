 
function trialcodeDur = generate_MRI_trialcode(durationname)
%%%%%%%%%%%%%%%%%%%%%%%%% MAKES TRIAL SEQUENCE **********
    %%% this code correctly creates 192 (actually 384 with null) trials such that in every 16 trials there is one of each staircase
    %%%   type and the number of left and rightward button presses is equal every four trials.

    
    %trialcode(:,1) = trial type 0= go, 1=stop; 2=null
    %trialcode(:,2) = duration
    %trialcode(:,3) = timecourse
    %trialcode(:,4) = trial type 0= go, 1=stop; 2=null
    %trialcode(:,5) = The fifth column is ladder number (1-4)

clear trialcode
NUMCHUNKS = 3;

for  tc=1:NUMCHUNKS
        for qblock=1:4
            LadderOrder=randperm(4);
            for st=1:4
                arrows = [0 1 0 1];
                [p  rand_idx]=sort(rand(1,4));
                arrows=arrows(rand_idx);
                %there are 4 in each, one stop, three go
                mini = [1 arrows(1) LadderOrder(st); 0 arrows(2) 0; 0 arrows(3) 0; 0 arrows(4) 0];
                [p  rand_idx]=sort(rand(1,4));
                mini=mini(rand_idx,:);
                start=(tc-1)*64+(qblock-1)*16+(st-1)*4+1;
                endof=(tc-1)*64+(qblock-1)*16+(st)*4;
                trialcode(start:endof,:)=mini;
            end
        end
end

mat2 = [2 2 0];
trialcodeNEW = insertrows(trialcode, mat2, 1:1:length(trialcode));
if nargin < 1
    durationname = 1;
end

load('durations.mat');
if durationname == 1
rand_isi_long = duration1; 
elseif durationname == 2
    rand_isi_long = duration2; 
elseif durationname == 3
    rand_isi_long = duration3;
elseif durationname == 4
    rand_isi_long = duration4; 

end


[p1  rand_idx1]=sort(rand(1,length(rand_isi_long)));

rand_isi_long=rand_isi_long(rand_idx1);

j=1;
for i=1:length(trialcodeNEW)
    
    trialtype = trialcodeNEW(i,1);
    arrowtype = trialcodeNEW(i,2);
    laddernumber = trialcodeNEW(i,3);
    
    if trialcodeNEW(i,1) ~= 2
        trialdur = 1.5;
    else
        trialdur = rand_isi_long(j);
        j=j+1;
    end
    
    if i == 1
        totalduration = 0;
    else
        totalduration = trialcodeDur(i-1,2) + trialcodeDur(i-1,3);
    end
    
    trialcodeDur(i,:) = [trialtype, trialdur, totalduration, arrowtype, laddernumber];
end


