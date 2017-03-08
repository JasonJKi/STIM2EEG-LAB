Filename= '..\DATA\60s_flash_30hz_1.xdf';
[Streams,FileHeader] = load_xdf(Filename)

for i =1:length(Streams)
    disp(Streams{i}.info.name);
%     subplot(1,length(Streams),i);plot(Streams{i}.time_stamps-min(Streams{i}.time_stamps))
    title(Streams{i}.info.name)
end

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