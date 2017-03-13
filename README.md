## About STIM2EEGLAB
#### by Jason Ki

##### Stimulus Player (Newton) – 

### 1)	START MATLAB
a.	Right Click MATLAB ICON on the Desktop -> go to properties  -> 
b.	Edit line under Target: [“C:\Program Files\MATLAB\R2016b\bin\matlab.exe”]
to 
```
“C:\Program Files\MATLAB\R2016b\bin\matlab.exe” -R “-nojvm”
```
and Press OK to close properties menu
(this will disable JAVA virtual machine which conflicts with Psychtoolbox for 64 bit MATLAB)
c.	START MATLAB (this will start MATLAB cmd window)
### 2)	Switch TO STIM2EEGLAB directory
-	In the cmd window cd into the StimulusPlayer script by typing the following command.
```
cd(‘C:\Users\Jason\STIM2EEGLAB\StimulusPlayer’)
```

### 3)	Start VideoPlayer 
-	Start your stimulus by typing in VideoPlayer(“stimPath\StimName”) in the command line.
-	Example:
```
VideoPlayer(‘C:\Users\Jason\STIM2EEGLAB\Stimulus\ManOfSteel.mp4’)
```
-	Once this command is typed in it will ask you to activate the lab streaming layer (lsl) in the recording machine.
### 4)	Now go to setup the EEG Recorder by following directions under EEG Recording (EEG).

### 5)	When all steps under EEG Recording (EEG) is complete press enter to start your stimulus video.

### 6)	Psychtoolbox will close automatically when it’s finished.

### 7)	Go to the EEG Recording Machine to stop Recording if you have finished the experiment.

##### EEG Recording (EEG) –

### 0)	open folder C:\Users\SKlab\Desktop\STIM2EEGLAB

### 1)	START Brain Amp Series to activate lab streaming layer interface with the brain product eeg system. 
a.	 open folder C:\Users\SKlab\Desktop\STIM2EEGLAB\BrainAmpSeries
b.	 double click to start BrainAmpSeries.exe
c.	leave the default setting and click link button to activate the lab streaming layer for the eeg (If the usb cable to eeg is not connected to the EEG machine then it’ll throw error).

### 2)	START LAB Recorder
This is where all STIM2EEGLAB software for recording lab streaming layer and start 
a.	open folder C:\Users\SKlab\Desktop\STIM2EEGLAB\LabRecorder
b.	double click to start LabRecorder.exe
c.	Click update in the bottom right corner
o	Under the Record from Streams, list with following streams should appear (order is varied). Click on the box for the following streams.
BrainAmpSeries (EEG)
BrainAmpSeries-Markers (EEG)
StimulusPlayer-Markers (Newton)
d.	Set xdf save location. xdf is the file in which all lab streaming layers are saved under
e.	Press Start button on the top right to begin recording.
### 3)	Go to Stimulus Player (Newton) step 7.

