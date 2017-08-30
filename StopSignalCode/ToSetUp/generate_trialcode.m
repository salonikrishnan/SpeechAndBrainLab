 %%%%%%%%%%%%%%%%%%%%%%%%% MAKES TRIAL SEQUENCE **********
    %%% this code correctly creates 64 (actually 128 with null) trials such that in every 16 trials there is one of each staircase
    %%%   type and the number of left and rightward button presses is equal every four trials.

    clear trialcode
NUMCHUNKS = 4;

load null_events;

for  tc=1:NUMCHUNKS
        for qblock=1:4
            LadderOrder=randperm(4);
            arrows = [1 1 0 0];
            [p  rand_idx]=sort(rand(1,4));
            arrows=arrows(rand_idx);
            for st=1:4
                %there are 4 in each, one stop, three go
                mini = [1 arrows(1) LadderOrder(st); 0 arrows(2) 0; 0 arrows(3) 0; 0 arrows(4) 0;];
                [p  rand_idx]=sort(rand(1,4));
                mini=mini(rand_idx,:);
                start=(tc-1)*64+(qblock-1)*16+(st-1)*4+1;
                endof=(tc-1)*64+(qblock-1)*16+(st)*4;
                trialcode(start:endof,:)=mini;
            end
        end
end
    
mat2 = [2 0 0];

newMAT = insertrows(trialcode, mat2, 2:1:length(trialcode));

trialcodeNEW = [newMAT(:,1) ones(length(newMAT),1) ones(length(newMAT),1) newMAT(:,2) newMAT(:,3)];

