clear all
dataDir= '..\DATA\';
stimToEegCcaDir = '..\..\stim2eeg-cca\' 
addpath([genpath('../liblsl-Matlab/') genpath(stimToEegCcaDir)])
Filename= '..\DATA\180s_flash_30hz.xdf';
[Streams,FileHeader] = load_xdf(Filename)

for i =1:length(Streams)
    disp(Streams{i}.info.name);
     subplot(1,length(Streams),i);plot(Streams{i}.time_stamps-min(Streams{i}.time_stamps))
    title(Streams{i}.info.name)
end

flashStreamInd=1
StimulusPlayerInd=2
tmp1=str2num(cell2mat(Streams{flashStreamInd}.time_series'));
timeStamp1 = Streams{flashStreamInd}.time_stamps;

dTimeStamp1 = diff(timeStamp1); %plot(dTimeStamp1)
timeStampIndex = find(dTimeStamp1>.9)+1;
dTimeStampMean = mean(dTimeStamp1(timeStampIndex));
dTimeStampStd = std(dTimeStamp1(timeStampIndex));
flashStartTimeIndx1 = timeStamp1(timeStampIndex+1);
m1 = mean(diff(flashStartTimeIndx1))
s1 = std(diff(flashStartTimeIndx1))

tmp2=Streams{StimulusPlayerInd}.time_series(1,:)';
tmp3=Streams{StimulusPlayerInd}.time_series(2,:)';
t0=min(find(tmp3==-100))
tf=min(find(tmp3 == max(tmp3)))
frameNum=tmp3(t0:tf)
frameNum(1)=0;
frameNum(2)=1;

stem(find(diff(frameNum)==1))
correctFrameIndx= find(diff(frameNum)==1)+1
corrFlashedIndx = find(mod(correctFrameIndx,30)==0)
timeStamp2 = Streams{StimulusPlayerInd}.time_stamps;
frameTimeTriggerTimeStamp = timeStamp2(corrFlashedIndx);
frameTimeTriggerTimeStamp=frameTimeTriggerTimeStamp(3:end)
plot(timeStamp2)

clf;hold on
plot(flashStartTimeIndx1,'.b')
plot(frameTimeTriggerTimeStamp,'.r')
mean((flashStartTimeIndx1-frameTimeTriggerTimeStamp))
std((flashStartTimeIndx1-frameTimeTriggerTimeStamp))
plot((flashStartTimeIndx1-frameTimeTriggerTimeStamp))





dTimeStampIndx2 = find(abs(diff(tmp2))>.03)+1;
clf;hold on
stem(dTimeStampIndx2,tmp2(dTimeStampIndx2),'r');
plot(tmp2,'b')
triggerIndx = dTimeStampIndx2(1:end);
%triggerIndx = [1  ;dTimeStampIndx2(2:end)];
frameTimeTriggerValue = tmp2(triggerIndx);%plot(frameTimeTriggerValue)
frameTimeTriggerTimeStamp = timeStamp2(triggerIndx);
std(diff(frameTimeTriggerTimeStamp))
mean(diff(frameTimeTriggerTimeStamp))

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