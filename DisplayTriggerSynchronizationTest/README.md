# STIM2EEG-LAB Stimulus and Response Time Locking 

#### Overview
The goal of utilizing Open Broadcasting Software Studio (OBS) with lab streaming layer (LSL) is to time lock each frame of the video media or any graphic displayed onto a screen with neural response and other related data such as eye tracker. This is done specifically to collect data examining evoked potential during sensory integrated activities such as movie viewing or etc. Event related potentials can occur within 10 milli-seconds of an event thus it is crucial to timelock eeg with the display of stimulus with fine temporal precision. Upon rendering of individual frame to the screen from obs studio, LSL “pushes” (an expression used by LSL to describe sending single data set) a stream containing frame time and number to the Lab Recorder (LSL’s data acquisition software). LSL uses tcp/ip protocol standards written . Each pushed stream is timestamped using the operating system's clock. The timestamps are used to temporally align various incoming streams (i.e. eeg). The stream(s) captured via Lab Recorder is stored in a single metadata file (.xdf) which stores stream information, data, and timestamps of all designated input streams. 

#### Implementing LSL Protocol to OBS
OBS is an open source software written in C/C++. OBS allows real time capturing, streaming and display of all graphical and audio data that is rendered from any software running on the operating system. The features provided by OBS is ideal for performing event related neural experimentation as it allows both displaying and capturing of audio-visual events. A particular area of interest for the STIM2EEG lab is to capture audio and visual information during game play. In this case, we want to capture graphical data that is rendered on to the screen during a racing gameplay while simultaneously capturing neural response. OBS imports the graphical display from the game by directly accessing graphical memory of the computer. Every frame rendered on to the screen is timestamped based on operating system’s timeclock and encoded using x264 library in real time. When the recording is stopped by the user, OBS outputs an .fvi or .mp4 media file. The ability to precisely capture the stimulus is crucial when analyzing event related response  

#### Frame Display and LSL Trigger Synchronization Experiment
In order to analyze time synchronization accuracy of obs studio and eeg, we load the .xdf file onto MATLAB using load_xdf.m which handles synchronization of streams and removal of jitters.   

#### Frame Display and LSL Trigger Synchronization Analysis

 
