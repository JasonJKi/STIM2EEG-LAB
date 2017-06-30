# STIM2EEG-LAB Stimulus and Response Time Locking 

#### Overview
The goal of utilizing Open Broadcasting Software Studio (OBS) with lab streaming layer (LSL) is to time lock each frame of the video media or any graphic displayed onto a screen with neural response and any event related data which can be as simple as a button event or more complex like the eye tracker, and etc. This is done specifically to collect data examining evoked potential during sensory integrated activities such as movie viewing or game play. Event related potentials can occur within 10 milli-seconds of sensory input thus it is crucial to be able to timelock neural response with the incoming stimulus  with fine precision. Upon rendering of each frame from obs studio to the screen, LSL “pushes a stream" (an expression used by LSL to describe sending single packe of data) containing frame time and corresponding frame number. For each packet of data pushed to the stream, it is timestamped based on the individual operating system's timeclock. These stamps are later renferenced to temporally align all incoming streams (i.e. eeg and video frames).

#### About LSL
A remarkable advantage of using LSL is that it uses tcp/ip protocol standards allowing multiple streams to be transmitted and read over the local area network. This means that data can be trasmitted in real time without boggling up any one paticular device's memory or cpu. All devices connected over the LAN can receive and transmit data using the LSL. This decentralized system allows for any system to push and pull packet(s) of data from the LAN.

For acquiring data in an experiment setting, it is ideal to centralize all streams so that it can be useful for real time data visualization or be stored/accessed for analysis without affecting the operation of stream ouputting devices. To do this, we use the Lab Recorder (LSL's stream recording software) in a designated machine to capture all streams. For every recording session Lab Recorder outputs a single metadata file (.xdf) to the hard disk which contains all stream information, data, and timestamps from all input sources. 

#### About OBS
OBS is an open source software written in C/C++. OBS allows real time capturing, streaming and display of all graphical and audio data that is rendered from any software running on the operating system. The features provided by OBS is ideal for performing event related neural experimentation as it allows both displaying and capturing of audio-visual events. A particular area of interest for the STIM2EEG lab is to capture audio and visual display during game play. In this case, we want to capture graphical data that is rendered on to the screen during a racing game while simultaneously capturing neural response. OBS imports the graphical data of the gameplay by directly accessing graphical memory in real time. Every frame rendered on to the screen is timestamped based on operating system’s timeclock and encoded using x264 library with high precision. When the recording is stopped, OBS outputs .fvi or .mp4 media file which contains is synchronized to the display.

#### Implementing LSL Protocol to OBS
1. Media Displaying
There are 3 key components that are crucial for displaying Media. Decoding, Media Controller, Graphical Rendering.  parts to OBS contains 3 parts when 

2. Screen Capturing
#### Frame Display and LSL Trigger Synchronization Experiment
In order to analyze time synchronization accuracy of obs studio and eeg, we load the .xdf file onto MATLAB using load_xdf.m which handles synchronization of streams and removal of jitters.   

#### Frame Display and LSL Trigger Synchronization Analysis

 
