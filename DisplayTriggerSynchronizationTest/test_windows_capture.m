clear all
dataDir= '..\DATA\';
rootDir = '..\..\STIM2EEG-LAB\' 
addpath([genpath('C:\Users\Jason\Documents\MATLAB\xdf\Matlab') genpath(rootDir)])
Filename= '..\DATA\180s_flash_30hz_window_capture.xdf';
%Filename= '..\DATA\180s_flash_30hz_stimplayer.xdf';

%Filename= '..\DATA\.xdf';

[Streams,FileHeader] = load_xdf(Filename)
saveFigure = false;
% convert lsl data for synchronization analysis 
for i =1:length(Streams)
    disp(Streams{i}.info.name);
    switch Streams{i}.info.name
        case 'BrainAmpSeries-Markers'
            flashStreamIndx=i
            tmp1=str2num(cell2mat(Streams{flashStreamIndx}.time_series'));
            flashEventTimeStamp = Streams{flashStreamIndx}.time_stamps;
        case 'OBS Studio'
            StimulusPlayerIndx=i
            tmp2=Streams{StimulusPlayerIndx}.time_series(1,:)';
            tmp3=Streams{StimulusPlayerIndx}.time_series(2,:)';
            frameTimeStamp =Streams{StimulusPlayerIndx}.time_stamps;
        case 'StimulusPlayer-Markers'
            StimulusPlayerIndx=i
            tmp2=Streams{StimulusPlayerIndx}.time_series(1,:)';
            tmp3=Streams{StimulusPlayerIndx}.time_series(2,:)';
            frameTimeStamp =Streams{StimulusPlayerIndx}.time_stamps;
        case 'BrainAmpSeries (EEG)'
            eegIndx=i
        otherwise
            continue
    end
end

%% indexing timestamp for the incoming flashes
% take a diff between timestamps to find beginning time point of each
% flash.
dflashEventTimeStamp = diff(flashEventTimeStamp); 
% due to irregularities in timestamp only find indexes in which time change
% of timetamps are greater than 900ms which is an approximate of time
% difference between each occuring flash.
% the first timestamp corresponds to the time in which the first flash
% appeared on the screen.
timeStampIndex = find(dflashEventTimeStamp>.8)+1;
timeStampIndex=[1 timeStampIndex]
flashStartTimeIndx = flashEventTimeStamp(timeStampIndex);
%flashStartTimeIndx = [flashEventTimeStamp(1) flashStartTimeIndx];
m1 = mean(diff(flashStartTimeIndx))
s1 = std(diff(flashStartTimeIndx))
figure(1);clf;
subplot(2,1,1);hold on;title('flash occurence timestamp')
plot(flashEventTimeStamp,'b');plot(timeStampIndex,flashStartTimeIndx,'r.');
legend('original time stamp','beginning of flash')
subplot(2,1,2);title('time difference between each flash');plot(diff(flashStartTimeIndx),'.');
legend(['m=' num2str(m1) ', std=' num2str(s1)])



vidObj = VideoReader('window_capture_flash_180s_30hz_2.mp4')
vidFrames=read(vidObj);
nFrames=size(vidFrames,4);

for i=1:nFrames
    avgFrames(i)=mean(mean(mean(vidFrames(:,:,:,i),3),2));
end
plot(avgFrames)
videoFlashIndx=find(avgFrames>200)-1;
%get frame markers
for i=1:length(videoFlashIndx)
   indxed=find(tmp2==(videoFlashIndx(i))); 
   if indxed
       indx(i)=videoFlashIndx(i);
   else
       indx(i)=0;
   end
end
frameMarkerFlashTimeStamp=frameTimeStamp(indx)
nSample=length(timeStampIndex)
figure(2)
clf;hold on
plot(flashStartTimeIndx-frameMarkerFlashTimeStamp,'.k')
plot(flashStartTimeIndx-frameMarkerFlashTimeStamp,'g')
s=std(flashStartTimeIndx-frameMarkerFlashTimeStamp)
m=mean(flashStartTimeIndx-frameMarkerFlashTimeStamp)
plot(1:nSample,m*ones(nSample,1),'r-');
plot(1:nSample,[s*ones(nSample,1) -s*ones(nSample,1) ]+m,'b--');
title('time diff between flash event and frame marker');
legend('flash event vs frame maker time difference', ['mean=' num2str(round(m,3))],['std=' num2str(round(s,3))])

