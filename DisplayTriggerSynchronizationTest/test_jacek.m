clear all
dataDir= '..\DATA\';

fileInfo = dir('../DATA/*jacek*.xdf')

% Stream Names
% 'BrainAmpSeries-Markers'
% 'StimulusPlayer-Markers'
% 'BrainAmpSeries'

eeg = cell(3,1)
for iFile = 1:length(fileInfo)
    [Streams,FileHeader] = load_xdf([dataDir fileInfo(iFile).name])
    
    for i =1:length(Streams)
        disp(Streams{i}.info.name);
        %     subplot(1,length(Streams),i);plot(Streams{i}.time_stamps-min(Streams{i}.time_stamps))
        title(Streams{i}.info.name)
        streamNames{i} = Streams{i}.info.name;
    end
    
    stimulusMarkerInd = strmatch('StimulusPlayer-Markers',streamNames)
    eegStreamInd = strmatch('BrainAmpSeries',streamNames,'exact')
    
    trigger=Streams{stimulusMarkerInd}.time_series';
    timeStampTrigger = Streams{stimulusMarkerInd}.time_stamps;
    eegStream=Streams{eegStreamInd}.time_series';
    timeStampEeg = Streams{eegStreamInd}.time_stamps;
    
    format long
    triggerIndex = find(trigger==2)
    triggerTime = timeStampTrigger(triggerIndex)
    
    t0Trigger = triggerTime(1)
    tfTrigger = triggerTime(end)
    
    t0EEGIndex = max(find(t0Trigger>timeStampEeg));
    t0EEG= timeStampEeg(t0EEGIndex);
    tfEEGIndex = max(find(tfTrigger>timeStampEeg));
    tfEEG=timeStampEeg(tfEEGIndex);
    
    durationEEGClock(iFile) =tfEEG-t0EEG
    durationTriggerClock(iFile) = tfTrigger-t0Trigger;
    
    timeDifferenceEEGvsTriggerClock(iFile) = durationEEGClock(iFile) - durationTriggerClock(iFile);
    
    eeg{iFile} = eegStream(t0EEGIndex:tfEEGIndex,:);
end
