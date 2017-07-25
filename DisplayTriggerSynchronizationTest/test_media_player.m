clear all
dataDir= '..\DATA\';
rootDir = '..\..\STIM2EEG-LAB\' 
addpath([genpath('C:\Users\Jason\Documents\MATLAB\xdf\Matlab') genpath(rootDir)])
Filename= '..\DATA\180s_flash_30hz_obs.xdf';
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
flashStartTimeIndx = flashEventTimeStamp(timeStampIndex);
flashStartTimeIndx = [flashEventTimeStamp(1) flashStartTimeIndx];
timeStampIndex=[1 timeStampIndex]
m1 = mean(diff(flashStartTimeIndx))
s1 = std(diff(flashStartTimeIndx))
figure(1);clf;
subplot(2,1,1);hold on;title('flash occurence timestamp')
plot(flashEventTimeStamp,'b');plot(timeStampIndex,flashStartTimeIndx,'r.');
legend('original time stamp','beginning of flash')
subplot(2,1,2);title('time difference between each flash');plot(diff(flashStartTimeIndx),'.');
legend(['m=' num2str(m1) ', std=' num2str(s1)])



%get frame markers
fps=30;t=180;
flashIndex=30:fps:((fps*180));
for i=1:length(flashIndex)
   indxed{i}=find(tmp3==flashIndex(i)); 
   if min(indxed{i})
       indx(i)=min(indxed{i});
   else
       indx(i)=0;
   end
end
frameMarkerFlashTimeStamp2 = frameTimeStamp(indx);
nSample=length(flashIndex);
nSample=length(flashStartTimeIndx);
frameMarkerFlashTimeStamp2 = frameMarkerFlashTimeStamp2(1:nSample)
s=std(flashStartTimeIndx-frameMarkerFlashTimeStamp2)
m=mean(flashStartTimeIndx-frameMarkerFlashTimeStamp2)
figure(2)
clf;hold on
plot(flashStartTimeIndx-frameMarkerFlashTimeStamp2,'.k')
plot(flashStartTimeIndx-frameMarkerFlashTimeStamp2,'g')

plot(1:nSample,m*ones(nSample,1),'r-');
plot(1:nSample,[s*ones(nSample,1) -s*ones(nSample,1) ]+m,'b--');
title('time diff between flash event and frame marker');
legend('flash event vs frame maker time difference', ['mean=' num2str(round(m,3))],['std=' num2str(round(s,3))])


if (saveFigure)
    saveas(figure(1),'DisplayMonitorFlashMarker.png');
    saveas(figure(2),'TimeDiffBetweenMediaFrameMarkerVsDisplayFlash.png');
    return
end
