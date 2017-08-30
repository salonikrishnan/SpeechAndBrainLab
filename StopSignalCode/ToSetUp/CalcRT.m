filename='test.wav';
[Y,fs]=audioread(filename);
data = Y(:,1); %in case of a stereo track

%%% Plot the data %%%
dt=1/fs;
t = 0:dt:(length(data)*dt)-dt;
plot(t,data); xlabel('Seconds'); ylabel('Amplitude');
%%%%%%%%%%%%%%%%%%%%%

threshold = 0.001; %we will have to play around with this to see what works
response_time = find(abs(data-median(data)) > threshold, 1, 'first' );
disp(response_time);
disp(response_time/fs); % this calculates reaction time in seconds by factoring in sampling rate 