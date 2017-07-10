# STIM2EEG-LAB Stimulus and Response Time Locking 

#### Overview
The goal of utilizing Open Broadcasting Software Studio (OBS) with Lab Streaming Layer (LSL) is to preciesely time lock each frame of the video media or any graphic displayed with neural response. More specifically, this system is put together in order to collect neural potential during sensory integrated activities such as movie viewing or game play. It has been shown that event related potentials (ERPs) can occur within 10 milli-seconds of sensory input thus it is crucial to timelock neural response with the incoming stimulus with high temporal precision. For every frame of video that is rendered from obs studio onto a display monitor, LSL “pushes a stream" (LSL method of sending single packe of data) containing corresponding frame time and frame number. Independent of the video or eeg collection software, every single packet of data pushed to the LSL stream is timestamped using the operating system's timeclock. Using these stamps, we can estimate timing of all incoming streams thus allowing temporal synchronization of various data sources.

#### About LSL
A remarkable feature LSL for data transmission is that it uses tcp/ip protocol which allows multiple sources of data to be sent abd received over the local area network. This means that data can be trasmitted in real time without boggling up any one paticular device's memory or cpu. This decentralized system allows all devices using lsl to push and pull packet(s) of LSL data from the LAN.

For acquiring data in an experiment setting, it is ideal to read and collect all streams to a single machine. This is useful for real time data visualization or performing analysis without affecting the operation of stream ouputting devices. For devices already outputting streams that require computationally intensive protocols, any other operation in the given machine can cause thread conflicts leading to jitters or worse, cause the device to crash. For storing all stream data conveniently, we use the [Lab Recorder](https://github.com/sccn/labstreaminglayer/wiki/LabRecorder.wiki)(LSL's stream recording software) in a designated "host" machine. For every recording session [Lab Recorder](https://github.com/sccn/labstreaminglayer/wiki/LabRecorder.wiki) outputs a single metadata file (.xdf) to the hard disk which contains all stream information, data, and timestamps from all input sources. .xdf file can be loaded onto MATLAB using load_xdf.m which handles synchronization of streams and removal of jitters.   

#### About OBS
OBS is an open source software written in C/C++. OBS allows real time capturing, streaming and display of all graphical and audio data rendered from any software running on the operating system or the operating system itself. The features provided by OBS is ideal for performing event related neural experimentation as it allows both displaying and capturing of audio-visual events. A particular area of interest for the STIM2EEG lab is to capture audio and visual display during game play. In this case, we want to capture graphical data that is rendered on to the screen during a racing game while simultaneously capturing neural response. OBS imports the graphical data of the gameplay by directly accessing graphical memory in real time. Every frame rendered on to the screen is timestamped based on operating system’s timeclock and encoded using x264 library with high precision. When the recording is stopped, OBS outputs .fvi or .mp4 media file which contains is synchronized to the display.

#### Implementing LSL Protocol to OBS
1. Media Displaying
There are two central processes in playing video Media, media decoding, and video rendering(texture Rendering).  
These processes run in parallel within it's own threads and there are numerous subprocesses controls the entire video display.  every frame displayed, lsl outputs a stream packet containing coinciding time and number of the current frame.

- Media Decoding
- Video Rendering

2. Screen Capturing
(to be continued)

#### Testing the Precision of Displayed Stimulus and its Corresponding LSL Trigger
In order to ensure temporal precision of the displayed stimulus and its corresponding LSL marker, we need a way of measuring the execution time difference between the physical rendering of each frame (to the display screen) and its corresponding LSL marker. To test this, we played a 3 minute mpeg4 video of 30hz which output a white flash every 30 frames using OBS video player and recorded the flash event occuring on the display monitor using a photoresistor. The photoresistor is activated on exposure to light once surpassed a set threshold (controlled by [cedrus](https://cedrus.com/stimtracker/)). Both the incoming flash event from the monitor via photoresistor and the corresponding LSL marker from OBS is captured using the [Lab Recorder](https://github.com/sccn/labstreaminglayer/wiki/LabRecorder.wiki) (LSL acquisition software). 

#### Analyzing the Temporal Precision of the Flash Event and LSL Trigger
The main objective of the analysis is to compute the difference between the timing of the flash event captured by the photoresistor and its corresponding LSL marker from  OBS. We want to know the difference between the actual stimulus event and its supposed time marker in order to ensure that neural epochs are exactly timelocked. The video stimulus played from OBS rendered a white flash to the screen every 30 frames, meaning the timing of every 30th frame markers (FM) from OBS studio should correspond to the flash event (FE) captured by the photoresistor. For a 180 second video, we obtain timestamp of 180 FE and 180 FM marking every 30th frame.In figure 1 shows the time of FE and FM. The difference between FE and FM is 19ms(for now) with standard deviation of (15ms).




