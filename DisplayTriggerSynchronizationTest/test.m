clear all
dataDir= '..\DATA\';
stimToEegCcaDir = '..\..\STIM2EEG-LAB\' 
addpath([genpath('../liblsl-Matlab/') genpath(stimToEegCcaDir)])
Filename= '..\DATA\180s_flash_30hz.xdf';
[Streams,FileHeader] = load_xdf(Filename)
saveFigure = true;
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
            frameTimeStamp = Streams{StimulusPlayerIndx}.time_stamps;
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
flashStartTimeIndx = flashEventTimeStamp(timeStampIndex);
flashStartTimeIndx = [flashEventTimeStamp(1) flashStartTimeIndx]
timeStampIndex=[1 timeStampIndex]
m1 = mean(diff(flashStartTimeIndx))
s1 = std(diff(flashStartTimeIndx))
figure(1);clf;
subplot(2,1,1);hold on;title('flash occurence timestamp')
plot(flashEventTimeStamp,'b');plot(timeStampIndex,flashStartTimeIndx,'r.');
legend('original time stamp','beginning of flash')
subplot(2,1,2);title('time difference between each flash');plot(diff(flashStartTimeIndx),'.');
legend(['time difference between the flashes, m=' num2str(m1)])

%% indexing timestamp for the coinciding frame markers of when the flashe occurs
dTframeTime = .3332; %estim difference in film time 
frameTimeTimestampIndx=find(diff(tmp2) > dTframeTime); % indexing frame time 
dTframeNumber = .999; %estim difference in film number
frameNumberTimestampIndx=find((diff(tmp3)) > dTframeNumber); % indexing frame number

frameTimeTimestampIndx2=find(abs(diff(frameTimeTimestampIndx))> 1)
if frameTimeTimestampIndx2
    firstFrameIndx= frameTimeTimestampIndx2(1)
    frameTimeTimestampIndx(1:firstFrameIndx)=[]
end
frameNumberTimestampIndx2=find(abs(diff(frameNumberTimestampIndx))> 1)
if frameNumberTimestampIndx2
    firstFrameIndx= frameNumberTimestampIndx2(1);
    frameNumberTimestampIndx(1:firstFrameIndx)=[];
end
frameMarkerTimeStamp=frameTimeStamp(frameTimeTimestampIndx);

% take timestamp of every 30th frame in which the flash should've appeared 
frameMarkerFlashTimeStamp=frameMarkerTimeStamp(30:30:end); 
nSample=length(frameMarkerFlashTimeStamp)

% plotting to make sure that we have the correct time stamp for the frame
% markers
figure(2);clf;hold on
subplot(2,1,1);stem(frameTimeTimestampIndx,tmp2(frameTimeTimestampIndx),'r');title('media frame time timestamp');
subplot(2,1,2);stem(frameNumberTimestampIndx,tmp3(frameNumberTimestampIndx),'b');title('media frame number timestamp');

% plotting time difference between the flash event on the monitor and the
% coinciding triggers sent from obs studio
figure(3)
clf;hold on
frameMarkerFlashTimeStamp=frameMarkerFlashTimeStamp(1:nSample);
m=mean((flashStartTimeIndx-frameMarkerFlashTimeStamp));
s=std((flashStartTimeIndx-frameMarkerFlashTimeStamp));
plot(1:nSample,flashStartTimeIndx-frameMarkerFlashTimeStamp,'.k');
plot(1:nSample,m*ones(nSample,1),'r-');
plot(1:nSample,[s*ones(nSample,1) -s*ones(nSample,1) ]+m,'b--');
title('time diff between flash event and frame marker');
legend('flash event vs frame maker time difference', ['mean=' num2str(round(m,3))],['std=' num2str(round(s,3))])

if (saveFigure)
    saveas(figure(1),'DisplayMonitorFlashMarker.png');
    saveas(figure(3),'TimeDiffBetweenMediaFrameMarkerVsDisplayFlash.png');
    saveas(figure(2),'MediaPlayerFrameMarker.png');
end