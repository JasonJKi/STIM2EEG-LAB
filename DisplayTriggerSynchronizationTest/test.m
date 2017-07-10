clear all
dataDir= '..\DATA\';
stimToEegCcaDir = '..\..\STIM2EE-GLAB\' 
addpath([genpath('../liblsl-Matlab/') genpath(stimToEegCcaDir)])
Filename= '..\DATA\180s_flash_30hz.xdf';
[Streams,FileHeader] = load_xdf(Filename)

% convert lsl data for synchronization analysis 
for i =1:length(Streams)
    disp(Streams{i}.info.name);
    switch Streams{i}.info.name
        case 'BrainAmpSeries-Markers'
            flashStreamIndx=i
            tmp1=str2num(cell2mat(Streams{flashStreamIndx}.time_series'));
            timeStamp1 = Streams{flashStreamIndx}.time_stamps;
        case 'OBS Studio'
            StimulusPlayerIndx=i
            tmp2=Streams{StimulusPlayerIndx}.time_series(1,:)';
            tmp3=Streams{StimulusPlayerIndx}.time_series(2,:)';
            timeStamp2 = Streams{StimulusPlayerIndx}.time_stamps;
        case 'BrainAmpSeries (EEG)'
            eegIndx=i
        otherwise
            continue
    end
end

%% indexing timestamp for the incoming flashes
% take a diff between timestamps to find beginning time point of each
% flash.
dTimeStamp1 = diff(timeStamp1); 
% due to irregularities in timestamp only find indexes in which time change
% of timetamps are greater than 900ms which is an approximate of time
% difference between each occuring flash.
% the first timestamp corresponds to the time in which the first flash
% appeared on the screen.
timeStampIndex = find(dTimeStamp1>.9)+1;
flashStartTimeIndx = timeStamp1(timeStampIndex);
flashStartTimeIndx = [timeStamp1(1) flashStartTimeIndx]
m1 = mean(diff(flashStartTimeIndx))
s1 = std(diff(flashStartTimeIndx))

figure(1);clf;
subplot(2,1,1);hold on;title('flash occurence timestamp')
plot(timeStamp1,'b');plot([1 timeStampIndex],flashStartTimeIndx,'r.');
legend('original time stamp','beginning of flash')
subplot(2,1,2);title('time difference between each flash');plot(diff(flashStartTimeIndx),'.');
legend(['time difference between the flashes, m=' num2str(m1)])
saveas(figure(1),'DisplayMonitorFlashMarker.png');


%% indexing timestamp for the coinciding frame markers of when the flashe occurs
dTframeTime1 = .3332; %estim difference in film time 
frameTimeTimestampIndx=find(diff(tmp2) > dTframeTime1); % indexing frame time 
dTframeTime2 = .999; %estim difference in film number
frameNumberTimestampIndx=find((diff(tmp3)) > dTframeTime2); % indexing frame number
frameMarkerTimeStamp=timeStamp2(frameNumberTimestampIndx);
% take timestamp of every 30th frame in which the flash should've appeared 
frameMarkerFlashTimeStamp=frameMarkerTimeStamp(30:30:end); 

figure(2);clf;hold on
subplot(2,1,1);stem(frameTimeTimestampIndx,tmp2(frameTimeTimestampIndx),'r');title('media frame time timestamp');
subplot(2,1,2);stem(frameNumberTimestampIndx,tmp3(frameNumberTimestampIndx),'b');title('media frame number timestamp');
saveas(figure(2),'MediaPlayerFrameMarker.png');

figure(3);clf;hold on
m=mean((flashStartTimeIndx-frameMarkerFlashTimeStamp))
s=std((flashStartTimeIndx-frameMarkerFlashTimeStamp))
plot(flashStartTimeIndx,'.b');
plot(frameMarkerFlashTimeStamp,'.r');
legend('flash event time', 'corresponding frame marker time')
title(['time diff between flash event and frame marker, m=' num2str(m) ' ,s=' num2str(s)]);
saveas(figure(3),'TimeDiffBetweenMediaFrameMarkerVsDisplayFlash.png');
