%% Calculate(SSDc)
% Central SSD was computed, for each subject, from the values of the 4 staircases after the subject had converged on 50% P(inhibit). 
%Values for the last 10 moves of each staircase were averaged to give a stable SSD estimate. 
% In case a staircase did not converge (which was rare), it was removed from analysis 
% and the SSDs from the remaining staircases were averaged to estimate the SSDc. 

%%%%%%%%%%%%%% Stimuli and Response on same matrix, pre-determined
% The first column is  trial number;
% The second column is block
% The third column is 0 = Go, 1 = NoGo; 2 is null, 3 is notrial (kluge, see opt_stop.m)
% The fourth column is 0=left, 1=right arrow; 2 is null
% The fifth column is ladder number (1-4);
% The sixth column is the value currently in "LadderX", corresponding to this...
% The seventh column is subject response (no response is 0);
% The eighth column is their reaction time
% The ninth column is time since beginning of trial
% The tenth column is ladder movement (-1 for down, +1 for up, 0 for N/A)	
filename = 'results/s21_j1_sw_18-Jun_17-43'		
load(filename);

%Ladder1
a=find(Seeker(:,5)==1);
Ladder1 = [Seeker(a,6) Seeker(a,7) Seeker(a,8) Seeker(a,10)];

a=find(Seeker(:,5)==2);
Ladder2 = [Seeker(a,6) Seeker(a,7) Seeker(a,8) Seeker(a,10)];

a=find(Seeker(:,5)==3);
Ladder3 = [Seeker(a,6) Seeker(a,7) Seeker(a,8) Seeker(a,10)];

a=find(Seeker(:,5)==4);
Ladder4 = [Seeker(a,6) Seeker(a,7) Seeker(a,8) Seeker(a,10)];

%%%% Make SSD graphs

a = max(Ladder1);
b = max(Ladder2);
c = max(Ladder3);
d = max(Ladder4);
ymax=max([a b c d]);
a = min(Ladder1);
b = min(Ladder2);
c = min(Ladder3);
d = min(Ladder4);
ymin=min([a b c d]);
if ymin>0,
	ymin=0;
end;

xmax=length(Ladder1)+1;

for a=1:size(Ladder1),
    Ladder1Plot(2*a-1)=Ladder1(a);
    Ladder2Plot(2*a-1)=Ladder2(a);
    Ladder3Plot(2*a-1)=Ladder3(a);
    Ladder4Plot(2*a-1)=Ladder4(a);
    Ladder1Plot(2*a)=Ladder1(a);
    Ladder2Plot(2*a)=Ladder2(a);
    Ladder3Plot(2*a)=Ladder3(a);
    Ladder4Plot(2*a)=Ladder4(a);
end;

subplot(2,2,1);
for a=1:size(Ladder1)-1;
	hold on;
	plot(a:a+1,Ladder1Plot(2*a-1:2*a), 'b');
	plot([a+1 a+1],Ladder1Plot(2*a:2*a+1), 'b');
end;
axis([1 xmax ymin ymax]);
subplot(2,2,2);
for a=1:size(Ladder2)-1;
	hold on;
	plot(a:a+1,Ladder2Plot(2*a-1:2*a), 'b');
	plot([a+1 a+1],Ladder2Plot(2*a:2*a+1), 'b');
end;
axis([1 xmax ymin ymax]);
subplot(2,2,3);
for a=1:size(Ladder3)-1;
	hold on;
	plot(a:a+1,Ladder3Plot(2*a-1:2*a), 'b');
	plot([a+1 a+1],Ladder3Plot(2*a:2*a+1), 'b');
end;
axis([1 xmax ymin ymax]);
subplot(2,2,4);
for a=1:size(Ladder4)-1;
	hold on;
	plot(a:a+1,Ladder4Plot(2*a-1:2*a), 'b');
	plot([a+1 a+1],Ladder4Plot(2*a:2*a+1), 'b');
end;
axis([1 xmax ymin ymax]);

num_steps = 10; %use last ten steps

%go rt
GRTmedian=median(Seeker(find(Seeker(:,1)>32 & Seeker(:,3)==0 & (Seeker(:,7)~=0)),8))*1000;
GRTmean=mean(Seeker(find(Seeker(:,1)>32 & Seeker(:,3)==0 & (Seeker(:,7)~=0)),8))*1000;
StDevGRT=std(Seeker(find(Seeker(:,1)>32 & Seeker(:,3)==0 & (Seeker(:,7)~=0)),8))*1000;

BOTT=length(Ladder1)-num_steps+1-1; TOP=length(Ladder1)-1; % look at last X steps of ladder
% look at last X steps of ladder, subtract 1 because want to include actual
% SSDs on each trial, and if don't -1 then includes what the next SSD will be
Ladder1mean=mean(Ladder1(BOTT:TOP));
Ladder2mean=mean(Ladder2(BOTT:TOP));
Ladder3mean=mean(Ladder3(BOTT:TOP));
Ladder4mean=mean(Ladder4(BOTT:TOP));

SSDfifty=mean([Ladder1mean Ladder2mean Ladder3mean Ladder4mean]);
SSRT=GRTmedian-SSDfifty;

% Percent Inhibition from bottom to top (so last X steps); do separately
% for each ladder and then average
for ladder=1:4,
    tmp=Seeker(find(Seeker(:,5)==ladder),7);
    tmp2=tmp(length(tmp)-num_steps+1:length(tmp)); % last X steps of ladder
    PctInhib(ladder)=100*sum(tmp2(:)==0)/length(tmp2);
end;

PctGoResp=100*(sum(Seeker(:,3)==0 & Seeker(:,7) ~= 0) / sum(Seeker(:,3)==0));

%Analysis to get SSRT using quantile based on actual PctInhib as opposed to assuming 50% like above
corr_rt=Seeker(find(Seeker(:,1)>32 & Seeker(:,3)==0 & Seeker(:,7)~=0),8)*1000;
GRTquant=quantile(corr_rt,mean(100-PctInhib)/100);
SSRTquant=GRTquant-SSDfifty;

fprintf('Median Go Reaction Time at 50 pct inhib(ms): %f\n',GRTmedian);
fprintf('Median Go Reaction Time at %0.2f pct inhib (ms): %f\n',mean(PctInhib),GRTquant);
fprintf('StDev Go Reaction Time: %f\n',StDevGRT);
fprintf('Mean SSD Ladder 1 (ms): %f\n',Ladder1mean);
fprintf('Mean SSD Ladder 2 (ms): %f\n',Ladder2mean);
fprintf('Mean SSD Ladder 3 (ms): %f\n',Ladder3mean);
fprintf('Mean SSD Ladder 4 (ms): %f\n',Ladder4mean);
fprintf('Subject mean SSD (ms): %f\n', SSDfifty);
%fprintf('Percent discrimination errors: %f\n',PctDimErrors);
fprintf('Percent responding on go trials: %f\n',PctGoResp);
fprintf('Subject SSRT assuming 50 pct inhib (ms): %f\n', SSRT);
fprintf('Subject SSRT at %0.2f pct inhib (ms): %f\n',mean(PctInhib),SSRTquant);
fprintf('Percent Inhibition Ladder 1: %0.1f\n',PctInhib(1));
fprintf('Percent Inhibition Ladder 2: %0.1f\n',PctInhib(2));
fprintf('Percent Inhibition Ladder 3: %0.1f\n',PctInhib(3));
fprintf('Percent Inhibition Ladder 4: %0.1f\n',PctInhib(4));

