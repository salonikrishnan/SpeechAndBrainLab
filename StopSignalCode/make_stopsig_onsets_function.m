function make_stopsig_onsets_function(directory_name)

base_directory = sprintf('~/Documents/MATLAB/SpeechAndBrainLab/StopSignalCode/results/%s',directory_name);
cd(base_directory);
subs = dir('f*');
% logfile_name = sprintf('/space/raid2/data/poldrack/CNP/scripts/behav_analyze/STOPSIGNAL/%s_stopsig_log.txt', directory_name);
% logfile = fopen(logfile_name,'a');

LEFT = KbName('1!'); 
RIGHT= KbName('2@'); 

try
    
    clear filename;
    clear trigger_time;
    filename=dir('*sw*'); %select pseudoword files
    load(filename.name);
    
    late_amount = 0;
    if exist('trigger_time')
        if trigger_time > 10 && trigger_time < 12 late_amount = 2; end
        if trigger_time > 12 && trigger_time < 14 late_amount = 4; end
        if trigger_time > 14 && trigger_time < 16 late_amount = 6; end
    end
    
    sprintf('Making STOPSIGNAL onset times for pseduoword run for %s',subs(g).name)
    
    % Onset File 1: Correct Go Trials
    
    go_onsets=Seeker(find((Seeker(:,3)==0)),12)+late_amount;
    fname=sprintf('run1_go_onsets.txt');
    fid=fopen(fname,'w');
    if length(go_onsets) > 0 fprintf(fid,'%0.4f\t1.5\t1\n',go_onsets); end
    fclose(fid);
    
    % Onset File 2: Successful Stop Trials
    
    succ_stop_onsets=Seeker(find(Seeker(:,3)==1 & Seeker(:,7)==0),12)+late_amount;
    fname=sprintf('run1_succ_stop_onsets.txt');
    fid=fopen(fname,'w');
    if length(succ_stop_onsets) > 0 fprintf(fid,'%0.4f\t1.5\t1\n',succ_stop_onsets); end
    fclose(fid);
    
    % Onset File 3: Unsuccessful Stop Trials (correct arrow direction)
    unsucc_stop_onsets=Seeker(find((Seeker(:,3)==1 & Seeker(:,7)~=0 & ((Seeker(:,4)==0 & Seeker(:,7)==LEFT)|(Seeker(:,4)==1 & Seeker(:,7)==RIGHT)))),12)+late_amount;
    
    fname=sprintf('run1_unsucc_stop_onsets.txt');
    fid=fopen(fname,'w');
    if length(unsucc_stop_onsets) > 0 fprintf(fid,'%0.4f\t1.5\t1\n',unsucc_stop_onsets); end
    fclose(fid);
    
    % Onset File 4: Junk Variable (trials where participants don't respond on go trials)
    junk_onsets=Seeker(find((Seeker(:,3)==0 & Seeker(:,7)==0)),12)+late_amount;
    
catch
    fprintf('%s didnt work or doesnt exist!\n',subs(g).name);
end;
    
