function make_stopsig_onsets_function(subject_code)

base_directory = sprintf('~/Documents/MATLAB/SpeechAndBrainLab/StopSignalCode/results/fMRI/sub%s',num2str(subject_code));
cd(base_directory);
size_subs = 0;
try
    
    %% first make pseudoword onsets
    
    %% read in file
    subs = dir('sw*.mat');
    size_subs = size(subs,1);
    for g = 1:size_subs
        clear filename;
        clear trigger_time;
        filename = subs(g).name;
        load(filename);
        
        %% in case trigger time exists
        late_amount = 0;
        if exist('trigger_time')
            if trigger_time > 10 && trigger_time < 12 late_amount = 2; end
            if trigger_time > 12 && trigger_time < 14 late_amount = 4; end
            if trigger_time > 14 && trigger_time < 16 late_amount = 6; end
        end
        
        %% display progress
        sprintf('Making STOPSIGNAL onset times for pseduoword run for %s',filename)
        
        %% Onset File 1: Correct Go Trials
        go_onsets=Seeker(find((Seeker(:,3)==0)),12)+late_amount;
        fname=sprintf('sw_%s_go_onsets.txt',num2str(g));
        fid=fopen(fname,'w');
        if length(go_onsets) > 0; fprintf(fid,'%0.4f\t1.5\t1\n',go_onsets); end
        fclose(fid);
        
        %% Onset File 2: Successful Stop Trials
        succ_stop_onsets=Seeker(find(Seeker(:,3)==1 & Seeker(:,7)==0),12)+late_amount;
        fname=sprintf('sw_%s_succ_stop_onsets.txt',num2str(g));
        fid=fopen(fname,'w');
        if length(succ_stop_onsets) > 0; fprintf(fid,'%0.4f\t1.5\t1\n',succ_stop_onsets); end
        fclose(fid);
        
        %% Onset File 3: Unsuccessful Stop Trials (correct arrow direction)
        unsucc_stop_onsets=Seeker(find(Seeker(:,3)==1 & Seeker(:,7)~=0),12)+late_amount;
        fname=sprintf('sw_%s_unsucc_stop_onsets.txt',num2str(g));
        fid=fopen(fname,'w');
        if length(unsucc_stop_onsets) > 0; fprintf(fid,'%0.4f\t1.5\t1\n',unsucc_stop_onsets); end
        fclose(fid);
        
        %% Onset File 4: Junk Variable (trials where participants don't respond on go trials)
        junk_onsets=Seeker(find((Seeker(:,3)==0 & Seeker(:,7)==0)),12)+late_amount;
        fname=sprintf('sw_%s_junk_onsets.txt',num2str(g));
        fid=fopen(fname,'w');
        if length(junk_onsets) > 0; fprintf(fid,'%0.4f\t1.5\t1\n',junk_onsets); end
        fclose(fid);
        
        if length(go_onsets) == 0; sprintf('%s has empty go_onsets!\n', filename); end
        if length(succ_stop_onsets) == 0; sprintf('%s has empty succ_stop_onsets!\n', filename); end
        if length(unsucc_stop_onsets) == 0; sprintf('%s has empty unsucc_stop_onsets!\n', filename); end
        if length(junk_onsets) == 0; sprintf('%s has empty junk_onsets!\n', filename); end
        
        if late_amount > 0; sprintf('%s triggered %0.0f seconds late, onsets adjusted.\n', filename,late_amount); end
        
    end
    
catch
    if size_subs ~= 0;
        fprintf('%s didnt work \n',subs(g).name);
    else
        fprintf('%s doesnt exist!\n',subject_code);
    end
end

%% then make manual onsets
LEFT = KbName('1!');
RIGHT= KbName('2@');

%% read in file
clear subs;
size_subs = 0;
subs = dir('sm*.mat');

try
    size_subs = size(subs,1);
    for g = 1:size_subs
        
        clear filename;
        clear trigger_time;
        filename = subs(g).name;
        load(filename);
        
        %% in case trigger time exists
        late_amount = 0;
        if exist('trigger_time')
            if trigger_time > 10 && trigger_time < 12 late_amount = 2; end
            if trigger_time > 12 && trigger_time < 14 late_amount = 4; end
            if trigger_time > 14 && trigger_time < 16 late_amount = 6; end
        end
        
        sprintf('Making STOPSIGNAL onset times for manual run for %s',filename)
        
        %% Onset File 1: Correct Go Trials
        go_onsets=Seeker(find((Seeker(:,3)==0 & ((Seeker(:,4)==0 & Seeker(:,7)==LEFT)|(Seeker(:,4)==1 & Seeker(:,7)==RIGHT)))),12)+late_amount;
        fname=sprintf('sm_%s_go_onsets.txt',num2str(g));
        fid=fopen(fname,'w');
        if length(go_onsets) > 0; fprintf(fid,'%0.4f\t1.5\t1\n',go_onsets); end
        fclose(fid);
        
        %% Onset File 2: Successful Stop Trials
        succ_stop_onsets=Seeker(find(Seeker(:,3)==1 & Seeker(:,7)==0),12)+late_amount;
        fname=sprintf('sm_%s_succ_stop_onsets.txt',num2str(g));
        fid=fopen(fname,'w');
        if length(succ_stop_onsets) > 0; fprintf(fid,'%0.4f\t1.5\t1\n',succ_stop_onsets); end
        fclose(fid);
        
        %% Onset File 3: Unsuccessful Stop Trials (correct arrow direction)
        unsucc_stop_onsets=Seeker(find((Seeker(:,3)==1 & Seeker(:,7)~=0 & ((Seeker(:,4)==0 & Seeker(:,7)==LEFT)|(Seeker(:,4)==1 & Seeker(:,7)==RIGHT)))),12)+late_amount;
        fname=sprintf('sm_%s_unsucc_stop_onsets.txt',num2str(g));
        fid=fopen(fname,'w');
        if length(unsucc_stop_onsets) > 0; fprintf(fid,'%0.4f\t1.5\t1\n',unsucc_stop_onsets); end
        fclose(fid);
        
        %% Onset File 4: Junk Variable (trials where participants don't respond on go trials or push the wrong button)
        junk_onsets=Seeker(find(((Seeker(:,4)==0 & Seeker(:,7)==RIGHT)|(Seeker(:,4)==1 & Seeker(:,7)==LEFT)) | (Seeker(:,3)==0 & Seeker(:,7)==0)),12)+late_amount;
        fname=sprintf('sm_%s_junk_onsets.txt',num2str(g));
        fid=fopen(fname,'w');
        if length(junk_onsets) > 0; fprintf(fid,'%0.4f\t1.5\t1\n',junk_onsets); end
        fclose(fid);
        
        if length(go_onsets) == 0; sprintf('%s has empty go_onsets!\n', filename); end
        if length(succ_stop_onsets) == 0; sprintf('%s has empty succ_stop_onsets!\n', filename); end
        if length(unsucc_stop_onsets) == 0; sprintf('%s has empty unsucc_stop_onsets!\n', filename); end
        if length(junk_onsets) == 0; sprintf('%s has empty junk_onsets!\n', filename); end
        
        if late_amount > 0; sprintf('%s triggered %0.0f seconds late, onsets adjusted.\n', filename,late_amount); end
        
    end    

catch
    if size_subs ~= 0;
        fprintf('%s didnt work \n',subs(g).name);
    else
        fprintf('%s doesnt exist!\n',subject_code);
    end
    
end