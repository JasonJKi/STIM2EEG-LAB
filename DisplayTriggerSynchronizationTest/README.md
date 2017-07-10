# STIM2EEG-LAB Stimulus and Response Time Locking 

#### Overview
The goal of utilizing Open Broadcasting Software Studio (OBS) with Lab Streaming Layer (LSL) is to preciesely time lock each frame of the video media or any graphic displayed with neural response. More specifically, this system is put together in order to collect neural potential during sensory integrated activities such as movie viewing or game play. It has been shown that event related potentials (ERPs) can occur within 10 milli-seconds of sensory input thus it is crucial to timelock neural response with the incoming stimulus with high temporal precision. For every frame of video that is rendered from obs studio onto a display monitor, LSL “pushes a stream" (LSL method of sending single packe of data) containing corresponding frame time and frame number. Independent of the video or eeg collection software, every single packet of data pushed to the LSL stream is timestamped using the operating system's timeclock. Using these stamps, we can estimate timing of all incoming streams thus allowing temporal synchronization of various data sources.

#### About LSL
A remarkable feature LSL for data transmission is that it uses tcp/ip protocol which allows multiple sources of data to be sent abd received over the local area network. This means that data can be trasmitted in real time without boggling up any one paticular device's memory or cpu. This decentralized system allows all devices using lsl to push and pull packet(s) of LSL data from the LAN.

For acquiring data in an experiment setting, it is ideal to read and collect all streams to a single machine. This is useful for real time data visualization or performing analysis without affecting the operation of stream ouputting devices. For devices already outputting streams that require computationally intensive protocols, any other operation in the given machine can cause thread conflicts leading to jitters or worse, cause the device to crash. For storing all stream data conveniently, we use the Lab Recorder (LSL's stream recording software) in a designated "host" machine. For every recording session Lab Recorder outputs a single metadata file (.xdf) to the hard disk which contains all stream information, data, and timestamps from all input sources. .xdf file can be loaded onto MATLAB using load_xdf.m which handles synchronization of streams and removal of jitters.   

#### About OBS
OBS is an open source software written in C/C++. OBS allows real time capturing, streaming and display of all graphical and audio data rendered from any software running on the operating system or the operating system itself. The features provided by OBS is ideal for performing event related neural experimentation as it allows both displaying and capturing of audio-visual events. A particular area of interest for the STIM2EEG lab is to capture audio and visual display during game play. In this case, we want to capture graphical data that is rendered on to the screen during a racing game while simultaneously capturing neural response. OBS imports the graphical data of the gameplay by directly accessing graphical memory in real time. Every frame rendered on to the screen is timestamped based on operating system’s timeclock and encoded using x264 library with high precision. When the recording is stopped, OBS outputs .fvi or .mp4 media file which contains is synchronized to the display.

#### Implementing LSL Protocol to OBS
1. Media Displaying
There are 4 key components in for displaying Media onto the screen. Media Decoding, Video Rendering, Texture Rendering and Drawing.  
These processes run in parallel within it's own threads. The execution of these functions is looped controlled based on the media frame rate. LSL stream is placed in the execution sequence just before when 2d sprite of the frame is drawn to the monitor. For every frame displayed, lsl outputs a stream packet containing coinciding time and number of the current frame.

2. Screen Capturing
(to be continued)

#### Frame Display and LSL Trigger Synchronization Experiment
In order to analyze time accuracy of OBS display and it's coinciding trigger output via LSL, we compare the screen display using a photoresitor. Here, we attached a photoresistor to a display monitor which captures flash displayed. The photoresistor is connected to cedrus (StimTracker), a marker interface for ActiChamp from Brain Vision EEG system. The incoming signal from the photoresitor is output to the network using LSL. The photoresitor generated a marker after every stimulus frame flip coinciding with a wh. Additionally, each time the screen changes from black to white (or vice versa), instead of the 'flip' marker, EngineEvents generates 'black' or 'white'. This allows us to confirm our ability to synchronize the stimulus light transitions to the EEG and video data using the LSL markers as reference. VideoStream.exe generates a marker for every video frame acquired, which we use to synchronize the recorded movie.

#### Frame Display and LSL Trigger Synchronization Analysis

 In order to analyze time synchronization accuracy of obs studio and eeg, we 
