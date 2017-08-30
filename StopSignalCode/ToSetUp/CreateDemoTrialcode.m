NUMCHUNKS=1;
for  tc=1:NUMCHUNKS
    for qblock=1:4
        LadderOrder=[randperm(2) randperm(2)];
        for st=1:4
            %there are 4 in each, one stop, three go
            if qblock ~= 1
                arrows = [1 0 1 0];
                [p  rand_idx]=sort(rand(1,4));
                arrows=arrows(rand_idx);
                mini = [1 arrows(2) LadderOrder(st); 0 arrows(1) 0; 0 arrows(3) 0; 0 arrows(4) 0;];
                [p  rand_idx]=sort(rand(1,4));
                mini=mini(rand_idx,:);
            else
                if st == 1 || st == 2
                    arrows = [1 0 1 0];
                    [p  rand_idx]=sort(rand(1,4));
                    arrows=arrows(rand_idx);
                    mini = [0 arrows(1) 0; 0 arrows(2) 0; 0 arrows(3) 0; 1 arrows(4) LadderOrder(st)];
                else
                    arrows = [1 0 1 0];
                    [p  rand_idx]=sort(rand(1,4));
                    arrows=arrows(rand_idx);
                    mini = [0 arrows(1) 0; 1 arrows(2) LadderOrder(st); 0 arrows(3) 0; 0 arrows(4) 0];
                end
            end
            start=(tc-1)*64+(qblock-1)*16+(st-1)*4+1;
            endof=(tc-1)*64+(qblock-1)*16+(st)*4;
            trialcode(start:endof,:)=mini;
        end
    end
end


save('democode.mat');