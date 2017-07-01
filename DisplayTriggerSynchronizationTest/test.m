clear all
dataDir= '..\DATA\';
stimToEegCcaDir = '..\..\stim2eeg-cca\' 
addpath([genpath('../liblsl-Matlab/') genpath(stimToEegCcaDir)])
Filename= '..\DATA\180s_flash_30hz_old30.xdf';
[Streams,FileHeader] = load_xdf(Filename)

for i =1:length(Streams)
    disp(Streams{i}.info.name);
     subplot(1,length(Streams),i);plot(Streams{i}.time_stamps-min(Streams{i}.time_stamps))
    title(Streams{i}.info.name)
end

flashStreamInd=1
StimulusPlayerInd=2
for i = 1:length(Streams{flashStreamInd}.time_series)
tmp1(i)=str2double(cell2mat(Streams{flashStreamInd}.time_series(i)));
end
tmp1=str2num(cell2mat(Streams{flashStreamInd}.time_series'));

timeStamp1 = Streams{flashStreamInd}.time_stamps;
tmp2=Streams{StimulusPlayerInd}.time_series(1,:)';
tmp3=Streams{StimulusPlayerInd}.time_series(2,:)';

timeStamp2 = Streams{StimulusPlayerInd}.time_stamps;
dTimeStamp1 = diff(timeStamp1); %plot(dTimeStamp1)
timeStampIndex = find(dTimeStamp1>.9)+1;plot(dTimeStamp1)
dTimeStampMean = mean(dTimeStamp1(timeStampIndex));
dTimeStampStd = std(dTimeStamp1(timeStampIndex));
flashStartTimeIndx1 = timeStamp1(timeStampIndex+1);
m1 = mean(diff(flashStartTimeIndx1))
s1 = std(diff(flashStartTimeIndx1))

dTimeStampIndx2 = find((diff(tmp2) > median(diff(tmp2))-1 & diff(tmp2) < median(diff(tmp2))+1) | abs(max(diff(tmp2))))+1;
dTimeStampIndx3 = find((diff(tmp3)) > .1);

clf;hold on
dTimeStampIndx2=dTimeStampIndx2(7:end);
stem(dTimeStampIndx2,tmp2(dTimeStampIndx2),'r');
frameTimeTriggerTimeStamp=timeStamp2(dTimeStampIndx2)
frameNumber = tmp3(dTimeStampIndx3)
stem(dTimeStampIndx3,frameNumber,'k');
frameTimeTriggerTimeStamp=timeStamp2(dTimeStampIndx3)

%frameTimeTriggerTimeStamp=frameTimeTriggerTimeStamp__(:);
%std(diff(frameTimeTriggerTimeStamp))
%mean(diff(frameTimeTriggerTimeStamp))

clf;hold on
frameTimeTriggerTimeStamp_=frameTimeTriggerTimeStamp(60:30:end);
plot(flashStartTimeIndx1,'.b')
plot(frameTimeTriggerTimeStamp_,'.r')
mean((flashStartTimeIndx1-frameTimeTriggerTimeStamp_))
std((flashStartTimeIndx1-frameTimeTriggerTimeStamp_))
plot((flashStartTimeIndx1-frameTimeTriggerTimeStamp_))

%%
% for i=1:96
%     plot(Streams{2}.time_series(i,:)')
%         title(i)
%     pause
%     drawnow
% end
flashStreamInd=1
StimulusPlayerInd=2
tmp1=str2num(cell2mat(Streams{flashStreamInd}.time_series'));
timeStamp1 = Streams{flashStreamInd}.time_stamps;
tmp2=Streams{StimulusPlayerInd}.time_series';
whos(diff(timeStamp1))
plot(diff(timeStamp1))
plot(tmp2)

plot(diff(tmp2)/(10e7))
if tmp2(1) == 0 
    tmp2(1:2:end) = tmp2(1:2:end) +1;
end
timeStamp2 = Streams{StimulusPlayerInd}.time_stamps;
t0VideoPlayerTrigger = timeStamp2(1);
tfVideoPlayerTrigger = timeStamp2(end)
t0=find(timeStamp1<t0VideoPlayerTrigger);
tf=find(timeStamp1>tfVideoPlayerTrigger);

startIndex = t0(end)-75
endIndex = tf(1)+75
startTime = timeStamp1(startIndex)
startTime1 = timeStamp2(1)

endTime = timeStamp1(endIndex)
endTime1 = timeStamp2(end)

triggerID =unique(estimatedDuration);
estimatedDuration = tmp1(startIndex:endIndex);
diffTriggers = diff(estimatedDuration)>1
flashIndex = find(diffTriggers==1)+1

flashTime0 = timeStamp1(startIndex:endIndex);
flashTime = flashTime0(flashIndex-10)
flashTrigger = estimatedDuration(flashIndex)

clf
stem(timeStamp1,(tmp1-4352)/(5376-4352));hold on;
stem(timeStamp2,tmp2/3,'r')
% lslTime = timeStamp2(63:60:end)
lslTime = timeStamp2(find(tmp2 == 3))
timeDifference = mean(flashTime - lslTime)
stdTimeDiff = std(flashTime - lslTime)
 subplot 211
% axis tight
stem(tmp1(startIndex:endIndex))
 subplot 212
% axis tight
 stem(tmp2')
% 
% plot(diff(find(strcmp(Streams{1}.time_series,'5376')))')
% 
% Streams{2}.info.sample_count


startIndx=find(tmp2(dTimeStampIndx2)==0)
endIndx=find(tmp2(dTimeStampIndx2)==max(tmp2(dTimeStampIndx2)))
indx =dTimeStampIndx2(startIndx(1):endIndx(end))
stem(startIndx,tmp2(startIndx),'g')
stem(endIndx,tmp2(endIndx),'k')

plot(tmp2,'b')

for i=1:length(endIndx)
    indx=dTimeStampIndx2(startIndx(i):endIndx(i))
    tmp2_(:,i)=tmp2(indx);
    frameTimeTriggerTimeStamp__(:,i)=timeStamp2(indx)
end
frameTimeTriggerTimeStamp=timeStamp2(dTimeStampIndx2);

