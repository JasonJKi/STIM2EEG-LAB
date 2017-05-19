clear all
dataDir= '..\DATA\';
stimToEegCcaDir = '..\..\stim2eeg-cca\' 
addpath([genpath('../liblsl-Matlab/') genpath(stimToEegCcaDir)])
fileInfo = dir('../DATA/*jacek*.xdf')

% Stream Names
% 'BrainAmpSeries-Markers'
% 'StimulusPlayer-Markers'
% 'BrainAmpSeries'

eeg = cell(4,1)
nSubj= size(eeg,1)
EEGChannels =[1:96];
nChannels = size(EEGChannels);
D=nChannels;
EOGChannels =[];
refElectrode=0;
filterCoeff=[];
fsDesired=0;
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
    eegStream = eegStream - repmat(mean(eegStream),size(eegStream,1),1);
    timeStampEeg = Streams{eegStreamInd}.time_stamps;
    
    format long
    triggerIndex = find(trigger==2);
    triggerTime = timeStampTrigger(triggerIndex);
    
    t0Trigger = triggerTime(1);
    tfTrigger = triggerTime(end);
    
    t0EEGIndex = max(find(t0Trigger>timeStampEeg));
    t0EEG= timeStampEeg(t0EEGIndex);
    tfEEGIndex = max(find(tfTrigger>timeStampEeg));
    tfEEG=timeStampEeg(tfEEGIndex);
    
    durationEEGClock(iFile) =tfEEG-t0EEG
    durationTriggerClock(iFile) = tfTrigger-t0Trigger;
    
    timeDifferenceEEGvsTriggerClock(iFile) = durationEEGClock(iFile) - durationTriggerClock(iFile);
    
    eeg{iFile} = eegStream(t0EEGIndex:tfEEGIndex,:);
    
    nSamples(iFile)= size(eeg{iFile},1);
    fs(iFile)=round(nSamples(iFile)/durationTriggerClock(iFile));
    
    eegPreprocessed{iFile} = preprocessEEG(resample(double(eeg{iFile}),1,25),fs(iFile)/25,EEGChannels,EOGChannels,refElectrode,7);
   
end


eegBYD1=eegPreprocessed{1};
eegBYD2=eegPreprocessed{3};
eegDDA1=eegPreprocessed{2};
eegDDA2=eegPreprocessed{4};

[dataOut,W,A1,Rxx,Ryy,Rxy,dGen,h] = rcaRun(cat(3,eegBYD1,eegBYD2),6,5);
[dataOut,W,A2,Rxx,Ryy,Rxy,dGen,h] = rcaRun(cat(3,eegDDA1,eegDDA2),6,5);

figure(1)
clf
suptitle('BYD')
for i=1:5;
    subplot(1,5,i)
    title(['C' num2str(i)])
    topoplot_jk(A1(:,i), 'JBhead96_sym.loc','electrodes','off','numcontour',0);
    caxis
    colorbar
    colormap jet

end
saveas(figure(1),'BYD_Components.jpg')
figure(2)
clf
suptitle('DDA')
for i=1:5;
    subplot(1,5,i)
    title(['C' num2str(i)])
    topoplot_jk(A2(:,i), 'JBhead96_sym.loc','electrodes','off','numcontour',0);
    caxis
    colorbar
    colormap jet
end
saveas(figure(2),'DDA_Components.jpg')

[dataOut,W,A3,Rxx,Ryy,Rxy,dGen,h] = rcaRun(...
    {cat(3,eegBYD1,eegBYD2),cat(3,eegDDA1,eegDDA2)},6,5);

figure(3)
clf
suptitle('BYD-DDA combined')
for i=1:5;
    subplot(1,5,i)
    title(['C' num2str(i)])
    topoplot_jk(A3(:,i), 'JBhead96_sym.loc','electrodes','off','numcontour',0);
    caxis
    colormap jet
    colorbar
end
saveas(figure(3),'BYD-DDA_Components.jpg')



allEeg = {eegBYD1,eegBYD2,eegDDA1,eegDDA2};


% memory-efficient computation of the  pooled covariance matrix,
% avoiding concatenation of all pairs of datasets
Rpool = zeros();
for ii = 1:2
    Rpool = Rpool + cov(allEeg{ii});
end
Rpool = Rpool ./ 2;

% memory-efficient computation of the cross-covariance matrix,
% avoiding concatenation of all pairs of datasets
Rxy = zeros(D);
permList = [1 1;2 2]
nPerms=size(permList,2);
for i = 1:nPerms
    Rxy_ = cov([allEeg{permList(1,i)},allEeg{permList(2,i)}]);
    Rxy = Rxy + Rxy_(1:D,D+1:2*D);
end
Rxy = Rxy + Rxy';
Rxy = Rxy ./ (nPerms);

gamma = 0
%% regularization
if gamma
    % shrinkage
    Rpool = (1-gamma)*Rpool + gamma*mean(eig(Rpool))*eye(D);
    [W,L] = eig(Rxy, Rpool);   [d,indx]=sort(diag(L),'descend'); W = W(:,indx);
else
    % regularization of pooled covariance
    K = 10; % how many PCs to keep
    [V,L] = eig(Rpool); [d,indx]=sort(diag(L),'descend'); V = V(:,indx);
    Rxy=V(:,1:K)*diag(1./d(1:K))*V(:,1:K)'*Rxy;
    [W,L] = eig(Rxy);   [d,indx]=sort(diag(L),'descend'); W = W(:,indx);
end
W = W(:,1:nComp);

A=Rpool*W*inv(W'*Rpool*W);

figure(3)
for i=1:5;
    subplot(1,5,i)
    topoplot_jk(A(:,i), 'JBhead96_sym.loc','electrodes','off','numcontour',0);
    caxis([-1 1])
end
allEeg = {eegBYD1,eegBYD2,eegDDA1,eegDDA2};
[dataOut,W,A,Rxx,Ryy,Rxy,dGen,h] = rcaRun(allEeg,10,5)

[U V H W r p]=S2E(X,Y,regParam,XTest,YTest)
