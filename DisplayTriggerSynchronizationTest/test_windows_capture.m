clear all;
dataDir= '..\DATA\';
rootDir = '..\..\STIM2EEG-LAB\' ;
addpath([genpath('C:\Users\Jason\Documents\MATLAB\xdf\Matlab') genpath(rootDir)]);
Filename= '..\DATA\180s_flash_30hz_window_capture.xdf';
[Streams,FileHeader] = load_xdf(Filename);
saveFigure = false;

% convert lsl data for synchronization analysis 
for i =1:length(Streams)
    disp(Streams{i}.info.name);
    switch Streams{i}.info.name
        case 'BrainAmpSeries-Markers'
            tmp1=str2num(cell2mat(Streams{i}.time_series'));
            photodiodeTimestamp = Streams{i}.time_stamps;
        case 'OBS Studio'
            n=size(Streams{i}.time_series,1);
            for ii=1:n;eval(['tmp' num2str(ii+1) '=Streams{i}.time_series(' num2str(ii) ',:)'';']);end
            frameTimestamp =Streams{i}.time_stamps;
        case 'StimulusPlayer-Markers'
            StimulusPlayerIndx=i;
            n=size(Streams{i}.time_series,1);
            for ii=1:n;eval(['tmp' num2str(ii+1) '=Streams{i}.time_series(' num2str(ii) ',:)'';']);end
            frameTimestamp =Streams{i}.time_stamps;
        case 'BrainAmpSeries (EEG)'
            eegIndx=i
        otherwise
            continue
    end
end

%% indexing timestamp for the flashe events on the photodiode
% take a diff between timestamps to find beginning time point of each
% flash.
dflashEventTimeStamp = diff(photodiodeTimestamp); 
% due to irregularities in timestamp only find indexes in which time change
% of timetamps are greater than 900ms which is an approximate of time
% difference between each occuring flash.
% the first timestamp corresponds to the time in which the first flash
% appeared on the screen.
timestampIndx = find(dflashEventTimeStamp>.8)+1;
timestampIndx=[1 timestampIndx];
nFlash=length(timestampIndx)

flashTimestamp = photodiodeTimestamp(timestampIndx);
m1 = mean(diff(flashTimestamp))
s1 = std(diff(flashTimestamp))

figure(1);clf;
subplot(2,1,1);hold on;title('flash occurence timestamp')
plot(photodiodeTimestamp,'b');plot(timestampIndx,flashTimestamp,'r.');
legend('original time stamp','beginning of flash')
subplot(2,1,2);hold on;title('time difference between each flash');
plot(diff(flashTimestamp));plot(diff(flashTimestamp),'.');
legend(['m=' num2str(m1) ', std=' num2str(s1)])

%%
figure; hist(diff(flashTimestamp),30);
%% indexing timestamp for the flashe events based on the intensity value of each frame
videoFiles=dir('*.mp4');
vidObj = VideoReader(videoFiles(end).name)
vidFrames=read(vidObj);
nFrames=size(vidFrames,4);
% compute average pixel intensity for frame
for i=1:nFrames
    avgFrames(i)=mean(mean(mean(vidFrames(:,:,:,i),3),2));
end
% find flash frame based on a threshold
flashFrameIndx=find(avgFrames>(max(avgFrames)-100)); %indexing the flash 

for i=1:length(flashFrameIndx)
    indx(i)=find(tmp2==flashFrameIndx(i));
end
flashFrameTimestamp=frameTimestamp(indx(1:nFlash));
nSample=length(flashFrameTimestamp);

figure(2)
clf;
subplot(3,1,1);hold on
plot(avgFrames);plot(flashFrameIndx,avgFrames(flashFrameIndx),'r.');
title('mean pixel intensity per frame');
legend('mean pixel per frame','flash frame')

subplot(3,1,2);hold on
plot(flashTimestamp:-flashFrameTimestamp,'.k')
plot(flashTimestamp-flashFrameTimestamp,'g')
s=std(flashTimestamp-flashFrameTimestamp)
m=mean(flashTimestamp-flashFrameTimestamp)
plot(1:nSample,m*ones(nSample,1),'r-');
plot(1:nSample,[s*ones(nSample,1) -s*ones(nSample,1) ]+m,'b--');
title('time difference between flash event and frame maker output event');
legend('time difference', ['mean=' num2str(round(m,3))],['std=' num2str(round(s,3))])

subplot(3,1,3);hold on
indx = 1:length(tmp3)
plot((tmp3(indx)-tmp4(indx))*10^-9)
title('time diff between tick event and output event');

figure(3);clf
hold on
y1=diff(diff(flashTimestamp));
y2=diff(flashTimestamp-flashFrameTimestamp);
y1=(y1-mean(y1))/std(y1);
y2=(y2-mean(y2))/std(y2);
plot(y1,'.-b');
plot(y2(2:end),'.-r');
plot(NaN,NaN,'*');
[RHO,PVAL]=corr(y1',y2(2:end)')
title('flash event and frame marker event intervals')
legend('flash event interval','time difference interval between flash and frame marker',['p=' num2str(RHO)])
