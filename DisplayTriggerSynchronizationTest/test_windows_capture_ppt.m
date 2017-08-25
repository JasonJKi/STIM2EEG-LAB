clear all;
dataDir= '..\DATA\';
rootDir = '..\..\STIM2EEG-LAB\' ;
addpath([genpath('C:\Users\Jason\Documents\MATLAB\xdf\Matlab') genpath(rootDir)]);
Filename= '..\DATA\180s_flash_30hz_window_capture.xdf';
[Streams,FileHeader] = load_xdf(Filename);
saveFigure = false;

% convert lsl data for synchronization analysis 
for i =1:length(Streams)
    disp(Streams{i}.info.name);
    switch Streams{i}.info.name
        case 'BrainAmpSeries-Markers'
            tmp1=str2num(cell2mat(Streams{i}.time_series'));
            pptTimestamp = Streams{i}.time_stamps;
        case 'OBS Studio'
            n=size(Streams{i}.time_series,1);
            for ii=1:n;eval(['tmp' num2str(ii+1) '=Streams{i}.time_series(' num2str(ii) ',:)'';']);end
            lslTimestamp =Streams{i}.time_stamps;
        case 'StimulusPlayer-Markers'
            StimulusPlayerIndx=i;
            n=size(Streams{i}.time_series,1);
            for ii=1:n;eval(['tmp' num2str(ii+1) '=Streams{i}.time_series(' num2str(ii) ',:)'';']);end
            lslTimestamp =Streams{i}.time_stamps;
        case 'BrainAmpSeries (EEG)'
            eegIndx=i
        otherwise
            continue
    end
end

%% index flash events of lsl based on frame intensity value
% load video file
videoFiles=dir('*.mov');
vidObj=VideoReader(videoFiles(end).name);
video = read(vidObj);

% compute average pixel intensity for frame 
nFrames=size(video,4);
avgFrames=zeros(nFrames,1);
for i=1:nFrames
    avgFrames(i)=mean(mean(mean(video(:,:,:,i),3),2));
end

% find flash frame based on a threshold plot(avgFrames)
flashFrameIndx=find(avgFrames>(max(avgFrames)-10)); %indexing the flash 
mp4FlashIndx=zeros(length(flashFrameIndx),1);
for i=1:length(flashFrameIndx)
    mp4FlashIndx(i)=find(tmp2==flashFrameIndx(i));
end
mp4FlashIndx(1)=[];
%% get ppt flash and frame marker events
triggerIdentifier=unique(tmp1) % identify markers in the data;
figure(1);clf;hold on;
title('parallel port signal');
p1=plot(tmp1,'b','DisplayName','') % plot all events

% index frame marking events based on the trigger identifier
pptframeIndx=find(tmp1==triggerIdentifier(2)| tmp1== triggerIdentifier(4));
x=1:length(tmp1);
newIndx=x(pptframeIndx);
pptframeIndx= newIndx(diff(newIndx) > 2)-1;
p2=plot(pptframeIndx,tmp1(pptframeIndx),'r.'); 

% index flash events on the monitor based on the trigger identifier
pptflashIndx=find((diff(tmp1) > 500))+1;
p3=plot(pptflashIndx,tmp1(pptflashIndx),'g.');
legend([p2 p3],'frame marker','flash marker');


  
%get frame markers from the media source
fps=30;t=180;
flashIndex=30:fps:((fps*180));
for i=1:length(flashIndex)
   indxed{i}=find(tmp5==flashIndex(i)); 
   if min(indxed{i})
       indx(i)=min(indxed{i});
       flashtimestampmedia(i)=lslTimestamp(indx(i));
   else
       indx(i)=0;
       flashtimestampmedia(i)=nan;
   end
end


%% plotting timestamps of the flash and frame marker events
figure(2);clf
subplot(2,1,1);hold on;title('frame markers: ppt vs lsl')
nFramelsl=length(lslTimestamp);
nFrameppt=length(pptTimestamp(pptframeIndx));
s1=stem(pptTimestamp(pptframeIndx),ones(nFrameppt,1),'r');
s2=stem(lslTimestamp,ones(nFramelsl,1),'b')
legend([s1 s2],['frame marker ppt, n=' num2str(nFrameppt)],['frame marker lsl, n=' num2str(nFramelsl)]);

subplot(2,1,2);hold on;title('flash markers: ppt vs lsl')
nFlashppt=length(pptTimestamp(pptflashIndx));
nFlashFramelsl=length(lslTimestamp(mp4FlashIndx-1));
nFlashFrameppt=length(pptTimestamp(pptframeIndx(mp4FlashIndx-1)));
nFlashFrameMedia = length(flashtimestampmedia)

s1=stem(pptTimestamp(pptflashIndx),ones(nFlashppt,1),'g');
s2=stem(lslTimestamp(mp4FlashIndx-1),ones(nFlashFramelsl,1),'k')
s3=stem(pptTimestamp(pptframeIndx(mp4FlashIndx-1)),ones(nFlashFrameppt,1),'r')
s4=stem(flashtimestampmedia,ones(nFlashFrameMedia,1),'m')
legend([s1 s2 s3 s4], ...
            ['flash marker ppt, n=' num2str(nFlashppt)], ...
            ['flash frame marker lsl, n=' num2str(nFlashFramelsl)], ...
            ['flash frame marker ppt, n=' num2str(nFlashFrameppt)],...
            ['flash frame marker media lsl, n=' num2str(nFlashFrameMedia)]);
        
% std(pptTimestamp(pptflashIndx)-pptTimestamp(pptframeIndx(mp4FlashIndx-1)))
% std(pptTimestamp(pptflashIndx)-lslTimestamp(mp4FlashIndx-1))
% mean(pptTimestamp(pptflashIndx)-lslTimestamp(mp4FlashIndx-1))
nanmean(pptTimestamp(pptflashIndx)-flashtimestampmedia)
nanstd(pptTimestamp(pptflashIndx)-flashtimestampmedia)