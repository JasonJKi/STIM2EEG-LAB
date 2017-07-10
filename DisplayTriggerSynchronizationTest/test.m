clear all
dataDir= '..\DATA\';
stimToEegCcaDir = '..\..\stim2eeg-cca\' 
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

dTimeStamp1 = diff(timeStamp1); %plot(dTimeStamp1)
timeStampIndex = find(dTimeStamp1>.9)+1;plot(dTimeStamp1)
flashStartTimeIndx1 = [timeStamp1(1) timeStamp1(timeStampIndex)];
m1 = mean(diff(flashStartTimeIndx1))
s1 = std(diff(flashStartTimeIndx1))

%dTimeStampIndx2 = find((diff(tmp2) > median(diff(tmp2))-1 & diff(tmp2) < median(diff(tmp2))+1) | abs(max(diff(tmp2))))+1;
dTimeStampIndx2=find(diff(tmp2) > .3)
dTimeStampIndx3 = find((diff(tmp3)) > .1);
clf;hold on
stem(dTimeStampIndx2,tmp2(dTimeStampIndx2),'r');
stem(dTimeStampIndx2,tmp3(dTimeStampIndx2),'r');
frameMarkerTimeStamp=timeStamp2(dTimeStampIndx2)

clf;hold on
frameMarkerFlashTimeStamp=frameMarkerTimeStamp(30:30:end);
mean((flashStartTimeIndx1-frameMarkerFlashTimeStamp))
std((flashStartTimeIndx1-frameMarkerFlashTimeStamp))
clf;hold on
plot(flashStartTimeIndx1,'.b')
plot(frameMarkerFlashTimeStamp,'.r')

